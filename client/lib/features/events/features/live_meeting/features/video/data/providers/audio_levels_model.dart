import 'dart:async';

import 'package:flutter/material.dart';
import 'package:client/features/events/features/live_meeting/features/video/data/providers/conference_room.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_html/js.dart' as js;
import 'package:universal_html/js_util.dart' as js_util;

/// Handles listening to media streams from all participants and determining who the dominant speaker
/// is.
///
/// We want to show you on stage when you are talking and also include you
/// in calculations on how much each person has talked.
///
/// This also exposes streams to determine when each person is talking and what their current audio
/// level is.
///
/// Notes:
/// - It is possible this doesn't work on all platforms for remote streams so will need to be tested
/// more.
/// - This uses hark (https://github.com/otalk/hark) to determine the speaker.
/// - This checks every 100ms which is the default and may be more frequent than we need.
class AudioLevelsModel with ChangeNotifier {
  final ConferenceRoom conferenceRoom;

  final Map<String, ParticipantAudioLevelTracker>
      _participantAudioLevelTrackers = {};
  final _dominantSpeakerSidStream = BehaviorSubject<String?>();

  AudioLevelsModel({required this.conferenceRoom});

  Stream<ParticipantAudioLevel>? get localAudioLevels =>
      isNullOrEmpty(conferenceRoom.room?.localParticipant?.userId)
          ? null
          : _participantAudioLevelTrackers[
                  conferenceRoom.room?.localParticipant?.userId]
              ?._audioLevelStream;

  Stream<String?> get dominantSpeakerSidStream => _dominantSpeakerSidStream;

  void initialize() {
    conferenceRoom.addListener(_onConferenceRoomUpdate);
  }

  @override
  void dispose() {
    super.dispose();

    _dominantSpeakerSidStream.close();
    conferenceRoom.addListener(_onConferenceRoomUpdate);
  }

  /// Looks at the current participants and start listening for any new ones and stop listening to any
  /// that are now gone.
  void _onConferenceRoomUpdate() {
    final startingNumAudioLevels = _participantAudioLevelTrackers.length;

    if (_participantAudioLevelTrackers.length != startingNumAudioLevels) {
      loggingService.log(
        'Current number of audio levels being tracked: ${_participantAudioLevelTrackers.length}',
      );
    }
  }
}

class ParticipantAudioLevel {
  final bool isSpeaking;

  /// Volume in decibels
  final double volume;

  ParticipantAudioLevel({
    this.isSpeaking = false,
    this.volume = 0,
  });

  ParticipantAudioLevel copyWith({
    bool? isSpeaking,
    double? volume,
  }) =>
      ParticipantAudioLevel(
        isSpeaking: isSpeaking ?? this.isSpeaking,
        volume: volume ?? this.volume,
      );

  @override
  String toString() => 'IsSpeaking: $isSpeaking, volume: $volume';
}

class ParticipantAudioLevelTracker {
  final String trackName;
  final html.MediaStream mediaStream;
  final void Function() onUpdate;

  final _audioLevelStream = BehaviorSubject<ParticipantAudioLevel>();

  late Object _harker;
  late StreamSubscription _streamSubscription;

  ParticipantAudioLevelTracker({
    required this.trackName,
    required this.mediaStream,
    required this.onUpdate,
  });

  ParticipantAudioLevel? get currentAudioLevel => _audioLevelStream.valueOrNull;

  void initialize() {
    _streamSubscription = _audioLevelStream.listen((_) => onUpdate());

    loggingService.log('Getting harker for $trackName');
    _harker = js_util.callMethod(html.window, 'hark', [
      mediaStream,
      js_util.jsify({'play': false, 'interval': 250}),
    ]);

    loggingService.log('Done setting up harker for $trackName');

    js_util.callMethod(_harker, 'on', [
      'speaking',
      js.allowInterop(() {
        final currentAudioLevel =
            _audioLevelStream.valueOrNull ?? ParticipantAudioLevel();
        _audioLevelStream.add(currentAudioLevel.copyWith(isSpeaking: true));
      }),
    ]);

    js_util.callMethod(_harker, 'on', [
      'stopped_speaking',
      js.allowInterop(() {
        final currentAudioLevel =
            _audioLevelStream.valueOrNull ?? ParticipantAudioLevel();
        _audioLevelStream.add(currentAudioLevel.copyWith(isSpeaking: false));
      }),
    ]);

    js_util.callMethod(_harker, 'on', [
      'volume_change',
      js.allowInterop((volume, _) {
        final currentAudioLevel =
            _audioLevelStream.valueOrNull ?? ParticipantAudioLevel();
        _audioLevelStream.add(currentAudioLevel.copyWith(volume: volume));
      }),
    ]);
  }

  void dispose() {
    js_util.callMethod(_harker, 'stop', []);
    _streamSubscription.cancel();
    _audioLevelStream.close();
  }
}
