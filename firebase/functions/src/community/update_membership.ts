import * as functions from 'firebase-functions';
import { HttpsError } from 'firebase-functions/lib/providers/https';
import { firestore, firestoreUtils } from '../utils/infra/firestore_utils';
import { OnCallMethod } from '../on_call_function';
import {
  UpdateMembershipRequest, Membership, MembershipStatus, Community,
} from '../types';
import { orElseUnauthorized, orElseInvalidArgument, orElseNotFound, jsonSubset } from '../utils/utils';
import { subscriptionPlanUtil } from '../utils/subscription_plan_util';
import {
  membershipIsAdmin, membershipIsMod, membershipIsMember, membershipIsFacilitator
} from '../types';

export class UpdateMembership extends OnCallMethod<UpdateMembershipRequest> {
  constructor() {
    super('updateMembership', (json) => json as UpdateMembershipRequest);
  }

  async action(
    request: UpdateMembershipRequest,
    context: functions.https.CallableContext
  ): Promise<void> {
    orElseUnauthorized(context.auth?.uid != null);
    orElseInvalidArgument(request.status != null);

    const authUid = context.auth!.uid;
    const { communityId, userId: targetUserId, status: targetStatus } = request;

    const communitySnapshot = await firestore.doc(`community/${communityId}`).get();
    orElseNotFound(communitySnapshot.exists);
    const community = communitySnapshot.data() as Community;

    const requesterMembershipSnap = await firestore
      .doc(`memberships/${authUid}/community-membership/${communityId}`)
      .get();
    const requesterStatus = requesterMembershipSnap.exists
      ? ((requesterMembershipSnap.data() as Membership).status ?? MembershipStatus.nonmember)
      : MembershipStatus.nonmember;

    const targetMembershipDoc = firestore.doc(`memberships/${targetUserId}/community-membership/${communityId}`);
    const targetMembershipSnap = await targetMembershipDoc.get();
    const currentStatus = targetMembershipSnap.exists
      ? ((targetMembershipSnap.data() as Membership).status ?? MembershipStatus.nonmember)
      : MembershipStatus.nonmember;

    orElseUnauthorized(
      this._isValidMemberUpdate({
        community,
        requesterStatus,
        currentStatus,
        targetStatus: targetStatus!,
        requestingUserId: authUid,
        targetUserId,
      })
    );

    const adminStatuses = [MembershipStatus.admin, MembershipStatus.owner, MembershipStatus.moderator];
    const facilitatorStatuses = [MembershipStatus.facilitator];
    const elevatingToAdmin = !adminStatuses.includes(currentStatus) && adminStatuses.includes(targetStatus!);
    const elevatingToFacilitator = !facilitatorStatuses.includes(currentStatus) && facilitatorStatuses.includes(targetStatus!);

    if (elevatingToAdmin || elevatingToFacilitator) {
      const capabilities = await subscriptionPlanUtil.calculateCapabilities(communityId);

      if (elevatingToAdmin) {
        const [adminDocs, ownerDocs, modDocs] = await Promise.all([
          firestore.collectionGroup('community-membership').where('communityId', '==', communityId).where('status', '==', MembershipStatus.admin).get(),
          firestore.collectionGroup('community-membership').where('communityId', '==', communityId).where('status', '==', MembershipStatus.owner).get(),
          firestore.collectionGroup('community-membership').where('communityId', '==', communityId).where('status', '==', MembershipStatus.moderator).get(),
        ]);

        const visibleAdmins = [...adminDocs.docs, ...ownerDocs.docs, ...modDocs.docs]
          .filter((doc) => !(doc.data() as Membership).invisible);

        if (visibleAdmins.length >= (capabilities.adminCount ?? 0)) {
          throw new HttpsError('resource-exhausted', 'Insufficient admin count quota.');
        }
      }

      if (elevatingToFacilitator) {
        const facilitatorDocs = await firestore
          .collectionGroup('community-membership')
          .where('communityId', '==', communityId)
          .where('status', '==', MembershipStatus.facilitator)
          .get();

        const currentNumFacilitators = facilitatorDocs.docs.filter(
          (doc) => !(doc.data() as Membership).invisible
        ).length;

        if (currentNumFacilitators >= (capabilities.facilitatorCount ?? 0)) {
          throw new HttpsError('resource-exhausted', 'Insufficient facilitator count quota.');
        }
      }
    }

    const updatedMembership: Membership = {
      userId: targetUserId,
      communityId,
      status: targetStatus,
      firstJoined: new Date(),
    };

    const data = jsonSubset(
      ['status'],
      firestoreUtils.toFirestoreJson(updatedMembership as unknown as Record<string, unknown>)
    );

    if (targetMembershipSnap.exists) {
      await targetMembershipDoc.update(data);
    } else {
      await targetMembershipDoc.set(
        firestoreUtils.toFirestoreJson(updatedMembership as unknown as Record<string, unknown>),
        { merge: true }
      );
    }
  }

  private _isValidMemberUpdate(opts: {
    community: Community;
    requesterStatus: MembershipStatus;
    currentStatus: MembershipStatus;
    targetStatus: MembershipStatus;
    requestingUserId: string;
    targetUserId: string;
  }): boolean {
    const { requesterStatus, currentStatus, targetStatus, requestingUserId, targetUserId } = opts;

    // Can't modify self (except leaving)
    if (requestingUserId === targetUserId && targetStatus !== MembershipStatus.nonmember) {
      return false;
    }

    // Need to be at least a mod to change others
    if (!membershipIsMod(requesterStatus)) return false;

    // Can't promote to a level equal to or above their own
    if (membershipIsAdmin(targetStatus) && !membershipIsAdmin(requesterStatus)) return false;
    if (targetStatus === MembershipStatus.owner) return false;

    // Can't demote someone at or above your level
    if (membershipIsAdmin(currentStatus) && !membershipIsAdmin(requesterStatus)) return false;

    return true;
  }
}
