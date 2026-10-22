const test = require('node:test')
const assert = require('node:assert/strict')

const {
    nextDeliveryState,
    isRetryableStatus,
    RETRY_DELAYS_SECONDS,
    MAX_ATTEMPTS_PER_RUN,
} = require('./retry')

const now = new Date('2026-01-01T00:00:00Z')

test('success marks the delivery delivered', () => {
    const state = nextDeliveryState({ runAttempt: 1, outcome: { ok: true, status: 204 }, now })
    assert.equal(state.status, 'delivered')
    assert.equal(state.delivered, true)
    assert.equal(state.nextAttemptAt, null)
    assert.equal(state.lastError, null)
    assert.equal(state.lastResponseStatus, 204)
})

test('retryable failures stay pending with growing backoff', () => {
    let previous = 0
    for (let attempt = 1; attempt < MAX_ATTEMPTS_PER_RUN; attempt++) {
        const state = nextDeliveryState({
            runAttempt: attempt,
            outcome: { ok: false, status: 503 },
            now,
        })
        assert.equal(state.status, 'pending')
        assert.equal(state.retryDelaySeconds, RETRY_DELAYS_SECONDS[attempt - 1])
        assert.equal(state.nextAttemptAt.getTime(), now.getTime() + state.retryDelaySeconds * 1000)
        assert.ok(state.retryDelaySeconds > previous)
        previous = state.retryDelaySeconds
    }
})

test('the last attempt of a run fails for good', () => {
    const state = nextDeliveryState({
        runAttempt: MAX_ATTEMPTS_PER_RUN,
        outcome: { ok: false, error: 'connect ECONNREFUSED' },
        now,
    })
    assert.equal(state.status, 'failed')
    assert.equal(state.nextAttemptAt, null)
    assert.equal(state.lastError, 'connect ECONNREFUSED')
})

test('client errors are not retried, except 408/425/429', () => {
    assert.equal(
        nextDeliveryState({ runAttempt: 1, outcome: { ok: false, status: 400 }, now }).status,
        'failed'
    )
    assert.equal(
        nextDeliveryState({ runAttempt: 1, outcome: { ok: false, status: 401 }, now }).status,
        'failed'
    )
    assert.equal(
        nextDeliveryState({ runAttempt: 1, outcome: { ok: false, status: 302 }, now }).status,
        'failed'
    )
    assert.equal(
        nextDeliveryState({ runAttempt: 1, outcome: { ok: false, status: 429 }, now }).status,
        'pending'
    )
    assert.equal(
        nextDeliveryState({ runAttempt: 1, outcome: { ok: false, status: 408 }, now }).status,
        'pending'
    )
    assert.equal(isRetryableStatus(undefined), true)
})

test('explicitly non-retryable failures fail at once', () => {
    const state = nextDeliveryState({
        runAttempt: 1,
        outcome: { ok: false, retryable: false, error: 'Integration is turned off' },
        now,
    })
    assert.equal(state.status, 'failed')
})

test('long errors are truncated', () => {
    const state = nextDeliveryState({
        runAttempt: 1,
        outcome: { ok: false, status: 500, error: 'x'.repeat(2000) },
        now,
    })
    assert.ok(state.lastError.length <= 500)
})
