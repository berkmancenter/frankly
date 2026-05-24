const functions = require('firebase-functions')

const defaultRegion = 'us-central1'

function configuredFunctionRegion() {
    const configured = functions.config().functions?.region
    if (typeof configured !== 'string') return defaultRegion

    const trimmed = configured.trim()
    return trimmed.length > 0 ? trimmed : defaultRegion
}

function regionalFunctions() {
    return functions.region(configuredFunctionRegion())
}

module.exports = {
    configuredFunctionRegion,
    defaultRegion,
    regionalFunctions,
}
