import 'dart:async';

import 'package:flutter/material.dart';
import 'package:client/features/events/features/event_page/data/providers/event_permissions_provider.dart';
import 'package:client/features/events/features/live_meeting/data/providers/live_meeting_provider.dart';
import 'package:client/features/events/features/live_meeting/features/video/data/providers/conference_room.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/views/talking_odometer_contract.dart';
import 'package:client/features/events/features/live_meeting/features/video/data/models/talking_odometer_model.dart';
import 'package:client/core/utils/extensions.dart';
import 'package:normal/normal.dart';
import 'package:provider/provider.dart';

enum TalkingState {
  talking,
  idle,
}

class TalkingOdometerPresenter {
  // This slows down the initial movement of the odometer
  static const startingSpeakingDuration = Duration(seconds: 60);
  static const Duration _kUpdateFrequency = Duration(seconds: 1);

  final TalkingOdometerView _view;
  final TalkingOdometerModel _model;
  final TalkingOdometerPresenterHelper _helper;
  final ConferenceRoom _conferenceRoom;
  final EventPermissionsProvider eventPermissions;

  Duration get totalTalkingTimeInMeeting {
    if (_model.userSpeakingDurations.isEmpty) return Duration.zero;
    final seconds = _model.userSpeakingDurations.values.reduce((a, b) => a + b);
    return Duration(seconds: seconds);
  }

  Duration get userTotalTalkingTime {
    final id = _conferenceRoom.room?.localParticipant?.userId;
    if (id == null) return Duration.zero;
    return Duration(seconds: _model.userSpeakingDurations[id] ?? 0);
  }

  void incrementDuration(String userId) =>
      _model.userSpeakingDurations[userId] =
          (_model.userSpeakingDurations[userId] ?? 0) + 1;

  TalkingOdometerPresenter(
    BuildContext context,
    this._view,
    this._model, {
    TalkingOdometerPresenterHelper? talkingOdometerPresenterHelper,
    ConferenceRoom? conferenceRoom,
    EventPermissionsProvider? eventPermissions,
  })  : _helper =
            talkingOdometerPresenterHelper ?? TalkingOdometerPresenterHelper(),
        _conferenceRoom =
            conferenceRoom ?? LiveMeetingProvider.read(context).conferenceRoom!,
        eventPermissions = context.read<EventPermissionsProvider>();

  void init() {
    _helper.updateTalkingState(
      talkingState: TalkingState.idle,
      model: _model,
      onHideTooltip: () => hideTooltip(),
    );
    _model.updateTimer = Timer.periodic(_kUpdateFrequency, (timer) {
      final numParticipants = _conferenceRoom.participants.length;
      if (numParticipants > 1) {
        _checkDominantSpeakerUpdates();
      } else {
        // Reset the talking state duration if all other participants leave. This will put their
        // indicator back to 0.
        _model.userSpeakingDurations = {};
      }
      _view.updateView();
    });
  }

  void dispose() {
    _model.updateTimer.cancel();
    _model.talkingStateTimer?.cancel();
    _model.tooltipShownTimer?.cancel();
  }

  void _checkDominantSpeakerUpdates() {
    final String? dominantSpeakerSid = _conferenceRoom.dominantSpeakerSid;

    _model.currentDominantSpeakerSid = dominantSpeakerSid;
    if (dominantSpeakerSid != null) {
      incrementDuration(dominantSpeakerSid);
    }

    final isLocalParticipantSpeaking = _model.currentDominantSpeakerSid ==
        _conferenceRoom.room?.localParticipant?.userId;
    TalkingState newTalkingState = _model.talkingState;

    // If the current speaker is no one, keep the state of the last speaker
    if (dominantSpeakerSid != null) {
      newTalkingState =
          isLocalParticipantSpeaking ? TalkingState.talking : TalkingState.idle;
    }

    if (isLocalParticipantSpeaking) {
      _model.lastSpokenTime = DateTime.now();
    }

    if (_model.talkingState != newTalkingState) {
      _helper.updateTalkingState(
        talkingState: newTalkingState,
        model: _model,
        onHideTooltip: () => hideTooltip(),
      );
    } else if (newTalkingState == TalkingState.talking &&
        isLocalParticipantSpeaking) {
      _model.talkingStateDuration += _kUpdateFrequency;
    }
    _setDialStateAndTooltip(newTalkingState);
  }

