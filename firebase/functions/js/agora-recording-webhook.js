const functions = require('firebase-functions')
const admin = require('firebase-admin')
const crypto = require('crypto')
const { Storage } = require('@google-cloud/storage')
const http = require('https')

const firestore = admin.firestore()
const storage = new Storage()
const bucketName = functions.config().agora.storage_bucket_name

const agoraAppId = functions.config().agora.app_id
const agoraRestKey = functions.config().agora.rest_key
const agoraRestSecret = functions.config().agora.rest_secret

// Agora cloud recording event types
// https://docs.agora.io/en/cloud-recording/develop/receive-notifications
// 41 = recorder_leave: the recorder module leaves the channel (recording stops)
const EVENT_TYPE_RECORDER_LEAVE = 41

function verifySignature(req) {
    const secret = functions.config().agora?.webhook_secret
    if (!secret) {
        console.warn('agora.webhook_secret not configured -- skipping signature check')
        return true
    }
    const signature = req.headers['agora-signature'] ?? req.headers['agorasignature']
    if (!signature) return false
    const rawBody = req.rawBody ?? Buffer.from(JSON.stringify(req.body))
    const expected = crypto.createHmac('sha1', secret).update(rawBody).digest('hex')
    const sigBuf = Buffer.from(signature)
    const expBuf = Buffer.from(expected)
    if (sigBuf.length !== expBuf.length) return false
    return crypto.timingSafeEqual(sigBuf, expBuf)
}

function getAuthHeader() {
    const credentials = Buffer.from(`${agoraRestKey}:${agoraRestSecret}`).toString('base64')
    return `Basic ${credentials}`
}

async function stopSttAgent(agentId) {
    const url = `https://api.agora.io/api/speech-to-text/v1/projects/${agoraAppId}/agents/${agentId}/leave`
    return new Promise((resolve, reject) => {
        const req = http.request(url, {
            method: 'POST',
            headers: {
                'Authorization': getAuthHeader(),
                'Content-Type': 'application/json',
            },
        }, (res) => {
            let data = ''
            res.on('data', (chunk) => { data += chunk })
            res.on('end', () => {
                if (res.statusCode >= 200 && res.statusCode < 300) {
                    resolve(data)
                } else {
                    reject(new Error(`STT stop failed (${res.statusCode}): ${data}`))
                }
            })
        })
        req.on('error', reject)
        req.end('')
    })
}

const agoraRecordingWebhook = functions.https.onRequest(async (req, res) => {
    if (req.method !== 'POST') {
        res.status(405).send('Method Not Allowed')
        return
    }

    if (!verifySignature(req)) {
        res.status(401).send('Unauthorized')
        return
    }

    const { eventType, payload } = req.body ?? {}

    if (eventType !== EVENT_TYPE_RECORDER_LEAVE) {
        res.status(200).send('ok')
        return
    }

    const cname = payload?.cname
    const sid = payload?.sid

    if (!cname) {
        console.warn('recorder_leave received with no cname', req.body)
        res.status(200).send('ok')
        return
    }

    console.log(`recorder_leave: cname=${cname} sid=${sid}`)

    try {
        const snap = await firestore
            .collection('recording-sessions')
            .where('roomId', '==', cname)
            .where('status', 'in', ['starting', 'recording'])
            .orderBy('startedAt', 'desc')
            .limit(1)
            .get()

        if (snap.empty) {
            console.log(`recorder_leave: no active session found for cname=${cname}`)
            res.status(200).send('ok')
            return
        }

        const sessionDoc = snap.docs[0]
        const sessionData = sessionDoc.data()

        // Stop the STT agent if one is running for this session.
        if (sessionData.agoraRttAgentId) {
            try {
                await stopSttAgent(sessionData.agoraRttAgentId)
                console.log(`recorder_leave: stopped STT agent ${sessionData.agoraRttAgentId}`)
            } catch (sttErr) {
                console.error(`recorder_leave: failed to stop STT agent: ${sttErr.message}`)
            }
        }

        await sessionDoc.ref.update({
            status: 'stopped',
            stoppedAt: admin.firestore.FieldValue.serverTimestamp(),
            stoppedByWebhook: true,
        })

        console.log(`recorder_leave: stopped session ${sessionDoc.id} for cname=${cname}`)
    } catch (err) {
        console.error(`recorder_leave: error stopping session for cname=${cname}:`, err)
    }

    res.status(200).send('ok')
})

module.exports = agoraRecordingWebhook
