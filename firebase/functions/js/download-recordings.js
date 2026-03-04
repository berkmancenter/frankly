const functions = require('firebase-functions')
const admin = require('firebase-admin')
const { Storage } = require('@google-cloud/storage')
const cors = require('cors')({ origin: true })

const firestore = admin.firestore()

const storage = new Storage()
const bucketName = functions.config().agora.storage_bucket_name

// Signed URLs expire after 15 minutes (milliseconds)
const signedUrlExpiration = 15 * 60 * 1000

// Expected path shape: community/{id}/templates/{id}/events/{id}
const eventPathRegex = /^community\/[^\/]+\/templates\/[^\/]+\/events\/[^\/]+$/

const downloadRecording = functions.https.onRequest((req, res) => {
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

            const bucket = storage.bucket(bucketName)
            const [files] = await bucket.getFiles({ prefix: `${event.id}/` })
            const mp4Files = files
                .filter((file) => file.name.endsWith('.mp4'))
                .sort((a, b) => a.name.localeCompare(b.name))

            if (mp4Files.length === 0) {
                res.status(404).json({ error: 'No recordings found' })
                return
            }

            // Generate a signed URL for each MP4. The client downloads directly
            // from GCS without blocking the function.
            const urls = await Promise.all(
                mp4Files.map(async (file) => {
                    const [url] = await file.getSignedUrl({
                        action: 'read',
                        expires: Date.now() + signedUrlExpiration,
                    })
                    return { name: file.name, url }
                })
            )

            res.status(200).json({ recordings: urls })
        } catch (err) {
            console.error('Error generating recording URLs:', err)
            res.status(500).json({ error: 'Failed to generate recording URLs' })
        }
    })
})

module.exports = downloadRecording
