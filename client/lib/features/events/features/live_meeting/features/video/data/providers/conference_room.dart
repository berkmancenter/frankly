import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:beamer/beamer.dart';
import 'package:client/core/utils/navigation_utils.dart';
import 'package:client/core/utils/random_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:client/features/events/features/live_meeting/data/providers/live_meeting_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/data/providers/meeting_guide_card_store.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/views/audio_video_error.dart';
import 'package:client/features/events/features/live_meeting/features/video/utils/debug.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/providers/meeting_agenda_provider.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/confirm_dialog.dart';
import 'package:client/app.dart';
import 'package:client/core/utils/firestore_utils.dart';
import 'package:client/services.dart';
import 'package:data_models/events/event.dart' hide Participant;
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:client/core/localization/localization_helper.dart';
import 'package:synchronized/synchronized.dart';
import 'package:universal_html/js_util.dart' as js_util;
import 'package:universal_html/html.dart' as html;

import '../../../../../../../../core/routing/locations.dart';
import 'agora_room.dart';

class FakeParticipant extends AgoraParticipant {
  final int id;

  FakeParticipant({required this.id, required bool isLocal})
      : super(
          rtcEngine: null,
          agoraUid: id,
          userId: id.toString(),
          isLocal: isLocal,
        );

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}

  @override
  List<dynamic> get audioTracks => [];

  @override
  String get identity => userId;

  @override
  QualityType get networkQualityLevel => QualityType.qualityGood;

  @override
  String get userId => id.toString();

  @override
  String get state => 'connected';

  @override
  List<dynamic> get videoTracks => [];
}

class VideoParticipant implements MeetingProviderParticipant {
  final AgoraParticipant participant;
  final Event event;
  final String eventPath;

  VideoParticipant(this.participant, this.event, this.eventPath);

  @override
  bool get audioOn => participant.audioTrackEnabled;

  @override
  bool get local => participant.isLocal;

  @override
  String get sessionId => participant.userId;

  @override
  String get userId => participant.identity;

  @override
  Future<void> mute() {
    loggingService.log('muting: $userId');
    return firestoreLiveMeetingService.updateParticipantMuteOverride(
      event: event,
      participantId: userId,
      muteOverride: true,
    );
  }
}

class ConferenceRoom with ChangeNotifier {
  final LiveMeetingProvider liveMeetingProvider;
  final AgendaProvider agendaProvider;
  final CommunityProvider communityProvider;
  final MeetingGuideCardStore meetingGuideCardModel;
  final String token;
  final String roomName;

  ConferenceRoom({
    required this.liveMeetingProvider,
    required this.agendaProvider,
    required this.communityProvider,
    required this.meetingGuideCardModel,
    required this.token,
    required this.roomName,
  }) {
    onException = _onExceptionStreamController.stream;
    Debug.enabled = true;
  }

  final StreamController<Exception> _onExceptionStreamController =
      StreamController<Exception>.broadcast();
  late Stream<Exception> onException;

  final Completer<AgoraRoom> _completer = Completer<AgoraRoom>();

  final List<StreamSubscription> _streamSubscriptions = [];

  final participantInitializationTimers = <String, Timer>{};

  final _audioTogglingLock = Lock();
  final _videoTogglingLock = Lock();

  List<AgoraParticipant> _orderedParticipants = [];

  late StreamSubscription _unraiseHandSubscription;

  /// List of users who have been muted by the host. All participants mute their audio streams until
  /// they unmute themselves.
  final _currentlyMutedUsers = <String>{};

  AgoraRoom? _room;
  bool hasStartedConnecting = false;
  String? _connectError;
  bool _isDisposed = false;

  int _numFakeParticipants = 0;

  int get numFakeParticipants => _numFakeParticipants;

  set numFakeParticipants(int value) {
    _numFakeParticipants = value;
    notifyListeners();
  }

  int get maxHighlightedParticipants {
    return liveMeetingProvider.showGuideCard &&
            !liveMeetingProvider.isMeetingCardMinimized
        ? 1
        : 2;
  }

  String? get connectError => _connectError;

