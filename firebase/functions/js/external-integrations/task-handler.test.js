const test = require('node:test')
const assert = require('node:assert/strict')

const { parseDeliveryTaskRequest, handleDeliveryTask } = require('./task-handler')

const valid = { deliveryId: 'dlv_0123abcd', runId: '0123456789abcdef', runAttempt: 2 }
const quiet = { error() {} }

test('accepts a well-formed task body', () => {
    assert.deepEqual(parseDeliveryTaskRequest(valid), valid)
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
        { ...valid, runAttempt: 1 },
        { ...valid, runAttempt: '2' },
    ]) {
        assert.equal(parseDeliveryTaskRequest(body), null, JSON.stringify(body))
    }
})

test('answers 400 for a malformed body without attempting', async () => {
    let called = false
    const result = await handleDeliveryTask({
        method: 'POST',
        body: { ...valid, runId: '' },
        attemptDelivery: async () => {
            called = true
            return {}
        },
    })
    assert.equal(result.status, 400)
    assert.equal(called, false)
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
