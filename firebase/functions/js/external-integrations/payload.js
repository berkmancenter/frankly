// Webhook payload (schema version 1) and delivery identity for external
// integrations. The payload never contains file contents, only metadata and
// a short-lived signed download URL.

const crypto = require('crypto')

const SCHEMA_VERSION = 1

const EVENT_RECORDING_READY = 'recording.ready'
const EVENT_TRANSCRIPT_READY = 'transcript.ready'
const SUPPORTED_EVENT_TYPES = [EVENT_RECORDING_READY, EVENT_TRANSCRIPT_READY]

// Recording session artifact keys (see session-artifacts.js) that produce a
// webhook. Raw per-speaker VTT fragments are not sent; the merged transcript
// is.
const ARTIFACT_RULES = [
    { prefix: 'complete_mp4_', eventType: EVENT_RECORDING_READY, kind: 'recording' },
    { prefix: 'complete_trx_', eventType: EVENT_TRANSCRIPT_READY, kind: 'transcript' },
]

const CONTENT_TYPES = {
    '.mp4': 'video/mp4',
    '.csv': 'text/csv',
    '.vtt': 'text/vtt',
    '.json': 'application/json',
}

/**
 * Stable delivery id. Derived from the integration, the event type and the
 * artifact's storage path (its file name), never from its position in a
 * list, so retries and resends of the same artifact share one id.
 */
function deliveryIdFor({ integrationId, eventType, artifactPath }) {
    if (!integrationId || !eventType || !artifactPath) {
        throw new Error('integrationId, eventType and artifactPath are required')
    }
    const digest = crypto
        .createHash('sha256')
        .update(`${integrationId}\n${eventType}\n${artifactPath}`, 'utf8')
        .digest('hex')
    return `dlv_${digest.slice(0, 40)}`
}

/** Lists artifacts on a recording session that can be delivered. */
function deliverableArtifacts(artifactPaths) {
    const result = []
    for (const [key, path] of Object.entries(artifactPaths || {})) {
        if (typeof path !== 'string' || path === '') continue
        const rule = ARTIFACT_RULES.find((r) => key.startsWith(r.prefix))
        if (!rule) continue
        result.push({ key, path, eventType: rule.eventType, kind: rule.kind })
    }
    return result.sort((a, b) => a.path.localeCompare(b.path))
}

function artifactKindForKey(key) {
    const rule = ARTIFACT_RULES.find((r) => key && key.startsWith(r.prefix))
    return rule ? rule.kind : 'file'
}

function contentTypeFor(fileName) {
    const lower = String(fileName || '').toLowerCase()
    const ext = Object.keys(CONTENT_TYPES).find((e) => lower.endsWith(e))
    return ext ? CONTENT_TYPES[ext] : 'application/octet-stream'
}

function toIso(value) {
    if (value == null) return null
    if (value instanceof Date) return value.toISOString()
    if (typeof value.toDate === 'function') return value.toDate().toISOString()
    if (typeof value === 'string') return value
    if (typeof value === 'number') return new Date(value).toISOString()
    return null
}

function stringOrNull(value) {
    return typeof value === 'string' && value !== '' ? value : null
}

/**
 * Builds the JSON payload for one delivery attempt.
 *
 * `artifact` is `{ key, path, sizeBytes, contentType, downloadUrl,
 * downloadUrlExpiresAt }`.
 */
function buildPayload({ delivery, attempt, sentAt, event, session, externalReference, artifact }) {
    const fileName = artifact.path.split('/').pop()
    return {
        schemaVersion: SCHEMA_VERSION,
        deliveryId: delivery.id,
        type: delivery.eventType,
        createdAt: toIso(delivery.createdAt) || toIso(sentAt),
        sentAt: toIso(sentAt),
        attempt,
        integration: { id: delivery.integrationId },
        community: { id: delivery.communityId },
        event: {
            id: delivery.eventId,
            templateId: stringOrNull(event && event.templateId),
            title: stringOrNull(event && event.title),
            scheduledTime: toIso(event && event.scheduledTime),
        },
        recordingSession: {
            id: delivery.recordingSessionId,
            roomType: stringOrNull(session && session.roomType),
            roomId: stringOrNull(session && session.roomId),
            breakoutSessionId: stringOrNull(session && session.breakoutSessionId),
            startedAt: toIso(session && session.startedAt),
            stoppedAt: toIso(session && session.stoppedAt),
        },
        externalReference: stringOrNull(externalReference),
        artifact: {
            key: artifact.key,
            kind: artifactKindForKey(artifact.key),
            fileName,
            contentType: artifact.contentType || contentTypeFor(fileName),
            sizeBytes: Number.isFinite(artifact.sizeBytes) ? artifact.sizeBytes : null,
            downloadUrl: artifact.downloadUrl,
            downloadUrlExpiresAt: toIso(artifact.downloadUrlExpiresAt),
        },
    }
}

module.exports = {
    SCHEMA_VERSION,
    EVENT_RECORDING_READY,
    EVENT_TRANSCRIPT_READY,
    SUPPORTED_EVENT_TYPES,
    deliveryIdFor,
    deliverableArtifacts,
    artifactKindForKey,
    contentTypeFor,
    buildPayload,
    toIso,
}