  void _setDialStateAndTooltip(TalkingState newTalkingState) {
    final lastSpokenDuration = DateTime.now().difference(_model.lastSpokenTime);
    final threshold = _helper.getDurationThreshold(
      newTalkingState,
      _conferenceRoom,
      _conferenceRoom.participants.length,
    );

    bool hasntSpokenInAWhile =
        newTalkingState == TalkingState.idle && threshold < lastSpokenDuration;

    bool speakingTooMuch = newTalkingState == TalkingState.talking &&
        threshold < _model.talkingStateDuration;

    final DialState newDialState;
    if (hasntSpokenInAWhile) {
      newDialState = DialState.warningLow;
    } else if (speakingTooMuch) {
      newDialState = DialState.warningHigh;
    } else {
      newDialState = DialState.value;
    }

    if (_model.dialState != newDialState) {
      _model.dialState = newDialState;
      if (newDialState != DialState.value) {
        _view.startAnimation();
      } else {
        _view.cancelAnimation();
      }
    }

    if ((hasntSpokenInAWhile || speakingTooMuch) &&
        !_model.tooltipAlreadyShown) {
      _model.tooltipAlreadyShown = true;
      showTooltip();

      // Only show tooltip for certain amount of time. Once this duration is reached - hide tooltip.
      _model.tooltipShownTimer =
          Timer(TalkingOdometerPresenterHelper._kTooltipShowDuration, () {
        hideTooltip();
      });
    }
  }

  /// Retrieves value [-1, 1] from [Duration] that is being used in the Indicator.
  double getOdometerIndicatorValue() {
    switch (_model.dialState) {
      case DialState.warningLow:
        return -1;
      case DialState.warningHigh:
        return 1;
      case DialState.value:
        if (totalTalkingTimeInMeeting.inMilliseconds == 0) return 0;
        final expectedProportion = 1 / _conferenceRoom.participants.length;
        final userSpeakingProportion = (userTotalTalkingTime.inMilliseconds +
                startingSpeakingDuration.inMilliseconds) /
            (totalTalkingTimeInMeeting.inMilliseconds +
                (_conferenceRoom.participants.length *
                    startingSpeakingDuration.inMilliseconds));

        // Returns the probability of this speaking time assuming a normal distribution of times and
        // standard deviation equal to the average proportion / 2
        final normalizedProportion = Normal.cdf(
          userSpeakingProportion,
          mean: expectedProportion,
          variance: expectedProportion * .5,
        );

        return ((normalizedProportion * 2) - 1).clamp(-.8, .8);
    }
  }

  String getMessage() {
    final Duration durationThreshold = _helper.getDurationThreshold(
      _model.talkingState,
      _conferenceRoom,
      _conferenceRoom.participants.length,
    );
    final String message;

    switch (_model.talkingState) {
      case TalkingState.talking:
        message =
            'Leave time for others\nThe conversation will benefit from diverse perspectives.';
        break;
      case TalkingState.idle:
        message =
            'Would you like to share?\nThe conversation would benefit from your perspective.';
        break;
    }

    // Get message slightly before official deadline. Reason for it is, tooltip can be shown
    // slightly before (maybe couple ms before) message content is updated thus causing to show nothing.
    if (_model.talkingStateDuration >=
            durationThreshold - Duration(seconds: 1) ||
        DateTime.now().difference(_model.lastSpokenTime) >=
            durationThreshold - Duration(seconds: 1)) {
      return message;
    } else {
      final speakingTime =
          userTotalTalkingTime.getFormattedTime(showHours: false);
      return 'You\'ve spoken for $speakingTime in this meeting.';
    }
  }

  // Tooltip is not maintained from Flutter that much, thus this is the only way of how to force
  // to show it programmatically. Stone-age solution, but works.
  void showTooltip() {
    ((_model.tooltipKey.currentState) as dynamic)?.ensureTooltipVisible();
  }

  // Tooltip is not maintained from Flutter that much, thus this is the only way of how to force
  // to hide it programmatically. Stone-age solution, but works.
  void hideTooltip() {
    ((_model.tooltipKey.currentState) as dynamic)?.deactivate();
  }
}

@visibleForTesting
class TalkingOdometerPresenterHelper {
  static const Duration _kTalkingThreshold = Duration(minutes: 2);
  static const Duration _kTooltipShowDuration = Duration(seconds: 6);

  static Duration _idleThreshold(int participants) =>
      Duration(minutes: 2 * participants);

  static const Duration _deliberationsTalkingThreshold = Duration(minutes: 3);
  static const Duration _deliberationsIdleThreshold = Duration(minutes: 7);

  void updateTalkingState({
    required TalkingState talkingState,
    required TalkingOdometerModel model,
    required Function() onHideTooltip,
  }) {
    onHideTooltip();
    model.talkingStateDuration = Duration.zero;
    model.talkingState = talkingState;
    model.tooltipAlreadyShown = false;
  }

  Duration getDurationThreshold(
    TalkingState talkingState,
    ConferenceRoom? conferenceRoom,
    int participants,
  ) {
    switch (talkingState) {
      case TalkingState.talking:
        return _kTalkingThreshold;
      case TalkingState.idle:
        return _idleThreshold(participants);
    }
  }
}
