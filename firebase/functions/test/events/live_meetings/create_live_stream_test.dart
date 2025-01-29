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

  test('Successfully creates live stream for admin user', () async {
    final req = CreateLiveStreamRequest(
      communityId: communityId,
    );

    final createLiveStream = CreateLiveStream();

    final result = await createLiveStream.action(
      req,
      CallableContext(adminUserId, null, 'fakeInstanceId'),
    );

    expect(result, isA<Map<String, dynamic>>());
    expect(result['muxId'], equals('fake-mux-stream-id'));
    expect(result['muxPlaybackId'], equals('fake-playback-id'));
    expect(
      result['streamServerUrl'],
      equals('rtmp://global-live.mux.com:5222/app'),
    );
    expect(result['streamKey'], equals('fake-stream-key'));

    verify(() => muxApi.createLiveStream()).called(1);
  });

  test('Throws unauthorized error for non-admin user', () async {
    // Create non-admin membership
    await communityUtils.addCommunityMember(
      communityId: communityId,
      userId: adminUserId,
    );

    final req = CreateLiveStreamRequest(
      communityId: communityId,
    );

    final createLiveStream = CreateLiveStream();

    expect(
      () => createLiveStream.action(
        req,
        CallableContext(adminUserId, null, 'fakeInstanceId'),
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

    verifyNever(() => muxApi.createLiveStream());
  });
}
