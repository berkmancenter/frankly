import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/on_call_function.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_functions/utils/subscription_plan_util.dart';
import 'package:junto_functions/utils/utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/membership.dart';
import 'package:junto_models/utils.dart';

/// Change membership for a user, taking into account the permissions of the requester and
/// potentially the admin count quota of their plan.
class UpdateMembership extends OnCallMethod<UpdateMembershipRequest> {
  UpdateMembership()
      : super('updateMembership',
            (json) => UpdateMembershipRequest.fromJson(json));

  @override
  Future<void> action(
      UpdateMembershipRequest request, CallableContext context) async {
    orElseUnauthorized(context?.authUid != null);
    orElseInvalidArgument(request.status != null);

    final authUid = context?.authUid!;
    final juntoId = request.juntoId;
    final targetUserId = request.userId;
    final targetStatus = request.status!;
    final invisible = request.invisible;

    // Get needed data.
    final juntoSnapshot = await firestore.document('junto/$juntoId').get();
    orElseNotFound(juntoSnapshot.exists);
    final junto = Junto.fromJson(
        firestoreUtils.fromFirestoreJson(juntoSnapshot.data.toMap()));

    final requesterMembershipDoc =
        firestore.document('memberships/$authUid/junto-membership/$juntoId');
    final requesterMembershipSnapshot = await requesterMembershipDoc.get();
    final requesterStatus = requesterMembershipSnapshot.exists
        ? Membership.fromJson(firestoreUtils.fromFirestoreJson(
                    requesterMembershipSnapshot.data.toMap()))
                .status ??
            MembershipStatus.nonmember
        : MembershipStatus.nonmember;

    final targetMembershipDoc = firestore
        .document('memberships/$targetUserId/junto-membership/$juntoId');
    final targetMembershipSnapshot = await targetMembershipDoc.get();
    final currentStatus = targetMembershipSnapshot.exists
        ? Membership.fromJson(firestoreUtils
                    .fromFirestoreJson(targetMembershipSnapshot.data.toMap()))
                .status ??
            MembershipStatus.nonmember
        : MembershipStatus.nonmember;

    final userRecord = await firestoreUtils.getUsers([authUid!]);
    final prodDomain = functions.config.get('app.prod_domain') as String;
    final alternativeEmailDomain =
        functions.config.get('app.alt_email_domain') as String;
    final isSuperAdmin = userRecord.isNotEmpty &&
        userRecord.first.emailVerified &&
        (userRecord.first.email.split('@').last == prodDomain ||
            userRecord.first.email.split('@').last == alternativeEmailDomain);

    // Check if user is privileged to attempt this change.
    orElseUnauthorized(_isValidMemberUpdate(
          junto: junto,
          requesterStatus: requesterStatus,
          currentStatus: currentStatus,
          targetStatus: targetStatus,
          requestingUserId: context!.authUid!,
          targetUserId: targetUserId,
        ) ||
        isSuperAdmin);

    // If elevating to admin, ensure sufficient quota.

    final adminStatuses = [
      MembershipStatus.admin,
      MembershipStatus.owner,
      MembershipStatus.mod
    ];
    final facilitatorStatuses = [MembershipStatus.facilitator];
    final elevatingToAdmin = !adminStatuses.contains(currentStatus) &&
        adminStatuses.contains(request.status);
    final elevatingToFacilitator =
        !facilitatorStatuses.contains(currentStatus) &&
            facilitatorStatuses.contains(request.status);

    if (!isSuperAdmin && (elevatingToAdmin || elevatingToFacilitator)) {
      final capabilities =
          await subscriptionPlanUtil.calculateCapabilities(request.juntoId);

      if (elevatingToAdmin) {
        final adminMemberships = await firestore
            .collectionGroup('junto-membership')
            .where(Membership.kFieldJuntoId, isEqualTo: request.juntoId)
            .where(Membership.kFieldStatus,
                isEqualTo: EnumToString.convertToString(MembershipStatus.admin))
            .get();
        final ownerMemberships = await firestore
            .collectionGroup('junto-membership')
            .where(Membership.kFieldJuntoId, isEqualTo: request.juntoId)
            .where(Membership.kFieldStatus,
                isEqualTo: EnumToString.convertToString(MembershipStatus.owner))
            .get();
        final modMemberships = await firestore
            .collectionGroup('junto-membership')
            .where(Membership.kFieldJuntoId, isEqualTo: request.juntoId)
            .where(Membership.kFieldStatus,
                isEqualTo: EnumToString.convertToString(MembershipStatus.mod))
            .get();

        final visibleAdmins = [
          ...adminMemberships.documents,
          ...ownerMemberships.documents,
          ...modMemberships.documents
        ]
            .where((element) =>
                !(element.data?.getBool(Membership.kFieldInvisible) ?? false))
            .toList();

        final currentNumAdmins = visibleAdmins.length;

        if (currentNumAdmins >= (capabilities.adminCount ?? 0)) {
          throw HttpsError(HttpsError.resourceExhausted,
              'Insufficient admin count quota.', null);
        }
      }

      if (elevatingToFacilitator) {
        final facilitatorMemberships = await firestore
            .collectionGroup('junto-membership')
            .where(Membership.kFieldJuntoId, isEqualTo: request.juntoId)
            .where(Membership.kFieldStatus,
                isEqualTo:
                    EnumToString.convertToString(MembershipStatus.facilitator))
            .get();

        final currentNumFacilitators = facilitatorMemberships.documents
            .where((element) =>
                !(element.data?.getBool(Membership.kFieldInvisible) ?? false))
            .length;

        if (currentNumFacilitators >= (capabilities.facilitatorCount ?? 0)) {
          throw HttpsError(HttpsError.resourceExhausted,
              'Insufficient facilitator count quota.', null);
        }
      }
    }

    // Make membership change.
    Membership updatedMembership = Membership(
      userId: request.userId,
      juntoId: request.juntoId,
      status: request.status,
      firstJoined: DateTime.now(),
    );
    if ((invisible ?? false) && isSuperAdmin) {
      updatedMembership = updatedMembership.copyWith(invisible: true);
    }
    if (targetMembershipSnapshot.exists) {
      final data = UpdateData.fromMap(
        jsonSubset(
          [
            Membership.kFieldStatus,
            if ((invisible != null) && isSuperAdmin) Membership.kFieldInvisible,
          ],
          firestoreUtils.toFirestoreJson(updatedMembership.toJson()),
        ),
      );
      await targetMembershipDoc.updateData(data);
    } else {
      final data = DocumentData.fromMap(
          firestoreUtils.toFirestoreJson(updatedMembership.toJson()));
      await targetMembershipDoc.setData(data, SetOptions(merge: true));
    }
  }

