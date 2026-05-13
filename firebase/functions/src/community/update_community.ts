import * as functions from 'firebase-functions'
import { HttpsError } from 'firebase-functions/lib/providers/https'
import { firestore, firestoreUtils } from '../utils/infra/firestore_utils'
import { OnCallMethod } from '../on_call_function'
import { UpdateCommunityRequest, Community, Membership } from '../types'
import { orElseUnauthorized, jsonSubset } from '../utils/utils'
import { subscriptionPlanUtil } from '../utils/subscription_plan_util'
import { membershipIsAdmin } from '../types'

const baseAllowedUpdateFields = new Set([
    'name',
    'contactEmail',
    'profileImageUrl',
    'bannerImageUrl',
    'isPublic',
    'description',
    'tagLine',
    'websiteUrl',
    'facebookUrl',
    'linkedinUrl',
    'twitterUrl',
    'blueskyUrl',
    'youtubeUrl',
    'instagramUrl',
    'communitySettings',
    'eventSettings',
    'donationDialogText',
    'ratingSurveyUrl',
    'themeLightColor',
    'themeDarkColor',
    'onboardingSteps',
])

export class UpdateCommunity extends OnCallMethod<UpdateCommunityRequest> {
    constructor() {
        super('UpdateCommunity', (json) => json as UpdateCommunityRequest)
    }

    async action(
        request: UpdateCommunityRequest,
        context: functions.https.CallableContext
    ): Promise<string> {
        orElseUnauthorized(context.auth?.uid != null)

        let community = { ...request.community }

        const membershipDoc = await firestore
            .doc(`memberships/${context.auth!.uid}/community-membership/${community.id}`)
            .get()
        const membership = membershipDoc.data() as Membership | undefined

        if (!membership?.status || !membershipIsAdmin(membership.status)) {
            throw new HttpsError('failed-precondition', 'unauthorized')
        }

        if (community.name != null && !community.name.trim()) {
            throw new HttpsError('failed-precondition', 'Name is required.')
        }

        if (!community.displayIds?.includes(community.id)) {
            community = {
                ...community,
                displayIds: [
                    ...(community.displayIds ?? []),
                    community.id,
                    community.id.toLowerCase(),
                ],
            }
        }

        const communityCollection = firestore.collection('/community/')

        for (const displayId of community.displayIds ?? []) {
            const existing = await communityCollection
                .where('displayIds', 'array-contains', displayId)
                .get()
            if (!existing.empty && existing.docs.some((doc) => doc.id !== community.id)) {
                throw new HttpsError(
                    'failed-precondition',
                    `The URL display name ${displayId} is already taken.`
                )
            }
        }

        const communityDocRef = communityCollection.doc(community.id)
        const capabilities = await subscriptionPlanUtil.calculateCapabilities(community.id)
        const allowedFields = new Set([
            ...baseAllowedUpdateFields,
            ...(capabilities.hasCustomUrls ? ['displayIds'] : []),
        ])

        const updateFields = (request.keys ?? []).filter((k) => allowedFields.has(k))
        if (updateFields.length === 0) {
            throw new HttpsError('failed-precondition', 'No fields to update')
        }

        try {
            const finalisedUpdateMap = jsonSubset(
                updateFields,
                firestoreUtils.toFirestoreJson(community as unknown as Record<string, unknown>)
            )
            console.log('Update data:', finalisedUpdateMap)
            await communityDocRef.update(finalisedUpdateMap)
            return ''
        } catch (e) {
            console.error('Exception:', e)
            throw new HttpsError('unknown', 'Failed to update document')
        }
    }
}