  Future<AgoraRoom> get connectionFuture => _completer.future;
  bool flashEnabled = false;

  bool get audioEnabled => _room?.localParticipant?.audioTrackEnabled ?? false;

  bool get videoEnabled {
    return _room?.localParticipant?.videoTrackEnabled ?? false;
  }

  List<AgoraParticipant> get handRaisedParticipants => _orderedParticipants
      .where((p) => meetingGuideCardModel.getHandRaisedTime(p.identity) != null)
      .toList();

  bool get isLocalSharingScreenActive =>
      screenSharerUserId == userService.currentUserId;

  String? get screenSharerUserId => participants
      .firstWhereOrNull((p) => p.screenshareTrack != null)
      ?.identity;

  AgoraParticipant? get screenSharer =>
      participants.firstWhereOrNull((p) => p.identity == screenSharerUserId);

  AgoraRoom? get room => _room;

  String? get dominantSpeakerSid =>
      _debouncedDominantSpeakerStream?.value?.userId;
  BehaviorSubjectWrapper<AgoraParticipant?>? _debouncedDominantSpeakerStream;
  StreamSubscription<AgoraParticipant?>? _debouncedDominantSpeakerSubscription;

  /// Returns an ordered list of participants to be displayed on screen.
  ///
  /// In order to keep a consistent ordering the determined ordering is stored in
  /// [_orderedParticipants] and that is used to initialize the ordering. They are then sorted by
  /// hand raise status and the dominant speaker is placed in the front. The final ordering is then
  /// stored again in [_orderedParticipants].
  List<AgoraParticipant> get participants {
    final localParticipant = _room?.localParticipant;
    final participantsCopy = <AgoraParticipant>[
      if (localParticipant != null) localParticipant,
      ..._room?.remoteParticipants ?? [],
    ];

    final newOrderedList = <AgoraParticipant>[];

    // Add existing ordered participants in order.
    for (final participant in _orderedParticipants) {
      final existingIndex =
          participantsCopy.indexWhere((p) => p.userId == participant.userId);
      if (existingIndex >= 0) {
        newOrderedList.add(participant);
        participantsCopy.removeAt(existingIndex);
      }
    }

    // Insert all new ones in at the end
    newOrderedList.addAll(participantsCopy);
    _orderedParticipants = newOrderedList;

    final localHandRaisedParticipants = handRaisedParticipants.toList();
    localHandRaisedParticipants.sort((a, b) {
      final aHandRaisedTime =
          meetingGuideCardModel.getHandRaisedTime(a.identity);
      final bHandRaisedTime =
          meetingGuideCardModel.getHandRaisedTime(b.identity);

      if (aHandRaisedTime == bHandRaisedTime) return 0;
      if (aHandRaisedTime == null) return 1;
      if (bHandRaisedTime == null) return -1;

      return aHandRaisedTime.compareTo(bHandRaisedTime);
    });

    final handRaisedIds =
        localHandRaisedParticipants.map((p) => p.userId).toSet();
    _orderedParticipants.removeWhere((p) => handRaisedIds.contains(p.userId));
    _orderedParticipants.insertAll(0, localHandRaisedParticipants);

    final dominantSpeaker = _orderedParticipants
        .firstWhereOrNull((p) => p.userId == dominantSpeakerSid);
    final dominantSpeakerIndex = dominantSpeaker != null
        ? _orderedParticipants.indexOf(dominantSpeaker)
        : -1;
    final shouldMoveDominantSpeaker =
        liveMeetingProvider.liveMeetingViewType == LiveMeetingViewType.stage ||
            dominantSpeakerIndex > 8 ||
            handRaisedIds.isNotEmpty;
    if (dominantSpeaker != null && shouldMoveDominantSpeaker) {
      _orderedParticipants.remove(dominantSpeaker);
      _orderedParticipants.insert(0, dominantSpeaker);
    }

    final pinnedIds =
        agendaProvider.currentLiveMeeting?.pinnedUserIds.toSet() ?? {};
    final pinnedParticipants = _orderedParticipants
        .where((p) => pinnedIds.contains(p.identity))
        .toList();
    _orderedParticipants.removeWhere((p) => pinnedIds.contains(p.identity));
    _orderedParticipants.insertAll(0, pinnedParticipants);

    return [
      ..._orderedParticipants,
      for (int i = 0; i < _numFakeParticipants; i++)
        FakeParticipant(id: i, isLocal: false),
    ];
  }

