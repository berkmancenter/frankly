const functions = require('firebase-functions')
const admin = require('firebase-admin')
const crypto = require('crypto')

const firestore = admin.firestore()

// Agora cloud recording event types
// https://docs.agora.io/en/cloud-recording/develop/event-types
const EVENT_TYPE_RECORDER_EXIT = 45

// Agora signs each notification with HMAC-SHA1 over the raw body using the
// customer secret. Verify before processing to prevent spoofing.
function verifySignature(req) {
    const secret = functions.config().agora?.webhook_secret
    if (!secret) {
        // If not configured, skip verification (development only).
        console.warn('agora.webhook_secret not configured -- skipping signature check')
        return true
    }
    const signature = req.headers['agora-signature'] ?? req.headers['agorasignature']
    if (!signature) return false
    const expected = crypto
        .createHmac('sha1', secret)
        .update(JSON.stringify(req.body))
        .digest('hex')
    return crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(expected))
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

    const { eventType, details } = req.body ?? {}

    if (eventType !== EVENT_TYPE_RECORDER_EXIT) {
        // Acknowledge but ignore events we don't handle.
        res.status(200).send('ok')
        return
    }

    const cname = details?.cname
    const sid = details?.sid

    if (!cname) {
        console.warn('recorder_exit received with no cname', req.body)
        res.status(200).send('ok')
        return
    }

    console.log(`recorder_exit: cname=${cname} sid=${sid}`)

    try {
        // Find the recording session for this channel (cname = roomId) that is
        // still active. There should be at most one per roomId at a time.
        const snap = await firestore
            .collection('recording-sessions')
            .where('roomId', '==', cname)
            .where('status', 'in', ['starting', 'recording'])
            .orderBy('startedAt', 'desc')
            .limit(1)
            .get()

        if (snap.empty) {
            console.log(`recorder_exit: no active session found for cname=${cname}`)
            res.status(200).send('ok')
            return
        }

        const sessionDoc = snap.docs[0]
        await sessionDoc.ref.update({
            status: 'stopped',
            stoppedAt: admin.firestore.FieldValue.serverTimestamp(),
            stoppedByWebhook: true,
        })

        console.log(`recorder_exit: stopped session ${sessionDoc.id} for cname=${cname}`)
    } catch (err) {
        console.error(`recorder_exit: error stopping session for cname=${cname}:`, err)
        // Return 200 so Agora does not keep retrying -- the error is logged.
    }

    res.status(200).send('ok')
})

module.exports = agoraRecordingWebhook
