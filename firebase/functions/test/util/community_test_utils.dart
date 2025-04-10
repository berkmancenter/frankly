import 'package:data_models/community/membership_request.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart'
    as admin_interop;
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:functions/community/create_community.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/community/membership.dart';
import 'package:functions/utils/infra/firebase_auth_utils.dart';
import 'package:functions/utils/infra/firestore_utils.dart';
import 'package:mocktail/mocktail.dart';

const adminUserId = 'adminUser';

class CommunityTestUtils {
  static final testCommunity = Community(
    id: '1999',
    name: 'Testing Community',
    isPublic: true,
  );
  Future<String> createTestCommunity() async {
    final result =
        await createCommunity(community: testCommunity, userId: adminUserId);
    return result['communityId'];
  }

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
        admin_interop.DocumentData.fromMap(
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

  Future<void> addJoinRequest({
    required MembershipRequest request,
  }) async {
    await firestore.runTransaction((transaction) async {
      transaction.set(
        firestore.document(
          'community/${request.communityId}/join-requests/${request.userId}',
        ),
        admin_interop.DocumentData.fromMap(
          firestoreUtils.toFirestoreJson(
            request.toJson(),
          ),
        ),
      );
    });
  }
}

class MockFirebaseAuthUtils extends Mock implements FirebaseAuthUtils {}

class MockUserRecord extends Mock implements admin_interop.UserRecord {}

class MockEventContext extends Mock implements EventContext {}
