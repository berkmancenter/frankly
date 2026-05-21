import 'package:flutter_test/flutter_test.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_video_data.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_video_model.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/agenda_item_video_presenter.dart';
import 'package:client/core/utils/extensions.dart';
import 'package:fake_async/fake_async.dart';
import 'package:mockito/mockito.dart';

import '../../../../../../../../mocked_classes.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockContext = MockBuildContext();
  final mockView = MockAgendaItemVideoView();
  final mockAgendaItemVideoHelper = MockAgendaItemVideoHelper();
  final mockMediaHelperService = MockMediaHelperService();
  final mockCommunityProvider = MockCommunityProvider();

  late AgendaItemVideoData agendaItemVideoData;
  late AgendaItemVideoModel model;
  late AgendaItemVideoPresenter presenter;

  setUp(() {
    agendaItemVideoData =
        AgendaItemVideoData('title', AgendaItemVideoType.url, 'url');
    model = AgendaItemVideoModel(true, agendaItemVideoData, (_) {});
    presenter = AgendaItemVideoPresenter(
      mockContext,
      mockView,
      model,
      agendaItemVideoHelper: mockAgendaItemVideoHelper,
      mediaHelperService: mockMediaHelperService,
      communityProvider: mockCommunityProvider,
    );
  });

  tearDown(() {
    reset(mockContext);
    reset(mockView);
    reset(mockAgendaItemVideoHelper);
    reset(mockMediaHelperService);
    reset(mockCommunityProvider);
  });

  test('updateVideoUrl', () {
    presenter.updateVideoUrl('  someUrl  ');

    expect(model.agendaItemVideoData.url, 'someUrl');
    verify(mockView.updateView()).called(1);
    verify(mockAgendaItemVideoHelper.updateParent(model)).called(1);
  });

  group('updateVideoUrl auto-detection', () {
    const youtubeUrl = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
    const vimeoUrl = 'https://vimeo.com/123456789';
    const vimeoId = '123456789';

    test('sets type to youtube when a YouTube ID is detected', () {
      when(mockMediaHelperService.getYoutubeVideoId(youtubeUrl))
          .thenReturn('dQw4w9WgXcQ');
      when(mockMediaHelperService.getVimeoVideoId(youtubeUrl)).thenReturn(null);

      presenter.updateVideoUrl(youtubeUrl);

      expect(
        model.agendaItemVideoData.type,
        AgendaItemVideoType.youtube,
      );
    });

    test('sets type to vimeo when a Vimeo ID is detected', () {
      when(mockMediaHelperService.getYoutubeVideoId(vimeoUrl)).thenReturn(null);
      when(mockMediaHelperService.getVimeoVideoId(vimeoUrl))
          .thenReturn(vimeoId);
      when(mockMediaHelperService.fetchVimeoDuration(vimeoId))
          .thenAnswer((_) async => null);

      fakeAsync((async) {
        presenter.updateVideoUrl(vimeoUrl);
        async.elapse(const Duration(milliseconds: 600));
      });

      expect(
        model.agendaItemVideoData.type,
        AgendaItemVideoType.vimeo,
      );
    });

    test(
        'calls notifyVideoDurationDetected when Vimeo duration fetch succeeds',
        () {
      const durationSeconds = 42;
      when(mockMediaHelperService.getYoutubeVideoId(vimeoUrl)).thenReturn(null);
      when(mockMediaHelperService.getVimeoVideoId(vimeoUrl))
          .thenReturn(vimeoId);
      when(mockMediaHelperService.fetchVimeoDuration(vimeoId))
          .thenAnswer((_) async => durationSeconds);

      fakeAsync((async) {
        presenter.updateVideoUrl(vimeoUrl);
        // Advance past the 600 ms debounce, then flush the async fetch.
        async.elapse(const Duration(milliseconds: 600));
        async.flushMicrotasks();

        verify(mockView.notifyVideoDurationDetected(durationSeconds)).called(1);
      });
    });

    test('does not call notifyVideoDurationDetected when fetch returns null',
        () {
      when(mockMediaHelperService.getYoutubeVideoId(vimeoUrl)).thenReturn(null);
      when(mockMediaHelperService.getVimeoVideoId(vimeoUrl))
          .thenReturn(vimeoId);
      when(mockMediaHelperService.fetchVimeoDuration(vimeoId))
          .thenAnswer((_) async => null);

      fakeAsync((async) {
        presenter.updateVideoUrl(vimeoUrl);
        async.elapse(const Duration(milliseconds: 600));
        async.flushMicrotasks();

        verifyNever(mockView.notifyVideoDurationDetected(any));
      });
    });

    test('debounces: only one fetch fired for rapid successive calls', () {
      when(mockMediaHelperService.getYoutubeVideoId(any)).thenReturn(null);
      when(mockMediaHelperService.getVimeoVideoId(any)).thenReturn(vimeoId);
      when(mockMediaHelperService.fetchVimeoDuration(vimeoId))
          .thenAnswer((_) async => 10);

      fakeAsync((async) {
        presenter.updateVideoUrl(vimeoUrl);
        async.elapse(const Duration(milliseconds: 300));
        presenter.updateVideoUrl(vimeoUrl);
        async.elapse(const Duration(milliseconds: 300));
        presenter.updateVideoUrl(vimeoUrl);
        async.elapse(const Duration(milliseconds: 600));
        async.flushMicrotasks();

        // fetchVimeoDuration should have been called only once (the last debounce).
        verify(mockMediaHelperService.fetchVimeoDuration(vimeoId)).called(1);
      });
    });
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
