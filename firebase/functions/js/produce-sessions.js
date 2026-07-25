const functions = require('firebase-functions')
const admin = require('firebase-admin')

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
        try {
            const mp4Files = allFiles.filter((f) => f.name.endsWith('.mp4'))

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
        try {
            const vttFiles = allFiles.filter((f) => f.name.endsWith('.vtt'))

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

        return null
    })

module.exports = produceSessions
