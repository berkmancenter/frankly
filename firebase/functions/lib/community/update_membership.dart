import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../on_call_function.dart';
import '../utils/infra/firestore_utils.dart';
import '../utils/subscription_plan_util.dart';
import '../utils/utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/community/membership.dart';
import 'package:data_models/utils/utils.dart';

/// Change membership for a user, taking into account the permissions of the requester and
/// potentially the admin count quota of their plan.
class UpdateMembership extends OnCallMethod<UpdateMembershipRequest> {
  UpdateMembership()
      : super(
          'updateMembership',
          (json) => UpdateMembershipRequest.fromJson(json),
        );

  @override
  Future<void> action(
    UpdateMembershipRequest request,
    CallableContext context,
  ) async {
    orElseUnauthorized(context.authUid != null);
    orElseInvalidArgument(request.status != null);

    final authUid = context.authUid;
    final communityId = request.communityId;
    final targetUserId = request.userId;
    final targetStatus = request.status;

    // Get needed data.
    final communitySnapshot =
        await firestore.document('community/$communityId').get();
    orElseNotFound(communitySnapshot.exists);
    final community = Community.fromJson(
      firestoreUtils.fromFirestoreJson(communitySnapshot.data.toMap()),
    );

    final requesterMembershipDoc = firestore
        .document('memberships/$authUid/community-membership/$communityId');
    final requesterMembershipSnapshot = await requesterMembershipDoc.get();
    final requesterStatus = requesterMembershipSnapshot.exists
        ? Membership.fromJson(
              firestoreUtils.fromFirestoreJson(
                requesterMembershipSnapshot.data.toMap(),
              ),
            ).status ??
            MembershipStatus.nonmember
        : MembershipStatus.nonmember;

    final targetMembershipDoc = firestore.document(
      'memberships/$targetUserId/community-membership/$communityId',
    );
    final targetMembershipSnapshot = await targetMembershipDoc.get();
    final currentStatus = targetMembershipSnapshot.exists
        ? Membership.fromJson(
              firestoreUtils
                  .fromFirestoreJson(targetMembershipSnapshot.data.toMap()),
            ).status ??
            MembershipStatus.nonmember
        : MembershipStatus.nonmember;

    // Check if user is privileged to attempt this change.
    orElseUnauthorized(
      _isValidMemberUpdate(
        community: community,
        requesterStatus: requesterStatus,
        currentStatus: currentStatus,
        targetStatus: targetStatus!,
        requestingUserId: context.authUid!,
        targetUserId: targetUserId,
      ),
    );

    // If elevating to admin, ensure sufficient quota.

    final adminStatuses = [
      MembershipStatus.admin,
      MembershipStatus.owner,
      MembershipStatus.mod,
    ];
    final facilitatorStatuses = [MembershipStatus.facilitator];
    final elevatingToAdmin = !adminStatuses.contains(currentStatus) &&
        adminStatuses.contains(request.status);
    final elevatingToFacilitator =
        !facilitatorStatuses.contains(currentStatus) &&
            facilitatorStatuses.contains(request.status);

    if (elevatingToAdmin || elevatingToFacilitator) {
      final capabilities =
          await subscriptionPlanUtil.calculateCapabilities(request.communityId);

      if (elevatingToAdmin) {
        final adminMemberships = await firestore
            .collectionGroup('community-membership')
            .where(Membership.kFieldCommunityId, isEqualTo: request.communityId)
            .where(
              Membership.kFieldStatus,
              isEqualTo: EnumToString.convertToString(MembershipStatus.admin),
            )
            .get();
        final ownerMemberships = await firestore
            .collectionGroup('community-membership')
            .where(Membership.kFieldCommunityId, isEqualTo: request.communityId)
            .where(
              Membership.kFieldStatus,
              isEqualTo: EnumToString.convertToString(MembershipStatus.owner),
            )
            .get();
        final modMemberships = await firestore
            .collectionGroup('community-membership')
            .where(Membership.kFieldCommunityId, isEqualTo: request.communityId)
            .where(
              Membership.kFieldStatus,
              isEqualTo: EnumToString.convertToString(MembershipStatus.mod),
            )
            .get();

        final visibleAdmins = [
          ...adminMemberships.documents,
          ...ownerMemberships.documents,
          ...modMemberships.documents,
        ]
            .where(
              (element) =>
                  !(element.data.getBool(Membership.kFieldInvisible) ?? false),
            )
            .toList();

        final currentNumAdmins = visibleAdmins.length;

        if (currentNumAdmins >= (capabilities.adminCount ?? 0)) {
          throw HttpsError(
            HttpsError.resourceExhausted,
            'Insufficient admin count quota.',
            null,
          );
        }
      }

      if (elevatingToFacilitator) {
        final facilitatorMemberships = await firestore
            .collectionGroup('community-membership')
            .where(Membership.kFieldCommunityId, isEqualTo: request.communityId)
            .where(
              Membership.kFieldStatus,
              isEqualTo:
                  EnumToString.convertToString(MembershipStatus.facilitator),
            )
            .get();

        final currentNumFacilitators = facilitatorMemberships.documents
            .where(
              (element) =>
                  !(element.data.getBool(Membership.kFieldInvisible) ?? false),
            )
            .length;

        if (currentNumFacilitators >= (capabilities.facilitatorCount ?? 0)) {
          throw HttpsError(
            HttpsError.resourceExhausted,
            'Insufficient facilitator count quota.',
            null,
          );
        }
      }
    }

    // Make membership change.
    Membership updatedMembership = Membership(
      userId: request.userId,
      communityId: request.communityId,
      status: request.status,
      firstJoined: DateTime.now(),
    );

    if (targetMembershipSnapshot.exists) {
      final data = UpdateData.fromMap(
        jsonSubset(
          [
            Membership.kFieldStatus,
          ],
          firestoreUtils.toFirestoreJson(updatedMembership.toJson()),
        ),
      );
      await targetMembershipDoc.updateData(data);
    } else {
      final data = DocumentData.fromMap(
        firestoreUtils.toFirestoreJson(updatedMembership.toJson()),
      );
      await targetMembershipDoc.setData(data, SetOptions(merge: true));
    }
  }

