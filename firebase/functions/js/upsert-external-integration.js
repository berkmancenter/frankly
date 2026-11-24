const functions = require('firebase-functions')
const { getAdminHandlers } = require('./external-integrations')

// Creates or updates a community's external integration (webhook). Community
// owners/admins only. Returns the signing secret once, on creation.
const upsertExternalIntegration = functions.https.onCall((data, context) =>
    getAdminHandlers().upsertIntegration(data, context.auth && context.auth.uid)
)

module.exports = upsertExternalIntegration
