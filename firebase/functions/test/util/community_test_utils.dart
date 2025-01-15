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

  Future<void> deleteAllCommunities() async {
    // Clean up all test data

    // Delete all communities
    final communityDocs = await firestore.collection('community').get();
    await Future.wait(
      communityDocs.documents.map((doc) async {
        // First delete all subcollections
        final commId = doc.documentID;

        // Delete join requests
        final joinRequestDocs =
            await firestore.collection('community/$commId/join-requests').get();
        await Future.wait(
          joinRequestDocs.documents.map((d) => d.reference.delete()),
        );

        // Delete events
        final eventDocs = await firestore
            .collectionGroup('events')
            .where('communityId', isEqualTo: commId)
            .get();
        await Future.wait(
          eventDocs.documents.map((d) => d.reference.delete()),
        );

        // Delete templates
        final templateDocs =
            await firestore.collection('community/$commId/templates').get();
        await Future.wait(
          templateDocs.documents.map((d) => d.reference.delete()),
        );

        // Delete the community document itself
        await doc.reference.delete();
      }),
    );

    // Delete all memberships
    final membershipDocs =
        await firestore.collectionGroup('community-membership').get();
    await Future.wait(
      membershipDocs.documents.map((doc) => doc.reference.delete()),
    );

    // Delete all user settings
    final settingsDocs =
        await firestore.collectionGroup('communityUserSettings').get();
    await Future.wait(
      settingsDocs.documents.map((doc) => doc.reference.delete()),
    );

    // Delete all email digests
    final digestDocs = await firestore.collectionGroup('emailDigests').get();
    await Future.wait(
      digestDocs.documents.map((doc) => doc.reference.delete()),
    );
  }
}

class MockFirebaseAuthUtils extends Mock implements FirebaseAuthUtils {}

class MockUserRecord extends Mock implements admin_interop.UserRecord {}
