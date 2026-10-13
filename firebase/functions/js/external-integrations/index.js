// Wires the external integration services to firebase-admin and the
// functions config. Services are created lazily so that deployments without
// any integration pay nothing at cold start.

const functions = require('firebase-functions')
const admin = require('firebase-admin')

const { readExternalIntegrationsConfig } = require('./config')
const { createTaskScheduler } = require('./cloud-tasks')
const { createDeliveryService } = require('./delivery')
const { createAdminHandlers } = require('./admin')

let deliveryService
let adminHandlers

function getDeliveryService() {
    if (!deliveryService) {
        deliveryService = createDeliveryService({
            firestore: admin.firestore(),
            bucket: admin.storage().bucket(functions.config().agora.storage_bucket_name),
            config: readExternalIntegrationsConfig(functions),
            enqueueFunctionCall: createTaskScheduler({ functions }),
        })
    }
    return deliveryService
}

function getAdminHandlers() {
    if (!adminHandlers) {
        adminHandlers = createAdminHandlers({
            firestore: admin.firestore(),
            config: readExternalIntegrationsConfig(functions),
            httpsError: (code, message) => new functions.https.HttpsError(code, message),
        })
    }
    return adminHandlers
}

/**
 * Sends a recording session's ready artifacts to the external integrations
 * enabled for its event. Never throws: integration problems must not affect
 * recording or transcript processing.
 */
async function deliverSessionArtifacts({ sessionId, sessionRef }) {
    try {
        const snapshot = await sessionRef.get()
        if (!snapshot.exists) return []
        return await getDeliveryService().queueSessionDeliveries({
            sessionId,
            session: snapshot.data(),
        })
    } catch (err) {
        console.error(
            `External integrations: could not queue deliveries for session ${sessionId}:`,
            err
        )
        return []
    }
}

module.exports = {
    getDeliveryService,
    getAdminHandlers,
    deliverSessionArtifacts,
}
