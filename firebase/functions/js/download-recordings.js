const functions = require('firebase-functions')
const admin = require('firebase-admin')
const { Storage } = require('@google-cloud/storage')
const archiver = require('archiver')
const cors = require('cors')({ origin: true })

const firestore = admin.firestore()

const storage = new Storage()
const bucketName = functions.config().agora.storage_bucket_name

const downloadRecording = functions.runWith({ timeoutSeconds: 300 }).https.onRequest((req, res) => {
    cors(req, res, async () => {
        // Determine if the user has access to this
        const authToken = req.headers.authorization?.split('Bearer ')[1]
        if (!authToken) {
            throw new functions.https.HttpsError('failed-precondition', 'Unauthorized')
        }

        // Verify the Firebase Auth token and get the UID
        const decodedToken = await admin.auth().verifyIdToken(authToken)
        const uid = decodedToken.uid

        // Extract the eventPath from the request body
        const { eventPath } = req.body
        if (!eventPath) {
            throw new functions.https.HttpsError('failed-precondition', 'eventPath not found')
            return
        }

        // Fetch the event object
        const eventDoc = await firestore.doc(eventPath).get()
        if (!eventDoc.exists) {
            throw new functions.https.HttpsError('failed-precondition', 'event not found')
        }
        const event = { id: eventDoc.id, ...eventDoc.data() }

        // Fetch the membership document
        const membershipPath = `memberships/${uid}/community-membership/${event.communityId}`
        const membershipDoc = await firestore.doc(membershipPath).get()
        if (!membershipDoc.exists) {
            throw new functions.https.HttpsError('failed-precondition', 'membership not found')
        }
        const membership = membershipDoc.data()

        // Check if the user is an admin
        if (!['owner', 'admin'].includes(membership.status)) {
            throw new functions.https.HttpsError('failed-precondition', 'Unauthorized')
        }

        // List all files in the bucket
        try {
            const bucket = storage.bucket(bucketName)
            const archive = archiver('zip', {
                zlib: { level: 9 }, // Compression level
            })

            res.setHeader('Content-Type', 'application/zip')
            res.setHeader('Content-Disposition', 'attachment; filename="files.zip"')

            archive.on('error', (err) => {
                console.error('Error creating zip file:', err)
            })

            // Pipe the archive's output to the response
            archive.pipe(res)

            const [files] = await bucket.getFiles({ prefix: `${event.id}/` })
            files
                .filter((file) => file.name.endsWith('.mp4'))
                .forEach((file) => {
                    console.log(`Processing file ${file.name}`)
                    const fileStream = file.createReadStream()
                    archive.append(fileStream, { name: file.name })
                })

            await archive.finalize()
        } catch (err) {
            console.error('Error creating zip file:', err)
            res.status(500).send('Error creating zip file.')
        }
    })
})

module.exports = downloadRecording
