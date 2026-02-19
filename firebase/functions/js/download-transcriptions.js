const functions = require('firebase-functions')
const { Storage } = require('@google-cloud/storage')
const cors = require('cors')({ origin: true })
const authorizeEvent = require('./utils/authorize-event')
const { HttpsError } = require('firebase-functions/lib/providers/auth')

const storage = new Storage()
const bucket = storage.bucket(functions.config().agora.storage_bucket_name)
const urlForDownloadExpiration = 24 * 60 * 60 * 1000 // 24 Hours
const signedDownloadURLsEnabled = functions.config().app.signedDownloadURLs


const GenerateTranscriptionURL = functions.https.onRequest((req, res) => {
    cors(req, res, async () => {
        const event = await authorizeEvent(req, res)
        const url = await _generateTranscriptionURL(event.id, urlForDownloadExpiration)
        res.status(200).json({ 'url': url })
    })
})

const _generateTranscriptionURL = async (eventId, expiration) => {
    const transcriptionPath = `${eventId}/${eventId}_transcription.txt`

    console.log(`Ensure the event transcription exists at ${bucket.name}/${transcriptionPath}.`)
    const transcriptionFile = bucket.file(transcriptionPath)
    const [transcriptionFileExists] = await transcriptionFile.exists()
    if (!transcriptionFileExists) {
        throw new HttpsError('failed-precondition', 'Transcription not found')
    }

    // Firebase emulators don't implement the getSignedUrl() endpoint unfortunately, so for local
    // development purposes this allows you to disable signed URLs and use a public URL for the
    // requested file instead
    console.log(`Generating a download URL for ${bucket.name}/${transcriptionPath}.`)
    let url
    if (signedDownloadURLsEnabled) {
        [url] = await transcriptionFile.getSignedUrl({
            action: 'read',
            expires: date.now() + expiration
        })
    } else {
        url = transcriptionFile.publicUrl()
    }

    console.log(`Download URL for the event transcription: ${url}`)
    return url
}

module.exports = GenerateTranscriptionURL
