// Community admin operations for external integrations: create/update,
// rotate the signing secret and delete. Only community owners and admins may
// call these. Secrets are generated here, stored where no client can read
// them, and returned to the caller exactly once.

const crypto = require('crypto')

const { generateSecret } = require('./signing')
const {
    validateWebhookUrl,
    assertResolvesToPublicAddress,
    validateLogoUrl,
} = require('./url-validation')
const { SUPPORTED_EVENT_TYPES } = require('./payload')
const { SECRETS, INTEGRATIONS, ENDPOINTS } = require('./delivery')

const ADMIN_STATUSES = ['owner', 'admin']
const MAX_INTEGRATIONS_PER_COMMUNITY = 10
const LIMITS = {
    displayName: 80,
    description: 500,
    externalReferenceLabel: 60,
}

const newIntegrationId = () => crypto.randomBytes(10).toString('hex')

function optionalText(value, field, max, fail) {
    if (value == null) return null
    if (typeof value !== 'string') fail(`${field} must be text`)
    const trimmed = value.trim()
    if (trimmed.length > max) fail(`${field} must be at most ${max} characters`)
    return trimmed === '' ? null : trimmed
}

/**
 * Validates and normalizes an upsert request. Throws via `fail(message)`.
 * Network checks (DNS) are done separately.
 */
function parseUpsertRequest(data, { allowedDomains, allowLocalTargets = false, fail }) {
    if (!data || typeof data !== 'object') fail('Invalid request')
    const communityId = typeof data.communityId === 'string' ? data.communityId.trim() : ''
    if (!communityId) fail('communityId is required')

    const integrationId =
        data.integrationId == null || data.integrationId === '' ? null : String(data.integrationId)
    if (integrationId != null && !/^[A-Za-z0-9_-]{1,64}$/.test(integrationId)) {
        fail('integrationId is not valid')
    }

    const displayName = optionalText(data.displayName, 'Display name', LIMITS.displayName, fail)
    if (!displayName) fail('Display name is required')

    const logo = validateLogoUrl(data.logoUrl == null ? null : String(data.logoUrl))
    if (!logo.ok) fail(logo.reason)

    const webhook = validateWebhookUrl(data.webhookUrl, { allowedDomains, allowLocalTargets })
    if (!webhook.ok) fail(webhook.reason)

    const events = Array.isArray(data.events) ? [...new Set(data.events.map(String))] : []
    if (events.length === 0) fail('Select at least one event to send')
    const unknown = events.filter((e) => !SUPPORTED_EVENT_TYPES.includes(e))
    if (unknown.length > 0) fail(`Unknown event type: ${unknown.join(', ')}`)

    return {
        communityId,
        integrationId,
        displayName,
        logoUrl: logo.url,
        description: optionalText(data.description, 'Description', LIMITS.description, fail),
        externalReferenceLabel: optionalText(
            data.externalReferenceLabel,
            'Reference label',
            LIMITS.externalReferenceLabel,
            fail
        ),
        webhookUrl: webhook.url,
        webhookHostname: webhook.hostname,
        webhookIsLocal: webhook.local === true,
        events,
        enabledForNewEvents: data.enabledForNewEvents === true,
        isActive: data.isActive !== false,
    }
}

/**
 * @param deps.firestore  firebase-admin Firestore
 * @param deps.config     parsed external integrations config
 * @param deps.httpsError (code, message) => Error, e.g. functions.https.HttpsError
 * @param deps.lookup     DNS lookup override (tests)
 */
