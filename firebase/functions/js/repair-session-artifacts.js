const functions = require('firebase-functions')
const admin = require('firebase-admin')
const cors = require('cors')({ origin: true })

const { reconcileArtifacts, transcriptState } = require('./session-artifacts')

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
                res.status(200).json({
                    repaired: false,
                    reason: 'No gcsPrefix on session',
                    transcript: 'none',
                })
                return
            }

            const result = await reconcileArtifacts({
                bucket: storage.bucket(bucketName),
                firestore,
                ref: sessionDoc.ref,
                session,
                deleteField: admin.firestore.FieldValue.delete(),
            })
            const { repaired, mp4s, vtts, merged, mp4Total, vttTotal } = result
            if (repaired) {
                console.log(
                    `Repaired session ${sessionId}: new mp4s=${mp4s}/${mp4Total} new vtts=${vtts}/${vttTotal} merged=${merged}`
                )
            }

            const hasTrx = Boolean(session.artifactPaths?.complete_trx_0) || merged
            const transcript = transcriptState({ session, hasTrx })
            res.status(200).json({ ...result, transcript })
        } catch (err) {
            console.error('Error repairing session artifacts:', err)
            res.status(500).json({ error: 'Failed to repair session artifacts' })
        }
    })
})

module.exports = repairSessionArtifacts
