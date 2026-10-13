const test = require('node:test')
const assert = require('node:assert/strict')

const { createDeliveryService, TASK_FUNCTION_NAME } = require('./delivery')
const { deliveryIdFor } = require('./payload')
const { verifySignature } = require('./signing')
const { MAX_ATTEMPTS_PER_RUN } = require('./retry')
const { FakeFirestore, FakeBucket } = require('./test-fakes')

const COMMUNITY = 'c1'
const EVENT_PATH = `community/${COMMUNITY}/templates/t1/events/e1`
const SECRET = 'whsec_unit-test'
const MP4 = 'rec/e1/main/room/s1/abc_0.mp4'
const CSV = 'rec/e1/main/room/s1/abc_0.csv'

function setup({
    integrations = [{ id: 'int1', events: ['recording.ready', 'transcript.ready'] }],
    eventEnabled = true,
    responses = [],
    lookupAddress = '93.184.216.34',
    enqueueError = null,
} = {}) {
    const docs = {
        [EVENT_PATH]: {
            id: 'e1',
            communityId: COMMUNITY,
            templateId: 't1',
            creatorId: 'host',
            title: 'Town hall',
        },
        'recording-sessions/s1': {
            communityId: COMMUNITY,
            eventId: 'e1',
            roomType: 'main',
            roomId: 'room',
            artifactPaths: {
                complete_mp4_0: MP4,
                transcript_vtt_0: 'rec/x.vtt',
                complete_trx_0: CSV,
            },
        },
        [`memberships/mod/community-membership/${COMMUNITY}`]: { status: 'moderator' },
        [`memberships/member/community-membership/${COMMUNITY}`]: { status: 'member' },
    }
    for (const integration of integrations) {
        docs[`community/${COMMUNITY}/external-integrations/${integration.id}`] = {
            id: integration.id,
            communityId: COMMUNITY,
            displayName: 'Receiver',
            isActive: integration.isActive !== false,
            events: integration.events,
        }
        docs[`community/${COMMUNITY}/external-integration-endpoints/${integration.id}`] = {
            webhookUrl: `https://hooks.example.com/${integration.id}`,
        }
        docs[`external-integration-secrets/${integration.id}`] = { secret: SECRET }
        if (eventEnabled) {
            docs[`${EVENT_PATH}/external-integration-settings/${integration.id}`] = {
                integrationId: integration.id,
                enabled: true,
                externalReference: 'ext-123',
            }
        }
    }

    const firestore = new FakeFirestore(docs)
    const bucket = new FakeBucket({
        [MP4]: { size: 1000, contentType: 'video/mp4' },
        [CSV]: { size: 20, contentType: 'text/csv' },
    })

    let clock = new Date('2026-03-01T12:00:00Z').getTime()
    const requests = []
    const fetchImpl = async (url, options) => {
        requests.push({ url, ...options })
        const next = responses.length > 0 ? responses.shift() : 200
        if (next instanceof Error) throw next
        return { status: next, text: async () => `status ${next}` }
    }
    const tasks = []
    const enqueueFunctionCall = async (task) => {
        if (enqueueError) throw enqueueError
        tasks.push(task)
    }

    const service = createDeliveryService({
        firestore,
        bucket,
        config: { allowedDomains: [], signedUrlTtlSeconds: 3600, requestTimeoutMs: 5000 },
        enqueueFunctionCall,
        fetchImpl,
        lookup: async () => [{ address: lookupAddress }],
        now: () => new Date(clock),
        logger: { warn() {}, error() {}, log() {} },
    })

    return {
        firestore,
        bucket,
        service,
        requests,
        tasks,
        advance: (ms) => {
            clock += ms
        },
        session: () => firestore.get('recording-sessions/s1'),
    }
}

const mp4Id = (integrationId = 'int1') =>
    deliveryIdFor({ integrationId, eventType: 'recording.ready', artifactPath: MP4 })
const csvId = (integrationId = 'int1') =>
    deliveryIdFor({ integrationId, eventType: 'transcript.ready', artifactPath: CSV })

test('does nothing when the community has no integration', async () => {
    const ctx = setup({ integrations: [] })
    const created = await ctx.service.queueSessionDeliveries({
        sessionId: 's1',
        session: ctx.session(),
    })
    assert.deepEqual(created, [])
    assert.equal(ctx.requests.length, 0)
})

test('does nothing when the integration is off for the event', async () => {
    const ctx = setup({ eventEnabled: false })
    const created = await ctx.service.queueSessionDeliveries({
        sessionId: 's1',
        session: ctx.session(),
    })
    assert.deepEqual(created, [])
    assert.equal(ctx.requests.length, 0)
})

