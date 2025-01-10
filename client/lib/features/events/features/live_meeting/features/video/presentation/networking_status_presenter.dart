import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:client/features/events/features/live_meeting/features/video/data/providers/conference_room.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/views/networking_status_contract.dart';
import 'package:client/features/events/features/live_meeting/features/video/data/models/networking_status_model.dart';
import 'package:client/services.dart';
import 'package:provider/provider.dart';

import '../data/providers/agora_room.dart';

class NetworkingStatusPresenter {
  /// Hold a time duration for how long it should wait until [_isLowNetworkQuality]
  /// should become true.
  static const Duration _kPrimaryThresholdDuration = Duration(seconds: 5);

  final NetworkingStatusView _view;
  final NetworkingStatusModel _model;
  final ConferenceRoom _conferenceRoom;

  NetworkingStatusPresenter(
    BuildContext context,
    this._view,
    this._model, {
    ConferenceRoom? conferenceRoom,
  }) : _conferenceRoom = conferenceRoom ?? context.read<ConferenceRoom>();

  void updateNetworkQuality() {
    final AgoraRoom? room = _conferenceRoom.room;
    final bool isVideoEnabled = _conferenceRoom.videoEnabled;
    _model.networkQualityLevel = room?.localParticipant?.networkQualityLevel;

    const badStates = [
      QualityType.qualityPoor,
      QualityType.qualityVbad,
      QualityType.qualityBad,
      QualityType.qualityDown,
    ];
    if (badStates.contains(_model.networkQualityLevel) && isVideoEnabled) {
      final Timer? timer = _model.timer;
      loggingService.log(
        'NetworkingStatusPresenter.updateNetworkQuality: Bad network connection',
      );

      // Only spawn new timer if it's not initialised (first time) or active already
      if (timer == null || !timer.isActive) {
        loggingService.log(
          'NetworkingStatusPresenter.updateNetworkQuality: Spawning new timer',
        );

        _model.timer = Timer.periodic(_kPrimaryThresholdDuration, (timer) {
          if (badStates.contains(_model.networkQualityLevel)) {
            loggingService.log(
              'NetworkingStatusPresenter.updateNetworkQuality: Bad network for more than $_kPrimaryThresholdDuration',
            );
            _model.isLowNetworkQuality = true;
            _view.updateView();
          } else {
            _model.isLowNetworkQuality = false;
            _view.updateView();

            loggingService.log(
              'NetworkingStatusPresenter.updateNetworkQuality: Connection improved',
            );
            timer.cancel();
          }
        });
      }
    }
    // If network conditions change or not in video mode
    else {
      if (_model.isLowNetworkQuality) {
        _model.isLowNetworkQuality = false;
        _view.updateView();
      }

      _model.timer?.cancel();
    }
  }

  void dismissLowNetworkQualityMessage() {
    _model.isLowNetworkQualityMessageDismissed = true;
    _view.updateView();
  }

  void dispose() {
    _model.timer?.cancel();
  }

  Widget getCorrectWidget({
    required Widget nothing,
    required Widget networkStatusAlert,
  }) {
    final currentTime = clockService.now();

    if (currentTime.isAfter(_model.messageShowTimeThreshold) &&
        !_model.isLowNetworkQualityMessageDismissed) {
      return networkStatusAlert;
    } else {
      return nothing;
    }
  }
}
