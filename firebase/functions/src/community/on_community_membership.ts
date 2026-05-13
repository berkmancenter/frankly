import * as admin from 'firebase-admin'
import { firestore, firestoreUtils } from '../utils/infra/firestore_utils'
import {
    OnFirestoreFunction,
    AppFirestoreFunctionData,
    FirestoreEventType,
} from '../on_firestore_function'
import { Membership, MembershipStatus, Community, OnboardingStep } from '../types'
import { FirestoreHelper } from '../utils/infra/on_firestore_helper'
import { membershipIsMember } from '../types'

export class OnCommunityMembership extends OnFirestoreFunction<Membership> {
    constructor() {
        super(
            [
                {
                    functionName: 'CommunityMembershipOnCreate',
                    firestoreEventType: FirestoreEventType.onCreate,
                },
            ],
            (snapshot) => {
                return firestoreUtils.fromFirestoreJson(
                    snapshot.data() ?? {}
                ) as unknown as Membership
            }
        )
    }

    get documentPath(): string {
        return 'memberships/{membershipId}/community-membership/{communityMembershipId}'
    }

    async onCreate(
        documentSnapshot: admin.firestore.DocumentSnapshot,
        parsedData: Membership,
        _updateTime: Date,
        _context: import('firebase-functions').EventContext
    ): Promise<void> {
        console.log(`Community Membership (${documentSnapshot.id}) has been created`)
        await this._updateOnboardingSteps(parsedData, documentSnapshot)
    }

    private async _updateOnboardingSteps(
        membership: Membership,
        originalSnapshot: admin.firestore.DocumentSnapshot
    ): Promise<void> {
        const communityId = membership.communityId
        const communityDoc = await firestore
            .doc(new FirestoreHelper().getPathToCommunityDocument({ communityId }))
            .get()

        if (!communityDoc.exists) {
            console.log(`Community (${communityId}) does not exist`)
            return
        }

        const communityData = communityDoc.data() as Community
        const onboardingSteps: string[] = communityData.onboardingSteps ?? []
        const step = OnboardingStep.inviteSomeone.toString()

        if (onboardingSteps.includes(step)) {
            console.log(`${step} already in Community (${communityId}) onboardingSteps`)
            return
        }

        // Check if user is community creator
        const creatorId = communityData.creatorId
        if (creatorId === membership.userId) {
            console.log(
                `User (${membership.userId}) is a creator of the Community (${communityId})`
            )
            return
        }

        // Verify user is in community
        const communityMemberships = await firestore
            .collectionGroup(FirestoreHelper.kCommunityMemberships)
            .where('communityId', '==', communityId)
            .get()

        const isUserInCommunity = communityMemberships.docs.some(
            (doc) => (doc.data() as Membership).userId === membership.userId
        )

        if (!isUserInCommunity) {
            console.log(
                `User (${membership.userId}) is not in community (${communityId}). Something is wrong`
            )
            return
        }

        await communityDoc.ref.update({ onboardingSteps: [...onboardingSteps, step] })
        console.log(`${step} has been added to Community (${communityId}) onboardingSteps`)
    }
}
