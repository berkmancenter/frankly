import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:functions/events/live_meetings/get_user_id_from_agora_id.dart';
import 'package:data_models/user/public_user_info.dart';
import 'package:test/test.dart';
import 'package:data_models/cloud_functions/requests.dart';

import '../../util/function_test_fixture.dart';
import '../../util/live_meeting_test_utils.dart';

void main() {
  const userId = 'testUserId';
  const agoraId = 123;
  final liveMeetingTestUtils = LiveMeetingTestUtils();
  setupTestFixture();

  test('Returns user ID when Agora ID exists', () async {
    // Create test public user info
    final publicUserInfo = PublicUserInfo(
      id: userId,
      displayName: 'Test User',
      agoraId: agoraId,
      imageUrl: 'http://example.com/image.jpg',
    );
    await liveMeetingTestUtils.addPublicUser(publicUser: publicUserInfo);

    final req = GetUserIdFromAgoraIdRequest(
      agoraId: agoraId,
    );

    final getUserIdFromAgoraId = GetUserIdFromAgoraId();

    final result = await getUserIdFromAgoraId.action(
      req,
      CallableContext(userId, null, 'fakeInstanceId'),
    );

    expect(result, isA<Map<String, dynamic>>());
    expect(result['userId'], equals(userId));
  });

  test('Throws not found error when Agora ID does not exist', () async {
    final req = GetUserIdFromAgoraIdRequest(
      agoraId: 999, // Non-existent Agora ID
    );

    final getUserIdFromAgoraId = GetUserIdFromAgoraId();

    expect(
      () => getUserIdFromAgoraId.action(
        req,
        CallableContext(userId, null, 'fakeInstanceId'),
      ),
      throwsA(
        predicate(
          (e) =>
              e is HttpsError &&
              e.code == HttpsError.notFound &&
              e.message == 'User with agora ID 999 not found',
        ),
      ),
    );
  });

  test('Throws unauthorized error when auth uid is null', () async {
    final req = GetUserIdFromAgoraIdRequest(
      agoraId: agoraId,
    );

    final getUserIdFromAgoraId = GetUserIdFromAgoraId();

    expect(
      () => getUserIdFromAgoraId.action(
        req,
        CallableContext(null, null, 'fakeInstanceId'),
      ),
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
