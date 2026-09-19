import 'package:data_models/community/membership.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:functions/events/live_meetings/create_live_stream.dart';
import 'package:functions/events/live_meetings/mux_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:data_models/cloud_functions/requests.dart';
import '../../util/community_test_utils.dart';
import '../../util/function_test_fixture.dart';
import '../../util/live_meeting_test_utils.dart';

void main() {
  late String communityId;
  final communityUtils = CommunityTestUtils();
  muxApi = MockMuxApi();
  setupTestFixture();

  setUp(() async {
    clearInteractions(muxApi);
    // Set up mock MUX response
    when(() => muxApi.createLiveStream()).thenAnswer(
      (_) async => {
        'id': 'fake-mux-stream-id',
        'playback_ids': [
          {'id': 'fake-playback-id', 'policy': 'public'},
        ],
        'stream_key': 'fake-stream-key',
      },
    );
    communityId = await communityUtils.createTestCommunity();
  });

  for (final status in [
    MembershipStatus.owner,
    MembershipStatus.admin,
    MembershipStatus.moderator,
  ]) {
    test('Creates a live stream for ${status.name}', () async {
      await communityUtils.addCommunityMember(
        communityId: communityId,
        userId: adminUserId,
        status: status,
      );
      final result = await CreateLiveStream().action(
        CreateLiveStreamRequest(communityId: communityId),
        CallableContext(adminUserId, null, 'fakeInstanceId'),
      );
      expect(result['muxId'], 'fake-mux-stream-id');
      expect(result['muxPlaybackId'], 'fake-playback-id');
      expect(result['streamServerUrl'], 'rtmp://global-live.mux.com:5222/app');
      expect(result['streamKey'], 'fake-stream-key');
      verify(() => muxApi.createLiveStream()).called(1);
    });
  }

  for (final status in [
    MembershipStatus.facilitator,
    MembershipStatus.member,
    MembershipStatus.attendee,
    MembershipStatus.nonmember,
    MembershipStatus.banned,
  ]) {
    test('Rejects ${status.name} before provisioning a stream', () async {
      await communityUtils.addCommunityMember(
        communityId: communityId,
        userId: adminUserId,
        status: status,
      );
      await expectLater(
        CreateLiveStream().action(
          CreateLiveStreamRequest(communityId: communityId),
          CallableContext(adminUserId, null, 'fakeInstanceId'),
        ),
        throwsA(
          isA<HttpsError>().having(
            (e) => e.code,
            'code',
            HttpsError.failedPrecondition,
          ),
        ),
      );
      verifyNever(() => muxApi.createLiveStream());
    });
  }

  for (final userId in <String?>['outsider', null]) {
    test('Rejects ${userId ?? 'unauthenticated caller'} before provisioning',
        () async {
      await expectLater(
        CreateLiveStream().action(
          CreateLiveStreamRequest(communityId: communityId),
          CallableContext(userId, null, 'fakeInstanceId'),
        ),
        throwsA(
          isA<HttpsError>().having(
            (e) => e.code,
            'code',
            HttpsError.failedPrecondition,
          ),
        ),
      );
      verifyNever(() => muxApi.createLiveStream());
    });
  }
}
