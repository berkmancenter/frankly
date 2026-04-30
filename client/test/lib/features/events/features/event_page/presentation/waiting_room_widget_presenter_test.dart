import 'package:client/features/events/features/event_page/data/models/waiting_room_widget_model.dart';
import 'package:client/features/events/features/event_page/presentation/views/waiting_room_widget_contract.dart';
import 'package:client/features/events/features/event_page/presentation/waiting_room_widget_presenter.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/services/video_metadata_service.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/media_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../../../../mocked_classes.mocks.dart';

class _FakeWaitingRoomWidgetView implements WaitingRoomWidgetView {
  int updateCount = 0;

  @override
  void updateView() {
    updateCount++;
  }
}

class _FakeVideoMetadataService implements VideoMetadataService {
  int callCount = 0;
  int? durationToReturn;

  @override
  Future<int?> getVideoDurationInSeconds(String videoUrl) async {
    callCount++;
    return durationToReturn;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockEvent = MockEvent();
  late WaitingRoomWidgetModel model;
  late _FakeWaitingRoomWidgetView view;
  late _FakeVideoMetadataService videoMetadataService;
  late WaitingRoomWidgetPresenter presenter;

  setUp(() {
    when(mockEvent.waitingRoomInfo).thenReturn(
      WaitingRoomInfo(durationSeconds: 0),
    );

    model = WaitingRoomWidgetModel(mockEvent);
    view = _FakeWaitingRoomWidgetView();
    videoMetadataService = _FakeVideoMetadataService();
    presenter = WaitingRoomWidgetPresenter(
      view,
      model,
      videoMetadataService: videoMetadataService,
    );
    presenter.init();
  });

  tearDown(() {
    reset(mockEvent);
  });

  test('updateIntroMedia auto-sets duration from uploaded intro video', () async {
    videoMetadataService.durationToReturn = 93;

    await presenter.updateIntroMedia(
      MediaItem(
        url: 'https://cdn.example.com/intro.mp4',
        type: MediaType.video,
      ),
    );

    expect(model.waitingRoomInfo.introMediaItem?.type, MediaType.video);
    expect(model.waitingRoomInfo.durationSeconds, 93);
    expect(videoMetadataService.callCount, 1);
    expect(view.updateCount, 1);
  });

  test('updateIntroMedia does not fetch metadata for intro image', () async {
    model.waitingRoomInfo = model.waitingRoomInfo.copyWith(durationSeconds: 25);

    await presenter.updateIntroMedia(
      MediaItem(
        url: 'https://cdn.example.com/intro.png',
        type: MediaType.image,
      ),
    );

    expect(model.waitingRoomInfo.introMediaItem?.type, MediaType.image);
    expect(model.waitingRoomInfo.durationSeconds, 25);
    expect(videoMetadataService.callCount, 0);
    expect(view.updateCount, 1);
  });

  test('updateIntroMedia fetches duration for cloudinary video URL', () async {
    videoMetadataService.durationToReturn = 77;

    await presenter.updateIntroMedia(
      MediaItem(
        url:
            'https://res.cloudinary.com/demo/video/upload/v12345/intro-file.mp4?foo=bar',
        type: MediaType.image,
      ),
    );

    expect(model.waitingRoomInfo.introMediaItem?.type, MediaType.video);
    expect(model.waitingRoomInfo.durationSeconds, 77);
    expect(videoMetadataService.callCount, 1);
    expect(view.updateCount, 1);
  });
}