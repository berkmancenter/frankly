const functions = require('firebase-functions')
const admin = require('firebase-admin')
const cors = require('cors')({ origin: true })
const path = require('path')
const fs = require('fs/promises')
const { Buffer } = require('buffer')
const confirmAuthorization = require('./utils/authorize-event')
const requestRunPod = require('./utils/runpod-client')
const generateRecordingURLForTranscription = require('./download-recordings')[1]
// ^ See caveat in main._register_js_functions()

const bucketName = functions.config().agora.storage_bucket_name
const bucket = admin.storage().bucket(bucketName)
const tempFolder = '/tmp/temp-event-transcriptions'
const timeout = 540 // Max seconds for Firebase v1 functions


const OnRecordingProduced = functions.runWith({ timeoutSeconds: timeout }).storage.bucket(bucketName)
    .object().onFinalize(async (object) => {
        if (!object.name.endsWith('complete_recording.mp4'))
            return

        const eventId = path.dirname(object.name).replace('/', '')
        console.log(`Recording assembly complete for event ${eventId}. Transcribing the recording.`)
        await _transcribeRecording(eventId)
    })

const TranscribeRecording = functions.runWith({ timeoutSeconds: timeout }).https.onRequest((req, res) => {
    cors(req, res, async () => {
        const event = await confirmAuthorization(req, res)
        await _transcribeRecording(event.id)
        res.status(200).send('OK')
    })
})

const _transcribeRecording = async (eventId) => {
    const recordingURL = await generateRecordingURLForTranscription(eventId)
    const requestInput = {
        input: {
            audio: recordingURL,
            model: 'turbo',
        }
    }

    console.log(`Transcribing recording URL: ${recordingURL}.`)
    const response = await requestRunPod(requestInput)
    if (!response.succeeded) {
        console.log(`Unable to complete transcriptions for event ${eventId}.`)
        console.log(`Final status for RunPod request ${response.id}: ${response.status}.`)
        return
    }

    const filename = `${eventId}_transcription.txt`
    await _uploadTranscription(eventId, response.output.transcription, filename)
}

const _uploadTranscription = async (eventId, transcription, filename) => {
    // Recycle the static temp folder (see the note produce-recordings._downloadRecordingFiles)
    await fs.rm(tempFolder, { recursive: true, force: true })
    await fs.mkdir(tempFolder)

    const transcriptionData = new Uint8Array(Buffer.from(transcription));
    const transcriptionOutputPath = `${tempFolder}/${filename}`
    await fs.writeFile(transcriptionOutputPath, transcriptionData);

    // Upload the transcription back to the GCS folder for the event
    const finalTranscriptionDestination = `${eventId}/${filename}`
    console.log(`Uploading transcription to GCS at ${bucket.name}/${finalTranscriptionDestination}.`)
    await bucket.upload(transcriptionOutputPath, { destination: finalTranscriptionDestination })
    console.log('Transcription upload complete.')
}

// See caveat in main._register_js_functions()
module.exports = [TranscribeRecording, OnRecordingProduced]
