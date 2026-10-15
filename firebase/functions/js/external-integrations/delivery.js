// Webhook delivery for external integrations.
//
// When a recording session's artifacts are registered, one delivery document
// is created per (integration, artifact) and sent right away. Failures are
// retried with backoff through Cloud Tasks. Nothing here may throw into the
// caller's artifact processing: callers wrap these calls, and every send path
// records its own errors on the delivery document.

const crypto = require('crypto')
const dns = require('dns')

const { buildWebhookHeaders } = require('./signing')
const { validateWebhookUrl, validateWebhookUrlForSend, safeLookup } = require('./url-validation')
const { postJson } = require('./http-post')
const { deliveryIdFor, deliverableArtifacts, buildPayload, contentTypeFor } = require('./payload')
const { nextDeliveryState, truncateError, STATUS_PENDING, STATUS_FAILED } = require('./retry')

const DELIVERIES = 'external-integration-deliveries'
const SECRETS = 'external-integration-secrets'
const INTEGRATIONS = 'external-integrations'
const ENDPOINTS = 'external-integration-endpoints'
const EVENT_SETTINGS = 'external-integration-settings'

const TASK_FUNCTION_NAME = 'externalIntegrationDeliveryTask'
const MODERATOR_STATUSES = ['owner', 'admin', 'moderator', 'mod']

// A run id is 8 random bytes in hex. The task endpoint rejects anything else.
const newRunId = () => crypto.randomBytes(8).toString('hex')
const RUN_ID_PATTERN = /^[a-f0-9]{16}$/

// How long after a lease expires a task that found the delivery in flight
// runs again.
const LEASE_GRACE_MS = 5000

function toDate(value) {
    if (value == null) return null
    if (value instanceof Date) return value
    if (typeof value.toDate === 'function') return value.toDate()
    return new Date(value)
}

function nonRetryable(message) {
    return { ok: false, retryable: false, error: message }
}

/**
 * @param deps.firestore   firebase-admin Firestore
 * @param deps.bucket      Cloud Storage bucket holding the artifacts
 * @param deps.config      parsed external integrations config
 * @param deps.enqueueFunctionCall  Cloud Tasks scheduler (see cloud-tasks.js)
 * @param deps.postImpl   HTTP POST implementation (see http-post.js)
 * @param deps.lookup      DNS lookup override for the early URL check (tests)
 * @param deps.connectLookup  DNS lookup used for the connection itself
 *                         (default safeLookup; tests)
 * @param deps.now         clock
 */
