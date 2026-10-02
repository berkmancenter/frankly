const functions = require('firebase-functions')
const admin = require('firebase-admin')

const {
    VTT_FLUSH_WAIT_MS,
    listSessionFiles,
    listUntilMp4,
    mp4sOf,
    vttsOf,
    registerMp4s,
    registerVtts,
    mergeTranscript,
    reconcileArtifacts,
} = require('./session-artifacts')

const firestore = admin.firestore()
const storage = admin.storage()
const bucketName = functions.config().agora.storage_bucket_name

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms))

// On stop, register MP4/VTT artifacts and merge the transcript.
const produceSessions = functions
    .runWith({ timeoutSeconds: 300 })
    .firestore.document('recording-sessions/{sessionId}')
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
        const ref = change.after.ref
        const listFiles = () => listSessionFiles(bucket, gcsPrefix)

        let allFiles
        try {
            allFiles = await listFiles()
        } catch (err) {
            console.error(`Error listing files for session ${sessionId}:`, err)
            return null
        }

        // --- Register MP4 ---
        // MP4 upload can lag the stop. Retry only if recording ran.
        let waitedMs = 0
        let finalMp4Files = []
        try {
            const hadRecording = after.agoraResourceId != null || after.agoraSid != null
            if (hadRecording && mp4sOf(allFiles).length === 0) {
                const result = await listUntilMp4({ listFiles, initialFiles: allFiles })
                allFiles = result.files
                waitedMs = result.waitedMs
            }

            finalMp4Files = mp4sOf(allFiles)
            if (finalMp4Files.length === 0) {
                console.warn(
                    `No MP4 found under ${gcsPrefix}/ for session ${sessionId} after waiting ${waitedMs}ms`
                )
            } else {
                await registerMp4s(ref, finalMp4Files)
                console.log(
                    `Registered ${
                        finalMp4Files.length
                    } MP4(s) for session ${sessionId} after ${waitedMs}ms: ${finalMp4Files
                        .map((f) => f.name)
                        .join(', ')}`
                )
            }
        } catch (err) {
            console.error(`Error registering MP4 for session ${sessionId}:`, err)
        }

        // --- Register VTT transcript files ---
        let finalVttFiles = []
        let vttListOk = true
        const hasSTT = after.agoraRttAgentId != null
        try {
            let vttFiles = vttsOf(allFiles)

            // Wait for STT flush; MP4 wait counts toward it.
            if (vttFiles.length === 0 && hasSTT) {
                const remainingMs = Math.max(0, VTT_FLUSH_WAIT_MS - waitedMs)
                if (remainingMs > 0) {
                    console.log(
                        `No VTT files yet for STT-enabled session ${sessionId}, waiting ${remainingMs}ms for agent flush...`
                    )
                    await sleep(remainingMs)
                }
                try {
                    allFiles = await listFiles()
                } catch (err) {
                    vttListOk = false
                    throw err
                }
                vttFiles = vttsOf(allFiles)
            }

            finalVttFiles = vttFiles
            if (vttFiles.length === 0) {
                console.log(`No VTT files found under ${gcsPrefix}/ for session ${sessionId}`)
            } else {
                await registerVtts(ref, vttFiles)
                console.log(
                    `Registered ${vttFiles.length} VTT file(s) for session ${sessionId}: ${vttFiles
                        .map((f) => f.name)
                        .join(', ')}`
                )
            }
        } catch (err) {
            console.error(`Error registering VTT for session ${sessionId}:`, err)
        }

        // --- Merge VTT fragments into one CSV transcript (header-only if none) ---
        try {
            if (finalVttFiles.length > 0 || (hasSTT && vttListOk)) {
                const outPath = await mergeTranscript({
                    bucket,
                    firestore,
                    ref,
                    session: after,
                    vttFiles: finalVttFiles,
                    mp4Files: finalMp4Files,
                })
                console.log(`Registered merged transcript for session ${sessionId}: ${outPath}`)
            }
        } catch (err) {
            console.error(`Error merging transcript for session ${sessionId}:`, err)
        }

        // --- Late pass: pick up fragments that landed after the first merge ---
        if (hasSTT || finalMp4Files.length > 0) {
            try {
                await sleep(VTT_FLUSH_WAIT_MS)
                const fresh = (await ref.get()).data()
                const result = await reconcileArtifacts({
                    bucket,
                    firestore,
                    ref,
                    session: fresh,
                    deleteField: admin.firestore.FieldValue.delete(),
                })
                if (result.repaired) {
                    console.log(
                        `Late reconcile for session ${sessionId}: ${JSON.stringify(result)}`
                    )
                }
            } catch (err) {
                console.error(`Error in late reconcile for session ${sessionId}:`, err)
            }
        }

        return null
    })

module.exports = produceSessions
