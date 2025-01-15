import 'package:data_models/community/membership.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/community/community.dart';
import 'package:functions/community/update_community.dart';
import 'package:test/test.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:functions/utils/infra/firestore_utils.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart';

import '../util/community_test_utils.dart';
import '../util/subscription_test_utils.dart';

void main() {
  const userId = 'fakeAuthId';
  String communityId = '';
  final communityTestUtils = CommunityTestUtils();
  final subscriptionTestUtils = SubscriptionTestUtils();

  setUp(() async {
    setFirebaseAppFactory(() => FirebaseAdmin.instance.initializeApp()!);
    Community testCommunity = Community(
      id: '1999',
      name: 'Testing Community',
      isPublic: true,
      profileImageUrl: 'http://someimage.com',
      bannerImageUrl: 'http://mybanner.com',
    );

    final communityResult = await communityTestUtils.createCommunity(
      community: testCommunity,
      userId: userId,
    );
    communityId = communityResult['communityId'];
  });

  test('Community should be updated', () async {
    final communityUpdater = UpdateCommunity();
    final testCommunity = Community(
      id: communityId,
      name: 'Testing Community Too',
      isPublic: false,
      description: 'A community of testers',
      tagLine: 'Test It!',
    );
    final req = UpdateCommunityRequest(
      community: testCommunity,
      keys: [
        Community.kFieldName,
        Community.kFieldTagLine,
        Community.kFieldDescription,
      ],
    );
    final result = await communityUpdater.action(
      req,
      CallableContext(userId, null, 'fakeInstanceId'),
    );
    expect(result, equals(''));

    final communitySnapshot =
        await firestore.document('community/$communityId').get();
    final updatedCommunity = Community.fromJson(
      firestoreUtils.fromFirestoreJson(communitySnapshot.data.toMap()),
    );

    final expectedCommunity = testCommunity.copyWith(
      id: communityId,
      creatorId: userId,
      isPublic: true,
      communitySettings: const CommunitySettings(),
      eventSettings: EventSettings.defaultSettings,
      createdDate: updatedCommunity.createdDate,
      displayIds: [communityId],
      profileImageUrl: 'http://someimage.com',
      bannerImageUrl: 'http://mybanner.com',
    );

    expect(updatedCommunity, equals(expectedCommunity));
  });

  test('Error thrown when request made by non-admin', () async {
    final communityUpdater = UpdateCommunity();
    final testCommunity = Community(
      id: communityId,
      name: 'Testing Community Too',
      isPublic: false,
      description: 'A community of testers',
      tagLine: 'Test It!',
    );
    final req = UpdateCommunityRequest(
      community: testCommunity,
      keys: [
        Community.kFieldName,
        Community.kFieldTagLine,
        Community.kFieldDescription,
      ],
    );
    const memberId = '932';
    await communityTestUtils.addCommunityMember(
      communityId: communityId,
      userId: memberId,
      status: MembershipStatus.member,
    );

    expect(
      () async {
        await communityUpdater.action(
          req,
          CallableContext(memberId, null, 'fakeInstanceId'),
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

  test('Error thrown when community name is not specified', () async {
    final communityUpdater = UpdateCommunity();
    final testCommunity = Community(
      id: communityId,
      isPublic: false,
      name: '',
      description: 'A community of testers',
      tagLine: 'Test It!',
    );
    final req = UpdateCommunityRequest(
      community: testCommunity,
      keys: [Community.kFieldTagLine, Community.kFieldDescription],
    );

    expect(
      () async {
        await communityUpdater.action(
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

  group("Unrestricted plan capabilities tests", () {
    setUp(() async {
      await subscriptionTestUtils.addUnrestrictedPlanCapabilities(
        planCapabilities: SubscriptionTestUtils.unrestrictedPlan,
      );
    });

    tearDown(() async {
      await subscriptionTestUtils.removeUnrestrictedPlanCapabilities();
    });

    test('Error thrown when display name already in use', () async {
      Community testCommunity2 = Community(
        id: '1939',
        name: 'Testing Community Number Two',
        isPublic: true,
        profileImageUrl: 'http://someimage.com',
        bannerImageUrl: 'http://mybanner.com',
      );

      final secondCommResult = await communityTestUtils.createCommunity(
        community: testCommunity2,
        userId: userId,
      );
      final secondCommunityId = secondCommResult['communityId'];
      final communityUpdater = UpdateCommunity();
      testCommunity2 = Community(
        id: secondCommunityId,
        name: 'Testing Community Number Two',
        isPublic: true,
        profileImageUrl: 'http://someimage.com',
        bannerImageUrl: 'http://mybanner.com',
        displayIds: ['testing', 'tester', 'testy'],
      );
      final req = UpdateCommunityRequest(
        community: testCommunity2,
        keys: [Community.kFieldDisplayIds],
      );
      await communityUpdater.action(
        req,
        CallableContext(userId, null, 'fakeInstanceId'),
      );
      final testCommunity = Community(
        id: communityId,
        name: 'Testing Community',
        isPublic: false,
        displayIds: ['tested', 'testy'],
        description: 'A community of testers',
        tagLine: 'Test It!',
      );
      final req2 = UpdateCommunityRequest(
        community: testCommunity,
        keys: [Community.kFieldDisplayIds],
      );

      expect(
        () async {
          await communityUpdater.action(
            req2,
            CallableContext(userId, null, 'fakeInstanceId'),
          );
        },
        throwsA(
          predicate(
            (e) =>
                e is HttpsError &&
                e.code == HttpsError.failedPrecondition &&
                e.message == 'The URL display name testy is already taken.',
          ),
        ),
      );
    });
    test('Display IDs updated when custom URLs allowed', () async {
      final communityUpdater = UpdateCommunity();
      final Community testCommunity = Community(
        id: communityId,
        name: 'Testing Community',
        isPublic: true,
        profileImageUrl: 'http://someimage.com',
        bannerImageUrl: 'http://mybanner.com',
        displayIds: ['testing-community'],
      );
      final req = UpdateCommunityRequest(
        community: testCommunity,
        keys: [
          Community.kFieldDisplayIds,
        ],
      );
      final result = await communityUpdater.action(
        req,
        CallableContext(userId, null, 'fakeInstanceId'),
      );
      expect(result, equals(''));

      final communitySnapshot =
          await firestore.document('community/$communityId').get();
      final updatedCommunity = Community.fromJson(
        firestoreUtils.fromFirestoreJson(communitySnapshot.data.toMap()),
      );

      expect(
        updatedCommunity.displayIds,
        unorderedEquals(
          [communityId, communityId.toLowerCase(), 'testing-community'],
        ),
      );
    });
  });

  test('Error thrown when no allowed update fields specified', () async {
    final communityUpdater = UpdateCommunity();
    final testCommunity = Community(
      id: communityId,
      isPublic: false,
      name: 'Testing Community Too',
      description: 'A community of testers',
      createdDate: DateTime.now(),
      tagLine: 'Test It!',
    );
    final req = UpdateCommunityRequest(
      community: testCommunity,
      keys: [Community.kFieldCreatedDate],
    );

    expect(
      () async {
        await communityUpdater.action(
          req,
          CallableContext(userId, null, 'fakeInstanceId'),
        );
      },
      throwsA(
        predicate(
          (e) =>
              e is HttpsError &&
              e.code == HttpsError.failedPrecondition &&
              e.message == 'No fields to update',
        ),
      ),
    );
  });
}
