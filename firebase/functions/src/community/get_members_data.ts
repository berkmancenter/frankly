import * as functions from 'firebase-functions'
import { HttpsError } from 'firebase-functions/lib/providers/https'
import { firestore, firestoreUtils } from '../utils/infra/firestore_utils'
import { firebaseAuthUtils } from '../utils/infra/firebase_auth_utils'
import { OnCallMethod } from '../on_call_function'
import {
    GetMembersDataRequest,
    GetMembersDataResponse,
    Membership,
    MemberDetails,
    MemberEventData,
    Event,
    Participant,
    ParticipantStatus,
    MembershipStatus,
} from '../types'
import { membershipIsAdmin } from '../types'

export class GetMembersData extends OnCallMethod<GetMembersDataRequest> {
    constructor() {
        super('GetMembersData', (json) => json as GetMembersDataRequest)
    }

    async action(
        request: GetMembersDataRequest,
        context: functions.https.CallableContext
    ): Promise<GetMembersDataResponse> {
        const { communityId } = request

        const adminMembershipDoc = await firestore
            .doc(`memberships/${context.auth?.uid}/community-membership/${communityId}`)
            .get()
        const membership = adminMembershipDoc.data() as Membership | undefined

        if (!membership?.status || !membershipIsAdmin(membership.status)) {
            throw new HttpsError('failed-precondition', 'Unauthorized')
        }

        let event: Event | undefined
        if (request.eventPath) {
            const eventDoc = await firestore.doc(request.eventPath).get()
            event = firestoreUtils.fromFirestoreJson(eventDoc.data() ?? {}) as unknown as Event
            event.id = eventDoc.id
        }

        // Process in batches of 250
        const memberDetailsList: MemberDetails[] = []
        for (let i = 0; i < request.userIds.length; i += 250) {
            const batch = request.userIds.slice(i, i + 250)
            const details = await Promise.all(
                batch.map((memberId) => this._getDataForUser({ memberId, communityId, event }))
            )
            memberDetailsList.push(...details)
        }

        return { membersDetailsList: memberDetailsList }
    }

    private async _getDataForUser(opts: {
        memberId: string
        communityId: string
        event?: Event
    }): Promise<MemberDetails> {
        const { memberId, communityId, event } = opts

        const membershipDoc = await firestore
            .doc(`memberships/${memberId}/community-membership/${communityId}`)
            .get()
        const membershipDetails: Membership = membershipDoc.exists
            ? (membershipDoc.data() as Membership)
            : { userId: memberId, communityId, status: MembershipStatus.nonmember }

        let memberInfo: import('firebase-admin').auth.UserRecord | undefined
        try {
            memberInfo = await firebaseAuthUtils.getUser(memberId)
        } catch (e) {
            console.error(`Error getting user info for ${memberId}:`, e)
        }

        let memberName = ''
        const memberDoc = await firestore.doc(`publicUser/${memberId}`).get()
        if (memberDoc.exists) {
            const publicUserInfo = memberDoc.data() as { displayName?: string }
            memberName = publicUserInfo.displayName ?? ''
        }

        let memberEventsData: MemberEventData | undefined
        if (event) {
            const eventPath = `${event.collectionPath}/${event.id}`
            const participantData = await firestore
                .doc(`${eventPath}/event-participants/${memberId}`)
                .get()
            const participant = participantData.data() as Participant

            memberEventsData = {
                eventId: event.id,
                templateId: event.templateId,
                participant,
            }
        }

        return {
            id: memberId,
            email: memberInfo?.email ?? 'Unknown',
            displayName: memberName,
            membership: membershipDetails,
            memberEvent: memberEventsData,
        }
    }
}
