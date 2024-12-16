import 'package:junto/app/junto/discussions/discussion_page/widgets/waiting_room_widget/waiting_room_widget_contract.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/waiting_room_widget/waiting_room_widget_model.dart';
import 'package:junto/common_widgets/visible_exception.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/media_item.dart';

class WaitingRoomWidgetPresenter {
  final WaitingRoomWidgetView _view;
  final WaitingRoomWidgetModel _model;

  WaitingRoomWidgetPresenter(this._view, this._model);

  bool get enableIntroVideo => _model.discussion.discussionType == DiscussionType.hostless;

  void init() {
    _model.waitingRoomInfo = _model.discussion.waitingRoomInfo?.copyWith() ?? WaitingRoomInfo();
  }

  void enableChat(value) {
    _model.waitingRoomInfo = _model.waitingRoomInfo.copyWith(enableChat: value);
    _view.updateView();
  }

  void updateWaitingText(String text) {
    _model.waitingRoomInfo = _model.waitingRoomInfo.copyWith(content: text);
    _view.updateView();
  }

  void updateWaitingMedia(MediaItem mediaItem) {
    _model.waitingRoomInfo = _model.waitingRoomInfo.copyWith(waitingMediaItem: mediaItem);
    _view.updateView();
  }

  void updateIntroMedia(MediaItem mediaItem) {
    _model.waitingRoomInfo = _model.waitingRoomInfo.copyWith(introMediaItem: mediaItem);
    _view.updateView();
  }

  void updateMinutesInString(String minutesInString) {
    final minutesInt = int.tryParse(minutesInString) ?? 0;
    final secondsInt = _model.waitingRoomInfo.durationSeconds % 60;
    final durationInSeconds = minutesInt * 60 + secondsInt;

    _model.waitingRoomInfo = _model.waitingRoomInfo.copyWith(durationSeconds: durationInSeconds);
    _view.updateView();
  }

  void updateSecondsInString(String secondsInString) {
    final minutesInt = _model.waitingRoomInfo.durationSeconds ~/ 60;
    final secondsInt = int.tryParse(secondsInString) ?? 0;
    final durationInSeconds = minutesInt * 60 + secondsInt;

    _model.waitingRoomInfo = _model.waitingRoomInfo.copyWith(durationSeconds: durationInSeconds);
    _view.updateView();
  }

  void updateWaitingBufferMinutesInString(String minutesInString) {
    final minutesInt = int.tryParse(minutesInString) ?? 0;
    final secondsInt = _model.waitingRoomInfo.waitingMediaBufferSeconds % 60;
    final durationInSeconds = minutesInt * 60 + secondsInt;

    _model.waitingRoomInfo =
        _model.waitingRoomInfo.copyWith(waitingMediaBufferSeconds: durationInSeconds);
    _view.updateView();
  }

  void updateWaitingBufferSecondsInString(String secondsInString) {
    final minutesInt = _model.waitingRoomInfo.waitingMediaBufferSeconds ~/ 60;
    final secondsInt = int.tryParse(secondsInString) ?? 0;
    final durationInSeconds = minutesInt * 60 + secondsInt;

    _model.waitingRoomInfo =
        _model.waitingRoomInfo.copyWith(waitingMediaBufferSeconds: durationInSeconds);
    _view.updateView();
  }

  Future<void> save() async {
    if (_model.discussion.timeUntilWaitingRoomFinished(clockService.now()).isNegative) {
      throw VisibleException("Can't update waiting room settings after meeting has started.");
    }
    await firestoreDiscussionService.updateDiscussion(
      discussion: _model.discussion.copyWith(waitingRoomInfo: _model.waitingRoomInfo),
      keys: [Discussion.kFieldWaitingRoomInfo],
    );
  }

  void deleteWaitingMedia() async {
    _model.waitingRoomInfo = _model.waitingRoomInfo.copyWith(waitingMediaItem: null);
    _view.updateView();
  }

  void deleteIntroMedia() {
    _model.waitingRoomInfo = _model.waitingRoomInfo.copyWith(introMediaItem: null);
    _view.updateView();
  }

  void updateLoopWaitingVideo(bool loop) {
    _model.waitingRoomInfo = _model.waitingRoomInfo.copyWith(loopWaitingVideo: loop);
    _view.updateView();
  }
}
