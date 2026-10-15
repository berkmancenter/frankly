const functions = require('firebase-functions')
const { getAdminHandlers } = require('./external-integrations')

// Removes an integration, its webhook URL and its secret. Delivery history is
// kept. Community owners/admins only.
const deleteExternalIntegration = functions.https.onCall((data, context) =>
    getAdminHandlers().deleteIntegration(data, context.auth && context.auth.uid)
)

module.exports = deleteExternalIntegration
