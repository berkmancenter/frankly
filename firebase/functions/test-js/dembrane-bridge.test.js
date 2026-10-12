const assert = require('assert')

const {
    deleteDeliveredRecordings,
    notifyDembraneBridge,
} = require('../js/dembrane-bridge')

function createSessionRef(latestData) {
    const updates = []

    return {
        updates,
        async get() {
            return {
                data: () => latestData,
            }
        },
        async update(update) {
            updates.push(update)
        },
    }
}

function createFieldValue() {
    return {
        serverTimestamp: () => 'SERVER_TS',
        delete: () => 'DELETE',
    }
}

describe('dembrane-bridge', () => {
    it('does no work unless explicitly enabled', async () => {
        await notifyDembraneBridge({})
        await notifyDembraneBridge({ enabled: false })
        await notifyDembraneBridge({ enabled: 'true' })
    })

    it('sends the minimal Dembrane payload with bearer auth for linked sessions', async () => {
        const sessionRef = createSessionRef({
            dembraneProjectId: 'project-123',
        })
        const fetchCalls = []
        const mp4Files = [
            {
                name: 'recordings/session-1/complete.mp4',
                async getSignedUrl() {
                    return ['https://signed.example.com/complete.mp4']
                },
            },
        ]

        await notifyDembraneBridge({
            enabled: true,
            sessionRef,
            sessionId: 'session-1',
            sessionData: { dembraneProjectId: 'project-123' },
            mp4Files,
            bridgeUrl: 'https://bridge.example.com',
            bridgeToken: 'bridge-secret',
            fetchImpl: async (url, options) => {
                fetchCalls.push({ url, options })
                return {
                    ok: true,
                    async text() {
                        return ''
                    },
                }
            },
            fieldValue: createFieldValue(),
            signedUrlExpirationMs: 60000,
        })

        assert.strictEqual(fetchCalls.length, 1)
        assert.strictEqual(fetchCalls[0].url, 'https://bridge.example.com')
        assert.strictEqual(
            fetchCalls[0].options.headers.Authorization,
            'Bearer bridge-secret'
        )
        assert.deepStrictEqual(JSON.parse(fetchCalls[0].options.body), {
            agoraFileUrl: 'https://signed.example.com/complete.mp4',
            dembraneProjectId: 'project-123',
        })
        assert.ok(
            sessionRef.updates.some(
                (update) =>
                    update['dembraneBridge.sentArtifacts.complete_mp4_0.gcsPath'] ===
                    'recordings/session-1/complete.mp4'
            )
        )
    })

    it('skips bridge calls for sessions without a Dembrane link', async () => {
        const sessionRef = createSessionRef({})
        let fetchCalled = false

        await notifyDembraneBridge({
            enabled: true,
            sessionRef,
            sessionId: 'session-2',
            sessionData: {},
            mp4Files: [
                {
                    name: 'recordings/session-2/complete.mp4',
                    async getSignedUrl() {
                        return ['https://signed.example.com/skipped.mp4']
                    },
                },
            ],
            bridgeUrl: 'https://bridge.example.com',
            bridgeToken: 'bridge-secret',
            fetchImpl: async () => {
                fetchCalled = true
                return { ok: true, text: async () => '' }
            },
            fieldValue: createFieldValue(),
            signedUrlExpirationMs: 60000,
        })

        assert.strictEqual(fetchCalled, false)
        assert.deepStrictEqual(sessionRef.updates, [])
    })

    it('does not resend artifacts that were already forwarded', async () => {
        const sessionRef = createSessionRef({
            dembraneProjectId: 'project-123',
            dembraneBridge: {
                sentArtifacts: {
                    complete_mp4_0: {
                        sentAt: 'already-sent',
                    },
                },
            },
        })
        let fetchCalled = false

        await notifyDembraneBridge({
            enabled: true,
            sessionRef,
            sessionId: 'session-3',
            sessionData: { dembraneProjectId: 'project-123' },
            mp4Files: [
                {
                    name: 'recordings/session-3/complete.mp4',
                    async getSignedUrl() {
                        return ['https://signed.example.com/already-sent.mp4']
                    },
                },
            ],
            bridgeUrl: 'https://bridge.example.com',
            bridgeToken: 'bridge-secret',
            fetchImpl: async () => {
                fetchCalled = true
                return { ok: true, text: async () => '' }
            },
            fieldValue: createFieldValue(),
            signedUrlExpirationMs: 60000,
        })

        assert.strictEqual(fetchCalled, false)
        assert.deepStrictEqual(sessionRef.updates, [])
    })
    it('records missing configuration without sending a recording', async () => {
        const sessionRef = createSessionRef({ dembraneProjectId: 'project-123' })
        await assert.rejects(notifyDembraneBridge({
            enabled: true,
            sessionRef,
            sessionId: 'missing-config',
            sessionData: {},
            fieldValue: createFieldValue(),
        }), /Missing .*bridge_url.*bridge_token/)
        assert.match(sessionRef.updates[0]['dembraneBridge.lastError'], /Missing/)
    })

    it('records an HTTP failure without marking the artifact delivered', async () => {
        const sessionRef = createSessionRef({ dembraneProjectId: 'project-123' })
        await assert.rejects(notifyDembraneBridge({
            enabled: true,
            sessionRef,
            sessionId: 'failed-delivery',
            sessionData: {},
            mp4Files: [{ name: 'complete.mp4', getSignedUrl: async () => ['https://signed.example.com/file'] }],
            bridgeUrl: 'https://bridge.example.com',
            bridgeToken: 'test-token',
            fetchImpl: async (_url, options) => {
                assert.strictEqual(options.timeout, 450000)
                return { ok: false, status: 503, text: async () => 'unavailable' }
            },
            fieldValue: createFieldValue(),
            signedUrlExpirationMs: 60000,
        }), /503/)
        assert.strictEqual(sessionRef.updates.length, 1)
        assert.match(sessionRef.updates[0]['dembraneBridge.lastError'], /503/)
        assert.strictEqual(sessionRef.updates[0]['dembraneBridge.sentArtifacts.complete_mp4_0.sentAt'], undefined)
    })


    it('deletes recording media but keeps transcripts once delivered', async () => {
        const sessionRef = createSessionRef({
            artifactPaths: {
                complete_mp4_0: 'recordings/session-4/complete.mp4',
                transcript_vtt_0: 'recordings/session-4/transcript.vtt',
            },
        })
        const deleted = []
        const file = (name) => ({
            name,
            async delete() {
                deleted.push(name)
            },
        })
        const bucket = {
            async getFiles({ prefix }) {
                assert.strictEqual(prefix, 'recordings/session-4/')
                return [
                    [
                        file('recordings/session-4/complete.mp4'),
                        file('recordings/session-4/index.m3u8'),
                        file('recordings/session-4/segment_0.ts'),
                        file('recordings/session-4/transcript.vtt'),
                    ],
                ]
            },
        }

        await deleteDeliveredRecordings({
            enabled: true,
            bucket,
            gcsPrefix: 'recordings/session-4',
            sessionRef,
            sessionId: 'session-4',
            fieldValue: createFieldValue(),
        })

        assert.deepStrictEqual(deleted.sort(), [
            'recordings/session-4/complete.mp4',
            'recordings/session-4/index.m3u8',
            'recordings/session-4/segment_0.ts',
        ])
        const update = sessionRef.updates[0]
        assert.strictEqual(update['dembraneBridge.recordingsDeletedCount'], 3)
        assert.strictEqual(update['artifactPaths.complete_mp4_0'], 'DELETE')
        assert.strictEqual(update['artifactPaths.transcript_vtt_0'], undefined)
    })

    it('keeps recordings when deletion is not enabled', async () => {
        const bucket = {
            async getFiles() {
                throw new Error('should not list files')
            },
        }
        const deleted = await deleteDeliveredRecordings({
            bucket,
            gcsPrefix: 'recordings/session-5',
            sessionRef: createSessionRef({}),
            sessionId: 'session-5',
            fieldValue: createFieldValue(),
        })
        assert.deepStrictEqual(deleted, [])
    })

    it('reports delivery only when there were recordings to send', async () => {
        const sent = await notifyDembraneBridge({
            enabled: true,
            sessionRef: createSessionRef({ dembraneProjectId: 'project-123' }),
            sessionId: 'session-6',
            sessionData: { dembraneProjectId: 'project-123' },
            mp4Files: [],
            bridgeUrl: 'https://bridge.example.com',
            bridgeToken: 'bridge-secret',
            fetchImpl: async () => ({ ok: true, text: async () => '' }),
            fieldValue: createFieldValue(),
            signedUrlExpirationMs: 60000,
        })
        assert.strictEqual(sent, false)
    })
})