  /// Determine if requesting user is allowed to do this (ignoring admin quota limitations).
  /// See https://github.com/JuntoChat/kazm_asml/blob/84bb24b68527aff524f2ae24ca3a48b1d6f97b03/client/firestore/firestore.rules#L415-L446
  bool _isValidMemberUpdate({
    required Junto junto,
    required MembershipStatus requesterStatus,
    required MembershipStatus currentStatus,
    required MembershipStatus targetStatus,
    required String requestingUserId,
    required String targetUserId,
  }) {
    return targetUserId == requestingUserId &&
            _canChangeSelfStatus(
              junto: junto,
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

  bool _requiresApprovalToJoin(Junto junto) {
    return junto.settingsMigration.requireApprovalToJoin;
  }

  bool _isJuntoCreator(Junto junto, String userId) {
    return junto.creatorId == userId;
  }

  bool _canChangeSelfStatus({
    required Junto junto,
    required MembershipStatus targetStatus,
    required String targetUserId,
  }) {
    final requiresApproval = _requiresApprovalToJoin(junto);
    final selfStatuses = [
      MembershipStatus.attendee,
      MembershipStatus.nonmember,
      if (!requiresApproval) MembershipStatus.member,
    ];
    return selfStatuses.contains(targetStatus) ||
        (targetStatus == MembershipStatus.owner &&
            _isJuntoCreator(junto, targetUserId));
  }
}
