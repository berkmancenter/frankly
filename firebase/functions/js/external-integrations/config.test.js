const test = require('node:test')
const assert = require('node:assert/strict')

const { parseExternalIntegrationsConfig } = require('./config')
const { validateWebhookUrl, validateWebhookUrlForSend } = require('./url-validation')

test('defaults when nothing is configured', () => {
    const config = parseExternalIntegrationsConfig(undefined, {})
    assert.deepEqual(config, {
        allowedDomains: [],
        allowLocalTargets: false,
        signedUrlTtlSeconds: 3600,
        requestTimeoutMs: 10000,
    })
})

test('parses and clamps values', () => {
    const config = parseExternalIntegrationsConfig(
        {
            allowed_domains: 'a.example, b.example',
            signed_url_ttl_minutes: '1',
            request_timeout_ms: '999999',
        },
        {}
    )
    assert.deepEqual(config.allowedDomains, ['a.example', 'b.example'])
    assert.equal(config.signedUrlTtlSeconds, 5 * 60)
    assert.equal(config.requestTimeoutMs, 60000)
})

test('local targets are only allowed inside the Functions emulator', () => {
    const raw = { allow_local_targets_in_emulator: 'true' }
    assert.equal(parseExternalIntegrationsConfig(raw, {}).allowLocalTargets, false)
    assert.equal(
        parseExternalIntegrationsConfig(raw, { FUNCTIONS_EMULATOR: 'false' }).allowLocalTargets,
        false
    )
    assert.equal(
        parseExternalIntegrationsConfig(raw, { FUNCTIONS_EMULATOR: 'true' }).allowLocalTargets,
        true
    )
    assert.equal(
        parseExternalIntegrationsConfig({}, { FUNCTIONS_EMULATOR: 'true' }).allowLocalTargets,
        false
    )
})

test('allowLocalTargets only opens loopback hosts', async () => {
    assert.equal(validateWebhookUrl('http://127.0.0.1:9999/hook').ok, false)
    assert.equal(
        validateWebhookUrl('http://127.0.0.1:9999/hook', { allowLocalTargets: true }).ok,
        true
    )
    assert.equal(validateWebhookUrl('http://localhost/hook', { allowLocalTargets: true }).ok, true)
    assert.equal(validateWebhookUrl('http://10.0.0.1/hook', { allowLocalTargets: true }).ok, false)
    assert.equal(
        validateWebhookUrl('http://169.254.169.254/hook', { allowLocalTargets: true }).ok,
        false
    )
    assert.equal(
        await validateWebhookUrlForSend('http://127.0.0.1:9999/hook', { allowLocalTargets: true }),
        'http://127.0.0.1:9999/hook'
    )
})
