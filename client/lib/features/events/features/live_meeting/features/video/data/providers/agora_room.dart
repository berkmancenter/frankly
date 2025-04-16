import 'dart:async';
import 'dart:ui';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/utils/utils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:universal_html/html.dart';

import '../../../../../../../../services.dart';
import '../../../../../event_page/data/providers/event_provider.dart';
import '../../../../data/providers/live_meeting_provider.dart';
import 'conference_room.dart';

enum AgoraRoomState {
  CONNECTING,
  CONNECTED,
  RECONNECTING,
  DISCONNECTED,
}

class AgoraRoom with ChangeNotifier {
  late final RtcEngine engine;
  late final RtcEngineEventHandler _rtcEngineEventHandler;

  final String channelName;
  final String token;
  final EventProvider eventProvider;
  final LiveMeetingProvider liveMeetingProvider;
  final ConferenceRoom conferenceRoom;

  AgoraRoom({
    required this.channelName,
    required this.token,
    required this.eventProvider,
    required this.liveMeetingProvider,
    required this.conferenceRoom,
  });

  bool connectedWithAudioEnabled = false;
  bool connectedWithVideoEnabled = false;

  AgoraRoomState _state = AgoraRoomState.CONNECTING;
  AgoraRoomState get state => _state;

  AgoraParticipant? _localParticipant;
  AgoraParticipant? get localParticipant => _localParticipant;

  final _remoteParticipants = <AgoraParticipant>[];
  List<AgoraParticipant>? get remoteParticipants => _remoteParticipants;

  List<AudioVolumeInfo> _remoteSpeakers = [];
  AudioVolumeInfo? _localSpeaker;

  final Map<int, bool> _audioMutedState = {};
  final Map<int, bool> _videoMutedState = {};

  final _dominantSpeakerStream = BehaviorSubject<AgoraParticipant?>();
  BehaviorSubject<AgoraParticipant?> get dominantSpeakerStream =>
      _dominantSpeakerStream;

  void _updateDominantSpeaker({
    int? localUid,
    required List<AudioVolumeInfo> speakers,
  }) {
    // Agora event calls for the local user and the remote users are separate, so we store them in variables to
    // have access to them for each update.
    final localSpeaker = speakers
        .where((s) => localUid != null && s.uid == localUid)
        .firstOrNull;
    final remoteSpeakers = speakers.where((s) => s.uid != localUid).toList();
    if (localSpeaker == null) {
      _remoteSpeakers = remoteSpeakers;
    } else {
      _localSpeaker = localSpeaker;
    }

    final dominantRemoteSpeaker = _remoteSpeakers.isEmpty
        ? null
        : _remoteSpeakers.reduce((a, b) {
            final aVolume = a.volume ?? 0;
            final bVolume = b.volume ?? 0;
            return aVolume > bVolume ? a : b;
          });

    const volumeCutoff = 1700;

    if (dominantRemoteSpeaker != null &&
        (dominantRemoteSpeaker.volume ?? 0) > volumeCutoff) {
      final dominantParticipant = _remoteParticipants
          .whereNotNull()
          .where((s) => s.agoraUid == dominantRemoteSpeaker.uid)
          .firstOrNull;
      _dominantSpeakerStream.add(dominantParticipant);
    } else if ((_localSpeaker?.volume ?? 0) > volumeCutoff) {
      _dominantSpeakerStream.add(_localParticipant);
    } else {
      _dominantSpeakerStream.add(null);
    }
  }

