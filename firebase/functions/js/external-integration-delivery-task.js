const functions = require('firebase-functions')
const { getDeliveryService } = require('./external-integrations')
const { handleDeliveryTask } = require('./external-integrations/task-handler')

// Cloud Tasks target for webhook retries. The body names a delivery, its run
// and the attempt number; anything that does not match the delivery's current
// state is ignored, so replays and duplicates do nothing. Cloud Tasks retries
// every non-2xx answer, so this answers 200 once the attempt ran or was
// skipped (our own retry policy schedules the next one) and also for a
// malformed body (logged as an error; retrying cannot fix it), and 500 only
// on unexpected errors so Cloud Tasks retries the task. See
// external-integrations/task-handler.js.
const externalIntegrationDeliveryTask = functions.https.onRequest(async (req, res) => {
    const result = await handleDeliveryTask({
        method: req.method,
        body: req.body,
        attemptDelivery: (request) => getDeliveryService().attemptDelivery(request),
    })
    if (typeof result.body === 'string') res.status(result.status).send(result.body)
    else res.status(result.status).json(result.body)
})

module.exports = externalIntegrationDeliveryTask
