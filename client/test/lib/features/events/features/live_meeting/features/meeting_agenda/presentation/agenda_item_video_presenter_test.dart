import 'package:flutter_test/flutter_test.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_video_data.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_video_model.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/agenda_item_video_presenter.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/services/video_metadata_service.dart';
import 'package:client/core/data/services/media_helper_service.dart';
import 'package:data_models/events/event.dart';
import 'package:mockito/mockito.dart';

import '../../../../../../../../mocked_classes.mocks.dart';

class FakeVideoMetadataService implements VideoMetadataService {
  final requestedUrls = <String>[];
  Future<int?> Function(String videoUrl)? onGetDuration;

  @override
  Future<int?> getVideoDurationInSeconds(String videoUrl) async {
    requestedUrls.add(videoUrl);
    final handler = onGetDuration;
    if (handler != null) {
      return handler(videoUrl);
    }

    return null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockContext = MockBuildContext();
  final mockView = MockAgendaItemVideoView();
  final mockAgendaItemVideoHelper = MockAgendaItemVideoHelper();
  final mediaHelperService = MediaHelperService();
  final mockCommunityProvider = MockCommunityProvider();

  late FakeVideoMetadataService videoMetadataService;

  late AgendaItemVideoData agendaItemVideoData;
  late AgendaItemVideoModel model;
  late AgendaItemVideoPresenter presenter;
  int? detectedDurationSeconds;

  setUp(() {
    agendaItemVideoData =
        AgendaItemVideoData('title', AgendaItemVideoType.url, 'url');
    model = AgendaItemVideoModel(true, agendaItemVideoData, (_) {});
    videoMetadataService = FakeVideoMetadataService();
    detectedDurationSeconds = null;
    presenter = AgendaItemVideoPresenter(
      mockContext,
      mockView,
      model,
      agendaItemVideoHelper: mockAgendaItemVideoHelper,
      mediaHelperService: mediaHelperService,
      communityProvider: mockCommunityProvider,
      videoMetadataService: videoMetadataService,
      onVideoDurationDetected: (durationSeconds) {
        detectedDurationSeconds = durationSeconds;
      },
    );
  });

  tearDown(() {
    presenter.dispose();
    reset(mockContext);
    reset(mockView);
    reset(mockAgendaItemVideoHelper);
    reset(mockCommunityProvider);
  });

  test('updateVideoUrl', () {
    presenter.updateVideoUrl('  someUrl  ');

    expect(model.agendaItemVideoData.url, 'someUrl');
    verify(mockView.updateView()).called(1);
    verify(mockAgendaItemVideoHelper.updateParent(model)).called(1);
  });

  test('updateVideoUrl triggers metadata fetch for supported direct video URL',
      () async {
    const videoUrl = 'https://cdn.example.com/video.mp4';
    videoMetadataService.onGetDuration = (_) async => 42;

    presenter.updateVideoUrl(videoUrl);
    await Future<void>.delayed(Duration(milliseconds: 600));

    expect(videoMetadataService.requestedUrls, [videoUrl]);
  });

  test('calls onVideoDurationDetected with detected duration', () async {
    const videoUrl = 'https://cdn.example.com/welcome.webm';
    videoMetadataService.onGetDuration = (_) async => 125;

    presenter.updateVideoUrl(videoUrl);
    await Future<void>.delayed(Duration(milliseconds: 600));

    expect(videoMetadataService.requestedUrls, [videoUrl]);
    expect(detectedDurationSeconds, 125);
  });

  test('does not trigger metadata fetch for unsupported URL extension', () async {
    const videoUrl = 'https://example.com/video-page';

    presenter.updateVideoUrl(videoUrl);
    await Future<void>.delayed(Duration(milliseconds: 600));

    expect(videoMetadataService.requestedUrls, isEmpty);
    expect(detectedDurationSeconds, isNull);
  });

  test('does not trigger metadata fetch for youtube/vimeo URLs', () async {
    const videoUrl = 'https://youtube.com/watch?v=abc123';

    presenter.updateVideoUrl(videoUrl);
    await Future<void>.delayed(Duration(milliseconds: 600));

    expect(videoMetadataService.requestedUrls, isEmpty);
    expect(detectedDurationSeconds, isNull);
  });

  group('isValidVideo', () {
    test('true', () {
      model.agendaItemVideoData.url = 'url.mp4';
      expect(presenter.isValidVideo(), isTrue);
    });

    test('false', () {
      model.agendaItemVideoData.url = 'url.mp4.mp3';
      expect(presenter.isValidVideo(), isFalse);
    });
  });

  test('getVideoUrl', () {
    expect(presenter.getVideoUrl(), 'url');
  });
}
