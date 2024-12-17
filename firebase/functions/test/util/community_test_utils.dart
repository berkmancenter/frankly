import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:functions/community/create_community.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/firestore/community.dart';
import 'package:data_models/firestore/membership.dart';
import 'package:functions/utils/firestore_utils.dart';

class CommunityTestUtils {
  Future<Map<String, dynamic>> createCommunity({
    required Community community,
    required String userId,
  }) async {
    final communityCreator = CreateCommunity();
    final req = CreateCommunityRequest(community: community);
    final result = await communityCreator.action(
      req,
      CallableContext(userId, null, 'fakeInstanceId'),
    );
    return result;
  }

  Future<void> addCommunityMember({
    required String userId,
    required String communityId,
    MembershipStatus status = MembershipStatus.attendee,
  }) async {
    await firestore.runTransaction((transaction) async {
      transaction.set(
        firestore
            .document('memberships/$userId/community-membership/$communityId'),
        DocumentData.fromMap(
          firestoreUtils.toFirestoreJson(
            Membership(
              communityId: communityId,
              userId: userId,
              status: status,
            ).toJson(),
          ),
        ),
      );
    });
  }
}
