const functions = require('firebase-functions')
const admin = require('firebase-admin')
const { Storage } = require('@google-cloud/storage')
const cors = require('cors')({ origin: true })

const firestore = admin.firestore()
const storage = new Storage()
const bucketName = functions.config().agora.storage_bucket_name

const signedUrlExpiration = 15 * 60 * 1000

const eventPathRegex = /^community\/[^\/]+\/templates\/[^\/]+\/events\/[^\/]+$/

/// Parses a VTT file into an array of cue objects.
function parseVtt(vttText) {
    const lines = vttText.split('\n')
    const cues = []
    let i = 0

    // Skip header
    while (i < lines.length && !lines[i].includes('-->')) i++

    while (i < lines.length) {
        const line = lines[i].trim()
        if (line.includes('-->')) {
            const [startStr, endStr] = line.split('-->')
            const start = startStr.trim()
            const end = endStr.trim()
            i++
            let text = ''
            while (i < lines.length && lines[i].trim() !== '') {
                if (text) text += ' '
                text += lines[i].trim()
                i++
            }
            if (text) {
                cues.push({ start, end, text })
            }
        } else {
            i++
        }
    }
    return cues
}

/// Converts VTT cues to CSV format with speaker name resolution.
function cuesToCsv(cues, uidMap) {
    const header = 'Start,End,Speaker,Text'
    const rows = cues.map((cue) => {
        // VTT may include speaker label as "<v SpeakerUid>text"
        let speaker = ''
        let text = cue.text
        const match = text.match(/^<v\s+(\d+)>(.*)$/)
        if (match) {
            const uid = match[1]
            speaker = uidMap[uid] || `Speaker ${uid}`
            text = match[2]
        }
        // Escape CSV fields
        const escaped = text.replace(/"/g, '""')
        const speakerEscaped = speaker.replace(/"/g, '""')
        return `${cue.start},${cue.end},"${speakerEscaped}","${escaped}"`
    })
    return [header, ...rows].join('\n')
}

/// Converts VTT cues to plain text format.
function cuesToPlainText(cues, uidMap) {
    return cues.map((cue) => {
        let speaker = ''
        let text = cue.text
        const match = text.match(/^<v\s+(\d+)>(.*)$/)
        if (match) {
            const uid = match[1]
            speaker = uidMap[uid] || `Speaker ${uid}`
            text = match[2]
        }
        return speaker ? `[${cue.start}] ${speaker}: ${text}` : `[${cue.start}] ${text}`
    }).join('\n')
}

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

            const { eventPath, format } = req.body
            if (!eventPath) {
                res.status(400).json({ error: 'eventPath not found' })
                return
            }
            if (!eventPathRegex.test(eventPath)) {
                res.status(400).json({ error: 'Invalid eventPath format' })
                return
            }

            const exportFormat = format || 'csv'
            if (!['csv', 'text', 'vtt'].includes(exportFormat)) {
                res.status(400).json({ error: 'Invalid format. Use: csv, text, vtt' })
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

            // Find all recording sessions for this event that have VTT artifacts.
            const sessionsSnap = await firestore
                .collection('recording-sessions')
                .where('eventId', '==', event.id)
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
                const uidMap = session.uidToDisplayName || {}
                const roomId = session.roomId || 'unknown'
                const roomType = session.roomType || 'main'

                // Collect all VTT artifact paths for this session.
                const vttPaths = Object.entries(artifactPaths)
                    .filter(([key]) => key.startsWith('transcript_vtt_'))
                    .map(([, path]) => path)

                if (vttPaths.length === 0) continue

                for (const vttPath of vttPaths) {
                    try {
                        const [contents] = await bucket.file(vttPath).download()
                        const vttText = contents.toString('utf-8')

                        if (exportFormat === 'vtt') {
                            // Return signed URL for raw VTT download
                            const [url] = await bucket.file(vttPath).getSignedUrl({
                                action: 'read',
                                expires: Date.now() + signedUrlExpiration,
                                responseDisposition: `attachment; filename="${roomId}.vtt"`,
                            })
                            transcripts.push({ roomId, roomType, format: 'vtt', url })
                        } else {
                            const cues = parseVtt(vttText)
                            let converted
                            let ext
                            if (exportFormat === 'csv') {
                                converted = cuesToCsv(cues, uidMap)
                                ext = 'csv'
                            } else {
                                converted = cuesToPlainText(cues, uidMap)
                                ext = 'txt'
                            }

                            // Write converted file to GCS and return signed URL.
                            const outPath = `${session.gcsPrefix}/transcript.${ext}`
                            await bucket.file(outPath).save(converted, {
                                contentType: ext === 'csv' ? 'text/csv' : 'text/plain',
                            })
                            const [url] = await bucket.file(outPath).getSignedUrl({
                                action: 'read',
                                expires: Date.now() + signedUrlExpiration,
                                responseDisposition: `attachment; filename="${roomId}.${ext}"`,
                            })
                            transcripts.push({ roomId, roomType, format: exportFormat, url })
                        }
                    } catch (fileErr) {
                        console.error(`Error processing VTT ${vttPath}:`, fileErr)
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
