import * as functions from 'firebase-functions'
import { HttpsError } from 'firebase-functions/lib/providers/https'
import { firestore, firestoreUtils } from '../utils/infra/firestore_utils'
import { OnCallMethod } from '../on_call_function'
import {
    CreateCommunityRequest,
    CreateCommunityResponse,
    Community,
    Membership,
    MembershipStatus,
    PartnerAgreement,
    CommunitySettings,
} from '../types'
import { orElseUnauthorized, jsonSubset } from '../utils/utils'

export class CreateCommunity extends OnCallMethod<CreateCommunityRequest> {
    constructor() {
        super('createCommunity', (json) => json as CreateCommunityRequest)
    }

    async action(
        request: CreateCommunityRequest,
        context: functions.https.CallableContext
    ): Promise<CreateCommunityResponse> {
        orElseUnauthorized(context.auth?.uid != null)

        const requestedCommunity = request.community
        if (!requestedCommunity) {
            throw new HttpsError('failed-precondition', 'Must provide community information.')
        }

        let community = { ...requestedCommunity }

        if (!community.name?.trim()) {
            throw new HttpsError('failed-precondition', 'Name is required.')
        }

        const communityCollection = firestore.collection('/community/')
        const communityDocRef = communityCollection.doc()

        if (community.displayIds && community.displayIds.length > 0) {
            console.log(`Checking if displayIds ${community.displayIds} are already in use.`)
            const communitiesWithMatchingId = await communityCollection
                .where('displayIds', 'array-contains', community.displayIds[0])
                .get()
            const alreadyUsedMessage = `The URL display name ${community.displayIds[0]} is already taken.`
            if (!communitiesWithMatchingId.empty) {
                throw new HttpsError('failed-precondition', alreadyUsedMessage)
            }
        }

        const userId = context.auth!.uid

        community = {
            ...community,
            id: communityDocRef.id,
            creatorId: userId,
            profileImageUrl:
                community.profileImageUrl ??
                `https://picsum.photos/seed/${communityDocRef.id}-profile/512`,
            bannerImageUrl: community.bannerImageUrl ?? '',
            communitySettings: community.communitySettings ?? ({} as CommunitySettings),
            displayIds: community.displayIds?.length
                ? [community.displayIds[0]]
                : [communityDocRef.id],
        }

        const agreementChangedFields = ['communityId']
        let agreementRef: FirebaseFirestore.DocumentReference
        let agreementUpdated: PartnerAgreement

        if (request.agreementId) {
            agreementRef = firestore.doc(`partner-agreements/${request.agreementId}`)
            const agreementDoc = await agreementRef.get()
            orElseUnauthorized(agreementDoc.exists)
            const agreement = agreementDoc.data() as PartnerAgreement
            agreementUpdated = { ...agreement, communityId: communityDocRef.id }
        } else {
            agreementRef = firestore.collection('partner-agreements').doc()
            agreementUpdated = {
                id: agreementRef.id,
                communityId: communityDocRef.id,
                allowPayments: true,
            }
            agreementChangedFields.push('id', 'allowPayments')
        }

        await firestore.runTransaction(async (transaction) => {
            const doc = await transaction.get(communityDocRef)
            if (doc.exists) {
                throw new HttpsError(
                    'failed-precondition',
                    `Community with ID ${communityDocRef.id} already exists.`
                )
            }

            transaction.set(
                communityDocRef,
                firestoreUtils.toFirestoreJson(community as unknown as Record<string, unknown>)
            )

            transaction.set(
                firestore.doc(`memberships/${userId}/community-membership/${communityDocRef.id}`),
                firestoreUtils.toFirestoreJson({
                    communityId: communityDocRef.id,
                    userId,
                    status: MembershipStatus.owner,
                })
            )

            transaction.set(
                agreementRef,
                jsonSubset(
                    agreementChangedFields,
                    firestoreUtils.toFirestoreJson(
                        agreementUpdated as unknown as Record<string, unknown>
                    )
                ),
                { merge: true }
            )
        })

        return { communityId: communityDocRef.id }
    }
}
