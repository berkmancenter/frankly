const test = require('node:test')
const assert = require('node:assert/strict')
const crypto = require('crypto')

const {
    generateSecret,
    computeSignature,
    signatureHeaderValue,
    verifySignature,
    buildWebhookHeaders,
    SECRET_PREFIX,
} = require('./signing')

const secret = 'whsec_test-secret'
const body = '{"hello":"world"}'
const timestamp = '1700000000'

test('signature is HMAC-SHA256 over "timestamp.body" in hex', () => {
    const expected = crypto
        .createHmac('sha256', secret)
        .update(`${timestamp}.${body}`)
        .digest('hex')
    assert.equal(computeSignature({ secret, timestamp, body }), expected)
    assert.equal(signatureHeaderValue({ secret, timestamp, body }), `v1=${expected}`)
})

test('signature changes when body, timestamp or secret change', () => {
    const base = computeSignature({ secret, timestamp, body })
    assert.notEqual(computeSignature({ secret, timestamp, body: body + ' ' }), base)
    assert.notEqual(computeSignature({ secret, timestamp: '1700000001', body }), base)
    assert.notEqual(computeSignature({ secret: 'whsec_other', timestamp, body }), base)
})

test('verifySignature accepts a valid signature within tolerance', () => {
    const header = signatureHeaderValue({ secret, timestamp, body })
    assert.equal(
        verifySignature({
            secret,
            timestamp,
            body,
            signatureHeader: header,
            now: 1700000100 * 1000,
        }),
        true
    )
})

test('verifySignature rejects tampered bodies, wrong secrets and old timestamps', () => {
    const header = signatureHeaderValue({ secret, timestamp, body })
    const now = 1700000000 * 1000
    assert.equal(
        verifySignature({ secret, timestamp, body: '{}', signatureHeader: header, now }),
        false
    )
    assert.equal(
        verifySignature({ secret: 'whsec_x', timestamp, body, signatureHeader: header, now }),
        false
    )
    assert.equal(
        verifySignature({
            secret,
            timestamp,
            body,
            signatureHeader: header,
            now: now + 301 * 1000,
        }),
        false
    )
    assert.equal(
        verifySignature({ secret, timestamp, body, signatureHeader: 'v0=abc', now }),
        false
    )
})

test('buildWebhookHeaders sets event, delivery, attempt, timestamp and signature', () => {
    const now = 1700000000123
    const headers = buildWebhookHeaders({
        secret,
        body,
        eventType: 'recording.ready',
        deliveryId: 'dlv_abc',
        attempt: 2,
        now,
    })
    assert.equal(headers['Content-Type'], 'application/json')
    assert.equal(headers['X-Frankly-Event'], 'recording.ready')
    assert.equal(headers['X-Frankly-Delivery'], 'dlv_abc')
    assert.equal(headers['X-Frankly-Attempt'], '2')
    assert.equal(headers['X-Frankly-Timestamp'], '1700000000')
    assert.equal(
        headers['X-Frankly-Signature'],
        signatureHeaderValue({ secret, timestamp: '1700000000', body })
    )
})

test('generateSecret returns distinct prefixed 256-bit secrets', () => {
    const a = generateSecret()
    const b = generateSecret()
    assert.ok(a.startsWith(SECRET_PREFIX))
    assert.notEqual(a, b)
    assert.equal(Buffer.from(a.slice(SECRET_PREFIX.length), 'base64url').length, 32)
})
