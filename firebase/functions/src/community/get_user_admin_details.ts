import * as functions from 'firebase-functions';
import { HttpsError } from 'firebase-functions/lib/providers/https';
import { firestore, firestoreUtils } from '../utils/infra/firestore_utils';
import { firebaseAuthUtils } from '../utils/infra/firebase_auth_utils';
import { OnCallMethod } from '../on_call_function';
import {
  GetUserAdminDetailsRequest, GetUserAdminDetailsResponse,
  Membership, Participant, ParticipantStatus, UserAdminDetails,
  MembershipRequest,
} from '../types';
import { membershipIsAdmin, membershipIsMember, membershipIsAttendee } from '../types';

export class GetUserAdminDetails extends OnCallMethod<GetUserAdminDetailsRequest> {
  constructor() {
    super('GetUserAdminDetails', (json) => json as GetUserAdminDetailsRequest);
  }

  async action(
    request: GetUserAdminDetailsRequest,
    context: functions.https.CallableContext
  ): Promise<GetUserAdminDetailsResponse> {
    const onlyRequestingSelf =
      request.userIds.length === 1 && request.userIds[0] === context.auth?.uid;
    let authorized = onlyRequestingSelf;

    if (!authorized && request.communityId) {
      const communityMembershipDoc = await firestore
        .doc(`memberships/${context.auth?.uid}/community-membership/${request.communityId}`)
        .get();
      const membership = communityMembershipDoc.data() as Membership | undefined;

      if (!authorized && request.eventPath) {
        const eventParticipantDocs = await Promise.all(
          request.userIds.map((id) =>
            firestore.doc(`${request.eventPath}/event-participants/${id}`).get()
          )
        );
        const allActive = eventParticipantDocs.every(
          (doc) => (doc.data() as Participant)?.status === ParticipantStatus.active
        );
        authorized = (membership?.status ? membershipIsAdmin(membership.status) : false) && allActive;
      }

      if (!authorized) {
        const memberDocuments = await Promise.all(
          request.userIds.map((id) =>
            firestore.doc(`memberships/${id}/community-membership/${request.communityId}`).get()
          )
        );
        const requestDocuments = await Promise.all(
          request.userIds.map((id) =>
            firestore.doc(`community/${request.communityId}/join-requests/${id}`).get()
          )
        );

        const memberships = memberDocuments
          .filter((doc) => doc.exists)
          .map((doc) => doc.data() as Membership)
          .filter((m) => m.status ? membershipIsAttendee(m.status) : false)
          .map((m) => m.userId);

        const requests = requestDocuments
          .filter((doc) => doc.exists && doc.data()?.['userId'] != null)
          .map((doc) => (doc.data() as MembershipRequest).userId);

        const joinedSet = new Set([...memberships, ...requests]);
        const allAreMembersOrRequesters = request.userIds.every((id) => joinedSet.has(id));

        authorized = (membership?.status ? membershipIsAdmin(membership.status) : false) && allAreMembersOrRequesters;
      }
    }

    if (!authorized) {
      throw new HttpsError('failed-precondition', 'unauthorized');
    }

    const userRecords = await firebaseAuthUtils.getUsers(request.userIds);
    return {
      userAdminDetails: userRecords.map((record): UserAdminDetails => ({
        userId: record.uid,
        email: record.email,
      })),
    };
  }
}
