const functions = require('firebase-functions')
const admin = require('firebase-admin')
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

const firestore = admin.firestore()
const storage = admin.storage()
const bucketName = functions.config().agora.storage_bucket_name

// Triggered when a recording session transitions to 'stopped'.
// Locates artifacts Agora deposited under gcsPrefix (MP4 recordings, VTT
// transcripts) and registers their paths on the session document.
const produceSessions = functions.firestore
    .document('recording-sessions/{sessionId}')
    .onUpdate(async (change, context) => {
        const before = change.before.data()
        const after = change.after.data()

        if (before.status === after.status) return null
        if (after.status !== 'stopped') return null

        const sessionId = context.params.sessionId
        const gcsPrefix = after.gcsPrefix
        if (!gcsPrefix) {
            console.warn(`Session ${sessionId} has no gcsPrefix, skipping post-processing`)
            return null
        }

        const bucket = storage.bucket(bucketName)

        // List all files under the session prefix once.
        let allFiles
        try {
            const [files] = await bucket.getFiles({ prefix: `${gcsPrefix}/` })
            allFiles = files

            // STT strips non-alphanumeric chars from fileNamePrefix segments
            // (Agora rejects them in STT but not Cloud Recording). Check the
            // sanitized prefix too so VTT files are discovered.
            const sanitizedPrefix = gcsPrefix
                .split('/')
                .map((s) => s.replace(/[^a-zA-Z0-9]/g, ''))
                .join('/')
            if (sanitizedPrefix !== gcsPrefix) {
                const [extraFiles] = await bucket.getFiles({ prefix: `${sanitizedPrefix}/` })
                allFiles = [...allFiles, ...extraFiles]
            }
        } catch (err) {
            console.error(`Error listing files for session ${sessionId}:`, err)
            return null
        }

        // --- Register MP4 ---
        let finalMp4Files = []
        try {
            const mp4Files = allFiles.filter((f) => f.name.endsWith('.mp4'))
            finalMp4Files = mp4Files

            if (mp4Files.length === 0) {
                console.warn(`No MP4 found under ${gcsPrefix}/ for session ${sessionId}`)
            } else {
                console.log(
                    `Found ${
                        mp4Files.length
                    } MP4(s) under ${gcsPrefix}/ for session ${sessionId}: ${mp4Files
                        .map((f) => f.name)
                        .join(', ')}`
                )
                const updates = {}
                mp4Files.forEach((f, i) => {
                    updates[`artifactPaths.complete_mp4_${i}`] = f.name
                })
                await change.after.ref.update(updates)
                console.log(`Registered ${mp4Files.length} MP4(s) for session ${sessionId}`)
            }
        } catch (err) {
            console.error(`Error registering MP4 for session ${sessionId}:`, err)
        }

        // --- Register VTT transcript files ---
        let finalVttFiles = []
        try {
            let vttFiles = allFiles.filter((f) => f.name.endsWith('.vtt'))

            // If STT was enabled but VTTs aren't found yet, the agent may still
            // be flushing files to storage. Retry after a delay.
            const hasSTT = after.agoraRttAgentId != null
            if (vttFiles.length === 0 && hasSTT) {
                console.log(
                    `No VTT files yet for STT-enabled session ${sessionId}, waiting 15s for agent flush...`
                )
                await new Promise((resolve) => setTimeout(resolve, 15000))

                // Re-scan both paths
                const [retryFiles] = await bucket.getFiles({ prefix: `${gcsPrefix}/` })
                let retryAll = retryFiles
                const sanitizedRetry = gcsPrefix
                    .split('/')
                    .map((s) => s.replace(/[^a-zA-Z0-9]/g, ''))
                    .join('/')
                if (sanitizedRetry !== gcsPrefix) {
                    const [extraRetry] = await bucket.getFiles({ prefix: `${sanitizedRetry}/` })
                    retryAll = [...retryAll, ...extraRetry]
                }
                vttFiles = retryAll.filter((f) => f.name.endsWith('.vtt'))
            }

            finalVttFiles = vttFiles

            if (vttFiles.length === 0) {
                console.log(`No VTT files found under ${gcsPrefix}/ for session ${sessionId}`)
            } else {
                console.log(
                    `Found ${vttFiles.length} VTT file(s) for session ${sessionId}: ${vttFiles
                        .map((f) => f.name)
                        .join(', ')}`
                )
                const updates = {}
                vttFiles.forEach((f, i) => {
                    updates[`artifactPaths.transcript_vtt_${i}`] = f.name
                })
                await change.after.ref.update(updates)
                console.log(`Registered ${vttFiles.length} VTT file(s) for session ${sessionId}`)
            }
        } catch (err) {
            console.error(`Error registering VTT for session ${sessionId}:`, err)
        }

        // --- Merge VTT fragments into one CSV transcript ---
        try {
            if (finalVttFiles.length > 0) {
                const entries = finalVttFiles.map((f) => ({ key: f.name, path: f.name }))
                const { localeEntries, defaultEntries } = splitLocaleAndDefault(entries)
                const candidates = findDuplicateCandidates(localeEntries, defaultEntries)

                const keysToDrop = new Set()
                for (const { localeEntry, defaultEntry } of candidates) {
                    const [localeBuf] = await bucket.file(localeEntry.path).download()
                    const [defaultBuf] = await bucket.file(defaultEntry.path).download()
                    const localeHash = crypto.createHash('sha256').update(localeBuf).digest('hex')
                    const defaultHash = crypto.createHash('sha256').update(defaultBuf).digest('hex')
                    if (
                        isContentDuplicate(
                            localeHash,
                            localeBuf.length,
                            defaultHash,
                            defaultBuf.length
                        )
                    ) {
                        keysToDrop.add(localeEntry.key)
                    }
                }

                const mergeOrder = buildMergeOrder(entries, keysToDrop)

                const rawUidMap = after.uidToDisplayName || {}
                const uidEntries = Object.entries(rawUidMap)
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

                const csvFragments = await Promise.all(
                    mergeOrder.map(async (entry) => {
                        const [buf] = await bucket.file(entry.path).download()
                        const cues = parseVtt(buf.toString('utf-8'))
                        return cuesToCsv(cues, uidMap)
                    })
                )
                const mergedCsv = mergeCsvContents(csvFragments)

                const mp4Name = finalMp4Files[0]?.name
                const outPath = mp4Name
                    ? mp4Name.replace(/\.mp4$/i, '.csv')
                    : `${gcsPrefix}/transcript_0.csv`

                await bucket.file(outPath).save(mergedCsv, { contentType: 'text/csv' })
                await change.after.ref.update({ 'artifactPaths.complete_trx_0': outPath })
                console.log(`Registered merged transcript for session ${sessionId}: ${outPath}`)
            }
        } catch (err) {
            console.error(`Error merging transcript for session ${sessionId}:`, err)
        }

        return null
    })

module.exports = produceSessions
