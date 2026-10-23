const functions = require('firebase-functions')
const admin = require('firebase-admin')
const cors = require('cors')({ origin: true })

const firestore = admin.firestore()
const storage = admin.storage()
const bucketName = functions.config().agora.storage_bucket_name

const signedUrlExpiration = 15 * 60 * 1000

const eventPathRegex = /^community\/[^\/]+\/templates\/[^\/]+\/events\/[^\/]+$/

// Returns one signed URL per recording-session's merged transcript CSV
// (complete_trx_<n>, written by produce-sessions.js)
const downloadTranscripts = functions.https.onRequest((req, res) => {
    cors(req, res, async () => {
        try {
            const authToken = req.headers.authorization?.split('Bearer ')[1]
            if (!authToken) {
                res.status(401).json({ error: 'Unauthorized' })
                return
            }

            const decodedToken = await admin.auth().verifyIdToken(authToken)
            const uid = decodedToken.uid

            const { eventPath } = req.body
            if (!eventPath) {
                res.status(400).json({ error: 'eventPath not found' })
                return
            }
            if (!eventPathRegex.test(eventPath)) {
                res.status(400).json({ error: 'Invalid eventPath format' })
                return
            }

            const eventDoc = await firestore.doc(eventPath).get()
            if (!eventDoc.exists) {
                res.status(404).json({ error: 'event not found' })
                return
            }
            const event = { id: eventDoc.id, ...eventDoc.data() }

            const membershipPath = `memberships/${uid}/community-membership/${event.communityId}`
            const membershipDoc = await firestore.doc(membershipPath).get()
            if (!membershipDoc.exists) {
                res.status(403).json({ error: 'membership not found' })
                return
            }
            const membership = membershipDoc.data()

            if (!['owner', 'admin'].includes(membership.status)) {
                res.status(403).json({ error: 'Unauthorized' })
                return
            }

            const sessionsSnap = await firestore
                .collection('recording-sessions')
                .where('eventId', '==', event.id)
                .where('communityId', '==', event.communityId)
                .where('status', '==', 'stopped')
                .get()

            if (sessionsSnap.empty) {
                res.status(200).json({ transcripts: [] })
                return
            }

            const bucket = storage.bucket(bucketName)
            const transcripts = []

            for (const sessionDoc of sessionsSnap.docs) {
                const session = sessionDoc.data()
                const artifactPaths = session.artifactPaths || {}
                const roomId = session.roomId || 'unknown'
                const roomType = session.roomType || 'main'

                const trxPaths = Object.entries(artifactPaths)
                    .filter(([key]) => key.startsWith('complete_trx_'))
                    .map(([, path]) => path)

                for (const trxPath of trxPaths) {
                    try {
                        const filename = trxPath.split('/').pop() || `${roomId}.csv`
                        const [url] = await bucket.file(trxPath).getSignedUrl({
                            action: 'read',
                            expires: Date.now() + signedUrlExpiration,
                            responseDisposition: `attachment; filename="${filename}"`,
                        })
                        transcripts.push({ roomId, roomType, url })
                    } catch (fileErr) {
                        console.error(`Error signing transcript ${trxPath}:`, fileErr)
                    }
                }
            }

            res.status(200).json({ transcripts })
        } catch (err) {
            console.error('Error generating transcript URLs:', err)
            res.status(500).json({ error: 'Failed to generate transcript URLs' })
        }
    })
})

module.exports = downloadTranscripts
