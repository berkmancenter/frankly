// Session artifact helpers shared by produceSessions and repairSessionArtifacts.

const crypto = require('crypto')

const {
    splitLocaleAndDefault,
    findDuplicateCandidates,
    isContentDuplicate,
    buildMergeOrder,
    mergeCsvContents,
    parseVtt,
    cuesToCsv,
} = require('./transcript-merge')

// 65s total.
const MP4_RETRY_DELAYS_MS = [5000, 10000, 20000, 30000]
const VTT_FLUSH_WAIT_MS = 15000
// Wait this long after stop before treating zero VTTs as final.
const TRX_SETTLE_MS = 60000

const defaultSleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms))

// Agora STT strips non-alphanumerics from prefix segments.
function sanitizePrefix(gcsPrefix) {
    return gcsPrefix
        .split('/')
        .map((s) => s.replace(/[^a-zA-Z0-9]/g, ''))
        .join('/')
}

// Raw plus sanitized prefix.
async function listSessionFiles(bucket, gcsPrefix) {
    const [files] = await bucket.getFiles({ prefix: `${gcsPrefix}/` })
    const sanitizedPrefix = sanitizePrefix(gcsPrefix)
    if (sanitizedPrefix === gcsPrefix) return files
    const [extraFiles] = await bucket.getFiles({ prefix: `${sanitizedPrefix}/` })
    return [...files, ...extraFiles]
}

const mp4sOf = (files) => files.filter((f) => f.name.endsWith('.mp4'))
const vttsOf = (files) => files.filter((f) => f.name.endsWith('.vtt'))

// Re-list with backoff until an MP4 appears.
async function listUntilMp4({ listFiles, initialFiles, delaysMs = MP4_RETRY_DELAYS_MS, sleep = defaultSleep }) {
    let files = initialFiles
    let waitedMs = 0
    for (const delay of delaysMs) {
        if (mp4sOf(files).length > 0) break
        await sleep(delay)
        waitedMs += delay
        files = await listFiles()
    }
    return { files, waitedMs }
}

async function registerMp4s(ref, mp4Files) {
    if (mp4Files.length === 0) return
    const updates = {}
    mp4Files.forEach((f, i) => {
        updates[`artifactPaths.complete_mp4_${i}`] = f.name
    })
    await ref.update(updates)
}

async function registerVtts(ref, vttFiles) {
    if (vttFiles.length === 0) return
    const updates = {}
    vttFiles.forEach((f, i) => {
        updates[`artifactPaths.transcript_vtt_${i}`] = f.name
    })
    await ref.update(updates)
}

async function resolveUidMap(firestore, rawUidMap) {
    const uidEntries = Object.entries(rawUidMap || {})
    const resolvedNames = await Promise.all(
        uidEntries.map(async ([, userId]) => {
            try {
                const userDoc = await firestore.doc(`publicUser/${userId}`).get()
                return userDoc.exists ? userDoc.data().displayName : null
            } catch (_) {
                return null
            }
        })
    )
    const uidMap = {}
    uidEntries.forEach(([agoraUid, userId], i) => {
        uidMap[agoraUid] = resolvedNames[i] || userId
    })
    return uidMap
}

// Merge VTTs to one CSV, register as complete_trx_0.
async function mergeTranscript({ bucket, firestore, ref, session, vttFiles, mp4Files }) {
    const entries = vttFiles.map((f) => ({ key: f.name, path: f.name }))
    const { localeEntries, defaultEntries } = splitLocaleAndDefault(entries)
    const candidates = findDuplicateCandidates(localeEntries, defaultEntries)

    const keysToDrop = new Set()
    for (const { localeEntry, defaultEntry } of candidates) {
        const [localeBuf] = await bucket.file(localeEntry.path).download()
        const [defaultBuf] = await bucket.file(defaultEntry.path).download()
        const localeHash = crypto.createHash('sha256').update(localeBuf).digest('hex')
        const defaultHash = crypto.createHash('sha256').update(defaultBuf).digest('hex')
        if (isContentDuplicate(localeHash, localeBuf.length, defaultHash, defaultBuf.length)) {
            keysToDrop.add(localeEntry.key)
        }
    }

    const mergeOrder = buildMergeOrder(entries, keysToDrop)
    const uidMap = await resolveUidMap(firestore, session.uidToDisplayName)

    const csvFragments = await Promise.all(
        mergeOrder.map(async (entry) => {
            const [buf] = await bucket.file(entry.path).download()
            return cuesToCsv(parseVtt(buf.toString('utf-8')), uidMap)
        })
    )
    const mergedCsv = mergeCsvContents(csvFragments)

    const mp4Name = mp4Files[0]?.name
    const outPath = mp4Name
        ? mp4Name.replace(/\.mp4$/i, '.csv')
        : `${session.gcsPrefix}/transcript_0.csv`

    await bucket.file(outPath).save(mergedCsv, { contentType: 'text/csv' })
    await ref.update({ 'artifactPaths.complete_trx_0': outPath })
    return outPath
}

const stoppedLongEnough = (session, now = Date.now()) => {
    const stoppedMs = session.stoppedAt?.toMillis?.()
    return stoppedMs != null && now - stoppedMs >= TRX_SETTLE_MS
}

// Transcript state for the client: 'ready' | 'pending' | 'none'.
function transcriptState({ session, hasTrx, now = Date.now() }) {
    if (hasTrx) return 'ready'
    if (session.agoraRttAgentId == null) return 'none'
    return stoppedLongEnough(session, now) ? 'none' : 'pending'
}

module.exports = {
    MP4_RETRY_DELAYS_MS,
    VTT_FLUSH_WAIT_MS,
    TRX_SETTLE_MS,
    stoppedLongEnough,
    transcriptState,
    sanitizePrefix,
    listSessionFiles,
    listUntilMp4,
    mp4sOf,
    vttsOf,
    registerMp4s,
    registerVtts,
    mergeTranscript,
}
