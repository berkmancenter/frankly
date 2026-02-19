const functions = require('firebase-functions')
const { Storage } = require('@google-cloud/storage')
const cors = require('cors')({ origin: true })
const authorizeEvent = require('./utils/authorize-event')
const { HttpsError } = require('firebase-functions/lib/providers/auth')

const storage = new Storage()
const bucket = storage.bucket(functions.config().agora.storage_bucket_name)
const urlForDownloadExpiration = 24 * 60 * 60 * 1000 // 24 Hours
const urlForTranscriptionExpiration = 60 * 60 * 1000 // 1 Hour
const signedDownloadURLsEnabled = functions.config().app.signedDownloadURLs


const GenerateRecordingURL = functions.https.onRequest((req, res) => {
    cors(req, res, async () => {
<<<<<<< Updated upstream
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
=======
        const event = await authorizeEvent(req, res)
        const url = await _generateRecordingURL(event.id, urlForDownloadExpiration)
        res.status(200).json({ 'url': url })
>>>>>>> Stashed changes
    })
})

const generateRecordingURLForTranscription = async (eventId) => {
    return await _generateRecordingURL(eventId, urlForTranscriptionExpiration)
}

const _generateRecordingURL = async (eventId, expiration) => {
    const recordingPath = `${eventId}/${eventId}_complete_recording.mp4`

    console.log(`Ensure the complete event recording exists at ${bucket.name}/${recordingPath}.`)
    const recordingFile = bucket.file(recordingPath)
    const [recordingFileExists] = await recordingFile.exists()
    if (!recordingFileExists) {
        throw new HttpsError('failed-precondition', 'Recording not found')
    }

    // Firebase emulators don't implement the getSignedUrl() endpoint unfortunately, so for local
    // development purposes this allows you to disable signed URLs and use a public URL for the
    // requested file instead
    console.log(`Generating a download URL for ${bucket.name}/${recordingPath}.`)
    let url
    if (signedDownloadURLsEnabled) {
        [url] = await recordingFile.getSignedUrl({
            action: 'read',
            expires: Date.now() + expiration
        })
    } else {
        url = recordingFile.publicUrl()
    }

    console.log(`Download URL for the event recording: ${url}`)
    return url
}

// See caveat in main._register_js_functions()
module.exports = [GenerateRecordingURL, generateRecordingURLForTranscription]
