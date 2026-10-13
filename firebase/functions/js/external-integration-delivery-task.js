const functions = require('firebase-functions')
const { getDeliveryService } = require('./external-integrations')

// Cloud Tasks target for webhook retries. The body names a delivery, its run
// and the attempt number; anything that does not match the delivery's current
// state is ignored, so replays and duplicates do nothing. Always answers 200
// so Cloud Tasks does not add its own retries on top of ours.
const externalIntegrationDeliveryTask = functions.https.onRequest(async (req, res) => {
    if (req.method !== 'POST') {
        res.status(405).send('Method not allowed')
        return
    }
    const { deliveryId, runId, runAttempt } = req.body || {}
    if (
        typeof deliveryId !== 'string' ||
        !/^dlv_[a-f0-9]{1,64}$/.test(deliveryId) ||
        typeof runId !== 'string' ||
        !Number.isInteger(runAttempt) ||
        runAttempt < 2
    ) {
        res.status(400).send('Invalid request')
        return
    }

    try {
        const result = await getDeliveryService().attemptDelivery({ deliveryId, runId, runAttempt })
        res.status(200).json({ status: result.status || null, skipped: result.skipped || null })
    } catch (err) {
        console.error(`External integrations: retry for ${deliveryId} failed:`, err)
        res.status(200).json({ error: 'attempt failed' })
    }
})

module.exports = externalIntegrationDeliveryTask
