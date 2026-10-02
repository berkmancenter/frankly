const test = require('node:test')
const assert = require('node:assert/strict')

const {
    MP4_RETRY_DELAYS_MS,
    sanitizePrefix,
    listSessionFiles,
    listUntilMp4,
    registerMp4s,
    registerVtts,
    mergeTranscript,
    TRX_SETTLE_MS,
    transcriptState,
    registeredPaths,
    artifactDiff,
    sameSet,
} = require('./session-artifacts')

const file = (name) => ({ name })

function fakeRef() {
    const updates = []
    return { updates, update: async (u) => updates.push(u) }
}

function fakeBucket(contents = {}, listings = {}) {
    const saved = {}
    return {
        saved,
        getFiles: async ({ prefix }) => [listings[prefix] || []],
        file: (path) => ({
            download: async () => [Buffer.from(contents[path] || '')],
            save: async (data) => {
                saved[path] = data
            },
        }),
    }
}

const fakeFirestore = (names = {}) => ({
    doc: (path) => ({
        get: async () => {
            const id = path.split('/')[1]
            return { exists: id in names, data: () => ({ displayName: names[id] }) }
        },
    }),
})

test('sanitizePrefix strips non-alphanumerics per segment', () => {
    assert.equal(sanitizePrefix('a-b/c_d/e'), 'ab/cd/e')
})

test('listSessionFiles merges raw and sanitized prefixes', async () => {
    const bucket = fakeBucket({}, { 'a-b/': [file('a-b/x.mp4')], 'ab/': [file('ab/x.vtt')] })
    const files = await listSessionFiles(bucket, 'a-b')
    assert.deepEqual(
        files.map((f) => f.name),
        ['a-b/x.mp4', 'ab/x.vtt']
    )
})

test('listSessionFiles lists once when prefix is already clean', async () => {
    let calls = 0
    const bucket = { getFiles: async () => (calls++, [[]]) }
    await listSessionFiles(bucket, 'abc')
    assert.equal(calls, 1)
})

test('listUntilMp4 does not wait when MP4 already present', async () => {
    const sleeps = []
    const result = await listUntilMp4({
        initialFiles: [file('p/a.mp4')],
        listFiles: async () => assert.fail('should not relist'),
        sleep: async (ms) => sleeps.push(ms),
    })
    assert.deepEqual(sleeps, [])
    assert.equal(result.waitedMs, 0)
})

test('listUntilMp4 stops as soon as MP4 appears', async () => {
    const sleeps = []
    const listings = [[], [file('p/a.mp4')]]
    const result = await listUntilMp4({
        initialFiles: [],
        listFiles: async () => listings.shift(),
        sleep: async (ms) => sleeps.push(ms),
    })
    assert.deepEqual(sleeps, MP4_RETRY_DELAYS_MS.slice(0, 2))
    assert.equal(result.waitedMs, 15000)
    assert.equal(result.files[0].name, 'p/a.mp4')
})

test('listUntilMp4 gives up after all delays', async () => {
    const sleeps = []
    const result = await listUntilMp4({
        initialFiles: [file('p/a.vtt')],
        listFiles: async () => [file('p/a.vtt')],
        sleep: async (ms) => sleeps.push(ms),
    })
    assert.deepEqual(sleeps, MP4_RETRY_DELAYS_MS)
    assert.equal(result.waitedMs, 65000)
    assert.equal(result.files.length, 1)
})

test('registerMp4s and registerVtts write indexed keys, skip empty', async () => {
    const ref = fakeRef()
    await registerMp4s(ref, [])
    await registerVtts(ref, [])
    assert.equal(ref.updates.length, 0)

    await registerMp4s(ref, [file('a.mp4'), file('b.mp4')])
    await registerVtts(ref, [file('a.vtt')])
    assert.deepEqual(ref.updates, [
        { 'artifactPaths.complete_mp4_0': 'a.mp4', 'artifactPaths.complete_mp4_1': 'b.mp4' },
        { 'artifactPaths.transcript_vtt_0': 'a.vtt' },
    ])
})

const vtt = (start, text) => `WEBVTT\n\n${start} --> 00:00:02.000\n${text}\n`

