const test = require('node:test')
const assert = require('node:assert/strict')

const { createAdminHandlers, parseUpsertRequest } = require('./admin')
const { FakeFirestore } = require('./test-fakes')

const COMMUNITY = 'c1'

class TestHttpsError extends Error {
    constructor(code, message) {
        super(message)
        this.code = code
    }
}

function setup({ allowedDomains = [], lookupAddress = '93.184.216.34' } = {}) {
    const firestore = new FakeFirestore({
        [`memberships/owner/community-membership/${COMMUNITY}`]: { status: 'owner' },
        [`memberships/admin/community-membership/${COMMUNITY}`]: { status: 'admin' },
        [`memberships/mod/community-membership/${COMMUNITY}`]: { status: 'moderator' },
    })
    const handlers = createAdminHandlers({
        firestore,
        config: { allowedDomains },
        httpsError: (code, message) => new TestHttpsError(code, message),
        lookup: async () => [{ address: lookupAddress }],
        now: () => new Date('2026-03-01T00:00:00Z'),
    })
    return { firestore, handlers }
}

const request = (overrides = {}) => ({
    communityId: COMMUNITY,
    displayName: '  Example Receiver ',
    logoUrl: 'https://cdn.example.com/logo.png',
    description: 'Sends recordings to Example',
    externalReferenceLabel: 'Project ID',
    webhookUrl: 'https://hooks.example.com/frankly',
    events: ['recording.ready', 'transcript.ready'],
    enabledForNewEvents: true,
    ...overrides,
})

test('only community owners and admins can configure integrations', async () => {
    const { handlers } = setup()
    await assert.rejects(
        handlers.upsertIntegration(request(), 'mod'),
        (e) => e.code === 'permission-denied'
    )
    await assert.rejects(
        handlers.upsertIntegration(request(), 'stranger'),
        (e) => e.code === 'permission-denied'
    )
    await assert.rejects(
        handlers.upsertIntegration(request(), undefined),
        (e) => e.code === 'unauthenticated'
    )
})

test('creating an integration returns the secret once and stores it server-side only', async () => {
    const { firestore, handlers } = setup()
    const result = await handlers.upsertIntegration(request(), 'owner')
    assert.ok(result.integrationId)
    assert.match(result.secret, /^whsec_/)

    const publicDoc = firestore.get(
        `community/${COMMUNITY}/external-integrations/${result.integrationId}`
    )
    assert.equal(publicDoc.displayName, 'Example Receiver')
    assert.equal(publicDoc.isActive, true)
    assert.equal(publicDoc.enabledForNewEvents, true)
    assert.deepEqual(publicDoc.events, ['recording.ready', 'transcript.ready'])
    assert.equal(JSON.stringify(publicDoc).includes(result.secret), false)
    assert.equal('webhookUrl' in publicDoc, false)

    const endpoint = firestore.get(
        `community/${COMMUNITY}/external-integration-endpoints/${result.integrationId}`
    )
    assert.equal(endpoint.webhookUrl, 'https://hooks.example.com/frankly')
    assert.equal(JSON.stringify(endpoint).includes(result.secret), false)

    const secretDoc = firestore.get(`external-integration-secrets/${result.integrationId}`)
    assert.equal(secretDoc.secret, result.secret)
})

test('updating does not return or change the secret', async () => {
    const { firestore, handlers } = setup()
    const created = await handlers.upsertIntegration(request(), 'owner')
    const updated = await handlers.upsertIntegration(
        request({ integrationId: created.integrationId, displayName: 'Renamed', isActive: false }),
        'admin'
    )
    assert.deepEqual(updated, { integrationId: created.integrationId })
    assert.equal(
        firestore.get(`external-integration-secrets/${created.integrationId}`).secret,
        created.secret
    )
    const publicDoc = firestore.get(
        `community/${COMMUNITY}/external-integrations/${created.integrationId}`
    )
    assert.equal(publicDoc.displayName, 'Renamed')
    assert.equal(publicDoc.isActive, false)
})

test('rejects non-https, internal and non-allowlisted webhook URLs', async () => {
    const { handlers } = setup({ allowedDomains: ['example.com'] })
    for (const webhookUrl of [
        'http://hooks.example.com/x',
        'https://localhost/x',
        'https://169.254.169.254/x',
        'https://hooks.other.org/x',
    ]) {
        await assert.rejects(
            handlers.upsertIntegration(request({ webhookUrl }), 'owner'),
            (e) => e.code === 'invalid-argument',
            webhookUrl
        )
    }
})

test('rejects webhook hosts that resolve to private addresses', async () => {
    const { handlers } = setup({ lookupAddress: '192.168.0.10' })
    await assert.rejects(
        handlers.upsertIntegration(request(), 'owner'),
        (e) => e.code === 'invalid-argument'
    )
})

test('validates names, events and logo URL', () => {
    const fail = (message) => {
        throw new Error(message)
    }
    assert.throws(() => parseUpsertRequest(request({ displayName: '' }), { fail }), /Display name/)
    assert.throws(() => parseUpsertRequest(request({ events: [] }), { fail }), /at least one/)
    assert.throws(
        () => parseUpsertRequest(request({ events: ['event.ended.x'] }), { fail }),
        /Unknown event/
    )
    assert.throws(
        () => parseUpsertRequest(request({ logoUrl: 'http://x.example/logo.png' }), { fail }),
        /Logo/
    )
    assert.throws(
        () => parseUpsertRequest(request({ displayName: 'x'.repeat(81) }), { fail }),
        /at most/
    )
})

test('rotating replaces the secret and returns the new one', async () => {
    const { firestore, handlers } = setup()
    const created = await handlers.upsertIntegration(request(), 'owner')
    const rotated = await handlers.rotateSecret(
        { communityId: COMMUNITY, integrationId: created.integrationId },
        'admin'
    )
    assert.match(rotated.secret, /^whsec_/)
    assert.notEqual(rotated.secret, created.secret)
    assert.equal(
        firestore.get(`external-integration-secrets/${created.integrationId}`).secret,
        rotated.secret
    )
    await assert.rejects(
        handlers.rotateSecret(
            { communityId: COMMUNITY, integrationId: created.integrationId },
            'mod'
        ),
        (e) => e.code === 'permission-denied'
    )
})

test('deleting removes the integration, endpoint and secret', async () => {
    const { firestore, handlers } = setup()
    const { integrationId } = await handlers.upsertIntegration(request(), 'owner')
    await handlers.deleteIntegration({ communityId: COMMUNITY, integrationId }, 'owner')
    assert.equal(
        firestore.get(`community/${COMMUNITY}/external-integrations/${integrationId}`),
        undefined
    )
    assert.equal(
        firestore.get(`community/${COMMUNITY}/external-integration-endpoints/${integrationId}`),
        undefined
    )
    assert.equal(firestore.get(`external-integration-secrets/${integrationId}`), undefined)
    await assert.rejects(
        handlers.deleteIntegration({ communityId: COMMUNITY, integrationId }, 'owner'),
        (e) => e.code === 'not-found'
    )
})