  Future<void> connect({
    bool enableAudio = false,
    bool enableVideo = false,
  }) async {
    engine = createAgoraRtcEngine();

    await engine.initialize(
      RtcEngineContext(
        appId: '76cd63ec061d4192ac03ff8cdde51395',
      ),
    );

    _localParticipant = AgoraParticipant(
      rtcEngine: engine,
      agoraUid: 0,
      isLocal: true,
      userId: userService.currentUserId!,
      token: token,
    )
      ..addListener(notifyListeners)
      ..audioTrackEnabled = enableAudio
      ..videoTrackEnabled = enableVideo;

    _rtcEngineEventHandler = RtcEngineEventHandler(
      onError: (ErrorCodeType err, String msg) {
        print('[onError] err: $err, msg: $msg');
        if (err == ErrorCodeType.errJoinChannelRejected) {
          conferenceRoom.setConnectError(
            'Could not join room. Please refresh and try again',
          );
        }
      },
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) async {
        _state = AgoraRoomState.CONNECTED;

        unawaited(conferenceRoom.onConnected(this));
        conferenceRoom.onLocalParticipantChanges();

        notifyListeners();
        print(
          '[onJoinChannelSuccess] connection: ${connection.toJson()} elapsed: $elapsed',
        );

        await engine.enableAudioVolumeIndication(
          interval: 200,
          smooth: 3,
          reportVad: true,
        );

        print('Joined with audio: $enableAudio and video: $enableVideo');
        if (enableVideo) {
          await conferenceRoom.toggleVideoEnabled(setEnabled: true);
        }
        if (enableAudio) {
          await conferenceRoom.toggleAudioEnabled(setEnabled: true);
        }
      },
      onUserJoined: (RtcConnection connection, int rUid, int elapsed) async {
        print(
          '[onUserJoined] connection: ${connection.toJson()} remoteUid: $rUid elapsed: $elapsed',
        );

        String? userId;
        try {
          final user = await cloudFunctionsLiveMeetingService
              .getUserIdFromAgoraId(GetUserIdFromAgoraIdRequest(agoraId: rUid));
          userId = user.userId;
        } catch (e) {
          print('Unexpected null participant: $rUid');
          rethrow;
        }

        final participant = AgoraParticipant(
          rtcEngine: engine,
          agoraUid: rUid,
          userId: userId,
          isLocal: false,
        )
          ..videoTrackEnabled = !(_videoMutedState[rUid] ?? false)
          ..audioTrackEnabled = !(_audioMutedState[rUid] ?? false);

        _remoteParticipants.add(participant);

        conferenceRoom.onParticipantConnected();
        notifyListeners();
      },
      onPermissionError: (PermissionType permissionType) {
        print('[onPermissionError] $permissionType');
      },
      onUserOffline:
          (RtcConnection connection, int rUid, UserOfflineReasonType reason) {
        print(
          '[onUserOffline] connection: ${connection.toJson()}  rUid: $rUid reason: $reason',
        );
        _remoteParticipants.removeWhere((a) => a.agoraUid == rUid);
        _videoMutedState.remove(rUid);
        _audioMutedState.remove(rUid);
        conferenceRoom.onParticipantDisconnected();
        notifyListeners();
      },
      onLeaveChannel: (RtcConnection connection, RtcStats stats) {
        print(
          '[onLeaveChannel] connection: ${connection.toJson()} stats: ${stats.toJson()}',
        );
        _remoteParticipants.clear();
        _state = AgoraRoomState.DISCONNECTED;
        notifyListeners();
      },
      onUserMuteVideo: (RtcConnection connection, int rUid, bool muted) {
        print(
          '[onUserMuteVideo] connection: ${connection.toJson()} muted: $muted',
        );

        _videoMutedState[rUid] = muted;
        _remoteParticipants
            .where((p) => p.agoraUid == rUid)
            .firstOrNull
            ?.videoTrackEnabled = !muted;
        notifyListeners();
      },
      onUserMuteAudio: (RtcConnection connection, int rUid, bool muted) {
        print(
          '[onUserMuteAudio] connection: ${connection.toJson()} muted: $muted',
        );
        _audioMutedState[rUid] = muted;
        _remoteParticipants
            .where((p) => p.agoraUid == rUid)
            .firstOrNull
            ?.audioTrackEnabled = !muted;

        notifyListeners();
      },
      onUserEnableVideo: (RtcConnection connection, int rUid, bool enabled) {
        print(
          '[onUserEnableVideo] connection: ${connection.toJson()} enabled: $enabled',
        );
      },
      onVideoSubscribeStateChanged: (
        String channelId,
        int uid,
        StreamSubscribeState oldState,
        StreamSubscribeState newState,
        int elapsedTime,
      ) {
        print(
          '[onVideoSubscribeStateChanged]  $channelId uid: $uid oldState: $oldState newState $newState',
        );
      },
      onRemoteAudioStateChanged: (
        RtcConnection connection,
        int remoteUid,
        RemoteAudioState state,
        RemoteAudioStateReason reason,
        int elapsed,
      ) {
        print(
          '[onRemoteAudioStateChanged] connection: ${connection.toJson()} remoteUid: $remoteUid state: $state reason: $reason elapsed: $elapsed',
        );

        notifyListeners();
      },
      onRemoteVideoStateChanged: (
        RtcConnection connection,
        int remoteUid,
        RemoteVideoState state,
        RemoteVideoStateReason reason,
        int elapsed,
      ) {
        print(
          '[onRemoteVideoStateChanged] connection: ${connection.toJson()} uid: $remoteUid state: $state',
        );

        notifyListeners();
      },
      onUserEnableLocalVideo:
          (RtcConnection connection, int uid, bool enabled) {
        print(
          '[onUserEnableLocalVideo] connection: ${connection.toJson()} uid: $uid enabled: $enabled',
        );
        notifyListeners();
      },
      onLocalAudioStateChanged: (
        RtcConnection connection,
        LocalAudioStreamState state,
        LocalAudioStreamReason reason,
      ) {
        print(
          '[onLocalAudioStateChanged] connection: ${connection.toJson()} state: $state reason: $reason',
        );
      },
      onNetworkQuality: (
        RtcConnection connection,
        int uid,
        QualityType txQuality,
        rxQuality,
      ) {
        if (uid == 0) {
          _localParticipant?.networkQualityLevel = txQuality;
        } else {
          _remoteParticipants
              .where((p) => p.agoraUid == uid)
              .firstOrNull
              ?.networkQualityLevel = txQuality;
        }
        notifyListeners();
      },
      onAudioVolumeIndication: (
        RtcConnection connection,
        List<AudioVolumeInfo> speakers,
        int speakerNumber,
        int totalVolume,
      ) {
        for (final speaker in speakers) {
          if (speaker.uid == connection.localUid) {
            _localParticipant?.volume = speaker.volume;
          } else {
            final participant = _remoteParticipants
                .where((s) => s.agoraUid == speaker.uid)
                .firstOrNull;
            participant?.volume = speaker.volume;
          }
        }

        _updateDominantSpeaker(
          localUid: connection.localUid,
          speakers: speakers,
        );
      },
    );