  void initialize(BuildContext context) {
    liveMeetingProvider.conferenceRoom = this;

    liveMeetingProvider.eventProvider.addListener(_muteOthersOnOverride);
  }

  void _muteOthersOnOverride() {
    final mutedUsers = liveMeetingProvider.eventProvider.eventParticipants
        .where((p) => p.muteOverride)
        .map((p) => p.id)
        .toSet();

    final newlyMutedUsers = mutedUsers.difference(_currentlyMutedUsers);
    final newlyUnmutedUsers = _currentlyMutedUsers.difference(mutedUsers);

    _currentlyMutedUsers.clear();
    _currentlyMutedUsers.addAll(mutedUsers);

    for (final participant
        in _room?.remoteParticipants ?? <AgoraParticipant>[]) {
      final userId = participant.identity;

      if (newlyMutedUsers.contains(userId) ||
          newlyUnmutedUsers.contains(userId)) {
        participant.toggleMuteOverride(
          isMuted: newlyMutedUsers.contains(userId),
        );
      }
    }
  }

  Future<void> connect() async {
    Debug.log('ConferenceRoom.connect()');
    try {
      hasStartedConnecting = true;
      _room = AgoraRoom(
        channelName: roomName,
        token: token,
        liveMeetingProvider: liveMeetingProvider,
        eventProvider: liveMeetingProvider.eventProvider,
        conferenceRoom: this,
      );
      await _room!.connect(
        enableVideo: false,
        enableAudio: false,
      );
      _room!.addListener(notifyListeners);
    } catch (err, stacktrace) {
      loggingService.log('error');
      loggingService.log(stacktrace);
      loggingService.log(err.runtimeType);

      _connectError = js_util.callMethod(err, 'toString', []);
      notifyListeners();

      Debug.log(err);
    }
  }

