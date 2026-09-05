const functions = require('firebase-functions')
const admin = require('firebase-admin')
const { regionalFunctions } = require('./function-region')
const fetch = require('node-fetch')
const { notifyDembraneBridge } = require('./dembrane-bridge')

const firestore = admin.firestore()
const storage = admin.storage()
const bucketName = functions.config().agora.storage_bucket_name
const dembraneBridgeUrl = functions.config().dembrane?.bridge_url
const dembraneBridgeToken = functions.config().dembrane?.bridge_token

const artifactLookupAttempts = 6
const artifactLookupDelayMs = 10000
const bridgeSignedUrlExpiration = 24 * 60 * 60 * 1000

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms))

function getErrorMessage(err) {
    return err instanceof Error ? err.message : String(err)
}

async function listMp4Files({ bucket, gcsPrefix }) {
    const [files] = await bucket.getFiles({ prefix: `${gcsPrefix}/` })
    return files
        .filter((file) => file.name.endsWith('.mp4'))
        .sort((left, right) => left.name.localeCompare(right.name))
}

async function waitForMp4Files({ bucket, gcsPrefix, sessionId }) {
    for (let attempt = 1; attempt <= artifactLookupAttempts; attempt += 1) {
        const mp4Files = await listMp4Files({ bucket, gcsPrefix })
        if (mp4Files.length > 0) {
            return mp4Files
        }

        if (attempt < artifactLookupAttempts) {
            console.log(
                `No MP4 found under ${gcsPrefix}/ for session ${sessionId} on attempt ${attempt}/${artifactLookupAttempts}. Retrying in ${artifactLookupDelayMs}ms`
            )
            await sleep(artifactLookupDelayMs)
        }
    }

    throw new Error(
        `No MP4 found under ${gcsPrefix}/ for session ${sessionId} after ${artifactLookupAttempts} attempts`
    )
}

function buildArtifactUpdates(mp4Files) {
    const updates = {}
    mp4Files.forEach((file, index) => {
        updates[`artifactPaths.complete_mp4_${index}`] = file.name
    })
    return updates
}

// Triggered when a recording session transitions to 'stopped'.
// Locates artifacts Agora deposited under gcsPrefix (MP4 recordings, VTT
// transcripts) and registers their paths on the session document.
const produceSessions = regionalFunctions().runWith({ timeoutSeconds: 540 }).firestore
    .document('recording-sessions/{sessionId}')
    .onUpdate(async (change, context) => {
        const before = change.before.data()
        const after = change.after.data()

        if (before.status === after.status) return null
        if (after.status !== 'stopped') return null

        const sessionId = context.params.sessionId
        const gcsPrefix = after.gcsPrefix
        if (!gcsPrefix) {
            console.warn(`Session ${sessionId} has no gcsPrefix, skipping post-processing`)
            return null
        }

        const bucket = storage.bucket(bucketName)

        // List all files under the session prefix once.
        let allFiles
        try {
            const [files] = await bucket.getFiles({ prefix: `${gcsPrefix}/` })
            allFiles = files

            // STT strips non-alphanumeric chars from fileNamePrefix segments
            // (Agora rejects them in STT but not Cloud Recording). Check the
            // sanitized prefix too so VTT files are discovered.
            const sanitizedPrefix = gcsPrefix
                .split('/')
                .map((s) => s.replace(/[^a-zA-Z0-9]/g, ''))
                .join('/')
            if (sanitizedPrefix !== gcsPrefix) {
                const [extraFiles] = await bucket.getFiles({ prefix: `${sanitizedPrefix}/` })
                allFiles = [...allFiles, ...extraFiles]
            }
        } catch (err) {
            console.error(`Error listing files for session ${sessionId}:`, err)
            return null
        }

        // --- Register MP4 ---
        try {
            const bridgeEnabled = String(functions.config().dembrane?.enabled) === 'true'
            const mp4Files = bridgeEnabled && after.dembraneProjectId
                ? await waitForMp4Files({ bucket, gcsPrefix, sessionId })
                : allFiles.filter((f) => f.name.endsWith('.mp4'))
            if (mp4Files.length > 0) {
                await change.after.ref.update(buildArtifactUpdates(mp4Files))
            }

            await notifyDembraneBridge({
                enabled: String(functions.config().dembrane?.enabled) === 'true',
                sessionRef: change.after.ref,
                sessionId,
                sessionData: after,
                mp4Files,
                bridgeUrl: dembraneBridgeUrl,
                bridgeToken: dembraneBridgeToken,
                fetchImpl: fetch,
                fieldValue: admin.firestore.FieldValue,
                signedUrlExpirationMs: bridgeSignedUrlExpiration,
            })

            await change.after.ref.update({
                'postProcessing.lastAttemptAt':
                    admin.firestore.FieldValue.serverTimestamp(),
                'postProcessing.lastCompletedAt':
                    admin.firestore.FieldValue.serverTimestamp(),
                'postProcessing.lastError': admin.firestore.FieldValue.delete(),
            })
        } catch (err) {
            const message = getErrorMessage(err)
            console.error(`Error post-processing session ${sessionId}:`, err)
            try {
                await change.after.ref.update({
                    'postProcessing.lastAttemptAt':
                        admin.firestore.FieldValue.serverTimestamp(),
                    'postProcessing.lastError': message,
                })
            } catch (updateErr) {
                console.error(
                    `Error recording post-processing failure for session ${sessionId}:`,
                    updateErr
                )
            }
            // Keep transcript registration independent of bridge delivery failures.
        }

        // --- Register VTT transcript files ---
        try {
            let vttFiles = allFiles.filter((f) => f.name.endsWith('.vtt'))

            // If STT was enabled but VTTs aren't found yet, the agent may still
            // be flushing files to storage. Retry after a delay.
            const hasSTT = after.agoraRttAgentId != null
            if (vttFiles.length === 0 && hasSTT) {
                console.log(
                    `No VTT files yet for STT-enabled session ${sessionId}, waiting 15s for agent flush...`
                )
                await new Promise((resolve) => setTimeout(resolve, 15000))

                // Re-scan both paths
                const [retryFiles] = await bucket.getFiles({ prefix: `${gcsPrefix}/` })
                let retryAll = retryFiles
                const sanitizedRetry = gcsPrefix
                    .split('/')
                    .map((s) => s.replace(/[^a-zA-Z0-9]/g, ''))
                    .join('/')
                if (sanitizedRetry !== gcsPrefix) {
                    const [extraRetry] = await bucket.getFiles({ prefix: `${sanitizedRetry}/` })
                    retryAll = [...retryAll, ...extraRetry]
                }
                vttFiles = retryAll.filter((f) => f.name.endsWith('.vtt'))
            }

            if (vttFiles.length === 0) {
                console.log(`No VTT files found under ${gcsPrefix}/ for session ${sessionId}`)
            } else {
                console.log(
                    `Found ${vttFiles.length} VTT file(s) for session ${sessionId}: ${vttFiles
                        .map((f) => f.name)
                        .join(', ')}`
                )
                const updates = {}
                vttFiles.forEach((f, i) => {
                    updates[`artifactPaths.transcript_vtt_${i}`] = f.name
                })
                await change.after.ref.update(updates)
                console.log(`Registered ${vttFiles.length} VTT file(s) for session ${sessionId}`)
            }
        } catch (err) {
            console.error(`Error registering VTT for session ${sessionId}:`, err)
        }

        return null
    })

module.exports = produceSessions
