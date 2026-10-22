const test = require('node:test')
const assert = require('node:assert/strict')

const {
    isBlockedAddress,
    parseAllowedDomains,
    validateWebhookUrl,
    assertResolvesToPublicAddress,
    validateWebhookUrlForSend,
    validateLogoUrl,
    createSafeLookup,
} = require('./url-validation')

test('accepts a public https URL', () => {
    const result = validateWebhookUrl('https://hooks.example.com/frankly?x=1')
    assert.equal(result.ok, true)
    assert.equal(result.hostname, 'hooks.example.com')
})

test('requires https', () => {
    assert.equal(validateWebhookUrl('http://hooks.example.com').ok, false)
    assert.equal(validateWebhookUrl('ftp://hooks.example.com').ok, false)
    assert.equal(validateWebhookUrl('not a url').ok, false)
    assert.equal(validateWebhookUrl('').ok, false)
    assert.equal(validateWebhookUrl(undefined).ok, false)
})

test('rejects credentials in the URL', () => {
    assert.equal(validateWebhookUrl('https://user:pass@hooks.example.com').ok, false)
})

test('rejects internal host names', () => {
    for (const url of [
        'https://localhost/hook',
        'https://foo.localhost/hook',
        'https://metadata.google.internal/computeMetadata/v1/',
        'https://service.internal/hook',
        'https://printer.local/hook',
        'https://intranet/hook',
    ]) {
        assert.equal(validateWebhookUrl(url).ok, false, url)
    }
})

test('rejects private, loopback, link-local and metadata IP literals', () => {
    for (const url of [
        'https://127.0.0.1/hook',
        'https://10.1.2.3/hook',
        'https://172.16.0.1/hook',
        'https://172.31.255.255/hook',
        'https://192.168.1.1/hook',
        'https://169.254.169.254/latest/meta-data',
        'https://100.64.0.1/hook',
        'https://0.0.0.0/hook',
        'https://[::1]/hook',
        'https://[fe80::1]/hook',
        'https://[fd12:3456::1]/hook',
        'https://[::ffff:10.0.0.1]/hook',
        'https://[::ffff:169.254.169.254]/hook',
    ]) {
        assert.equal(validateWebhookUrl(url).ok, false, url)
    }
})

test('accepts public IP literals', () => {
    assert.equal(validateWebhookUrl('https://8.8.8.8/hook').ok, true)
    assert.equal(validateWebhookUrl('https://172.32.0.1/hook').ok, true)
    assert.equal(validateWebhookUrl('https://[2606:4700:4700::1111]/hook').ok, true)
})

test('isBlockedAddress covers IPv4 and IPv6 ranges', () => {
    assert.equal(isBlockedAddress('127.0.0.1'), true)
    assert.equal(isBlockedAddress('169.254.1.1'), true)
    assert.equal(isBlockedAddress('::'), true)
    assert.equal(isBlockedAddress('::ffff:192.168.0.1'), true)
    assert.equal(isBlockedAddress('64:ff9b::a00:1'), true) // NAT64 of 10.0.0.1
    assert.equal(isBlockedAddress('1.1.1.1'), false)
    assert.equal(isBlockedAddress('2001:4860:4860::8888'), false)
    assert.equal(isBlockedAddress('not-an-ip'), true)
})

test('domain allowlist: empty allows any public host', () => {
    assert.deepEqual(parseAllowedDomains(''), [])
    assert.equal(validateWebhookUrl('https://a.example.org', { allowedDomains: [] }).ok, true)
})

test('domain allowlist: exact and subdomain matches only', () => {
    const allowedDomains = parseAllowedDomains('partner.example, *.other.test')
    assert.deepEqual(allowedDomains, ['partner.example', 'other.test'])
    assert.equal(validateWebhookUrl('https://partner.example/h', { allowedDomains }).ok, true)
    assert.equal(validateWebhookUrl('https://api.partner.example/h', { allowedDomains }).ok, true)
    assert.equal(validateWebhookUrl('https://x.other.test/h', { allowedDomains }).ok, true)
    assert.equal(validateWebhookUrl('https://evilpartner.example/h', { allowedDomains }).ok, false)
    assert.equal(
        validateWebhookUrl('https://partner.example.evil.com/h', { allowedDomains }).ok,
        false
    )
})

