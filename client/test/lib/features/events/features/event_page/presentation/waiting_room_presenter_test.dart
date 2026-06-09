import 'package:client/core/data/services/clock_service.dart';
import 'package:client/features/events/features/event_page/presentation/waiting_room_presenter.dart';
import 'package:client/services.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/media_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../../../mocked_classes.mocks.dart';

void main() {
  final mockClockService = MockClockService();
  final mockCommunityProvider = MockCommunityProvider();
  final mockEventProvider = MockEventProvider();
  final mockLiveMeetingProvider = MockLiveMeetingProvider();

  late WaitingRoomPresenter presenter;

  Event _buildEvent({
    required DateTime scheduledTime,
    int waitingMediaBufferSeconds = 0,
  }) {
    return Event(
      id: 'event-id',
      status: EventStatus.active,
      collectionPath: 'communities/community-id/events',
      communityId: 'community-id',
      templateId: 'template-id',
      creatorId: 'creator-id',
      scheduledTime: scheduledTime,
      waitingRoomInfo: WaitingRoomInfo(
        waitingMediaBufferSeconds: waitingMediaBufferSeconds,
        waitingMediaItem: MediaItem(
          type: MediaType.video,
          url: 'https://example.com/waiting.mp4',
        ),
        introMediaItem: MediaItem(
          type: MediaType.video,
          url: 'https://example.com/intro.mp4',
        ),
      ),
    );
  }

  setUpAll(() {
    if (!services.isRegistered<ClockService>()) {
      services.registerSingleton<ClockService>(mockClockService);
    }
  });

  tearDownAll(() async {
    await services.reset();
  });

  setUp(() {
    presenter = WaitingRoomPresenter(
      communityProvider: mockCommunityProvider,
      eventProvider: mockEventProvider,
      liveMeetingProvider: mockLiveMeetingProvider,
    );

    when(mockCommunityProvider.community).thenReturn(
      Community(
        id: 'community-id',
        profileImageUrl: 'https://example.com/community.png',
      ),
    );
  });

  tearDown(() {
    reset(mockClockService);
    reset(mockCommunityProvider);
    reset(mockEventProvider);
    reset(mockLiveMeetingProvider);
  });

  test('initialize schedules a transition notification at scheduled start', () async {
    final now = DateTime.utc(2026, 6, 8, 12, 0, 0);
    when(mockClockService.now()).thenReturn(now);
    when(mockEventProvider.event).thenReturn(
      _buildEvent(scheduledTime: now.add(Duration(milliseconds: 20))),
    );

    var notifications = 0;
    presenter.addListener(() => notifications++);

    presenter.initialize();
    expect(presenter.introVideoStartTime, isNull);
    expect(notifications, 0);

    await Future<void>.delayed(Duration(milliseconds: 35));

    expect(presenter.introVideoStartTime, Duration.zero);
    expect(notifications, 1);
  });

  test('waiting video end after scheduled start jumps intro to elapsed time', () {
    final now = DateTime.utc(2026, 6, 8, 12, 0, 20);
    when(mockClockService.now()).thenReturn(now);
    when(mockEventProvider.event).thenReturn(
      _buildEvent(scheduledTime: now.subtract(Duration(seconds: 12))),
    );

    presenter.onVideoEnded(wasIntroVideo: false);

    expect(presenter.introVideoStartTime, Duration(seconds: 12));
  });

  test('intro video end swaps media to community image', () {
    final now = DateTime.utc(2026, 6, 8, 12, 0, 20);
    when(mockClockService.now()).thenReturn(now);
    when(mockEventProvider.event).thenReturn(
      _buildEvent(scheduledTime: now.subtract(Duration(seconds: 8))),
    );

    expect(presenter.media.type, MediaType.video);
    expect(presenter.media.url, 'https://example.com/intro.mp4');

    presenter.onVideoEnded(wasIntroVideo: true);

    expect(presenter.media.type, MediaType.image);
    expect(presenter.media.url, 'https://example.com/community.png');
  });
}