    engine.registerEventHandler(_rtcEngineEventHandler);

    await engine.enableVideo();
    await engine.enableAudio();
    await engine.muteAllRemoteAudioStreams(false);

    await engine.enableLocalVideo(false);
    await engine.enableLocalAudio(false);

    await engine.joinChannel(
      channelId: channelName,
      token: token,
      uid: uidToInt(userService.currentUserId!),
      options: ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
        enableAudioRecordingOrPlayout: true,
      ),
    );
  }

  @override
  dispose() {
    engine.unregisterEventHandler(_rtcEngineEventHandler);
    engine.leaveChannel();
    engine.stopPreview();
    engine.enableLocalVideo(false);
    engine.enableLocalAudio(false);
    engine.release();

    super.dispose();
  }
}

class VideoTrack {
  final bool isStarted;
  final bool isEnabled;
  final Size dimensions;

  VideoTrack({
    required this.isStarted,
    required this.isEnabled,
    required this.dimensions,
  });
}

class AgoraParticipant with ChangeNotifier {
  AgoraParticipant({
    RtcEngine? rtcEngine,
    // Agora user Id
    required this.agoraUid,
    required this.isLocal,
    // User ID in the app
    required this.userId,
    this.token,
  }) : _rtcEngineObj = rtcEngine;

  RtcEngine get _rtcEngine => _rtcEngineObj!;
  final RtcEngine? _rtcEngineObj;
  final int agoraUid;
  final String userId;
  final bool isLocal;
  final String? token;

  String get identity => userId;

  QualityType networkQualityLevel = QualityType.qualityUnknown;

  int? volume = 0;

  bool audioTrackEnabled = true;

  bool videoLocalPreviewStarted = false;
  bool videoTrackEnabled = true;

  MediaStreamTrack? get screenshareTrack => null;

  Future<void> enableAudio({required bool setEnabled, String? deviceId}) async {
    if (setEnabled) {
      if (deviceId != null) {
        try {
          await _rtcEngine.getAudioDeviceManager().setRecordingDevice(deviceId);
        } catch (e) {
          print('Error setting device ID $deviceId');
        }
      }

      await _rtcEngine.enableLocalAudio(true);
      await _rtcEngine.updateChannelMediaOptions(
        ChannelMediaOptions(
          publishMicrophoneTrack: true,
        ),
      );
    } else {
      await _rtcEngine.updateChannelMediaOptions(
        ChannelMediaOptions(
          publishMicrophoneTrack: false,
        ),
      );
      await _rtcEngine.enableLocalAudio(false);
    }
    audioTrackEnabled = setEnabled;
  }

  Future<void> enableVideo({required bool setEnabled, String? deviceId}) async {
    if (setEnabled) {
      if (!videoLocalPreviewStarted) {
        videoLocalPreviewStarted = true;
        await _rtcEngine.startPreview();
      }

      if (deviceId != null) {
        try {
          await _rtcEngine.getVideoDeviceManager().setDevice(deviceId);
        } catch (e) {
          print('Error setting device ID $deviceId');
        }
      }

      await _rtcEngine.enableLocalVideo(true);
      await _rtcEngine.updateChannelMediaOptions(
        ChannelMediaOptions(
          publishCameraTrack: true,
        ),
      );
    } else {
      await _rtcEngine.updateChannelMediaOptions(
        ChannelMediaOptions(
          publishCameraTrack: false,
        ),
      );
      await _rtcEngine.enableLocalVideo(false);
    }

    videoTrackEnabled = setEnabled;
  }

  startScreenShare() {
    // If interested in screensharing can implement here
  }

  stopScreenShare() {}

  Future<void> toggleMuteOverride({required bool isMuted}) async {
    await _rtcEngine.muteRemoteAudioStream(uid: agoraUid, mute: isMuted);
  }
}
