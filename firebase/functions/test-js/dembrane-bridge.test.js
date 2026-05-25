const assert = require('assert')

const { notifyDembraneBridge } = require('../js/dembrane-bridge')

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
})
