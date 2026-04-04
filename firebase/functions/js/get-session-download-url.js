const functions = require('firebase-functions')
const admin = require('firebase-admin')
const { Storage } = require('@google-cloud/storage')
const cors = require('cors')({ origin: true })

const firestore = admin.firestore()
const storage = new Storage()
const bucketName = functions.config().agora.storage_bucket_name

// Signed URLs expire after 15 minutes
const signedUrlExpiration = 15 * 60 * 1000

const getSessionDownloadUrl = functions.https.onRequest((req, res) => {
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
            if (!sessionId || typeof sessionId !== 'string' || sessionId.trim() === '') {
                res.status(400).json({ error: 'sessionId is required' })
                return
            }

            const sessionDoc = await firestore
                .collection('recording-sessions')
                .doc(sessionId)
                .get()
            if (!sessionDoc.exists) {
                res.status(404).json({ error: 'Session not found' })
                return
            }
            const session = sessionDoc.data()

            // Verify the caller is an admin/owner of the session's community.
            const membershipPath = `memberships/${uid}/community-membership/${session.communityId}`
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

            const artifactPaths = session.artifactPaths ?? {}
            if (Object.keys(artifactPaths).length === 0) {
                res.status(200).json({ urls: {} })
                return
            }

            const bucket = storage.bucket(bucketName)
            const urlEntries = await Promise.all(
                Object.entries(artifactPaths).map(async ([key, gcsPath]) => {
                    const file = bucket.file(gcsPath)
                    const filename = gcsPath.split('/').pop()
                    const [url] = await file.getSignedUrl({
                        action: 'read',
                        expires: Date.now() + signedUrlExpiration,
                        responseDisposition: `attachment; filename="${filename}"`,
                    })
                    return [key, url]
                })
            )

            const urls = Object.fromEntries(urlEntries)
            res.status(200).json({ urls })
        } catch (err) {
            console.error('Error generating session download URLs:', err)
            res.status(500).json({ error: 'Failed to generate session download URLs' })
        }
    })
})

module.exports = getSessionDownloadUrl
