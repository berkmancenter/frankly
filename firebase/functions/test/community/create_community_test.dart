import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/community/membership.dart';
import 'package:test/test.dart';
import 'package:functions/community/create_community.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:functions/utils/firestore_utils.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart';

void main() {
  setUp(() async {
    setFirebaseAppFactory(() => FirebaseAdmin.instance.initializeApp()!);
  });

  test('Community should be created without partner agreement', () async {
    const userId = 'fakeAuthId';
    final communityCreator = CreateCommunity();
    final testCommunity = Community(
      id: '1234',
      name: 'Testing Community',
      isPublic: true,
      profileImageUrl: 'http://someimage.com',
      bannerImageUrl: 'http://mybanner.com',
    );
    final req = CreateCommunityRequest(community: testCommunity);
    final result = await communityCreator.action(
      req,
      CallableContext(userId, null, 'fakeInstanceId'),
    );
    expect(result, contains('communityId'));
    final communityId = result['communityId'];
    final communitySnapshot =
        await firestore.document('community/$communityId').get();
    final createdCommunity = Community.fromJson(
      firestoreUtils.fromFirestoreJson(communitySnapshot.data.toMap()),
    );

    final expectedCommunity = testCommunity.copyWith(
      id: communityId,
      creatorId: userId,
      communitySettings: const CommunitySettings(),
      eventSettings: EventSettings.defaultSettings,
      createdDate: createdCommunity.createdDate,
      displayIds: [communityId],
    );

    expect(createdCommunity, equals(expectedCommunity));
    final membershipSnapshot = await firestore
        .document('memberships/fakeAuthId/community-membership/$communityId')
        .get();
    final createdMembership = Membership.fromJson(
      firestoreUtils.fromFirestoreJson(membershipSnapshot.data.toMap()),
    );
    expect(
      createdMembership,
      equals(
        Membership(
          communityId: communityId,
          userId: userId,
          status: MembershipStatus.owner,
          firstJoined: createdMembership.firstJoined,
        ),
      ),
    );
    // add verification of partner agreement when default partner agreement info added to firestore
  });

  test('Community should be created under existing partner agreement',
      () async {
    // Implement this when default partner agreement info added to firestore
  });

  test('Community should be created with default image URLs', () async {
    const userId = 'fakeAuthId';
    final communityCreator = CreateCommunity();
    final testCommunity =
        Community(id: '1234', name: 'Testing Community', isPublic: true);
    final req = CreateCommunityRequest(community: testCommunity);
    final result = await communityCreator.action(
      req,
      CallableContext(userId, null, 'fakeInstanceId'),
    );
    expect(result, contains('communityId'));
    final communityId = result['communityId'];
    final communitySnapshot =
        await firestore.document('community/$communityId').get();
    final createdCommunity = Community.fromJson(
      firestoreUtils.fromFirestoreJson(communitySnapshot.data.toMap()),
    );

    final expectedCommunity = testCommunity.copyWith(
      id: communityId,
      creatorId: userId,
      communitySettings: const CommunitySettings(),
      eventSettings: EventSettings.defaultSettings,
      createdDate: createdCommunity.createdDate,
      profileImageUrl: 'https://picsum.photos/seed/$communityId-profile/512',
      bannerImageUrl: '',
      displayIds: [communityId],
    );

    expect(createdCommunity, equals(expectedCommunity));
    final membershipSnapshot = await firestore
        .document('memberships/fakeAuthId/community-membership/$communityId')
        .get();
    final createdMembership = Membership.fromJson(
      firestoreUtils.fromFirestoreJson(membershipSnapshot.data.toMap()),
    );
    expect(
      createdMembership,
      equals(
        Membership(
          communityId: communityId,
          userId: userId,
          status: MembershipStatus.owner,
          firstJoined: createdMembership.firstJoined,
        ),
      ),
    );
  });

  test('Exception should be thrown if specified partner agreement not found',
      () async {
    const userId = 'fakeAuthId';
    final communityCreator = CreateCommunity();
    final testCommunity =
        Community(id: '1234', name: 'Testing Community', isPublic: true);
    final req = CreateCommunityRequest(
      community: testCommunity,
      agreementId: 'fakeagreement',
    );
    expect(
      () async {
        await communityCreator.action(
          req,
          CallableContext(userId, null, 'fakeInstanceId'),
        );
      },
      throwsA(
        predicate(
          (e) =>
              e is HttpsError &&
              e.code == HttpsError.failedPrecondition &&
              e.message == 'unauthorized',
        ),
      ),
    );
  });

  test('Exception should be thrown if no community specified', () async {
    const userId = 'fakeAuthId';
    final communityCreator = CreateCommunity();
    final req = CreateCommunityRequest(community: null);
    expect(
      () async {
        await communityCreator.action(
          req,
          CallableContext(userId, null, 'fakeInstanceId'),
        );
      },
      throwsA(
        predicate(
          (e) =>
              e is HttpsError &&
              e.code == HttpsError.failedPrecondition &&
              e.message == 'Must provide community information.',
        ),
      ),
    );
  });

  test('Exception should be thrown if community name not specified', () async {
    const userId = 'fakeAuthId';
    final communityCreator = CreateCommunity();
    final testCommunity = Community(id: '1234', isPublic: true);
    final req = CreateCommunityRequest(community: testCommunity);
    expect(
      () async {
        await communityCreator.action(
          req,
          CallableContext(userId, null, 'fakeInstanceId'),
        );
      },
      throwsA(
        predicate(
          (e) =>
              e is HttpsError &&
              e.code == HttpsError.failedPrecondition &&
              e.message == 'Name is required.',
        ),
      ),
    );
  });

  test('Exception should be thrown if request unauthorized', () async {
    final communityCreator = CreateCommunity();
    final testCommunity = Community(id: '1234', isPublic: true);
    final req = CreateCommunityRequest(community: testCommunity);
    expect(
      () async {
        await communityCreator.action(
          req,
          CallableContext(null, null, 'fakeInstanceId'),
        );
      },
      throwsA(
        predicate(
          (e) =>
              e is HttpsError &&
              e.code == HttpsError.failedPrecondition &&
              e.message == 'unauthorized',
        ),
      ),
    );
  });
}
