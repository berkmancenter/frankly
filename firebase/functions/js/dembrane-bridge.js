function getMissingBridgeConfig({ bridgeUrl, bridgeToken }) {
    const missing = []
    if (!bridgeUrl) missing.push('functions.config().dembrane.bridge_url')
    if (!bridgeToken) missing.push('functions.config().dembrane.bridge_token')
    return missing
}

function buildBridgeHeaders({ bridgeToken }) {
    return {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${bridgeToken}`,
    }
}

function buildBridgePayload({ agoraFileUrl, dembraneProjectId }) {
    return {
        agoraFileUrl,
        dembraneProjectId,
    }
}

async function updateBridgeError({ sessionRef, fieldValue, message }) {
    await sessionRef.update({
        'dembraneBridge.lastAttemptAt': fieldValue.serverTimestamp(),
        'dembraneBridge.lastError': message,
    })
}

async function notifyDembraneBridge({
    enabled = false,
    sessionRef,
    sessionId,
    sessionData,
    mp4Files,
    bridgeUrl,
    bridgeToken,
    fetchImpl,
    fieldValue,
    signedUrlExpirationMs,
}) {
    if (enabled !== true) return

    const latestSnapshot = await sessionRef.get()
    const latestData = latestSnapshot.data() ?? {}
    const dembraneProjectId = latestData.dembraneProjectId ?? sessionData.dembraneProjectId
    if (!dembraneProjectId) {
        return
    }

    const missingConfig = getMissingBridgeConfig({ bridgeUrl, bridgeToken })
    if (missingConfig.length > 0) {
        const message = `Missing ${missingConfig.join(
            ' and '
        )} for Dembrane-linked recording`
        await updateBridgeError({ sessionRef, fieldValue, message })
        throw new Error(`${message}. sessionId=${sessionId}`)
    }

    const sentArtifacts = latestData.dembraneBridge?.sentArtifacts ?? {}
    for (let index = 0; index < mp4Files.length; index++) {
        const artifactKey = `complete_mp4_${index}`
        if (sentArtifacts[artifactKey]?.sentAt) {
            continue
        }

        const file = mp4Files[index]
        try {
            const [agoraFileUrl] = await file.getSignedUrl({
                action: 'read',
                expires: Date.now() + signedUrlExpirationMs,
            })
            const response = await fetchImpl(bridgeUrl, {
                method: 'POST',
                timeout: 450000,
                headers: buildBridgeHeaders({ bridgeToken }),
                body: JSON.stringify(
                    buildBridgePayload({
                        agoraFileUrl,
                        dembraneProjectId,
                    })
                ),
            })
            if (!response.ok) {
                const responseBody = await response.text()
                throw new Error(
                    `Dembrane bridge failed for session ${sessionId}, artifact ${artifactKey}: ${response.status} ${responseBody}`
                )
            }

            await sessionRef.update({
                [`dembraneBridge.sentArtifacts.${artifactKey}.sentAt`]:
                    fieldValue.serverTimestamp(),
                [`dembraneBridge.sentArtifacts.${artifactKey}.gcsPath`]: file.name,
                'dembraneBridge.lastAttemptAt': fieldValue.serverTimestamp(),
                'dembraneBridge.lastSuccessAt': fieldValue.serverTimestamp(),
                'dembraneBridge.lastError': fieldValue.delete(),
            })
        } catch (err) {
            const message = err instanceof Error ? err.message : String(err)
            await updateBridgeError({ sessionRef, fieldValue, message })
            throw err
        }
    }

    return mp4Files.length > 0
}

const recordingMediaExtensions = ['.mp4', '.m3u8', '.ts']

function isRecordingMedia(fileName) {
    return recordingMediaExtensions.some((extension) => fileName.endsWith(extension))
}

// Deletes the Agora recording media (MP4 and HLS) for a session once every
// MP4 has been delivered to Dembrane, so recordings are not kept in Cloud
// Storage. Transcript files (VTT) are left in place.
async function deleteDeliveredRecordings({
    enabled = false,
    bucket,
    gcsPrefix,
    sessionRef,
    sessionId,
    fieldValue,
}) {
    if (enabled !== true || !gcsPrefix) return []

    const [files] = await bucket.getFiles({ prefix: `${gcsPrefix}/` })
    const mediaFiles = files.filter((file) => isRecordingMedia(file.name))
    await Promise.all(mediaFiles.map((file) => file.delete({ ignoreNotFound: true })))

    const latestSnapshot = await sessionRef.get()
    const artifactPaths = latestSnapshot.data()?.artifactPaths ?? {}
    const updates = {
        'dembraneBridge.recordingsDeletedAt': fieldValue.serverTimestamp(),
        'dembraneBridge.recordingsDeletedCount': mediaFiles.length,
    }
    Object.keys(artifactPaths)
        .filter((key) => key.startsWith('complete_mp4_'))
        .forEach((key) => {
            updates[`artifactPaths.${key}`] = fieldValue.delete()
        })
    await sessionRef.update(updates)

    console.log(
        `Deleted ${mediaFiles.length} recording file(s) under ${gcsPrefix}/ for session ${sessionId} after Dembrane delivery`
    )
    return mediaFiles.map((file) => file.name)
}

module.exports = {
    deleteDeliveredRecordings,
    buildBridgeHeaders,
    buildBridgePayload,
    getMissingBridgeConfig,
    notifyDembraneBridge,
}
