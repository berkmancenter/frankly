import 'package:client/features/events/features/event_page/presentation/views/waiting_room_widget_contract.dart';
import 'package:client/features/events/features/event_page/data/models/waiting_room_widget_model.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/services/video_metadata_service.dart';
import 'package:client/core/data/services/media_helper_service.dart';
import 'package:client/core/utils/visible_exception.dart';
import 'package:client/services.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/media_item.dart';

class WaitingRoomWidgetPresenter {
  final WaitingRoomWidgetView _view;
  final WaitingRoomWidgetModel _model;
  final VideoMetadataService _videoMetadataService;

  WaitingRoomWidgetPresenter(
    this._view,
    this._model, {
    VideoMetadataService? videoMetadataService,
  }) : _videoMetadataService = videoMetadataService ?? VideoMetadataService();

  bool get enableIntroVideo => _model.event.eventType == EventType.hostless;

  void init() {
    _model.waitingRoomInfo =
        _model.event.waitingRoomInfo?.copyWith() ?? WaitingRoomInfo();
  }

  void updateWaitingText(String text) {
    _model.waitingRoomInfo = _model.waitingRoomInfo.copyWith(content: text);
    _view.updateView();
  }

  void updateWaitingMedia(MediaItem mediaItem) {
    _model.waitingRoomInfo =
        _model.waitingRoomInfo.copyWith(waitingMediaItem: mediaItem);
    _view.updateView();
  }

  bool _looksLikeVideoUrl(String url) {
    final normalizedPath = (Uri.tryParse(url)?.path ?? url).toLowerCase();
    return MediaHelperService.allowedVideoFormats.any(
          (ext) => normalizedPath.endsWith('.$ext'),
        ) ||
        normalizedPath.contains('/video/upload/');
  }

  Future<void> updateIntroMedia(MediaItem mediaItem) async {
    final shouldTreatAsVideo =
        mediaItem.type == MediaType.video || _looksLikeVideoUrl(mediaItem.url);
    final normalizedMediaItem = shouldTreatAsVideo &&
            mediaItem.type != MediaType.video
        ? mediaItem.copyWith(type: MediaType.video)
        : mediaItem;

    _model.waitingRoomInfo =
        _model.waitingRoomInfo.copyWith(introMediaItem: normalizedMediaItem);

    if (shouldTreatAsVideo) {
      final durationSeconds =
          await _videoMetadataService.getVideoDurationInSeconds(mediaItem.url);
      if (durationSeconds != null && durationSeconds > 0) {
        _model.waitingRoomInfo =
            _model.waitingRoomInfo.copyWith(durationSeconds: durationSeconds);
      }
    }

    _view.updateView();
  }

  void updateMinutesInString(String minutesInString) {
    final minutesInt = int.tryParse(minutesInString) ?? 0;
    final secondsInt = _model.waitingRoomInfo.durationSeconds % 60;
    final durationInSeconds = minutesInt * 60 + secondsInt;

    _model.waitingRoomInfo =
        _model.waitingRoomInfo.copyWith(durationSeconds: durationInSeconds);
    _view.updateView();
  }

  void updateSecondsInString(String secondsInString) {
    final minutesInt = _model.waitingRoomInfo.durationSeconds ~/ 60;
    final secondsInt = int.tryParse(secondsInString) ?? 0;
    final durationInSeconds = minutesInt * 60 + secondsInt;

    _model.waitingRoomInfo =
        _model.waitingRoomInfo.copyWith(durationSeconds: durationInSeconds);
    _view.updateView();
  }

  void updateWaitingBufferMinutesInString(String minutesInString) {
    final minutesInt = int.tryParse(minutesInString) ?? 0;
    final secondsInt = _model.waitingRoomInfo.waitingMediaBufferSeconds % 60;
    final durationInSeconds = minutesInt * 60 + secondsInt;

    _model.waitingRoomInfo = _model.waitingRoomInfo
        .copyWith(waitingMediaBufferSeconds: durationInSeconds);
    _view.updateView();
  }

  void updateWaitingBufferSecondsInString(String secondsInString) {
    final minutesInt = _model.waitingRoomInfo.waitingMediaBufferSeconds ~/ 60;
    final secondsInt = int.tryParse(secondsInString) ?? 0;
    final durationInSeconds = minutesInt * 60 + secondsInt;

    _model.waitingRoomInfo = _model.waitingRoomInfo
        .copyWith(waitingMediaBufferSeconds: durationInSeconds);
    _view.updateView();
  }

  Future<void> save() async {
    if (_model.event
        .timeUntilWaitingRoomFinished(clockService.now())
        .isNegative) {
      throw VisibleException(
        "Can't update waiting room settings after meeting has started.",
      );
    }
    await firestoreEventService.updateEvent(
      event: _model.event.copyWith(waitingRoomInfo: _model.waitingRoomInfo),
      keys: [Event.kFieldWaitingRoomInfo],
    );
  }

  void deleteWaitingMedia() async {
    _model.waitingRoomInfo =
        _model.waitingRoomInfo.copyWith(waitingMediaItem: null);
    _view.updateView();
  }

  void deleteIntroMedia() {
    _model.waitingRoomInfo =
        _model.waitingRoomInfo.copyWith(introMediaItem: null);
    _view.updateView();
  }

  void updateLoopWaitingVideo(bool loop) {
    _model.waitingRoomInfo =
        _model.waitingRoomInfo.copyWith(loopWaitingVideo: loop);
    _view.updateView();
  }
}
