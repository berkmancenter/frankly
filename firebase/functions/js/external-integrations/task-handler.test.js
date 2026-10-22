const test = require('node:test')
const assert = require('node:assert/strict')

const { parseDeliveryTaskRequest, handleDeliveryTask } = require('./task-handler')

const valid = { deliveryId: 'dlv_0123abcd', runId: '0123456789abcdef', runAttempt: 2 }
const quiet = { error() {} }

test('accepts a well-formed task body', () => {
    assert.deepEqual(parseDeliveryTaskRequest(valid), valid)
    assert.deepEqual(parseDeliveryTaskRequest({ ...valid, afterLease: true }), {
        ...valid,
        afterLease: true,
    })
    // A task that waited for an in-flight first attempt.
    assert.deepEqual(parseDeliveryTaskRequest({ ...valid, runAttempt: 1, afterLease: true }), {
        ...valid,
        runAttempt: 1,
        afterLease: true,
    })
})

test('rejects malformed task bodies', () => {
    for (const body of [
        undefined,
        {},
        { ...valid, deliveryId: 'nope' },
        { ...valid, runId: undefined },
        { ...valid, runId: '' },
        { ...valid, runId: '0123456789ABCDEF' },
        { ...valid, runId: '0123456789abcde' },
        { ...valid, runId: 12345 },
        { ...valid, runAttempt: 0 },
        { ...valid, runAttempt: '2' },
        { ...valid, afterLease: 'yes' },
        { ...valid, afterLease: false },
    ]) {
        assert.equal(parseDeliveryTaskRequest(body), null, JSON.stringify(body))
    }
})

test('answers 200 for a malformed body without attempting, and logs it', async () => {
    let called = false
    const errors = []
    const result = await handleDeliveryTask({
        method: 'POST',
        body: { ...valid, runId: '' },
        attemptDelivery: async () => {
            called = true
            return {}
        },
        logger: { error: (...args) => errors.push(args) },
    })
    // Cloud Tasks retries any non-2xx answer; a malformed task never heals.
    assert.deepEqual(result, { status: 200, body: { error: 'ignored malformed task' } })
    assert.equal(called, false)
    assert.equal(errors.length, 1)
})

test('answers 405 for other methods', async () => {
    const result = await handleDeliveryTask({
        method: 'GET',
        body: valid,
        attemptDelivery: async () => ({}),
    })
    assert.equal(result.status, 405)
})

test('answers 200 when the attempt ran or was skipped', async () => {
    const ran = await handleDeliveryTask({
        method: 'POST',
        body: valid,
        attemptDelivery: async (request) => {
            assert.deepEqual(request, valid)
            return { status: 'delivered' }
        },
    })
    assert.deepEqual(ran, { status: 200, body: { status: 'delivered', skipped: null } })

    const skipped = await handleDeliveryTask({
        method: 'POST',
        body: valid,
        attemptDelivery: async () => ({ skipped: 'stale-attempt' }),
    })
    assert.deepEqual(skipped, { status: 200, body: { status: null, skipped: 'stale-attempt' } })
})

test('answers 500 on unexpected errors so Cloud Tasks retries', async () => {
    const result = await handleDeliveryTask({
        method: 'POST',
        body: valid,
        attemptDelivery: async () => {
            throw new Error('firestore unavailable')
        },
        logger: quiet,
    })
    assert.equal(result.status, 500)
})
