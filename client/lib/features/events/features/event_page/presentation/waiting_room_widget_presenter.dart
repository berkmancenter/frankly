import 'package:client/features/events/features/event_page/presentation/views/waiting_room_widget_contract.dart';
import 'package:client/features/events/features/event_page/data/models/waiting_room_widget_model.dart';
import 'package:client/core/utils/visible_exception.dart';
import 'package:client/services.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/media_item.dart';

class WaitingRoomWidgetPresenter {
  final WaitingRoomWidgetView _view;
  final WaitingRoomWidgetModel _model;

  WaitingRoomWidgetPresenter(this._view, this._model);

  bool get enableIntroVideo => _model.event.eventType == EventType.hostless;

  void init() {
    _model.waitingRoomInfo =
        _model.event.waitingRoomInfo?.copyWith() ?? WaitingRoomInfo();
  }

  void updateEvent(Event event) {
    _model.event = event;
    _view.updateView();
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

  void updateIntroMedia(MediaItem mediaItem) {
    _model.waitingRoomInfo =
        _model.waitingRoomInfo.copyWith(introMediaItem: mediaItem);
    _view.updateView();
  }

  void updateDuration(Duration duration) {
    _model.waitingRoomInfo = _model.waitingRoomInfo
        .copyWith(durationSeconds: duration.inSeconds);
    _view.updateView();
  }

  void updateWaitingBufferDuration(Duration duration) {
    _model.waitingRoomInfo = _model.waitingRoomInfo
        .copyWith(waitingMediaBufferSeconds: duration.inSeconds);
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