function createAdminHandlers({ firestore, config, httpsError, lookup, now = () => new Date() }) {
    const fail = (message) => {
        throw httpsError('invalid-argument', message)
    }

    async function assertCommunityAdmin(uid, communityId) {
        if (!uid) throw httpsError('unauthenticated', 'Sign in required')
        if (typeof communityId !== 'string' || communityId === '') fail('communityId is required')
        const membership = await firestore
            .doc(`memberships/${uid}/community-membership/${communityId}`)
            .get()
        if (!membership.exists || !ADMIN_STATUSES.includes(membership.data().status)) {
            throw httpsError('permission-denied', 'Only community admins can manage integrations')
        }
    }

    async function upsertIntegration(data, uid) {
        const request = parseUpsertRequest(data, {
            allowedDomains: config.allowedDomains,
            allowLocalTargets: config.allowLocalTargets === true,
            fail,
        })
        await assertCommunityAdmin(uid, request.communityId)

        if (!request.webhookIsLocal) {
            try {
                await assertResolvesToPublicAddress(request.webhookHostname, { lookup })
            } catch (err) {
                fail(err.message)
            }
        }

        const integrations = firestore.collection(
            `community/${request.communityId}/${INTEGRATIONS}`
        )
        const timestamp = now()
        const isNew = request.integrationId == null
        const integrationId = isNew ? newIntegrationId() : request.integrationId
        const integrationRef = integrations.doc(integrationId)
        const endpointRef = firestore.doc(
            `community/${request.communityId}/${ENDPOINTS}/${integrationId}`
        )

        if (isNew) {
            const existing = await integrations.get()
            if (existing.size >= MAX_INTEGRATIONS_PER_COMMUNITY) {
                throw httpsError(
                    'resource-exhausted',
                    'This community has reached the integration limit'
                )
            }
        } else {
            const existing = await integrationRef.get()
            if (!existing.exists) throw httpsError('not-found', 'Integration not found')
        }

        const publicFields = {
            id: integrationId,
            communityId: request.communityId,
            displayName: request.displayName,
            logoUrl: request.logoUrl,
            description: request.description,
            externalReferenceLabel: request.externalReferenceLabel,
            events: request.events,
            enabledForNewEvents: request.enabledForNewEvents,
            isActive: request.isActive,
            updatedAt: timestamp,
        }

        const batch = firestore.batch()
        let secret = null
        if (isNew) {
            secret = generateSecret()
            batch.set(integrationRef, {
                ...publicFields,
                createdAt: timestamp,
                secretRotatedAt: timestamp,
            })
            batch.set(firestore.doc(`${SECRETS}/${integrationId}`), {
                integrationId,
                communityId: request.communityId,
                secret,
                createdAt: timestamp,
            })
        } else {
            batch.set(integrationRef, publicFields, { merge: true })
        }
        batch.set(endpointRef, {
            integrationId,
            communityId: request.communityId,
            webhookUrl: request.webhookUrl,
            updatedAt: timestamp,
        })
        await batch.commit()

        return secret ? { integrationId, secret } : { integrationId }
    }

    async function loadIntegration(data, uid) {
        const communityId = data && data.communityId
        const integrationId = data && data.integrationId
        await assertCommunityAdmin(uid, communityId)
        if (typeof integrationId !== 'string' || integrationId === '')
            fail('integrationId is required')
        const ref = firestore.doc(`community/${communityId}/${INTEGRATIONS}/${integrationId}`)
        const snapshot = await ref.get()
        if (!snapshot.exists) throw httpsError('not-found', 'Integration not found')
        return { communityId, integrationId, ref }
    }

    async function rotateSecret(data, uid) {
        const { communityId, integrationId, ref } = await loadIntegration(data, uid)
        const secret = generateSecret()
        const timestamp = now()
        const batch = firestore.batch()
        batch.set(firestore.doc(`${SECRETS}/${integrationId}`), {
            integrationId,
            communityId,
            secret,
            createdAt: timestamp,
        })
        batch.update(ref, { secretRotatedAt: timestamp, updatedAt: timestamp })
        await batch.commit()
        return { secret }
    }

    async function deleteIntegration(data, uid) {
        const { communityId, integrationId, ref } = await loadIntegration(data, uid)
        const batch = firestore.batch()
        batch.delete(ref)
        batch.delete(firestore.doc(`community/${communityId}/${ENDPOINTS}/${integrationId}`))
        batch.delete(firestore.doc(`${SECRETS}/${integrationId}`))
        await batch.commit()
        return { integrationId }
    }

    return { upsertIntegration, rotateSecret, deleteIntegration }
}

module.exports = {
    MAX_INTEGRATIONS_PER_COMMUNITY,
    parseUpsertRequest,
    createAdminHandlers,
}
