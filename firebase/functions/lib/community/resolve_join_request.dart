import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../on_call_function.dart';
import '../utils/email_templates.dart';
import '../utils/firestore_utils.dart';
import '../utils/send_email_client.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/community/membership.dart';
import 'package:data_models/community/membership_request.dart';
import 'package:data_models/utils/utils.dart';

class ResolveJoinRequest extends OnCallMethod<ResolveJoinRequestRequest> {
  ResolveJoinRequest()
      : super(
          'resolveJoinRequest',
          (jsonMap) => ResolveJoinRequestRequest.fromJson(jsonMap),
        );

  @override
  Future<void> action(
    ResolveJoinRequestRequest request,
    CallableContext context,
  ) async {
    return firestore.runTransaction((transaction) async {
      // get docs and verify admin permitted to approve / deny

      final modMembership = await firestoreUtils.getFirestoreObject(
        transaction: transaction,
        path:
            'memberships/${context.authUid}/community-membership/${request.communityId}',
        constructor: (map) => Membership.fromJson(map),
      );

      final userMembershipRequestSnapshot = await transaction.get(
        firestore.document(
          'community/${request.communityId}/join-requests/${request.userId}',
        ),
      );
      final userMembershipRequest = MembershipRequest.fromJson(
        userMembershipRequestSnapshot.data.toMap() ?? {},
      );
      final hasActiveRequest =
          userMembershipRequest.status == MembershipRequestStatus.requested;

      final userMembershipSnapshot = await transaction.get(
        firestore.document(
          'memberships/${request.userId}/community-membership/${request.communityId}',
        ),
      );
      final userMembership = userMembershipSnapshot.exists
          ? Membership.fromJson(
              firestoreUtils
                  .fromFirestoreJson(userMembershipSnapshot.data.toMap() ?? {}),
            )
          : Membership(
              userId: request.userId,
              communityId: request.communityId,
              status: MembershipStatus.nonmember,
              firstJoined: DateTime.now(),
            );

      if (!modMembership.isMod ||
          !hasActiveRequest ||
          userMembership.status?.isMember == true) {
        throw HttpsError(HttpsError.failedPrecondition, 'unauthorized', null);
      }

      // perform approval / denial

      if (request.approve == true) {
        final email = await constructApprovalEmail(
          transaction: transaction,
          userId: request.userId,
          communityId: request.communityId,
        );

        final userMembershipUpdated =
            userMembership.copyWith(status: MembershipStatus.member);
        if (userMembershipSnapshot.exists) {
          transaction.update(
            userMembershipSnapshot.reference,
            UpdateData.fromMap(
              jsonSubset(
                ['status'],
                firestoreUtils.toFirestoreJson(userMembershipUpdated.toJson()),
              ),
            ),
          );
        } else {
          transaction.set(
            userMembershipSnapshot.reference,
            DocumentData.fromMap(
              firestoreUtils.toFirestoreJson(userMembershipUpdated.toJson()),
            ),
          );
        }

        final userMembershipRequestUpdated = userMembershipRequest.copyWith(
          status: MembershipRequestStatus.approved,
        );
        if (userMembershipRequestSnapshot.exists) {
          transaction.update(
            userMembershipRequestSnapshot.reference,
            UpdateData.fromMap(
              jsonSubset(
                ['status'],
                firestoreUtils.toFirestoreJson(
                  userMembershipRequestUpdated.toJson(),
                ),
              ),
            ),
          );
        } else {
          transaction.set(
            userMembershipRequestSnapshot.reference,
            DocumentData.fromMap(
              firestoreUtils
                  .toFirestoreJson(userMembershipRequestUpdated.toJson()),
            ),
          );
        }

        await sendEmailClient.sendEmail(email, transaction: transaction);
      } else {
        final userMembershipRequestUpdated = userMembershipRequest.copyWith(
          status: MembershipRequestStatus.denied,
        );
        if (userMembershipRequestSnapshot.exists) {
          transaction.update(
            userMembershipRequestSnapshot.reference,
            UpdateData.fromMap(
              jsonSubset(
                ['status'],
                firestoreUtils.toFirestoreJson(
                  userMembershipRequestUpdated.toJson(),
                ),
              ),
            ),
          );
        } else {
          transaction.set(
            userMembershipRequestSnapshot.reference,
            DocumentData.fromMap(
              firestoreUtils
                  .toFirestoreJson(userMembershipRequestUpdated.toJson()),
            ),
          );
        }
      }
    });
  }

  Future<SendGridEmail> constructApprovalEmail({
    required Transaction transaction,
    required String userId,
    required String communityId,
  }) async {
    final users = await firestoreUtils.getUsers([userId]);
    final community = await firestoreUtils.getFirestoreObject(
      path: 'community/$communityId',
      constructor: (map) => Community.fromJson(map),
    );

    final emailAddress = users.single.email;
    final message = SendGridEmailMessage(
      subject: 'Join Request Approved: ${community.name ?? community.id}',
      html: makeJoinApprovedBody(community: community),
    );
    final noReplyEmailAddr =
        functions.config.get('app.no_reply_email') as String;
    return SendGridEmail(
      to: [emailAddress],
      from: '${community.name ?? community.id} <$noReplyEmailAddr>',
      message: message,
    );
  }
}
