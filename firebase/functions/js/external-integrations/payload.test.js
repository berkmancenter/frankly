const test = require('node:test')
const assert = require('node:assert/strict')

const { deliveryIdFor, deliverableArtifacts, buildPayload, SCHEMA_VERSION } = require('./payload')

const base = {
    integrationId: 'int1',
    eventType: 'recording.ready',
    artifactPath: 'rec/event1/main/room1/session1/abc_0.mp4',
}

test('delivery id is stable for the same integration, event type and artifact', () => {
    assert.equal(deliveryIdFor(base), deliveryIdFor({ ...base }))
    assert.match(deliveryIdFor(base), /^dlv_[a-f0-9]{40}$/)
})

test('delivery id differs per integration, event type and artifact path', () => {
    const id = deliveryIdFor(base)
    assert.notEqual(deliveryIdFor({ ...base, integrationId: 'int2' }), id)
    assert.notEqual(deliveryIdFor({ ...base, eventType: 'transcript.ready' }), id)
    assert.notEqual(deliveryIdFor({ ...base, artifactPath: `${base.artifactPath}x` }), id)
})

test('delivery id does not depend on the artifact list position', () => {
    // Same file registered under a different index key keeps its id.
    const before = deliverableArtifacts({ complete_mp4_0: 'p/b.mp4', complete_mp4_1: 'p/c.mp4' })
    const after = deliverableArtifacts({
        complete_mp4_0: 'p/a.mp4',
        complete_mp4_1: 'p/b.mp4',
        complete_mp4_2: 'p/c.mp4',
    })
    const idOf = (artifacts, path) =>
        deliveryIdFor({
            integrationId: 'i',
            eventType: 'recording.ready',
            artifactPath: artifacts.find((a) => a.path === path).path,
        })
    assert.equal(idOf(before, 'p/b.mp4'), idOf(after, 'p/b.mp4'))
    assert.equal(idOf(before, 'p/c.mp4'), idOf(after, 'p/c.mp4'))
})

test('deliverableArtifacts maps recordings and merged transcripts only', () => {
    const artifacts = deliverableArtifacts({
        complete_mp4_0: 'p/s/a.mp4',
        transcript_vtt_0: 'p/s/a.vtt',
        complete_trx_0: 'p/s/a.csv',
        unrelated: 'p/s/x',
        complete_mp4_1: '',
    })
    assert.deepEqual(
        artifacts.map((a) => [a.key, a.eventType, a.kind]),
        [
            ['complete_trx_0', 'transcript.ready', 'transcript'],
            ['complete_mp4_0', 'recording.ready', 'recording'],
        ]
    )
})

test('payload has the documented shape and no file contents', () => {
    const delivery = {
        id: 'dlv_1',
        eventType: 'recording.ready',
        integrationId: 'int1',
        communityId: 'c1',
        eventId: 'e1',
        recordingSessionId: 's1',
        createdAt: new Date('2026-01-01T10:00:00Z'),
    }
    const payload = buildPayload({
        delivery,
        attempt: 2,
        sentAt: new Date('2026-01-01T10:05:00Z'),
        event: {
            templateId: 't1',
            title: 'Town hall',
            scheduledTime: new Date('2026-01-01T09:00:00Z'),
        },
        session: {
            roomType: 'breakout',
            roomId: 'r1',
            breakoutSessionId: 'b1',
            startedAt: new Date('2026-01-01T09:00:00Z'),
            stoppedAt: new Date('2026-01-01T09:55:00Z'),
        },
        externalReference: 'project-42',
        artifact: {
            key: 'complete_mp4_0',
            path: 'rec/e1/b1/r1/s1/file_0.mp4',
            sizeBytes: 1234,
            contentType: 'video/mp4',
            downloadUrl: 'https://storage.example/x',
            downloadUrlExpiresAt: new Date('2026-01-01T11:05:00Z'),
        },
    })

    assert.deepEqual(payload, {
        schemaVersion: SCHEMA_VERSION,
        deliveryId: 'dlv_1',
        type: 'recording.ready',
        createdAt: '2026-01-01T10:00:00.000Z',
        sentAt: '2026-01-01T10:05:00.000Z',
        attempt: 2,
        integration: { id: 'int1' },
        community: { id: 'c1' },
        event: {
            id: 'e1',
            templateId: 't1',
            title: 'Town hall',
            scheduledTime: '2026-01-01T09:00:00.000Z',
        },
        recordingSession: {
            id: 's1',
            roomType: 'breakout',
            roomId: 'r1',
            breakoutSessionId: 'b1',
            startedAt: '2026-01-01T09:00:00.000Z',
            stoppedAt: '2026-01-01T09:55:00.000Z',
        },
        externalReference: 'project-42',
        artifact: {
            key: 'complete_mp4_0',
            kind: 'recording',
            fileName: 'file_0.mp4',
            contentType: 'video/mp4',
            sizeBytes: 1234,
            downloadUrl: 'https://storage.example/x',
            downloadUrlExpiresAt: '2026-01-01T11:05:00.000Z',
        },
    })
})

test('payload fills nulls for missing optional data', () => {
    const payload = buildPayload({
        delivery: {
            id: 'd',
            eventType: 'transcript.ready',
            integrationId: 'i',
            communityId: 'c',
            eventId: 'e',
            recordingSessionId: 's',
        },
        attempt: 1,
        sentAt: new Date('2026-01-01T00:00:00Z'),
        event: null,
        session: null,
        externalReference: '',
        artifact: {
            key: 'complete_trx_0',
            path: 'a/b.csv',
            downloadUrl: 'u',
            downloadUrlExpiresAt: null,
        },
    })
    assert.equal(payload.externalReference, null)
    assert.equal(payload.event.title, null)
    assert.equal(payload.recordingSession.roomType, null)
    assert.equal(payload.artifact.contentType, 'text/csv')
    assert.equal(payload.artifact.sizeBytes, null)
    assert.equal(payload.createdAt, '2026-01-01T00:00:00.000Z')
})
