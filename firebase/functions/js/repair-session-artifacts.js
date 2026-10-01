const functions = require('firebase-functions')
const admin = require('firebase-admin')
const cors = require('cors')({ origin: true })

const {
    listSessionFiles,
    mp4sOf,
    vttsOf,
    registerMp4s,
    registerVtts,
    mergeTranscript,
    stoppedLongEnough,
    transcriptState,
} = require('./session-artifacts')

const firestore = admin.firestore()
const storage = admin.storage()
const bucketName = functions.config().agora.storage_bucket_name

// Idempotently fills in artifacts produceSessions missed. Called by the client.
const repairSessionArtifacts = functions.https.onRequest((req, res) => {
    cors(req, res, async () => {
        try {
            const authToken = req.headers.authorization?.split('Bearer ')[1]
            if (!authToken) {
                res.status(401).json({ error: 'Unauthorized' })
                return
            }

            const decodedToken = await admin.auth().verifyIdToken(authToken)
            const uid = decodedToken.uid

            const { sessionId } = req.body
            if (!sessionId || typeof sessionId !== 'string') {
                res.status(400).json({ error: 'sessionId is required' })
                return
            }

            const sessionDoc = await firestore.collection('recording-sessions').doc(sessionId).get()
            if (!sessionDoc.exists) {
                res.status(404).json({ error: 'Session not found' })
                return
            }
            const session = sessionDoc.data()

            // Verify caller is admin/owner of the session's community.
            const membershipPath = `memberships/${uid}/community-membership/${session.communityId}`
            const membershipDoc = await firestore.doc(membershipPath).get()
            if (!membershipDoc.exists) {
                res.status(403).json({ error: 'Membership not found' })
                return
            }
            if (!['owner', 'admin'].includes(membershipDoc.data().status)) {
                res.status(403).json({ error: 'Unauthorized' })
                return
            }

            const gcsPrefix = session.gcsPrefix
            if (!gcsPrefix) {
                res.status(200).json({ repaired: false, reason: 'No gcsPrefix on session', transcript: 'none' })
                return
            }

            const keys = Object.keys(session.artifactPaths || {})
            const hasMp4 = keys.some((k) => k.startsWith('complete_mp4_'))
            const hasVtt = keys.some((k) => k.startsWith('transcript_vtt_'))
            const hasTrx = keys.includes('complete_trx_0')
            if (hasMp4 && hasVtt && hasTrx) {
                res.status(200).json({ repaired: false, reason: 'Nothing to repair', transcript: 'ready' })
                return
            }

            const bucket = storage.bucket(bucketName)
            const allFiles = await listSessionFiles(bucket, gcsPrefix)
            const mp4Files = mp4sOf(allFiles)
            const vttFiles = vttsOf(allFiles)

            let mp4s = 0
            let vtts = 0
            let merged = false

            if (!hasMp4 && mp4Files.length > 0) {
                await registerMp4s(sessionDoc.ref, mp4Files)
                mp4s = mp4Files.length
            }
            if (!hasVtt && vttFiles.length > 0) {
                await registerVtts(sessionDoc.ref, vttFiles)
                vtts = vttFiles.length
            }
            // Zero VTTs get a header-only CSV once late ones are unlikely.
            const trxSettled =
                session.agoraRttAgentId != null && stoppedLongEnough(session)
            if (!hasTrx && (vttFiles.length > 0 || trxSettled)) {
                await mergeTranscript({
                    bucket,
                    firestore,
                    ref: sessionDoc.ref,
                    session,
                    vttFiles,
                    mp4Files,
                })
                merged = true
            }

            const repaired = mp4s > 0 || vtts > 0 || merged
            if (repaired) {
                console.log(
                    `Repaired session ${sessionId}: mp4s=${mp4s} vtts=${vtts} merged=${merged}`
                )
            }

            const transcript = transcriptState({ session, hasTrx: hasTrx || merged })
            res.status(200).json({ repaired, mp4s, vtts, merged, transcript })
        } catch (err) {
            console.error('Error repairing session artifacts:', err)
            res.status(500).json({ error: 'Failed to repair session artifacts' })
        }
    })
})

module.exports = repairSessionArtifacts
