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

const MP4_KEY = 'complete_mp4_'
const VTT_KEY = 'transcript_vtt_'
const TRX_KEY = 'complete_trx_0'

// Registered artifactPaths values for a key prefix.
function registeredPaths(session, keyPrefix) {
    return Object.entries(session.artifactPaths || {})
        .filter(([k]) => k.startsWith(keyPrefix))
        .map(([, v]) => v)
}

// GCS files not registered, and registered paths no longer in GCS.
function artifactDiff(session, keyPrefix, files) {
    const registered = new Set(registeredPaths(session, keyPrefix))
    const names = new Set(files.map((f) => f.name))
    return {
        unregistered: files.filter((f) => !registered.has(f.name)).map((f) => f.name),
        missing: [...registered].filter((p) => !names.has(p)),
    }
}

const sameSet = (diff) => diff.unregistered.length === 0 && diff.missing.length === 0

// Re-list with backoff until an MP4 appears.
async function listUntilMp4({
    listFiles,
    initialFiles,
    delaysMs = MP4_RETRY_DELAYS_MS,
    sleep = defaultSleep,
}) {
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

// Write indexed keys; delete stale higher indexes when deleteField is given.
async function registerIndexed(ref, keyPrefix, files, { session, deleteField } = {}) {
    if (files.length === 0) return
    const updates = {}
    files.forEach((f, i) => {
        updates[`artifactPaths.${keyPrefix}${i}`] = f.name
    })
    if (session && deleteField) {
        for (const k of Object.keys(session.artifactPaths || {})) {
            const idx = Number(k.slice(keyPrefix.length))
            if (k.startsWith(keyPrefix) && idx >= files.length) {
                updates[`artifactPaths.${k}`] = deleteField
            }
        }
    }
    await ref.update(updates)
}

const registerMp4s = (ref, mp4Files, opts) => registerIndexed(ref, MP4_KEY, mp4Files, opts)
const registerVtts = (ref, vttFiles, opts) => registerIndexed(ref, VTT_KEY, vttFiles, opts)

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

// Merge VTTs to one CSV (header-only if none), register as complete_trx_0.
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
    const mergedCsv = mergeCsvContents(csvFragments) || `${cuesToCsv([], {})}\n`

    const mp4Name = mp4Files[0]?.name
    const outPath = mp4Name
        ? mp4Name.replace(/\.mp4$/i, '.csv')
        : `${session.gcsPrefix}/transcript_0.csv`

    await bucket.file(outPath).save(mergedCsv, { contentType: 'text/csv' })
    await ref.update({
        [`artifactPaths.${TRX_KEY}`]: outPath,
        mergedVtts: vttFiles.map((f) => f.name),
    })
    return outPath
}

// True if the CSV is missing or was built from a different VTT set.
// Legacy sessions fall back to registered VTTs as the merge source.
function transcriptStale(session, vttFiles) {
    if (!session.artifactPaths?.[TRX_KEY]) return true
    const sources = new Set(session.mergedVtts ?? registeredPaths(session, VTT_KEY))
    return sources.size !== vttFiles.length || vttFiles.some((f) => !sources.has(f.name))
}

const stoppedLongEnough = (session, now = Date.now()) => {
    const stoppedMs = session.stoppedAt?.toMillis?.()
    return stoppedMs != null && now - stoppedMs >= TRX_SETTLE_MS
}

// Bring artifactPaths and the CSV in line with what is in GCS.
async function reconcileArtifacts({
    bucket,
    firestore,
    ref,
    session,
    deleteField,
    now = Date.now(),
}) {
    const allFiles = await listSessionFiles(bucket, session.gcsPrefix)
    const mp4Files = mp4sOf(allFiles)
    const vttFiles = vttsOf(allFiles)
    const mp4Diff = artifactDiff(session, MP4_KEY, mp4Files)
    const vttDiff = artifactDiff(session, VTT_KEY, vttFiles)

    let mp4s = 0
    let vtts = 0
    let rewrote = false
    let merged = false

    // Never wipe registered keys because a listing came back empty.
    if (mp4Files.length > 0 && !sameSet(mp4Diff)) {
        await registerMp4s(ref, mp4Files, { session, deleteField })
        mp4s = mp4Diff.unregistered.length
        rewrote = true
    }
    if (vttFiles.length > 0 && !sameSet(vttDiff)) {
        await registerVtts(ref, vttFiles, { session, deleteField })
        vtts = vttDiff.unregistered.length
        rewrote = true
    }

    // Zero VTTs get a header-only CSV once late ones are unlikely.
    const trxPath = session.artifactPaths?.[TRX_KEY]
    const hasTrx = Boolean(trxPath && allFiles.some((f) => f.name === trxPath))
    const trxSettled = session.agoraRttAgentId != null && stoppedLongEnough(session, now)
    const needsMerge =
        vttFiles.length > 0 ? !hasTrx || transcriptStale(session, vttFiles) : !hasTrx && trxSettled
    if (needsMerge) {
        await mergeTranscript({ bucket, firestore, ref, session, vttFiles, mp4Files })
        merged = true
    }

    return {
        repaired: rewrote || merged,
        mp4s,
        vtts,
        merged,
        mp4Total: mp4Files.length,
        vttTotal: vttFiles.length,
    }
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
    MP4_KEY,
    VTT_KEY,
    TRX_KEY,
    registeredPaths,
    artifactDiff,
    sameSet,
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
    transcriptStale,
    reconcileArtifacts,
}
