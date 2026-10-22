// Webhook signing for external integrations.
//
// Each request carries a Unix timestamp and an HMAC-SHA256 signature over
// `${timestamp}.${rawBody}` using the integration's secret. Receivers
// recompute the signature, compare in constant time and reject old
// timestamps to stop replays. See docs/pages/external-integrations.md.

const crypto = require('crypto')

const SIGNATURE_VERSION = 'v1'
const SECRET_PREFIX = 'whsec_'

const HEADER_EVENT = 'X-Frankly-Event'
const HEADER_DELIVERY = 'X-Frankly-Delivery'
const HEADER_TIMESTAMP = 'X-Frankly-Timestamp'
const HEADER_SIGNATURE = 'X-Frankly-Signature'
const HEADER_ATTEMPT = 'X-Frankly-Attempt'
const USER_AGENT = 'Frankly-Webhooks/1'

/** Generates a new random signing secret (32 bytes, base64url). */
function generateSecret() {
    return SECRET_PREFIX + crypto.randomBytes(32).toString('base64url')
}

/** Returns the hex HMAC-SHA256 of `${timestamp}.${body}`. */
function computeSignature({ secret, timestamp, body }) {
    return crypto.createHmac('sha256', secret).update(`${timestamp}.${body}`, 'utf8').digest('hex')
}

/** Value of the signature header, e.g. `v1=5257a869...`. */
function signatureHeaderValue({ secret, timestamp, body }) {
    return `${SIGNATURE_VERSION}=${computeSignature({ secret, timestamp, body })}`
}

/**
 * Verifies a signature header. Provided for receivers written in Node and for
 * tests; Frankly itself only signs.
 */
function verifySignature({
    secret,
    timestamp,
    body,
    signatureHeader,
    toleranceSeconds = 300,
    now = Date.now(),
}) {
    const ts = Number(timestamp)
    if (!Number.isFinite(ts)) return false
    if (Math.abs(Math.floor(now / 1000) - ts) > toleranceSeconds) return false
    const expected = computeSignature({ secret, timestamp, body })
    const candidates = String(signatureHeader || '')
        .split(',')
        .map((part) => part.trim())
        .filter((part) => part.startsWith(`${SIGNATURE_VERSION}=`))
        .map((part) => part.slice(SIGNATURE_VERSION.length + 1))
    return candidates.some((candidate) => {
        const a = Buffer.from(candidate, 'utf8')
        const b = Buffer.from(expected, 'utf8')
        return a.length === b.length && crypto.timingSafeEqual(a, b)
    })
}

/** Builds the full header set for a webhook request. */
function buildWebhookHeaders({ secret, body, eventType, deliveryId, attempt, now = Date.now() }) {
    const timestamp = Math.floor(now / 1000).toString()
    return {
        'Content-Type': 'application/json',
        'User-Agent': USER_AGENT,
        [HEADER_EVENT]: eventType,
        [HEADER_DELIVERY]: deliveryId,
        [HEADER_ATTEMPT]: String(attempt),
        [HEADER_TIMESTAMP]: timestamp,
        [HEADER_SIGNATURE]: signatureHeaderValue({ secret, timestamp, body }),
    }
}

module.exports = {
    SIGNATURE_VERSION,
    SECRET_PREFIX,
    HEADER_EVENT,
    HEADER_DELIVERY,
    HEADER_TIMESTAMP,
    HEADER_SIGNATURE,
    HEADER_ATTEMPT,
    USER_AGENT,
    generateSecret,
    computeSignature,
    signatureHeaderValue,
    verifySignature,
    buildWebhookHeaders,
}
