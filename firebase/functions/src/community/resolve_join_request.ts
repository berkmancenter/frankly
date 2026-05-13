import * as functions from 'firebase-functions';
import { HttpsError } from 'firebase-functions/lib/providers/https';
import { firestore, firestoreUtils } from '../utils/infra/firestore_utils';
import { sendEmailClient } from '../utils/send_email_client';
import { firebaseAuthUtils } from '../utils/infra/firebase_auth_utils';
import { OnCallMethod } from '../on_call_function';
import {
  ResolveJoinRequestRequest, Membership, MembershipStatus, MembershipRequest,
  MembershipRequestStatus, Community,
} from '../types';
import { membershipIsMod } from '../types';
import { jsonSubset } from '../utils/utils';

export class ResolveJoinRequest extends OnCallMethod<ResolveJoinRequestRequest> {
  constructor() {
    super('resolveJoinRequest', (json) => json as ResolveJoinRequestRequest);
  }

  async action(
    request: ResolveJoinRequestRequest,
    context: functions.https.CallableContext
  ): Promise<void> {
    await firestore.runTransaction(async (transaction) => {
      // Get mod membership
      const modMembershipDoc = await transaction.get(
        firestore.doc(`memberships/${context.auth?.uid}/community-membership/${request.communityId}`)
      );
      const modMembership = modMembershipDoc.data() as Membership | undefined;

      // Get join request
      const userMembershipRequestRef = firestore.doc(
        `community/${request.communityId}/join-requests/${request.userId}`
      );
      const userMembershipRequestSnap = await transaction.get(userMembershipRequestRef);
      const userMembershipRequest = userMembershipRequestSnap.data() as MembershipRequest | undefined;
      const hasActiveRequest = userMembershipRequest?.status === MembershipRequestStatus.requested;

      // Get user membership
      const userMembershipRef = firestore.doc(
        `memberships/${request.userId}/community-membership/${request.communityId}`
      );
      const userMembershipSnap = await transaction.get(userMembershipRef);
      const userMembership: Membership = userMembershipSnap.exists
        ? (userMembershipSnap.data() as Membership)
        : { userId: request.userId, communityId: request.communityId, status: MembershipStatus.nonmember, firstJoined: new Date() };

      const isMod = modMembership?.status ? membershipIsMod(modMembership.status) : false;
      if (!isMod || !hasActiveRequest || userMembership.status === MembershipStatus.member) {
        throw new HttpsError('failed-precondition', 'unauthorized');
      }

      if (request.approve) {
        // Update user membership to member
        const updatedMembership = { ...userMembership, status: MembershipStatus.member };
        if (userMembershipSnap.exists) {
          transaction.update(
            userMembershipRef,
            jsonSubset(['status'], firestoreUtils.toFirestoreJson(updatedMembership as unknown as Record<string, unknown>))
          );
        } else {
          transaction.set(
            userMembershipRef,
            firestoreUtils.toFirestoreJson(updatedMembership as unknown as Record<string, unknown>)
          );
        }

        // Update request to approved
        const updatedRequest = { ...userMembershipRequest, status: MembershipRequestStatus.approved };
        if (userMembershipRequestSnap.exists) {
          transaction.update(
            userMembershipRequestRef,
            jsonSubset(['status'], firestoreUtils.toFirestoreJson(updatedRequest as unknown as Record<string, unknown>))
          );
        } else {
          transaction.set(
            userMembershipRequestRef,
            firestoreUtils.toFirestoreJson(updatedRequest as unknown as Record<string, unknown>)
          );
        }
      } else {
        // Deny
        const updatedRequest = { ...userMembershipRequest, status: MembershipRequestStatus.denied };
        if (userMembershipRequestSnap.exists) {
          transaction.update(
            userMembershipRequestRef,
            jsonSubset(['status'], firestoreUtils.toFirestoreJson(updatedRequest as unknown as Record<string, unknown>))
          );
        } else {
          transaction.set(
            userMembershipRequestRef,
            firestoreUtils.toFirestoreJson(updatedRequest as unknown as Record<string, unknown>)
          );
        }
      }
    });
  }
}
