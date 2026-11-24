const functions = require('firebase-functions')
const { getAdminHandlers } = require('./external-integrations')

// Replaces an integration's signing secret and returns the new one once.
// Community owners/admins only. The old secret stops working immediately.
const rotateExternalIntegrationSecret = functions.https.onCall((data, context) =>
    getAdminHandlers().rotateSecret(data, context.auth && context.auth.uid)
)

module.exports = rotateExternalIntegrationSecret
