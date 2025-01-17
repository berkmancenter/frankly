import 'package:data_models/community/community.dart';
import 'package:data_models/community/community_user_settings.dart';
import 'package:data_models/community/membership.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:functions/utils/infra/firestore_utils.dart';
import 'package:functions/utils/notifications_utils.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:functions/community/unsubscribe_from_community_notifications.dart';

import '../util/community_test_utils.dart';
import '../util/email_test_utils.dart';
import '../util/function_test_fixture.dart';

void main() {
  const testUserId = 'testUser123';
  const adminUserId = 'admin1';
  String testCommunityId1 = 'community1';
  String testCommunityId2 = 'community2';
  final mockNotificationsUtils = MockNotificationsUtils();
  final communityTestUtils = CommunityTestUtils();
  setupTestFixture();

  test('Should unsubscribe user from all community notifications', () async {
    // Create test community
    final communityResult = await communityTestUtils.createCommunity(
      community: Community(
        id: '19921239',
        name: 'Testing Community',
        isPublic: true,
      ),
      userId: adminUserId,
    );
    testCommunityId1 = communityResult['communityId'];

    // Add regular member
    await communityTestUtils.addCommunityMember(
      communityId: testCommunityId1,
      userId: testUserId,
      status: MembershipStatus.member,
    );
    final community2Result = await communityTestUtils.createCommunity(
      community: Community(
        id: '199212393333',
        name: 'Another Testing Community',
        isPublic: true,
      ),
      userId: adminUserId,
    );
    testCommunityId2 = community2Result['communityId'];
    // Add regular member
    await communityTestUtils.addCommunityMember(
      communityId: testCommunityId2,
      userId: testUserId,
      status: MembershipStatus.member,
    );

    final mockUnsubscribeData = UnsubscribeData(testUserId);

    // Setup mock response for encrypted data
    when(
      () => mockNotificationsUtils.decryptUnsubscribeData('encrypted_data'),
    ).thenReturn(mockUnsubscribeData);

    // Execute the function
    final unsubscribe = UnsubscribeFromCommunityNotifications(
      notificationsUtils: mockNotificationsUtils,
    );

    final req = UnsubscribeFromCommunityNotificationsRequest(
      data: 'encrypted_data',
    );

    await unsubscribe.action(
      req,
      CallableContext(adminUserId, null, 'fakeInstanceId'),
    );

    // Verify results
    for (final communityId in [testCommunityId1, testCommunityId2]) {
      final settingsDoc = await firestore
          .document(
            'privateUserData/$testUserId/communityUserSettings/$communityId',
          )
          .get();

      final settings = CommunityUserSettings.fromJson(
        firestoreUtils.fromFirestoreJson(settingsDoc.data.toMap()),
      );

      expect(settings.notifyAnnouncements, equals(NotificationEmailType.none));
      expect(settings.notifyEvents, equals(NotificationEmailType.none));
      expect(settings.userId, equals(testUserId));
      expect(settings.communityId, equals(communityId));
    }

    // Verify notifications utils was called correctly
    verify(
      () => mockNotificationsUtils.decryptUnsubscribeData('encrypted_data'),
    ).called(1);
  });

  test('Should handle user with no community memberships', () async {
    final mockUnsubscribeData = UnsubscribeData('nonMemberUser');

    when(
      () => mockNotificationsUtils.decryptUnsubscribeData('encrypted_data'),
    ).thenReturn(mockUnsubscribeData);

    final unsubscribe = UnsubscribeFromCommunityNotifications(
      notificationsUtils: mockNotificationsUtils,
    );

    final req = UnsubscribeFromCommunityNotificationsRequest(
      data: 'encrypted_data',
    );

    // Should complete without error
    await expectLater(
      unsubscribe.action(
        req,
        CallableContext('nonMemberUser', null, 'fakeInstanceId'),
      ),
      completes,
    );
  });

  test('Should handle invalid encrypted data', () async {
    when(
      () => mockNotificationsUtils.decryptUnsubscribeData('invalid_data'),
    ).thenThrow(Exception('Invalid encrypted data'));

    final unsubscribe = UnsubscribeFromCommunityNotifications(
      notificationsUtils: mockNotificationsUtils,
    );

    final req = UnsubscribeFromCommunityNotificationsRequest(
      data: 'invalid_data',
    );

    expect(
      () async => await unsubscribe.action(
        req,
        CallableContext(testUserId, null, 'fakeInstanceId'),
      ),
      throwsException,
    );
  });
}