  void setConnectError(String error) {
    _connectError = error;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) super.notifyListeners();
  }

  @override
  void dispose() {
    loggingService.log('disposing');
    Debug.log('ConferenceRoom.dispose()');

    _isDisposed = true;
    liveMeetingProvider.conferenceRoom = null;

    _room?.dispose();
    _updateLiveMeetingParticipants(participantsOverride: [], notify: false);
    _disposeStreamsAndSubscriptions();
    super.dispose();
  }

  void _disposeStreamsAndSubscriptions() {
    liveMeetingProvider.eventProvider.removeListener(_muteOthersOnOverride);

    _debouncedDominantSpeakerSubscription?.cancel();
    _unraiseHandSubscription.cancel();
    _debouncedDominantSpeakerStream?.dispose();

    _onExceptionStreamController.close();
    for (final streamSubscription in _streamSubscriptions) {
      streamSubscription.cancel();
    }
  }

  Future<bool> _requestUserMediaPermission({bool? audio, bool? video}) async {
    try {
      final stream = await html.window.navigator.mediaDevices?.getUserMedia({
        'audio': audio ?? false,
        'video': video ?? false,
      });
      if (stream == null) {
        return false;
      }
      print('Microphone permission granted.');
      // Stop using the audio stream right away
      stream.getTracks().forEach((track) => track.stop());
      return true;
    } catch (e) {
      print('Microphone permission denied.');
      print(e);
      return false;
    }
  }

  Future<void> toggleVideoEnabled({
    bool? setEnabled,
    bool updateProvider = true,
  }) async {
    final updatedEnabledValue = setEnabled ?? !videoEnabled;

    if (updatedEnabledValue) {
      final granted = await _requestUserMediaPermission(video: true);
      if (!granted) {
        await showAlert(
          navigatorState.context,
          'Error enabling camera. Please ensure you have granted permission',
        );
        return;
      }
    }

    // Lock this code so that different sections toggling audio will not cause race conditions.
    await _videoTogglingLock.synchronized(
      () async {
        await _room!.localParticipant!.enableVideo(
          setEnabled: updatedEnabledValue,
          deviceId: sharedPreferencesService.getDefaultCameraId(),
        );
        if (updateProvider) {
          liveMeetingProvider.shouldStartLocalVideoOn = updatedEnabledValue;
        }
      },
      timeout: Duration(seconds: 4),
    );
    notifyListeners();
  }

  Future<void> toggleAudioEnabled({
    bool? setEnabled,
    bool updateProvider = true,
  }) async {
    final updatedEnabledValue = setEnabled ?? !audioEnabled;

    if (updatedEnabledValue) {
      final granted = await _requestUserMediaPermission(audio: true);
      if (!granted) {
        await showAlert(
          navigatorState.context,
          'Error enabling microphone. Please ensure you have granted permission',
        );
        return;
      }
    }

    // Lock this code so that different sections toggling audio will not cause race conditions.
    await _audioTogglingLock.synchronized(
      () async {
        if (updatedEnabledValue &&
            liveMeetingProvider.audioTemporarilyDisabled) {
          return;
        }

        final audioEnableFutures = [
          _room!.localParticipant!.enableAudio(
            setEnabled: updatedEnabledValue,
            deviceId: sharedPreferencesService.getDefaultMicrophoneId(),
          ),
          if ((liveMeetingProvider
                      .eventProvider.selfParticipant?.muteOverride ??
                  false) &&
              updatedEnabledValue)
            firestoreLiveMeetingService.updateParticipantMuteOverride(
              event: liveMeetingProvider.eventProvider.event,
              participantId: userService.currentUserId!,
              muteOverride: false,
            ),
        ];

        await Future.wait(audioEnableFutures);

        if (updateProvider) {
          liveMeetingProvider.shouldStartLocalAudioOn = updatedEnabledValue;
        }
      },
      timeout: Duration(seconds: 4),
    );

    notifyListeners();
  }

  Future<void> toggleScreenShare({bool? setEnabled}) async {
    final updatedEnabledValue = setEnabled ?? !isLocalSharingScreenActive;
    if (updatedEnabledValue) {
      await _room!.localParticipant!.startScreenShare();
    } else {
      await _room!.localParticipant!.stopScreenShare();
    }
    notifyListeners();
  }

  Future<void> onConnected(AgoraRoom room) async {
    Debug.log('ConferenceRoom._onConnected => state: ${room.state}');

    _debouncedDominantSpeakerStream = BehaviorSubjectWrapper(
      room.dominantSpeakerStream
          .distinct()
          .debounceTime(Duration(milliseconds: 500))
          .switchMap((id) {
        if (id == null) {
          // If it is null then wait a few seconds to make sure there arent other changes before switching over to no active speaker
          return Rx.timer(null, Duration(seconds: 3));
        }
        return Stream.value(id); // Immediately emit new speaker ID
      }).debounceTime(Duration(seconds: 1)),
    );
    _debouncedDominantSpeakerSubscription =
        _debouncedDominantSpeakerStream!.listen((_) => notifyListeners());

    _unraiseHandSubscription = _debouncedDominantSpeakerStream!
        .distinct()
        .debounceTime(Duration(seconds: 4))
        .distinct()
        .listen((dominantSpeaker) {
      final dismissRaisedHand =
          room.localParticipant?.agoraUid == dominantSpeaker?.agoraUid;
      final isHandRaised =
          meetingGuideCardModel.getHandIsRaised(userService.currentUserId!);
      final currentAgendaModelItemId =
          meetingGuideCardModel.meetingGuideCardAgendaItem?.id;
      if (dismissRaisedHand &&
          isHandRaised &&
          currentAgendaModelItemId != null) {
        firestoreMeetingGuideService.toggleHandRaise(
          agendaItemId: currentAgendaModelItemId,
          userId: userService.currentUserId!,
          liveMeetingPath: agendaProvider.liveMeetingPath,
          isHandRaised: false,
        );
      }
    });

    _updateLiveMeetingParticipants();
    print('updated live meeting participants');
    notifyListeners();
    _completer.complete(room);

    final isTest = (routerDelegate.currentBeamLocation.state as BeamState)
            .queryParameters['test'] !=
        null;
    if (isTest) {
      if (!(_room?.localParticipant?.audioTrackEnabled ?? false)) {
        await AudioVideoErrorDialog.showOnError(
          navigatorState.context,
          () => toggleAudioEnabled(setEnabled: true),
        );
      }
      if (!(_room?.localParticipant?.videoTrackEnabled ?? false)) {
        await AudioVideoErrorDialog.showOnError(
          navigatorState.context,
          () => toggleVideoEnabled(setEnabled: true),
        );
      }
    } else if (liveMeetingProvider.shouldStartLocalAudioOn ||
        liveMeetingProvider.shouldStartLocalVideoOn) {
      unawaited(_promptToTurnOnVideo());
    }
  }

  Future<void> _promptToTurnOnVideo() async {
    final enableAudioVideo = await ConfirmDialog(
      title: appLocalizationService.getLocalization().turnOnAudioVideo,
      mainText: 'Would you like to turn on audio and video?',
    ).show();
    if (enableAudioVideo) {
      if (!(_room?.localParticipant?.audioTrackEnabled ?? false)) {
        await AudioVideoErrorDialog.showOnError(
          navigatorState.context,
          () => toggleAudioEnabled(setEnabled: true),
        );
      }
      if (!(_room?.localParticipant?.videoTrackEnabled ?? false)) {
        await AudioVideoErrorDialog.showOnError(
          navigatorState.context,
          () => toggleVideoEnabled(setEnabled: true),
        );
      }
    }
  }

  void _updateLiveMeetingParticipants({
    List<AgoraParticipant>? participantsOverride,
    bool notify = true,
  }) {
    final participants = participantsOverride ?? this.participants;
    final participantIds = participants.map((p) => p.userId).toSet();

    // Remove initialization timers for participants that have left
    participantInitializationTimers
        .removeWhere((id, _) => !participantIds.contains(id));
    // Add timers for newly connected users
    for (final participant in participants) {
      participantInitializationTimers[participant.userId] ??=
          Timer(Duration(seconds: 4), () => notifyListeners());
    }

    liveMeetingProvider.setMeetingProviderParticipants(
      participants
          .map(
            (p) => VideoParticipant(
              p,
              liveMeetingProvider.eventProvider.event,
              liveMeetingProvider.eventPath,
            ),
          )
          .toList(),
      notify: notify,
    );
  }

  void onLocalParticipantChanges() {
    Debug.log('ConferenceRoom.onLocalParticipant');
    _updateLiveMeetingParticipants();
    notifyListeners();
  }

  void onParticipantConnected() {
    Debug.log('ConferenceRoom._onParticipantConnected');

    _updateLiveMeetingParticipants();
  }

  void onParticipantDisconnected() {
    Debug.log('ConferenceRoom._onParticipantDisconnected');
    _updateLiveMeetingParticipants();

    if (liveMeetingProvider.isInBreakout) {
      Future.delayed(
          Duration(milliseconds: (5.0 * random.nextDouble() * 1000).round()),
          () {
        if (!_isDisposed) {
          agendaProvider.checkReadyToAdvance();
        }
      });
    }

    notifyListeners();
  }

  static ConferenceRoom? read(BuildContext context) {
    try {
      return Provider.of<ConferenceRoom>(context, listen: false);
    } on ProviderNotFoundException {
      return null;
    }
  }

  /// If this method is called from a place in the tree that is not a descendant of ConferenceRoom
  /// it will throw.
  static ConferenceRoom watch(BuildContext context) =>
      Provider.of<ConferenceRoom>(context);

  static ConferenceRoom? watchOrNull(BuildContext context) {
    try {
      return Provider.of<ConferenceRoom>(context);
    } on ProviderNotFoundException {
      return null;
    }
  }
}
