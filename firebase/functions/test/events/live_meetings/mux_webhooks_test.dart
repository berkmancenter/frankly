import 'package:data_models/events/event.dart';
import 'package:functions/events/live_meetings/mux_webhooks.dart';
import 'package:functions/utils/infra/firestore_utils.dart';
import 'package:functions/utils/utils.dart';
import 'package:test/test.dart';
import '../../util/event_test_utils.dart';
import '../../util/function_test_fixture.dart';

void main() {
  final eventUtils = EventTestUtils();
  setupTestFixture();

  test('handles live stream status change correctly', () async {
    // Create test event with live stream info
    final event = await eventUtils.createEvent(
      event: Event(
        id: '1234',
        status: EventStatus.active,
        communityId: 'test-community',
        templateId: 'template-123',
        creatorId: 'test-user',
        nullableEventType: EventType.hosted,
        collectionPath: '',
        liveStreamInfo: LiveStreamInfo(
          muxId: 'stream-abc123',
          muxStatus: 'idle',
        ),
      ),
      userId: 'test-user',
    );

    final muxWebhooks = MuxWebhooks();

    // Simulate Mux webhook payload for stream becoming active
    final request = JsonMap({
      'type': 'video.live_stream.active',
      'object': {
        'id': 'stream-abc123',
      },
      'data': {
        'status': 'active',
      },
    });

    await muxWebhooks.action(request);

    // Verify event was updated with new status
    final updatedEventSnapshot = await firestore.document(event.fullPath).get();

    final updatedEvent = Event.fromJson(
      firestoreUtils.fromFirestoreJson(updatedEventSnapshot.data.toMap()),
    );

    expect(updatedEvent.liveStreamInfo?.muxStatus, equals('active'));
  });

  test('handles live stream completion correctly', () async {
    // Create test event with live stream info
    final event = await eventUtils.createEvent(
      event: Event(
        id: '5678',
        status: EventStatus.active,
        communityId: 'test-community',
        templateId: 'template-123',
        creatorId: 'test-user',
        nullableEventType: EventType.hosted,
        collectionPath: '',
        liveStreamInfo: LiveStreamInfo(
          muxId: 'stream-xyz789',
          muxStatus: 'active',
        ),
      ),
      userId: 'test-user',
    );

    final muxWebhooks = MuxWebhooks();

    // Simulate Mux webhook payload for stream completion
    final request = JsonMap({
      'type': 'video.asset.live_stream_completed',
      'data': {
        'live_stream_id': 'stream-xyz789',
        'playback_ids': [
          {'policy': 'public', 'id': 'playback-123'},
          {'policy': 'private', 'id': 'playback-456'},
        ],
      },
    });

    await muxWebhooks.action(request);

    // Verify event was updated with new playback ID
    final updatedEventSnapshot = await firestore.document(event.fullPath).get();

    final updatedEvent = Event.fromJson(
      firestoreUtils.fromFirestoreJson(updatedEventSnapshot.data.toMap()),
    );

    expect(
      updatedEvent.liveStreamInfo?.latestAssetPlaybackId,
      equals('playback-123'),
    );
  });

  test('ignores non-status change webhook events', () async {
    // Create test event with live stream info
    final event = await eventUtils.createEvent(
      event: Event(
        id: '9012',
        status: EventStatus.active,
        communityId: 'test-community',
        templateId: 'template-123',
        creatorId: 'test-user',
        nullableEventType: EventType.hosted,
        collectionPath: '',
        liveStreamInfo: LiveStreamInfo(
          muxId: 'stream-def456',
          muxStatus: 'active',
        ),
      ),
      userId: 'test-user',
    );

    final muxWebhooks = MuxWebhooks();

    // Simulate Mux webhook payload for non-status change event
    final request = JsonMap({
      'type': 'video.live_stream.connected',
      'object': {
        'id': 'stream-def456',
      },
      'data': {
        'status': 'connected',
      },
    });

    await muxWebhooks.action(request);

    // Verify event status was not changed
    final updatedEventSnapshot = await firestore.document(event.fullPath).get();

    final updatedEvent = Event.fromJson(
      firestoreUtils.fromFirestoreJson(updatedEventSnapshot.data.toMap()),
    );

    expect(updatedEvent.liveStreamInfo?.muxStatus, equals('active'));
  });
}
