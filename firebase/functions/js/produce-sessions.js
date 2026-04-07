const functions = require('firebase-functions')
const admin = require('firebase-admin')
const { Storage } = require('@google-cloud/storage')

const firestore = admin.firestore()
const storage = new Storage()
const bucketName = functions.config().agora.storage_bucket_name

// Triggered when a recording session transitions to 'stopped'.
// Locates the MP4 Agora deposited under gcsPrefix, registers its path on the
// session document, then assembles any available transcript segments into a
// JSON file and registers that path too.
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

        // --- Register MP4 ---
        try {
            const [files] = await bucket.getFiles({ prefix: `${gcsPrefix}/` })
            const mp4Files = files.filter((f) => f.name.endsWith('.mp4'))

            if (mp4Files.length === 0) {
                console.warn(`No MP4 found under ${gcsPrefix}/ for session ${sessionId}`)
            } else {
                console.log(`Found ${mp4Files.length} MP4(s) under ${gcsPrefix}/ for session ${sessionId}: ${mp4Files.map((f) => f.name).join(', ')}`)
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

        // --- Export transcript ---
        try {
            const segmentsSnap = await change.after.ref
                .collection('transcript-segments')
                .orderBy('startMs')
                .get()

            if (segmentsSnap.empty) {
                console.log(`No transcript segments for session ${sessionId}, skipping export`)
                return null
            }

            const segments = segmentsSnap.docs.map((doc) => {
                const d = doc.data()
                return {
                    text: d.text,
                    startMs: d.startMs,
                    durationMs: d.durationMs,
                    speakerUid: d.speakerUid,
                    language: d.language,
                }
            })

            const transcriptPath = `${gcsPrefix}/transcript.json`
            await bucket.file(transcriptPath).save(JSON.stringify(segments), {
                contentType: 'application/json',
            })

            await change.after.ref.update({
                'artifactPaths.transcript_json': transcriptPath,
            })
            console.log(`Exported transcript to ${transcriptPath} for session ${sessionId}`)
        } catch (err) {
            console.error(`Error exporting transcript for session ${sessionId}:`, err)
        }

        return null
    })

module.exports = produceSessions
