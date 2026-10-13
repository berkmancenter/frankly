const test = require('node:test')
const assert = require('node:assert/strict')

const {
    isBlockedAddress,
    parseAllowedDomains,
    validateWebhookUrl,
    assertResolvesToPublicAddress,
    validateWebhookUrlForSend,
    validateLogoUrl,
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

test('logo URLs must be https when present', () => {
    assert.deepEqual(validateLogoUrl(''), { ok: true, url: null })
    assert.equal(validateLogoUrl('https://cdn.example.com/logo.png').ok, true)
    assert.equal(validateLogoUrl('http://cdn.example.com/logo.png').ok, false)
    assert.equal(validateLogoUrl('javascript:alert(1)').ok, false)
})