test('DNS check rejects names resolving to internal addresses (not retryable)', async () => {
    const lookup = async () => [{ address: '93.184.216.34' }, { address: '10.0.0.5' }]
    await assert.rejects(
        assertResolvesToPublicAddress('rebind.example.com', { lookup }),
        (err) => err.retryable === false
    )
})

test('DNS check treats resolution failures as retryable', async () => {
    const lookup = async () => {
        throw new Error('ENOTFOUND')
    }
    await assert.rejects(
        assertResolvesToPublicAddress('down.example.com', { lookup }),
        (err) => err.retryable === true
    )
})

test('validateWebhookUrlForSend combines static and DNS checks', async () => {
    const lookup = async () => [{ address: '93.184.216.34' }]
    assert.equal(
        await validateWebhookUrlForSend('https://hooks.example.com/x', { lookup }),
        'https://hooks.example.com/x'
    )
    await assert.rejects(
        validateWebhookUrlForSend('http://hooks.example.com/x', { lookup }),
        (err) => err.retryable === false
    )
    await assert.rejects(
        validateWebhookUrlForSend('https://hooks.example.com/x', {
            lookup,
            allowedDomains: ['partner.example'],
        }),
        /allowed domain/
    )
})

function fakeResolver(addresses) {
    const calls = []
    const resolve = (hostname, options, callback) => {
        calls.push({ hostname, options })
        setImmediate(() => callback(null, addresses))
    }
    return { resolve, calls }
}

const lookupWith = (safeLookup, hostname, options) =>
    new Promise((resolve) => {
        safeLookup(hostname, options, (err, address, family) => resolve({ err, address, family }))
    })

test('safeLookup refuses private and metadata addresses at connect time', async () => {
    for (const address of ['10.0.0.1', '169.254.169.254', '::1']) {
        const { resolve } = fakeResolver([{ address, family: address.includes(':') ? 6 : 4 }])
        const safeLookup = createSafeLookup(resolve)
        for (const options of [{ all: true }, {}]) {
            const { err, address: result } = await lookupWith(
                safeLookup,
                'rebind.example.com',
                options
            )
            assert.ok(err, `${address} ${JSON.stringify(options)}`)
            assert.equal(err.retryable, false)
            assert.match(err.message, /private or internal/)
            assert.equal(result, undefined)
        }
    }
})

test('safeLookup refuses when any of several addresses is blocked', async () => {
    const { resolve } = fakeResolver([
        { address: '93.184.216.34', family: 4 },
        { address: '10.0.0.1', family: 4 },
    ])
    const { err } = await lookupWith(createSafeLookup(resolve), 'mixed.example.com', {})
    assert.equal(err.retryable, false)
})

test('safeLookup passes public addresses through in both callback forms', async () => {
    const addresses = [
        { address: '93.184.216.34', family: 4 },
        { address: '2606:2800:220:1:248:1893:25c8:1946', family: 6 },
    ]
    const { resolve, calls } = fakeResolver(addresses)
    const safeLookup = createSafeLookup(resolve)

    const all = await lookupWith(safeLookup, 'hooks.example.com', { all: true, family: 0 })
    assert.equal(all.err, null)
    assert.deepEqual(all.address, addresses)

    const single = await lookupWith(safeLookup, 'hooks.example.com', { family: 4 })
    assert.equal(single.err, null)
    assert.equal(single.address, '93.184.216.34')
    assert.equal(single.family, 4)

    // Always asks the resolver for every address, keeping the caller's options.
    assert.deepEqual(calls[1].options, { family: 4, all: true })
})

test('safeLookup passes resolver errors through', async () => {
    const failure = Object.assign(new Error('getaddrinfo ENOTFOUND'), { code: 'ENOTFOUND' })
    const safeLookup = createSafeLookup((hostname, options, callback) => callback(failure))
    const { err } = await lookupWith(safeLookup, 'down.example.com', {})
    assert.equal(err, failure)
    assert.notEqual(err.retryable, false)
})

test('logo URLs must be https when present', () => {
    assert.deepEqual(validateLogoUrl(''), { ok: true, url: null })
    assert.equal(validateLogoUrl('https://cdn.example.com/logo.png').ok, true)
    assert.equal(validateLogoUrl('http://cdn.example.com/logo.png').ok, false)
    assert.equal(validateLogoUrl('javascript:alert(1)').ok, false)
})
