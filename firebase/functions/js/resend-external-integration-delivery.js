const functions = require('firebase-functions')
const { getDeliveryService } = require('./external-integrations')

const ERRORS = {
    'not-found': ['not-found', 'Delivery not found'],
    'permission-denied': [
        'permission-denied',
        'Only the event host or community moderators can resend',
    ],
    'in-flight': ['failed-precondition', 'This delivery is being sent right now'],
}

// Sends a delivery again with a fresh download URL and a new retry budget.
// Allowed for the event host and community moderators/admins.
const resendExternalIntegrationDelivery = functions
    .runWith({ timeoutSeconds: 120 })
    .https.onCall(async (data, context) => {
        const uid = context.auth && context.auth.uid
        if (!uid) throw new functions.https.HttpsError('unauthenticated', 'Sign in required')
        const deliveryId = data && data.deliveryId
        if (typeof deliveryId !== 'string' || !/^dlv_[a-f0-9]{1,64}$/.test(deliveryId)) {
            throw new functions.https.HttpsError('invalid-argument', 'deliveryId is required')
        }

        const result = await getDeliveryService().resendDelivery({ deliveryId, uid })
        if (result.error) {
            const [code, message] = ERRORS[result.error] || ['internal', 'Could not resend']
            throw new functions.https.HttpsError(code, message)
        }
        return { status: result.status }
    })

module.exports = resendExternalIntegrationDelivery