  /// Determine if requesting user is allowed to do this (ignoring admin quota limitations).
  bool _isValidMemberUpdate({
    required Community community,
    required MembershipStatus requesterStatus,
    required MembershipStatus currentStatus,
    required MembershipStatus targetStatus,
    required String requestingUserId,
    required String targetUserId,
  }) {
    return targetUserId == requestingUserId &&
            _canChangeSelfStatus(
              community: community,
              targetStatus: targetStatus,
              targetUserId: targetUserId,
            ) ||
        _canChangeElevatedMembership(
          requesterStatus: requesterStatus,
          currentStatus: currentStatus,
          targetStatus: targetStatus,
        );
  }

  bool _canChangeElevatedMembership({
    required MembershipStatus requesterStatus,
    required MembershipStatus currentStatus,
    required MembershipStatus targetStatus,
  }) {
    return currentStatus != MembershipStatus.nonmember &&
        (requesterStatus == MembershipStatus.owner ||
            (requesterStatus == MembershipStatus.admin &&
                ![targetStatus, currentStatus]
                    .contains(MembershipStatus.owner)));
  }

  bool _requiresApprovalToJoin(Community community) {
    return community.settingsMigration.requireApprovalToJoin;
  }

  bool _isCommunityCreator(Community community, String userId) {
    return community.creatorId == userId;
  }

  bool _canChangeSelfStatus({
    required Community community,
    required MembershipStatus targetStatus,
    required String targetUserId,
  }) {
    final requiresApproval = _requiresApprovalToJoin(community);
    final selfStatuses = [
      MembershipStatus.attendee,
      MembershipStatus.nonmember,
      if (!requiresApproval) MembershipStatus.member,
    ];
    return selfStatuses.contains(targetStatus) ||
        (targetStatus == MembershipStatus.owner &&
            _isCommunityCreator(community, targetUserId));
  }
}
