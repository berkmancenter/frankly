const functions = require('firebase-functions')
const admin = require('firebase-admin')
const { HttpsError } = require('firebase-functions/lib/providers/auth')
const cors = require('cors')({ origin: true })
const path = require('path')
const fs = require('fs/promises')
const { spawn } = require('child_process');
const events = require('events')
const confirmAuthorization = require('./utils/authorize-event')

const bucketName = functions.config().agora.storage_bucket_name
const bucket = admin.storage().bucket(bucketName)
const tempFolder = '/tmp/temp-event-recordings'
const timeout = 540 // Max seconds for Firebase v1 functions


const OnRecordingComplete = functions.runWith({ timeoutSeconds: timeout }).storage.bucket(bucketName)
    .object().onFinalize(async (object) => {
        if (path.extname(object.name) !== '.mp4' || object.name.includes('complete_recording'))
            return

        const eventId = path.dirname(object.name).replace('/', '')
        console.log(`Recording complete for event ${eventId}.`)

        await _produceRecording(eventId)
    })

const ProduceRecording = functions.runWith({ timeoutSeconds: timeout }).https.onRequest((req, res) => {
    cors(req, res, async () => {
        const event = await confirmAuthorization(req, res)
        await _produceRecording(event.id)
        res.status(200).send('OK')
    })
})

const _produceRecording = async (eventId) => {
    // Download the event recordings into a local temp folder
    console.log(`Preparing to download recording files from GCS for event ${eventId}.`)
    const recordingFiles = await _downloadRecordingFiles(eventId)
    if (recordingFiles.length == 0) {
        console.log(`Unable to prepare a recording for event ${eventId}.`)
        throw new HttpsError('failed-precondition',
            `No recording files found at ${bucket.name}/${eventId}/.`)
    }

    // Extract the playlists of streaming segments and sort them by playlist creation datetime to
    // ensure the final video is in the correct order, since segment ordering is maintained
    // within an individual playlist but not between playlists
    const playlistFiles = recordingFiles
        .filter(file => path.extname(file.name) === '.m3u8')
        .sort((f1, f2) =>
            new Date([f1.getMetadata()].timeCreated) - new Date([f2.getMetadata()].timeCreated))

    // Generate a manifest file of the streaming segment playlists
    // (Required by ffmpeg when working with muliple playlists at once)
    console.log('Generating the manifest file for ffmpeg.')
    const manifestPath = `${tempFolder}/manifest.txt`
    await fs.writeFile(manifestPath, playlistFiles.map(file =>
        `file '${tempFolder}/${path.basename(file.name)}'\n`))

    // Concatenate playlists of streaming segments into a single mp4 of the event main room
    const filename = `${eventId}_complete_recording.mp4`
    const videoOutputPath = `${tempFolder}/${filename}`
    const ffmpegExitCode = await _concatStreamingSegments(manifestPath, videoOutputPath)
    if (ffmpegExitCode !== 0) {
        throw new HttpsError('internal', `ffmpeg exited with code ${ffmpegExitCode}`)
    }

    // Upload the final event video back to the GCS folder for the event
    const finalVideoDestination = `${eventId}/${filename}`
    console.log(`Uploading final video to GCS at ${bucket.name}/${finalVideoDestination}.`)
    await bucket.upload(videoOutputPath, { destination: finalVideoDestination })
    console.log('Final video upload complete.')
}

const _concatStreamingSegments = async (manifestPath, outputPath) => {
    /*
    Note: The ffmpeg binary is available on the Node 20 / Ubuntu 22 image that we are currently
    using on the Cloud Run services underlying our Firebase functions. But this may or may not be
    available on future images when we upgrade before Google's 2026-10-30 image decomission date.
    Google maintains lists of available binaries per image type, so we will want to confirm or deny
    that before switching over and plan accordingly.
    */

    // Spawn a subprocess invoking ffmpeg to concatenate playlists of streaming segments from the
    // event into a single output mp4
    const ffmpeg = spawn('ffmpeg', [
        '-f', 'concat',
        '-safe', '0',
        '-i', manifestPath,
        '-c', 'copy',
        outputPath,
    ])

    ffmpeg.stdout.on('data', data => console.log(`${data}`))
    ffmpeg.stderr.on('data', data => console.error(`${data}`))

    let outputCode
    ffmpeg.on('close', code => {
        console.log(`ffmpeg exited with code ${code}.`)
        outputCode = code
    })

    await events.once(ffmpeg, 'close')
    return outputCode
}

const _downloadRecordingFiles = async (eventId) => {
    /*
    Note: A static folder under /tmp is used rather than fs.mkdtemp() to ensure the function has a
    cleanup step that will prevent old temp files from a previous run pushing the Firebase function
    over its memory limit. This occurs when two subsequent executions of the same Firebase function
    happen to make use of the same running instance of the underlying Cloud Run service.
    (I learned this was necessary the hard way.)
    */

    // Recycle the static temp folder (see the note above)
    await fs.rm(tempFolder, { recursive: true, force: true })
    await fs.mkdir(tempFolder)

    // Fetch the filenames from the GCS bucket for the specified event
    //const eventFolder = `${eventId}/`
    console.log(`Fetching filenames from GCS at ${bucket.name}/${eventId}/.`)
    const [eventFiles] = await bucket.getFiles({ directory: `${eventId}/`, delimiter: '/' })
    console.log(`Fetched ${eventFiles.length} filenames from GCS.`)

    // Filter by recording-related files
    const recordingFiles = eventFiles.filter(file =>
        ['.ts', '.m3u8'].includes(path.extname(file.name)))
    console.log(`${recordingFiles.length} of the event files are .ts segments or .m3u8 playlists.`)
    if (recordingFiles.length == 0)
        return []


    // Download the recording files to the temp folder created above
    console.log(`Downloading ${recordingFiles.length} files from GCS.`)
    await Promise.all(recordingFiles.map(async file =>
        file.download({ destination: `${tempFolder}/${path.basename(file.name)}` })
    ))

    return recordingFiles
}

// See caveat in main._register_js_functions()
module.exports = [ProduceRecording, OnRecordingComplete]
