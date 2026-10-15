const test = require('node:test')
const assert = require('node:assert/strict')

const { createDeliveryService, TASK_FUNCTION_NAME } = require('./delivery')
const { deliveryIdFor } = require('./payload')
const { verifySignature } = require('./signing')
const { MAX_ATTEMPTS_PER_RUN } = require('./retry')
const { FakeFirestore, FakeBucket } = require('./test-fakes')
const { postJson } = require('./http-post')
const { createSafeLookup } = require('./url-validation')

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
    postImpl = null,
    connectLookup = undefined,
    configOverrides = {},
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
    const fakePost = async (url, options) => {
        requests.push({ url, ...options })
        const next = responses.length > 0 ? responses.shift() : 200
        if (next instanceof Error) throw next
        return { status: next, bodySnippet: `status ${next}` }
    }
    const tasks = []
    const enqueueFunctionCall = async (task) => {
        if (enqueueError) throw enqueueError
        tasks.push(task)
    }

    const service = createDeliveryService({
        firestore,
        bucket,
        config: {
            allowedDomains: [],
            signedUrlTtlSeconds: 3600,
            requestTimeoutMs: 5000,
            ...configOverrides,
        },
        enqueueFunctionCall,
        postImpl: postImpl || fakePost,
        lookup: async () => [{ address: lookupAddress }],
        connectLookup,
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
        assert.equal(request.allowHttp, false)
        assert.equal(request.timeoutMs, 5000)
        assert.equal(typeof request.lookup, 'function')
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

test('every finished attempt clears its lease', async () => {
    const ctx = setup({
        integrations: [{ id: 'int1', events: ['recording.ready'] }],
        responses: [503],
    })
    await ctx.service.queueSessionDeliveries({ sessionId: 's1', session: ctx.session() })
    const path = `external-integration-deliveries/${mp4Id()}`
    assert.equal(ctx.firestore.get(path).status, 'pending')
    assert.equal(ctx.firestore.get(path).inFlightUntil, null)

    ctx.advance(60000)
    await ctx.service.attemptDelivery(ctx.tasks[0].payload)
    assert.equal(ctx.firestore.get(path).status, 'delivered')
    assert.equal(ctx.firestore.get(path).inFlightUntil, null)
})

// A receiver call that never returns stands in for a function that stopped
// between claiming an attempt and recording its result.
function setupWithStoppedAttempt() {
    const calls = []
    const ctx = setup({
        integrations: [{ id: 'int1', events: ['recording.ready'] }],
        postImpl: async (url, options) => {
            calls.push({ url, ...options })
            if (calls.length === 1) return { status: 503, bodySnippet: '' }
            if (calls.length === 2) return new Promise(() => {})
            return { status: 200, bodySnippet: '' }
        },
    })
    return { ...ctx, calls }
}

test('a task that finds the attempt in flight runs again after the lease', async () => {
    const ctx = setupWithStoppedAttempt()
    await ctx.service.queueSessionDeliveries({ sessionId: 's1', session: ctx.session() })
    const task = ctx.tasks[0].payload
    ctx.advance(60000)

    // Attempt 2 is claimed and then stops.
    ctx.service.attemptDelivery(task)
    await new Promise((resolve) => setImmediate(resolve))
    assert.equal(ctx.calls.length, 2)
    const path = `external-integration-deliveries/${mp4Id()}`
    const lease = ctx.firestore.get(path).inFlightUntil
    assert.ok(lease)

    // Cloud Tasks retries the same task while the lease is active.
    assert.deepEqual(await ctx.service.attemptDelivery(task), {
        skipped: 'in-flight',
        requeued: true,
    })
    assert.equal(ctx.tasks.length, 2)
    assert.deepEqual(ctx.tasks[1].payload, { ...task, afterLease: true })
    assert.ok(ctx.tasks[1].scheduleTime > lease)
    assert.equal(ctx.calls.length, 2)
})

test('an attempt that stopped after its claim is retried once its lease expires', async () => {
    const ctx = setupWithStoppedAttempt()
    await ctx.service.queueSessionDeliveries({ sessionId: 's1', session: ctx.session() })
    const task = ctx.tasks[0].payload
    ctx.advance(60000)
    ctx.service.attemptDelivery(task)
    await new Promise((resolve) => setImmediate(resolve))
    await ctx.service.attemptDelivery(task)
    const waiting = ctx.tasks[1]

    // When the waiting task runs, the lease has expired: the attempt is
    // claimed again and sent once, even if the task arrives twice.
    ctx.advance(waiting.scheduleTime.getTime() - Date.parse('2026-03-01T12:01:00Z'))
    const results = await Promise.all([
        ctx.service.attemptDelivery(waiting.payload),
        ctx.service.attemptDelivery(waiting.payload),
    ])
    assert.equal(ctx.calls.length, 3)
    // The duplicate finds the new claim in flight and, having waited once
    // already, drops out.
    assert.deepEqual(results.map((r) => r.status || r.skipped).sort(), ['delivered', 'in-flight'])
    const delivery = ctx.firestore.get(`external-integration-deliveries/${mp4Id()}`)
    assert.equal(delivery.status, 'delivered')
    assert.equal(delivery.runAttempts, 2)
    assert.equal(delivery.inFlightUntil, null)
    assert.equal(ctx.tasks.length, 2)
})

test('a task that waited for a lease does not wait again', async () => {
    const ctx = setupWithStoppedAttempt()
    await ctx.service.queueSessionDeliveries({ sessionId: 's1', session: ctx.session() })
    const task = ctx.tasks[0].payload
    ctx.advance(60000)
    ctx.service.attemptDelivery(task)
    await new Promise((resolve) => setImmediate(resolve))

    assert.deepEqual(await ctx.service.attemptDelivery({ ...task, afterLease: true }), {
        skipped: 'in-flight',
    })
    assert.equal(ctx.tasks.length, 1)
    assert.equal(ctx.calls.length, 2)
})

test('a task without a run id is ignored', async () => {
    const ctx = setup({
        integrations: [{ id: 'int1', events: ['recording.ready'] }],
        responses: [500],
    })
    await ctx.service.queueSessionDeliveries({ sessionId: 's1', session: ctx.session() })
    const { payload } = ctx.tasks[0]
    for (const runId of ['', undefined, null]) {
        assert.deepEqual(await ctx.service.attemptDelivery({ ...payload, runId }), {
            skipped: 'stale-run',
        })
    }
    assert.equal(ctx.requests.length, 1)
})

// Simulates a function that stopped after creating a delivery but before
// sending it: the claim transaction never runs.
async function createUndispatched(ctx) {
    const runTransaction = ctx.firestore.runTransaction
    ctx.firestore.runTransaction = async () => ({ skipped: 'simulated-stop' })
    await ctx.service.queueSessionDeliveries({ sessionId: 's1', session: ctx.session() })
    ctx.firestore.runTransaction = runTransaction
    assert.equal(ctx.requests.length, 0)
}

test('queueing again sends a delivery that was created but never sent', async () => {
    const ctx = setup({ integrations: [{ id: 'int1', events: ['recording.ready'] }] })
    await createUndispatched(ctx)
    const pending = ctx.firestore.get(`external-integration-deliveries/${mp4Id()}`)
    assert.equal(pending.status, 'pending')
    assert.equal(pending.runAttempts, 0)

    const created = await ctx.service.queueSessionDeliveries({
        sessionId: 's1',
        session: ctx.session(),
    })
    assert.deepEqual(created, [])
    assert.equal(ctx.requests.length, 1)
    const delivery = ctx.firestore.get(`external-integration-deliveries/${mp4Id()}`)
    assert.equal(delivery.status, 'delivered')
    assert.equal(delivery.runId, pending.runId)
    assert.equal(delivery.attempts, 1)

    await ctx.service.queueSessionDeliveries({ sessionId: 's1', session: ctx.session() })
    assert.equal(ctx.requests.length, 1)
})

test('two concurrent recoveries send once', async () => {
    const ctx = setup({ integrations: [{ id: 'int1', events: ['recording.ready'] }] })
    await createUndispatched(ctx)
    await Promise.all([
        ctx.service.queueSessionDeliveries({ sessionId: 's1', session: ctx.session() }),
        ctx.service.queueSessionDeliveries({ sessionId: 's1', session: ctx.session() }),
    ])
    assert.equal(ctx.requests.length, 1)
    assert.equal(ctx.firestore.get(`external-integration-deliveries/${mp4Id()}`).attempts, 1)
})

test('does not recover a delivery that already made an attempt in its run', async () => {
    const ctx = setup({
        integrations: [{ id: 'int1', events: ['recording.ready'] }],
        responses: [503],
    })
    await ctx.service.queueSessionDeliveries({ sessionId: 's1', session: ctx.session() })
    assert.equal(ctx.requests.length, 1)
    await ctx.service.queueSessionDeliveries({ sessionId: 's1', session: ctx.session() })
    assert.equal(ctx.requests.length, 1)
})

test('deliveries created before a failing create are still sent', async () => {
    // Artifacts are created in path order: the CSV first, then the MP4.
    const ctx = setup()
    const failingId = mp4Id()
    const doc = ctx.firestore.doc.bind(ctx.firestore)
    ctx.firestore.doc = (path) => {
        const ref = doc(path)
        if (path === `external-integration-deliveries/${failingId}`) {
            ref.create = async () => {
                throw new Error('firestore unavailable')
            }
        }
        return ref
    }
    await assert.rejects(
        ctx.service.queueSessionDeliveries({ sessionId: 's1', session: ctx.session() }),
        /firestore unavailable/
    )
    assert.equal(ctx.requests.length, 1)
    assert.equal(
        ctx.firestore.get(`external-integration-deliveries/${csvId()}`).status,
        'delivered'
    )
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

test('refuses to connect when the host resolves to a private address at connect time', async () => {
    // The early check sees a public address, the connection lookup a private
    // one (DNS rebinding). The real HTTP client must not connect.
    const resolverCalls = []
    const rebinding = (hostname, options, callback) => {
        resolverCalls.push(hostname)
        callback(null, [{ address: '10.0.0.7', family: 4 }])
    }
    const ctx = setup({
        integrations: [{ id: 'int1', events: ['recording.ready'] }],
        postImpl: postJson,
        connectLookup: createSafeLookup(rebinding),
    })
    await ctx.service.queueSessionDeliveries({ sessionId: 's1', session: ctx.session() })
    const delivery = ctx.firestore.get(`external-integration-deliveries/${mp4Id()}`)
    assert.deepEqual(resolverCalls, ['hooks.example.com'])
    assert.equal(delivery.status, 'failed')
    assert.match(delivery.lastError, /private or internal/)
    assert.equal(ctx.tasks.length, 0)
})

test('network errors are retried, blocked addresses are not', async () => {
    const blocked = new Error('Webhook host resolves to a private or internal address')
    blocked.retryable = false
    const ctx = setup({
        integrations: [{ id: 'int1', events: ['recording.ready'] }],
        responses: [new Error('ECONNRESET'), blocked],
    })
    await ctx.service.queueSessionDeliveries({ sessionId: 's1', session: ctx.session() })
    let delivery = ctx.firestore.get(`external-integration-deliveries/${mp4Id()}`)
    assert.equal(delivery.status, 'pending')
    assert.equal(ctx.tasks.length, 1)

    ctx.advance(60000)
    await ctx.service.attemptDelivery(ctx.tasks[0].payload)
    delivery = ctx.firestore.get(`external-integration-deliveries/${mp4Id()}`)
    assert.equal(delivery.status, 'failed')
    assert.equal(ctx.tasks.length, 1)
})

test('local receivers in the emulator use http and plain DNS', async () => {
    const ctx = setup({
        integrations: [{ id: 'int1', events: ['recording.ready'] }],
        configOverrides: { allowLocalTargets: true },
    })
    await ctx.firestore
        .doc(`community/${COMMUNITY}/external-integration-endpoints/int1`)
        .set({ webhookUrl: 'http://127.0.0.1:9999/hook' })
    await ctx.service.queueSessionDeliveries({ sessionId: 's1', session: ctx.session() })
    assert.equal(ctx.requests.length, 1)
    assert.equal(ctx.requests[0].url, 'http://127.0.0.1:9999/hook')
    assert.equal(ctx.requests[0].allowHttp, true)
    assert.equal(ctx.requests[0].lookup, require('dns').lookup)
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