function createDeliveryService({
    firestore,
    bucket,
    config,
    enqueueFunctionCall,
    postImpl = postJson,
    lookup,
    connectLookup = safeLookup,
    now = () => new Date(),
    logger = console,
}) {
    const integrationsRef = (communityId) =>
        firestore.collection(`community/${communityId}/${INTEGRATIONS}`)

    async function findEventDoc(communityId, eventId) {
        const snapshot = await firestore.collectionGroup('events').where('id', '==', eventId).get()
        const prefix = `community/${communityId}/`
        return snapshot.docs.find((doc) => doc.ref.path.startsWith(prefix)) || null
    }

    async function activeIntegrations(communityId) {
        const snapshot = await integrationsRef(communityId).where('isActive', '==', true).get()
        return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }))
    }

    /**
     * Creates delivery documents for every deliverable artifact of a stopped
     * recording session and sends the new ones. Existing deliveries (same
     * stable id) are left alone, except one that was created but never sent
     * (for example because the function stopped before sending): it is sent
     * now with its existing run, so calling this again is safe and also
     * recovers such deliveries. The claim in attemptDelivery makes sure a
     * delivery is only sent once even if two calls recover it together.
     *
     * Returns the ids of deliveries created by this call.
     */
    async function queueSessionDeliveries({ sessionId, session }) {
        if (!session || !session.communityId || !session.eventId) return []
        const artifacts = deliverableArtifacts(session.artifactPaths)
        if (artifacts.length === 0) return []

        // Cheap exit: most communities have no integration configured.
        const integrations = await activeIntegrations(session.communityId)
        if (integrations.length === 0) return []

        const eventDoc = await findEventDoc(session.communityId, session.eventId)
        if (!eventDoc) {
            logger.warn(
                `External integrations: event ${session.eventId} not found for session ${sessionId}`
            )
            return []
        }
        const eventPath = eventDoc.ref.path

        const created = []
        const recovered = []
        try {
            await createDeliveries({
                session,
                sessionId,
                eventPath,
                integrations,
                artifacts,
                created,
                recovered,
            })
        } finally {
            // Send whatever was created or recovered, even if a later create failed.
            await Promise.all(
                [...created, ...recovered].map(({ id, runId }) =>
                    attemptDelivery({ deliveryId: id, runId, runAttempt: 1 }).catch((err) =>
                        logger.error(
                            `External integrations: attempt for ${id} failed unexpectedly`,
                            err
                        )
                    )
                )
            )
        }
        return created.map(({ id }) => id)
    }

    // True for a delivery that was created but whose current run never made
    // an attempt and is not being attempted right now.
    function isUndispatched(data, at) {
        if (!data || data.status !== STATUS_PENDING) return false
        if ((data.runAttempts || 0) !== 0) return false
        if (typeof data.runId !== 'string' || !RUN_ID_PATTERN.test(data.runId)) return false
        const inFlightUntil = toDate(data.inFlightUntil)
        return !(inFlightUntil && inFlightUntil > at)
    }

    async function createDeliveries({
        session,
        sessionId,
        eventPath,
        integrations,
        artifacts,
        created,
        recovered,
    }) {
        for (const integration of integrations) {
            const settingsDoc = await firestore
                .doc(`${eventPath}/${EVENT_SETTINGS}/${integration.id}`)
                .get()
            if (!settingsDoc.exists || settingsDoc.data().enabled !== true) continue

            const subscribed = new Set(integration.events || [])
            for (const artifact of artifacts) {
                if (!subscribed.has(artifact.eventType)) continue
                const id = deliveryIdFor({
                    integrationId: integration.id,
                    eventType: artifact.eventType,
                    artifactPath: artifact.path,
                })
                const timestamp = now()
                const runId = newRunId()
                const ref = firestore.doc(`${DELIVERIES}/${id}`)
                try {
                    await ref.create({
                        id,
                        communityId: session.communityId,
                        eventId: session.eventId,
                        eventPath,
                        integrationId: integration.id,
                        eventType: artifact.eventType,
                        recordingSessionId: sessionId,
                        artifactKey: artifact.key,
                        artifactPath: artifact.path,
                        status: STATUS_PENDING,
                        attempts: 0,
                        runAttempts: 0,
                        runId,
                        lastError: null,
                        lastResponseStatus: null,
                        createdAt: timestamp,
                        updatedAt: timestamp,
                        lastAttemptAt: null,
                        nextAttemptAt: timestamp,
                        deliveredAt: null,
                        inFlightUntil: null,
                    })
                    created.push({ id, runId })
                } catch (err) {
                    // gRPC ALREADY_EXISTS: delivered or queued before.
                    if (!(err && (err.code === 6 || err.code === 'already-exists'))) throw err
                    const existing = await ref.get()
                    if (existing.exists && isUndispatched(existing.data(), timestamp)) {
                        recovered.push({ id, runId: existing.data().runId })
                    }
                }
            }
        }
    }

    /**
     * Claims and runs one attempt. `runId` and `runAttempt` must match the
     * delivery's current run, which makes stale or duplicated Cloud Tasks
     * no-ops.
     *
     * A claim sets a lease (`inFlightUntil`) that the final update clears. If
     * the function stops between the two, the lease stays behind and the
     * same attempt may be claimed again once it has expired. A task that
     * finds the delivery in flight is scheduled again for just after the
     * lease, once (`afterLease`), so such an attempt is not lost.
     */
    async function attemptDelivery({ deliveryId, runId, runAttempt, afterLease = false }) {
        const ref = firestore.doc(`${DELIVERIES}/${deliveryId}`)
        const claimedAt = now()
        const claim = await firestore.runTransaction(async (tx) => {
            const snapshot = await tx.get(ref)
            if (!snapshot.exists) return { skipped: 'missing' }
            const data = snapshot.data()
            if (data.status !== STATUS_PENDING) return { skipped: 'not-pending' }
            if (data.runId !== runId) return { skipped: 'stale-run' }
            const runAttempts = data.runAttempts || 0
            const inFlightUntil = toDate(data.inFlightUntil)
            // This attempt was claimed but never recorded its result.
            const unfinished = runAttempts === runAttempt && inFlightUntil != null
            if (runAttempts !== runAttempt - 1 && !unfinished) return { skipped: 'stale-attempt' }
            if (inFlightUntil && inFlightUntil > claimedAt) {
                return { skipped: 'in-flight', inFlightUntil }
            }

            const attempts = (data.attempts || 0) + 1
            tx.update(ref, {
                attempts,
                runAttempts: runAttempt,
                lastAttemptAt: claimedAt,
                updatedAt: claimedAt,
                inFlightUntil: new Date(claimedAt.getTime() + config.requestTimeoutMs + 60000),
            })
            return { delivery: { ...data, attempts, runAttempts: runAttempt } }
        })
        if (claim.skipped === 'in-flight') {
            return waitForLease({ deliveryId, runId, runAttempt, afterLease }, claim.inFlightUntil)
        }
        if (claim.skipped) return claim

        const delivery = claim.delivery
        let outcome
        try {
            outcome = await sendDelivery(delivery)
        } catch (err) {
            outcome = {
                ok: false,
                retryable: err && err.retryable === false ? false : true,
                error: err instanceof Error ? err.message : String(err),
            }
        }

        const finishedAt = now()
        const state = nextDeliveryState({ runAttempt, outcome, now: finishedAt })
        const update = {
            status: state.status,
            lastError: state.lastError,
            lastResponseStatus: state.lastResponseStatus,
            nextAttemptAt: state.nextAttemptAt,
            updatedAt: finishedAt,
            inFlightUntil: null,
        }
        if (state.delivered) update.deliveredAt = finishedAt

        if (state.status === STATUS_PENDING) {
            try {
                await enqueueFunctionCall({
                    functionName: TASK_FUNCTION_NAME,
                    payload: { deliveryId, runId: delivery.runId, runAttempt: runAttempt + 1 },
                    scheduleTime: state.nextAttemptAt,
                })
            } catch (err) {
                update.status = STATUS_FAILED
                update.nextAttemptAt = null
                update.lastError = truncateError(
                    `${state.lastError} (retry could not be scheduled: ${err && err.message})`
                )
            }
        }

        await ref.update(update)
        return { status: update.status, outcome }
    }

    // Schedules the same task again for just after the lease. A task that
    // already waited once gives up instead, so this cannot loop: by then the
    // attempt was claimed again by someone else, who owns it.
    async function waitForLease({ deliveryId, runId, runAttempt, afterLease }, inFlightUntil) {
        if (afterLease) {
            logger.error(
                `External integrations: ${deliveryId} attempt ${runAttempt} is still in flight after its lease; dropping this task`
            )
            return { skipped: 'in-flight' }
        }
        await enqueueFunctionCall({
            functionName: TASK_FUNCTION_NAME,
            payload: { deliveryId, runId, runAttempt, afterLease: true },
            scheduleTime: new Date(inFlightUntil.getTime() + LEASE_GRACE_MS),
        })
        return { skipped: 'in-flight', requeued: true }
    }

    async function sendDelivery(delivery) {
        const { communityId, integrationId, eventType } = delivery

        const integrationDoc = await firestore
            .doc(`community/${communityId}/${INTEGRATIONS}/${integrationId}`)
            .get()
        if (!integrationDoc.exists || integrationDoc.data().isActive !== true) {
            return nonRetryable('Integration is turned off or was removed')
        }
        if (!(integrationDoc.data().events || []).includes(eventType)) {
            return nonRetryable(`Integration no longer receives ${eventType}`)
        }

        const settingsDoc = await firestore
            .doc(`${delivery.eventPath}/${EVENT_SETTINGS}/${integrationId}`)
            .get()
        if (!settingsDoc.exists || settingsDoc.data().enabled !== true) {
            return nonRetryable('Integration is turned off for this event')
        }

        const [endpointDoc, secretDoc] = await Promise.all([
            firestore.doc(`community/${communityId}/${ENDPOINTS}/${integrationId}`).get(),
            firestore.doc(`${SECRETS}/${integrationId}`).get(),
        ])
        if (!endpointDoc.exists || !secretDoc.exists || !secretDoc.data().secret) {
            return nonRetryable('Integration is missing its webhook URL or secret')
        }

        const url = await validateWebhookUrlForSend(endpointDoc.data().webhookUrl, {
            allowedDomains: config.allowedDomains,
            allowLocalTargets: config.allowLocalTargets === true,
            lookup,
        })

        const file = bucket.file(delivery.artifactPath)
        const [exists] = await file.exists()
        if (!exists) return nonRetryable('Artifact file no longer exists')
        const [metadata] = await file.getMetadata()
        const sentAt = now()
        const expiresAt = new Date(sentAt.getTime() + config.signedUrlTtlSeconds * 1000)
        const fileName = delivery.artifactPath.split('/').pop()
        const [downloadUrl] = await file.getSignedUrl({
            action: 'read',
            expires: expiresAt.getTime(),
            responseDisposition: `attachment; filename="${fileName}"`,
        })

        const [eventDoc, sessionDoc] = await Promise.all([
            firestore.doc(delivery.eventPath).get(),
            delivery.recordingSessionId
                ? firestore.doc(`recording-sessions/${delivery.recordingSessionId}`).get()
                : Promise.resolve(null),
        ])

        const size = Number(metadata && metadata.size)
        const payload = buildPayload({
            delivery,
            attempt: delivery.attempts,
            sentAt,
            event: eventDoc.exists ? eventDoc.data() : null,
            session: sessionDoc && sessionDoc.exists ? sessionDoc.data() : null,
            externalReference: settingsDoc.data().externalReference,
            artifact: {
                key: delivery.artifactKey,
                path: delivery.artifactPath,
                sizeBytes: Number.isFinite(size) ? size : null,
                contentType: (metadata && metadata.contentType) || contentTypeFor(fileName),
                downloadUrl,
                downloadUrlExpiresAt: expiresAt,
            },
        })
        const body = JSON.stringify(payload)
        const headers = buildWebhookHeaders({
            secret: secretDoc.data().secret,
            body,
            eventType,
            deliveryId: delivery.id,
            attempt: delivery.attempts,
            now: sentAt.getTime(),
        })

        // Local receivers (emulator only) may use http and loopback addresses.
        // Every other URL connects through connectLookup, which refuses
        // private addresses again at connect time.
        const local =
            config.allowLocalTargets === true &&
            validateWebhookUrl(url, { allowLocalTargets: true }).local === true

        let response
        try {
            response = await postImpl(url, {
                headers,
                body,
                timeoutMs: config.requestTimeoutMs,
                lookup: local ? dns.lookup : connectLookup,
                allowHttp: local,
            })
        } catch (err) {
            const outcome = { ok: false, error: `Request failed: ${err && err.message}` }
            if (err && err.retryable === false) outcome.retryable = false
            return outcome
        }

        if (response.status >= 200 && response.status < 300) {
            return { ok: true, status: response.status }
        }
        const text = (response.bodySnippet || '').slice(0, 200)
        return {
            ok: false,
            status: response.status,
            error: `HTTP ${response.status}${text ? `: ${text}` : ''}`,
        }
    }

    async function canResend({ uid, delivery }) {
        const membership = await firestore
            .doc(`memberships/${uid}/community-membership/${delivery.communityId}`)
            .get()
        if (membership.exists && MODERATOR_STATUSES.includes(membership.data().status)) return true
        if (delivery.eventPath) {
            const event = await firestore.doc(delivery.eventPath).get()
            if (event.exists && event.data().creatorId === uid) return true
        }
        return false
    }

    /**
     * Starts a new run for a delivery (manual resend). A fresh signed URL is
     * created because each attempt builds its own payload.
     */
    async function resendDelivery({ deliveryId, uid }) {
        const ref = firestore.doc(`${DELIVERIES}/${deliveryId}`)
        const snapshot = await ref.get()
        if (!snapshot.exists) return { error: 'not-found' }
        const delivery = snapshot.data()
        if (!(await canResend({ uid, delivery }))) return { error: 'permission-denied' }

        const runId = newRunId()
        const startedAt = now()
        const started = await firestore.runTransaction(async (tx) => {
            const latest = await tx.get(ref)
            const data = latest.data()
            const inFlightUntil = toDate(data.inFlightUntil)
            if (inFlightUntil && inFlightUntil > startedAt) return false
            tx.update(ref, {
                status: STATUS_PENDING,
                runId,
                runAttempts: 0,
                nextAttemptAt: startedAt,
                updatedAt: startedAt,
            })
            return true
        })
        if (!started) return { error: 'in-flight' }

        const result = await attemptDelivery({ deliveryId, runId, runAttempt: 1 })
        return { status: result.status }
    }

    return {
        queueSessionDeliveries,
        attemptDelivery,
        resendDelivery,
        sendDelivery,
    }
}

module.exports = {
    DELIVERIES,
    SECRETS,
    INTEGRATIONS,
    ENDPOINTS,
    EVENT_SETTINGS,
    TASK_FUNCTION_NAME,
    RUN_ID_PATTERN,
    LEASE_GRACE_MS,
    createDeliveryService,
}