test('sends a signed delivery per subscribed artifact and records success', async () => {
    const ctx = setup()
    const created = await ctx.service.queueSessionDeliveries({
        sessionId: 's1',
        session: ctx.session(),
    })
    assert.deepEqual(new Set(created), new Set([mp4Id(), csvId()]))
    assert.equal(ctx.requests.length, 2)

    for (const request of ctx.requests) {
        assert.equal(request.url, 'https://hooks.example.com/int1')
        assert.equal(request.method, 'POST')
        assert.equal(request.redirect, 'manual')
        const ok = verifySignature({
            secret: SECRET,
            timestamp: request.headers['X-Frankly-Timestamp'],
            body: request.body,
            signatureHeader: request.headers['X-Frankly-Signature'],
            now: new Date('2026-03-01T12:00:00Z').getTime(),
        })
        assert.equal(ok, true)
        const payload = JSON.parse(request.body)
        assert.equal(payload.deliveryId, request.headers['X-Frankly-Delivery'])
        assert.equal(payload.type, request.headers['X-Frankly-Event'])
        assert.equal(payload.externalReference, 'ext-123')
        assert.equal(payload.community.id, COMMUNITY)
        assert.equal(payload.event.id, 'e1')
        assert.equal(payload.recordingSession.id, 's1')
        assert.match(payload.artifact.downloadUrl, /^https:\/\/storage\.example\.test\//)
        assert.equal(payload.artifact.downloadUrlExpiresAt, '2026-03-01T13:00:00.000Z')
    }

    const delivery = ctx.firestore.get(`external-integration-deliveries/${mp4Id()}`)
    assert.equal(delivery.status, 'delivered')
    assert.equal(delivery.attempts, 1)
    assert.equal(delivery.lastError, null)
    assert.ok(delivery.deliveredAt instanceof Date)
    assert.equal(delivery.artifactPath, MP4)
    assert.equal(ctx.tasks.length, 0)
})

test('only sends event types the integration subscribed to', async () => {
    const ctx = setup({ integrations: [{ id: 'int1', events: ['transcript.ready'] }] })
    const created = await ctx.service.queueSessionDeliveries({
        sessionId: 's1',
        session: ctx.session(),
    })
    assert.deepEqual(created, [csvId()])
})

test('queueing twice does not create or send duplicates', async () => {
    const ctx = setup()
    await ctx.service.queueSessionDeliveries({ sessionId: 's1', session: ctx.session() })
    const again = await ctx.service.queueSessionDeliveries({
        sessionId: 's1',
        session: ctx.session(),
    })
    assert.deepEqual(again, [])
    assert.equal(ctx.requests.length, 2)
})

test('server errors are retried through Cloud Tasks until delivered', async () => {
    const ctx = setup({
        integrations: [{ id: 'int1', events: ['recording.ready'] }],
        responses: [503],
    })
    await ctx.service.queueSessionDeliveries({ sessionId: 's1', session: ctx.session() })

    let delivery = ctx.firestore.get(`external-integration-deliveries/${mp4Id()}`)
    assert.equal(delivery.status, 'pending')
    assert.equal(delivery.attempts, 1)
    assert.equal(delivery.lastResponseStatus, 503)
    assert.match(delivery.lastError, /HTTP 503/)
    assert.equal(ctx.tasks.length, 1)
    assert.equal(ctx.tasks[0].functionName, TASK_FUNCTION_NAME)
    assert.deepEqual(ctx.tasks[0].payload, {
        deliveryId: mp4Id(),
        runId: delivery.runId,
        runAttempt: 2,
    })
    assert.equal(ctx.tasks[0].scheduleTime.getTime(), new Date('2026-03-01T12:01:00Z').getTime())

    ctx.advance(60000)
    const result = await ctx.service.attemptDelivery(ctx.tasks[0].payload)
    assert.equal(result.status, 'delivered')
    delivery = ctx.firestore.get(`external-integration-deliveries/${mp4Id()}`)
    assert.equal(delivery.status, 'delivered')
    assert.equal(delivery.attempts, 2)
    assert.equal(delivery.lastError, null)

    // Each attempt signs a fresh download URL.
    assert.equal(ctx.bucket.signedUrlRequests.length, 2)
    assert.notEqual(
        ctx.bucket.signedUrlRequests[0].expires,
        ctx.bucket.signedUrlRequests[1].expires
    )
})

test('stale or duplicate tasks are ignored', async () => {
    const ctx = setup({
        integrations: [{ id: 'int1', events: ['recording.ready'] }],
        responses: [500],
    })
    await ctx.service.queueSessionDeliveries({ sessionId: 's1', session: ctx.session() })
    const { payload } = ctx.tasks[0]

    assert.deepEqual(await ctx.service.attemptDelivery({ ...payload, runId: 'other' }), {
        skipped: 'stale-run',
    })
    assert.deepEqual(await ctx.service.attemptDelivery({ ...payload, runAttempt: 5 }), {
        skipped: 'stale-attempt',
    })

    await ctx.service.attemptDelivery(payload)
    assert.deepEqual(await ctx.service.attemptDelivery(payload), { skipped: 'not-pending' })
    assert.equal(ctx.requests.length, 2)
})

test('gives up after the last retry', async () => {
    const ctx = setup({
        integrations: [{ id: 'int1', events: ['recording.ready'] }],
        responses: new Array(MAX_ATTEMPTS_PER_RUN).fill(new Error('ECONNRESET')),
    })
    await ctx.service.queueSessionDeliveries({ sessionId: 's1', session: ctx.session() })
    while (ctx.tasks.length > 0) {
        const task = ctx.tasks.shift()
        ctx.advance(task.scheduleTime.getTime() - Date.parse('2026-03-01T12:00:00Z'))
        await ctx.service.attemptDelivery(task.payload)
    }
    const delivery = ctx.firestore.get(`external-integration-deliveries/${mp4Id()}`)
    assert.equal(delivery.status, 'failed')
    assert.equal(delivery.attempts, MAX_ATTEMPTS_PER_RUN)
    assert.match(delivery.lastError, /ECONNRESET/)
    assert.equal(ctx.requests.length, MAX_ATTEMPTS_PER_RUN)
})

test('client errors fail without retry', async () => {
    const ctx = setup({
        integrations: [{ id: 'int1', events: ['recording.ready'] }],
        responses: [400],
    })
    await ctx.service.queueSessionDeliveries({ sessionId: 's1', session: ctx.session() })
    const delivery = ctx.firestore.get(`external-integration-deliveries/${mp4Id()}`)
    assert.equal(delivery.status, 'failed')
    assert.equal(ctx.tasks.length, 0)
})

test('a retry that cannot be scheduled marks the delivery failed', async () => {
    const ctx = setup({
        integrations: [{ id: 'int1', events: ['recording.ready'] }],
        responses: [503],
        enqueueError: new Error('queue missing'),
    })
    await ctx.service.queueSessionDeliveries({ sessionId: 's1', session: ctx.session() })
    const delivery = ctx.firestore.get(`external-integration-deliveries/${mp4Id()}`)
    assert.equal(delivery.status, 'failed')
    assert.match(delivery.lastError, /retry could not be scheduled: queue missing/)
})

test('refuses to call a host that resolves to a private address', async () => {
    const ctx = setup({
        integrations: [{ id: 'int1', events: ['recording.ready'] }],
        lookupAddress: '10.0.0.7',
    })
    await ctx.service.queueSessionDeliveries({ sessionId: 's1', session: ctx.session() })
    const delivery = ctx.firestore.get(`external-integration-deliveries/${mp4Id()}`)
    assert.equal(delivery.status, 'failed')
    assert.match(delivery.lastError, /private or internal/)
    assert.equal(ctx.requests.length, 0)
})

test('skips sending when the integration was switched off after queueing', async () => {
    const ctx = setup({
        integrations: [{ id: 'int1', events: ['recording.ready'] }],
        responses: [503],
    })
    await ctx.service.queueSessionDeliveries({ sessionId: 's1', session: ctx.session() })
    await ctx.firestore
        .doc(`community/${COMMUNITY}/external-integrations/int1`)
        .update({ isActive: false })
    await ctx.service.attemptDelivery(ctx.tasks[0].payload)
    const delivery = ctx.firestore.get(`external-integration-deliveries/${mp4Id()}`)
    assert.equal(delivery.status, 'failed')
    assert.match(delivery.lastError, /turned off or was removed/)
    assert.equal(ctx.requests.length, 1)
})

test('resend is allowed for moderators and the event host, with a fresh URL', async () => {
    const ctx = setup({
        integrations: [{ id: 'int1', events: ['recording.ready'] }],
        responses: [400],
    })
    await ctx.service.queueSessionDeliveries({ sessionId: 's1', session: ctx.session() })
    assert.equal(ctx.firestore.get(`external-integration-deliveries/${mp4Id()}`).status, 'failed')

    assert.deepEqual(await ctx.service.resendDelivery({ deliveryId: mp4Id(), uid: 'member' }), {
        error: 'permission-denied',
    })
    assert.deepEqual(await ctx.service.resendDelivery({ deliveryId: 'dlv_missing', uid: 'mod' }), {
        error: 'not-found',
    })

    ctx.advance(10 * 60 * 1000)
    assert.deepEqual(await ctx.service.resendDelivery({ deliveryId: mp4Id(), uid: 'host' }), {
        status: 'delivered',
    })
    const delivery = ctx.firestore.get(`external-integration-deliveries/${mp4Id()}`)
    assert.equal(delivery.status, 'delivered')
    assert.equal(delivery.attempts, 2)
    assert.equal(ctx.requests.length, 2)
    const [first, second] = ctx.requests.map((r) => JSON.parse(r.body))
    assert.equal(first.deliveryId, second.deliveryId)
    assert.notEqual(first.artifact.downloadUrl, second.artifact.downloadUrl)
    assert.equal(second.attempt, 2)

    assert.deepEqual(await ctx.service.resendDelivery({ deliveryId: mp4Id(), uid: 'mod' }), {
        status: 'delivered',
    })
})

test('a receiver failure never throws out of queueSessionDeliveries', async () => {
    const ctx = setup({ responses: [new Error('boom'), new Error('boom')] })
    await assert.doesNotReject(
        ctx.service.queueSessionDeliveries({ sessionId: 's1', session: ctx.session() })
    )
})
