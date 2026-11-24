const assert = require('node:assert/strict')
const { test } = require('node:test')

process.env.FIREBASE_CONFIG ??= JSON.stringify({ projectId: 'region-test' })

const {
    configuredFunctionRegion,
    defaultRegion,
} = require('../js/function-region')

test('uses a configured region after trimming whitespace', () => {
    assert.equal(
        configuredFunctionRegion({ functions: { region: ' europe-west1 ' } }),
        'europe-west1',
    )
})

test('falls back to us-central1 for missing, blank, or non-string values', () => {
    assert.equal(configuredFunctionRegion({}), defaultRegion)
    assert.equal(
        configuredFunctionRegion({ functions: { region: '  ' } }),
        defaultRegion,
    )
    assert.equal(
        configuredFunctionRegion({ functions: { region: 123 } }),
        defaultRegion,
    )
})
