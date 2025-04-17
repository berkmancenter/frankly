import 'dart:async';

import 'package:flutter/material.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/talking_odometer_presenter.dart';

enum DialState {
  warningLow,
  value,
  warningHigh,
}

class TalkingOdometerModel {
  final tooltipKey = GlobalKey<State<Tooltip>>();

  /// Timer that updates UI every 1 second. It's needed due to showing Indicator update
  /// within Odometer.
  late Timer updateTimer;

  Map<String, int> userSpeakingDurations = {};
  Duration talkingStateDuration = Duration.zero;
  TalkingState talkingState = TalkingState.idle;
  DialState dialState = DialState.value;
  DateTime lastSpokenTime = DateTime.now();

  /// Indicates we already showed the tooltip for this talking state period
  bool tooltipAlreadyShown = false;

  Timer? talkingStateTimer;
  Timer? tooltipShownTimer;

  /// SID comes from twilio so is not app userId from Firestore.
  String? currentDominantSpeakerSid;
}
