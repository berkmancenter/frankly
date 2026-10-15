// Request handling for the Cloud Tasks retry endpoint
// (externalIntegrationDeliveryTask), kept free of firebase imports so it can
// be tested directly.

const { RUN_ID_PATTERN } = require('./delivery')

const DELIVERY_ID_PATTERN = /^dlv_[a-f0-9]{1,64}$/

/**
 * Returns `{ deliveryId, runId, runAttempt }` for a valid task body, or
 * null.
 */
function parseDeliveryTaskRequest(body) {
    const { deliveryId, runId, runAttempt } = body || {}
    if (typeof deliveryId !== 'string' || !DELIVERY_ID_PATTERN.test(deliveryId)) return null
    if (typeof runId !== 'string' || !RUN_ID_PATTERN.test(runId)) return null
    if (!Number.isInteger(runAttempt) || runAttempt < 2) return null
    return { deliveryId, runId, runAttempt }
}

/**
 * Runs one task request and returns `{ status, body }` for the response.
 *
 * - 400 for a malformed body: Cloud Tasks retrying it cannot help.
 * - 200 when the attempt ran or was skipped as stale. Our own retry policy
 *   decides what happens next, so Cloud Tasks must not add retries.
 * - 500 when something unexpected failed (for example Firestore was not
 *   reachable), so Cloud Tasks retries the task. Replays are safe: an attempt
 *   that already ran is skipped as stale.
 */
async function handleDeliveryTask({ method, body, attemptDelivery, logger = console }) {
    if (method !== 'POST') return { status: 405, body: 'Method not allowed' }
    const request = parseDeliveryTaskRequest(body)
    if (!request) return { status: 400, body: 'Invalid request' }
    try {
        const result = await attemptDelivery(request)
        return {
            status: 200,
            body: { status: result.status || null, skipped: result.skipped || null },
        }
    } catch (err) {
        logger.error(`External integrations: retry for ${request.deliveryId} failed:`, err)
        return { status: 500, body: { error: 'attempt failed' } }
    }
}

module.exports = { parseDeliveryTaskRequest, handleDeliveryTask }