test('mergeTranscript orders fragments, drops locale dupes, maps speakers', async () => {
    const bsid = 'aBreakoutSessionId20'
    const early = `p/evt-${bsid}_r_s_20260101000000000.vtt`
    const late = `p/evt-${bsid}_r_s_20260101000100000.vtt`
    const dupe = `p/evt-en-US_${bsid}_r_s_20260101000000000.vtt`
    const bucket = fakeBucket({
        [early]: vtt('00:00:00.000', '<v 1>hello'),
        [late]: vtt('00:01:00.000', '<v 2>bye'),
        [dupe]: vtt('00:00:00.000', '<v 1>hello'),
    })
    const ref = fakeRef()

    const outPath = await mergeTranscript({
        bucket,
        firestore: fakeFirestore({ u1: 'Ann' }),
        ref,
        session: { gcsPrefix: 'p', uidToDisplayName: { 1: 'u1', 2: 'u2' } },
        vttFiles: [file(late), file(dupe), file(early)],
        mp4Files: [file('p/rec.mp4')],
    })

    assert.equal(outPath, 'p/rec.csv')
    assert.deepEqual(ref.updates, [{ 'artifactPaths.complete_trx_0': 'p/rec.csv' }])
    assert.equal(
        bucket.saved['p/rec.csv'],
        'Start,End,Speaker,Speaker ID,Text\n' +
            '00:00:00.000,00:00:02.000,"Ann","1","hello"\n' +
            '00:01:00.000,00:00:02.000,"u2","2","bye"\n'
    )
})

test('mergeTranscript falls back to gcsPrefix path without MP4', async () => {
    const bucket = fakeBucket({ 'p/a.vtt': vtt('00:00:00.000', 'hi') })
    const outPath = await mergeTranscript({
        bucket,
        firestore: fakeFirestore(),
        ref: fakeRef(),
        session: { gcsPrefix: 'p' },
        vttFiles: [file('p/a.vtt')],
        mp4Files: [],
    })
    assert.equal(outPath, 'p/transcript_0.csv')
})

test('transcriptState settles to none only after the settle window', () => {
    const now = 1_000_000
    const stoppedAt = (ms) => ({ toMillis: () => ms })
    const agent = { agoraRttAgentId: 'a' }
    assert.equal(transcriptState({ session: agent, hasTrx: true, now }), 'ready')
    assert.equal(transcriptState({ session: {}, hasTrx: false, now }), 'none')
    assert.equal(transcriptState({ session: agent, hasTrx: false, now }), 'pending')
    assert.equal(
        transcriptState({
            session: { ...agent, stoppedAt: stoppedAt(now - 1000) },
            hasTrx: false,
            now,
        }),
        'pending'
    )
    assert.equal(
        transcriptState({
            session: { ...agent, stoppedAt: stoppedAt(now - TRX_SETTLE_MS) },
            hasTrx: false,
            now,
        }),
        'none'
    )
})

test('mergeTranscript writes a header-only CSV when there are no VTTs', async () => {
    const bucket = fakeBucket()
    const ref = fakeRef()
    const outPath = await mergeTranscript({
        bucket,
        firestore: fakeFirestore({}),
        ref,
        session: { gcsPrefix: 'p' },
        vttFiles: [],
        mp4Files: [file('p/rec.mp4')],
    })
    assert.equal(outPath, 'p/rec.csv')
    assert.equal(bucket.saved['p/rec.csv'], 'Start,End,Speaker,Speaker ID,Text\n')
    assert.deepEqual(ref.updates, [{ 'artifactPaths.complete_trx_0': 'p/rec.csv' }])
})

test('registeredPaths filters by key prefix', () => {
    const session = {
        artifactPaths: {
            complete_mp4_0: 'a.mp4',
            transcript_vtt_0: 'a.vtt',
            complete_trx_0: 'a.csv',
        },
    }
    assert.deepEqual(registeredPaths(session, 'complete_mp4_'), ['a.mp4'])
    assert.deepEqual(registeredPaths({}, 'complete_mp4_'), [])
})

test('artifactDiff finds unregistered and missing paths', () => {
    const session = { artifactPaths: { complete_mp4_0: 'a.mp4', complete_mp4_1: 'gone.mp4' } }
    const diff = artifactDiff(session, 'complete_mp4_', [file('a.mp4'), file('b.mp4')])
    assert.deepEqual(diff, { unregistered: ['b.mp4'], missing: ['gone.mp4'] })
    assert.equal(sameSet(diff), false)
    assert.equal(
        sameSet(artifactDiff(session, 'complete_mp4_', [file('a.mp4'), file('gone.mp4')])),
        true
    )
})
