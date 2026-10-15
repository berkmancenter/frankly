// Retry policy and delivery status transitions for external integrations.

// Delay before attempt 2, 3, ... of one run. A run is the first send plus its
// retries; a manual resend starts a new run. 6 attempts over ~8.5 hours.
const RETRY_DELAYS_SECONDS = [60, 5 * 60, 30 * 60, 2 * 60 * 60, 6 * 60 * 60]
const MAX_ATTEMPTS_PER_RUN = RETRY_DELAYS_SECONDS.length + 1

const STATUS_PENDING = 'pending'
const STATUS_DELIVERED = 'delivered'
const STATUS_FAILED = 'failed'

const MAX_ERROR_LENGTH = 500

/** Whether an HTTP status should be retried. */
function isRetryableStatus(status) {
    if (status == null) return true // network error or timeout
    if (status >= 500) return true
    return status === 408 || status === 425 || status === 429
}

function truncateError(message) {
    const text = String(message == null ? '' : message)
    return text.length > MAX_ERROR_LENGTH ? `${text.slice(0, MAX_ERROR_LENGTH - 3)}...` : text
}

/**
 * Computes the delivery fields to write after an attempt.
 *
 * - `runAttempt`: 1-based attempt number within the current run (already
 *   counted).
 * - `outcome`: `{ ok: true, status }` or `{ ok: false, status?, error,
 *   retryable? }`.
 *
 * Returns `{ status, nextAttemptAt, retryDelaySeconds, lastError,
 * lastResponseStatus, delivered }`.
 */
function nextDeliveryState({
    runAttempt,
    outcome,
    now = new Date(),
    delaysSeconds = RETRY_DELAYS_SECONDS,
}) {
    if (outcome.ok) {
        return {
            status: STATUS_DELIVERED,
            delivered: true,
            nextAttemptAt: null,
            retryDelaySeconds: null,
            lastError: null,
            lastResponseStatus: outcome.status == null ? null : outcome.status,
        }
    }

    const retryable = outcome.retryable === false ? false : isRetryableStatus(outcome.status)
    const delay = delaysSeconds[runAttempt - 1]
    const lastError = truncateError(outcome.error || `HTTP ${outcome.status}`)
    const lastResponseStatus = outcome.status == null ? null : outcome.status

    if (retryable && delay != null) {
        return {
            status: STATUS_PENDING,
            delivered: false,
            nextAttemptAt: new Date(now.getTime() + delay * 1000),
            retryDelaySeconds: delay,
            lastError,
            lastResponseStatus,
        }
    }

    return {
        status: STATUS_FAILED,
        delivered: false,
        nextAttemptAt: null,
        retryDelaySeconds: null,
        lastError,
        lastResponseStatus,
    }
}

module.exports = {
    RETRY_DELAYS_SECONDS,
    MAX_ATTEMPTS_PER_RUN,
    STATUS_PENDING,
    STATUS_DELIVERED,
    STATUS_FAILED,
    isRetryableStatus,
    truncateError,
    nextDeliveryState,
}
