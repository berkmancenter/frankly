import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:client/core/utils/provider_utils.dart';
import 'package:client/core/utils/random_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/live_meeting/presentation/widgets/meeting_rating.dart';
import 'package:client/features/events/features/live_meeting/features/video/data/providers/conference_room.dart';
import 'package:client/features/events/features/event_page/presentation/views/pre_post_event_dialog_page.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/features/community/presentation/views/app_share.dart';
import 'package:client/core/widgets/confirm_dialog.dart';
import 'package:client/features/events/features/live_meeting/presentation/widgets/confirm_text_input_dialogue.dart';
import 'package:client/features/community/presentation/widgets/donate_widget.dart';
import 'package:client/core/widgets/navbar/nav_bar_provider.dart';
import 'package:client/config/environment.dart';
import 'package:client/app.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/core/utils/firestore_utils.dart';
import 'package:client/services.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/data/providers/dialog_provider.dart';
import 'package:client/features/events/features/live_meeting/presentation/hostless_action_fallback_controller.dart';
import 'package:client/core/utils/platform_utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/event_proposal.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_html/js_util.dart';

abstract class MeetingProviderParticipant {
  String get userId;

  String get sessionId;

  bool get audioOn;

  bool get local;

  Future<void> mute();
}

class ConferenceRoomNotifier extends ChangeNotifier {
  void add(Listenable conferenceRoom) {
    conferenceRoom.addListener(notifyListeners);
  }

  void remove(Listenable conferenceRoom) {
    conferenceRoom.removeListener(notifyListeners);
  }
}

enum LiveMeetingViewType {
  bradyBunch,
  stage,
}

enum MeetingUiState {
  leftMeeting,
  enterMeetingPrescreen,
  breakoutRoom,
  waitingRoom,
  liveStream,
  inMeeting,
}

/// A presenter for the MeetingDialog class. It controls the things across the meeting such as the
/// agenda, control bar, and looking up the live meeting firestore streams.
class LiveMeetingProvider with ChangeNotifier {
  final CommunityProvider communityProvider;
  final EventProvider eventProvider;
  final NavBarProvider navBarProvider;
  final bool isInstant;
  final BeamLocation? leaveLocation;
  final Function()? onLeave;
  final Function(String, {bool? hideOnMobile}) showToast;

  bool _leftMeeting = false;
  bool _userLeftBreakouts = false;
  String? _activeBreakoutRoomId;
  String? _breakoutRoomOverride;

  /// Holds a reference to the current breakout room join info
  Future<GetMeetingJoinInfoResponse>? _activeRoomJoinInfoFuture;

  bool _meetingHadParticipants = false;
  bool _audioTemporarilyDisabled = false;

  late bool shouldStartLocalVideoOn;
  late bool shouldStartLocalAudioOn;

  final Set<String> _handledBreakoutSessionIds = {};

  late BehaviorSubjectWrapper<LiveMeeting> _liveMeetingStream;
  BehaviorSubjectWrapper<LiveMeeting>? _breakoutLiveMeetingStream;

  /// Used to detect changes in the main live meeting object
  LiveMeeting? _previousLiveMeeting;

  String? _currentBreakoutRoomsStreamSession;
  BehaviorSubjectWrapper<List<BreakoutRoom>>? _assignedBreakoutRoomStream;

  List<MeetingProviderParticipant>? _meetingProviderParticipants;

  ConferenceRoom? _conferenceRoom;

  late StreamSubscription _liveMeetingSubscription;
  StreamSubscription? _selfParticipantSubscription;
  StreamSubscription? _assignedBreakoutRoomsStreamSubscription;

  StreamSubscription? _breakoutLiveMeetingSubscription;
  late StreamSubscription _onUnloadSubscription;

  Timer? _scheduledStartTimer;
  Timer? _meetingStartTimer;
  Timer? _checkAssignToBreakoutsTimer;

  Timer? _presenceUpdater;

  HostlessActionFallbackController? _hostlessGoToBreakoutsFallbackController;
  HostlessActionFallbackController? _pendingBreakoutsFallbackController;

  bool _clickedEnterMeeting = false;

  bool get clickedEnterMeeting => _clickedEnterMeeting;

  set clickedEnterMeeting(bool value) {
    _clickedEnterMeeting = true;
    notifyListeners();
  }

  late final Future<bool> canAutoplayLookupFuture;

  final conferenceRoomNotifier = ConferenceRoomNotifier();

  LiveMeetingProvider({
    required this.communityProvider,
    required this.eventProvider,
    required this.navBarProvider,
    this.isInstant = false,
    this.leaveLocation,
    this.onLeave,
    required this.showToast,
  });

  static const int _postEventEmailThresholdInMinutes = 5;

  MeetingUiState get activeUiState {
    final showEnterMeeting = isInstant && !clickedEnterMeeting;

    if (leftMeeting) {
      return MeetingUiState.leftMeeting;
    } else if (showEnterMeeting) {
      return MeetingUiState.enterMeetingPrescreen;
    } else if (shouldBeInBreakout) {
      return MeetingUiState.breakoutRoom;
    } else if (shouldBeInWaitingRoom) {
      return MeetingUiState.waitingRoom;
    } else if (shouldBeInLiveStream) {
      return MeetingUiState.liveStream;
    } else {
      return MeetingUiState.inMeeting;
    }
  }

  bool get showGuideCard => eventProvider.event.agendaItems.isNotEmpty;

  List<MeetingProviderParticipant>? get meetingProviderParticipants =>
      _meetingProviderParticipants;

  Stream<LiveMeeting>? get liveMeetingStream => _liveMeetingStream.stream;

  Stream<LiveMeeting>? get breakoutRoomLiveMeetingStream =>
      _breakoutLiveMeetingStream?.stream;

  LiveMeeting? get liveMeeting => _liveMeetingStream.stream.valueOrNull;

  LiveMeeting? get breakoutRoomLiveMeeting =>
      _breakoutLiveMeetingStream?.stream.valueOrNull;

  /// Returns the live meeting object for the active meeting or breakout room.
  LiveMeeting? get activeLiveMeeting =>
      isInBreakout ? breakoutRoomLiveMeeting : liveMeeting;

  List<String> get presentParticipantIds {
    return meetingProviderParticipants?.map((p) => p.userId).toList() ?? [];
  }

  bool get leftMeeting => _leftMeeting;

  bool get isInBreakout => currentBreakoutRoomId != null;

  bool get breakoutsActive =>
      liveMeeting?.currentBreakoutSession?.breakoutRoomStatus ==
      BreakoutRoomStatus.active;

  bool get userLeftBreakouts => _userLeftBreakouts;

  String? get breakoutRoomOverride => _breakoutRoomOverride;

  String? get currentBreakoutRoomId {
    if (_userLeftBreakouts) return null;
    return breakoutRoomOverride ?? assignedBreakoutRoomId;
  }

  bool get isHost => eventProvider.event.creatorId == userService.currentUserId;

  bool get isMeetingStarted =>
      liveMeeting?.events
          .any((e) => e.event == LiveMeetingEventType.agendaItemStarted) ??
      false;

  String get eventPath => eventProvider.event.fullPath;

  String? get assignedBreakoutRoomId =>
      _assignedBreakoutRoomStream?.stream.valueOrNull?.firstOrNull?.roomId;

  bool get assignedBreakoutRoomIsLoading =>
      _assignedBreakoutRoomStream?.stream.valueOrNull == null;

  bool get shouldBeInBreakout =>
      currentBreakoutRoomId != null &&
      liveMeeting?.currentBreakoutSession?.breakoutRoomStatus ==
          BreakoutRoomStatus.active;

  bool get shouldBeInLiveStream =>
      eventProvider.isLiveStream && !shouldBeInBreakout;

  bool get audioDefaultOn => sharedPreferencesService.getMicOnByDefault();

  bool get videoDefaultOn => sharedPreferencesService.getCameraOnByDefault();

  bool get shouldBeInWaitingRoom {
    final isHostless = eventProvider.event.eventType == EventType.hostless;
    final hostlessInWaitingRoom = isHostless && !shouldBeInBreakout;

    final isLiveStream = eventProvider.event.eventType == EventType.livestream;
    final isBeforeStartTime = !eventProvider.event
        .timeUntilScheduledStart(clockService.now())
        .isNegative;
    final waitingRoomInfo = eventProvider.event.waitingRoomInfo;
    final hasWaitingRoom = waitingRoomInfo != null &&
        (!isNullOrEmpty(waitingRoomInfo.content) ||
            !isNullOrEmpty(waitingRoomInfo.introMediaItem?.url));
    final livestreamInWaitingRoom =
        isLiveStream && isBeforeStartTime && hasWaitingRoom;

    return hostlessInWaitingRoom || livestreamInWaitingRoom;
  }

  /// Returns the path to the live meeting document for the active meeting or breakout room.
  String get activeLiveMeetingPath => isInBreakout
      ? firestoreLiveMeetingService.getBreakoutLiveMeetingPath(
          event: eventProvider.event,
          breakoutSessionId:
              liveMeeting?.currentBreakoutSession?.breakoutRoomSessionId ?? '',
          breakoutRoomId: currentBreakoutRoomId ?? '',
        )
      : firestoreLiveMeetingService.getLiveMeetingPath(eventProvider.event);

  LiveMeetingViewType? _liveMeetingViewType;

  LiveMeetingViewType? get liveMeetingViewType {
    return _liveMeetingViewType;
  }

  void updateLiveMeetingViewType(LiveMeetingViewType type) {
    _liveMeetingViewType = type;
    notifyListeners();
  }

  ConferenceRoom? get conferenceRoom => _conferenceRoom;

  set conferenceRoom(ConferenceRoom? value) {
    if (_conferenceRoom != null) {
      conferenceRoomNotifier.remove(_conferenceRoom!);
    }
    if (value != null) conferenceRoomNotifier.add(value);
    _conferenceRoom = value;

    Future(() => notifyListeners());
  }

  bool _isMeetingCardMinimized = false;

  bool get isMeetingCardMinimized => _isMeetingCardMinimized;

  Future<void> updateGuideCardIsMinimized({required bool isMinimized}) async {
    final userCanMinimizeMeeting = eventProvider.event.isHosted && isHost;
    if (userCanMinimizeMeeting) {
      await firestoreLiveMeetingService.updateGuideCardIsMinimized(
        event: eventProvider.event,
        isCardMinimized: isMinimized,
      );
    }
    _isMeetingCardMinimized = isMinimized;
    notifyListeners();
  }

  void _resetAudioVideoOn() {
    shouldStartLocalAudioOn =
        shouldStartLocalAudioOn && eventProvider.event.isHosted;
    shouldStartLocalVideoOn =
        shouldStartLocalVideoOn && eventProvider.event.isHosted;
  }

  Stream<List<EventProposal>> get proposals {
    final path =
        firestoreLiveMeetingService.getLiveMeetingPath(eventProvider.event);
    return firestoreLiveMeetingService.getProposals(liveMeetingPath: path);
  }

  void initialize() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      updateQueryParameterToJoinEvent();
    });

    _liveMeetingViewType = eventProvider.defaultStageView
        ? LiveMeetingViewType.stage
        : LiveMeetingViewType.bradyBunch;

    shouldStartLocalAudioOn = audioDefaultOn;
    shouldStartLocalVideoOn = videoDefaultOn;

    _resetAudioVideoOn();

    _liveMeetingStream = firestoreLiveMeetingService.liveMeetingStream(
      parentDoc: eventPath,
      id: eventProvider.event.id,
    );

    _liveMeetingSubscription =
        _liveMeetingStream.stream.listen(_onLiveMeetingChange);
    _selfParticipantSubscription =
        eventProvider.selfParticipantStream?.listen((currentParticipant) {
      if (currentParticipant.status == ParticipantStatus.banned) {
        leaveMeeting();
      }

      if (currentParticipant.muteOverride &&
          (conferenceRoom?.audioEnabled ?? false)) {
        conferenceRoom?.toggleAudioEnabled(setEnabled: false);
        showToast('You have been muted by the host.');
      }

      _checkShowBreakoutDialog();
    });

    firestoreLiveMeetingService.updateMeetingPresence(
      event: eventProvider.event,
      isPresent: true,
    );

    _onUnloadSubscription = html.window.onBeforeUnload.listen((event) {
      firestoreLiveMeetingService.updateMeetingPresence(
        event: eventProvider.event,
        isPresent: false,
      );
    });

    _updateTimersBeforeStart();
    canAutoplayLookupFuture = _checkIfCanAutoplay();

    _presenceUpdater = Timer.periodic(Duration(seconds: 5), (_) {
      if (_activeBreakoutRoomId != null &&
          eventProvider.selfParticipant?.currentBreakoutRoomId !=
              _activeBreakoutRoomId) {
        firestoreLiveMeetingService.updateMeetingPresence(
          event: eventProvider.event,
          currentBreakoutRoomId: _activeBreakoutRoomId,
          isPresent: true,
        );
      }
    });
  }

  Future<bool> _checkIfCanAutoplay() async {
    final canAutoplay = await promiseToFuture(checkCanAutoplay()) as bool;
    if (canAutoplay) {
      clickedEnterMeeting = true;
    }

    return Future.microtask(() => canAutoplay);
  }

  /// If the meeting hasn't started then setup timers to rebuild listeners when the meeting starts.
  ///
  /// Also add on a short buffer after the start time so that any consumers will definitely
  /// build after the meeting start time. Without the buffer I fear race conditions where callers
  /// may still think the meeting time has not arrived yet.
  void _updateTimersBeforeStart() {
    final timeUntilScheduledStart =
        eventProvider.event.timeUntilScheduledStart(clockService.now());
    if (!timeUntilScheduledStart.isNegative) {
      _scheduledStartTimer =
          Timer(timeUntilScheduledStart + Duration(milliseconds: 100), () {
        notifyListeners();
      });
    }
    final timeUntilWaitingRoomFinished =
        eventProvider.event.timeUntilWaitingRoomFinished(clockService.now());
    if (timeUntilWaitingRoomFinished != timeUntilScheduledStart &&
        !timeUntilWaitingRoomFinished.isNegative) {
      _meetingStartTimer =
          Timer(timeUntilWaitingRoomFinished + Duration(milliseconds: 100), () {
        notifyListeners();
      });
    }

    if (!timeUntilWaitingRoomFinished.isNegative &&
        eventProvider.event.eventType == EventType.hostless) {
      // Setup a check that hostless is done
      _hostlessGoToBreakoutsFallbackController?.cancel();
      _hostlessGoToBreakoutsFallbackController =
          HostlessActionFallbackController(
        totalParticipants: eventProvider.presentParticipantCount,
        targetActionCount: 5,
        action: () async {
          loggingService.log('Checking hostless during the fallback.');
          await cloudFunctionsLiveMeetingService.checkHostlessGoToBreakouts(
            CheckHostlessGoToBreakoutsRequest(
              eventPath: eventPath,
            ),
          );
        },
        delay: timeUntilWaitingRoomFinished +
            Duration(milliseconds: 5000 + random.nextInt(20000)),
        checkIsActionCompleted: () async =>
            liveMeeting?.currentBreakoutSession?.breakoutRoomStatus != null &&
            liveMeeting?.currentBreakoutSession?.breakoutRoomStatus !=
                BreakoutRoomStatus.inactive,
      )..initialize();
    }
  }

  @override
  void dispose() {
    _liveMeetingSubscription.cancel();
    _selfParticipantSubscription?.cancel();
    _breakoutLiveMeetingSubscription?.cancel();
    _onUnloadSubscription.cancel();
    _assignedBreakoutRoomsStreamSubscription?.cancel();

    _presenceUpdater?.cancel();

    _scheduledStartTimer?.cancel();
    _meetingStartTimer?.cancel();
    _checkAssignToBreakoutsTimer?.cancel();

    _hostlessGoToBreakoutsFallbackController?.cancel();
    _pendingBreakoutsFallbackController?.cancel();

    firestoreLiveMeetingService.updateMeetingPresence(
      event: eventProvider.event,
      isPresent: false,
    );

    Future.microtask(() => navBarProvider.resetHideNav());
    _liveMeetingStream.dispose();
    _breakoutLiveMeetingStream?.dispose();
    _assignedBreakoutRoomStream?.dispose();

    super.dispose();
  }

  void _onLiveMeetingChange(LiveMeeting liveMeeting) {
    _checkShowBreakoutDialog();

    _checkLoadBreakoutsStream(liveMeeting);

    if (!breakoutsActive && !isNullOrEmpty(_activeBreakoutRoomId)) {
      leaveBreakoutRoom();
      _userLeftBreakouts = false;
    }

    if (_isMeetingCardMinimized != liveMeeting.isMeetingCardMinimized &&
        liveMeeting.isMeetingCardMinimized !=
            _previousLiveMeeting?.isMeetingCardMinimized) {
      _isMeetingCardMinimized = liveMeeting.isMeetingCardMinimized;

      if (_previousLiveMeeting?.isMeetingCardMinimized != null) {
        if (_isMeetingCardMinimized) {
          showToast(
            'Guide agenda item minimized by host for all participants.',
            hideOnMobile: true,
          );
        } else {
          showToast(
            'Guide agenda item expanded by host for all participants.',
            hideOnMobile: true,
          );
        }
      }
    }

    _previousLiveMeeting = liveMeeting;

    notifyListeners();
  }

  void _checkLoadBreakoutsStream(LiveMeeting liveMeeting) {
    if (_previousLiveMeeting?.currentBreakoutSession?.breakoutRoomStatus ==
            BreakoutRoomStatus.pending &&
        liveMeeting.currentBreakoutSession?.breakoutRoomStatus !=
            BreakoutRoomStatus.pending) {
      ConfirmDialog.confirmDialogDismisser.dismiss();
    }

    if (liveMeeting.currentBreakoutSession?.breakoutRoomStatus ==
            BreakoutRoomStatus.active &&
        liveMeeting.currentBreakoutSession?.breakoutRoomSessionId !=
            _currentBreakoutRoomsStreamSession) {
      _currentBreakoutRoomsStreamSession =
          liveMeeting.currentBreakoutSession?.breakoutRoomSessionId;
      _isMeetingCardMinimized = false;

      _assignedBreakoutRoomStream =
          firestoreLiveMeetingService.assignedBreakoutRoomsStream(
        event: eventProvider.event,
        breakoutRoomSessionId:
            liveMeeting.currentBreakoutSession?.breakoutRoomSessionId ?? '',
        userId: userService.currentUserId ?? '',
      );
      _assignedBreakoutRoomsStreamSubscription?.cancel();
      _assignedBreakoutRoomsStreamSubscription =
          _assignedBreakoutRoomStream?.stream.listen((assignedBreakoutRooms) {
        loggingService.log('Assigned breakout room: $assignedBreakoutRooms');
        notifyListeners();
      });
    } else if (liveMeeting.currentBreakoutSession?.breakoutRoomStatus !=
        BreakoutRoomStatus.active) {
      _currentBreakoutRoomsStreamSession = null;
      _assignedBreakoutRoomStream = null;
      _assignedBreakoutRoomsStreamSubscription?.cancel();
    }
  }

  Future<void> _checkShowBreakoutDialog() async {
    final localLiveMeeting = liveMeeting;
    if (localLiveMeeting == null) return;

    final currentlyAvailableForBreakoutId =
        eventProvider.selfParticipant?.availableForBreakoutSessionId;
    final currentBreakoutSession = liveMeeting?.currentBreakoutSession;
    final currentBreakoutSessionId =
        currentBreakoutSession?.breakoutRoomSessionId;
    if (currentBreakoutSessionId != null &&
        currentBreakoutSession != null &&
        localLiveMeeting.currentBreakoutSession?.breakoutRoomStatus ==
            BreakoutRoomStatus.pending &&
        !_handledBreakoutSessionIds.contains(currentBreakoutSessionId) &&
        currentlyAvailableForBreakoutId != currentBreakoutSessionId) {
      _checkAssignToBreakoutsTimer?.cancel();
      _handledBreakoutSessionIds.add(currentBreakoutSessionId);

      // Setup check to assign breakouts
      final timeUntilBreakouts =
          currentBreakoutSession.scheduledTime?.difference(DateTime.now());
      if (timeUntilBreakouts != null) {
        _pendingBreakoutsFallbackController?.cancel();
        _pendingBreakoutsFallbackController = HostlessActionFallbackController(
          totalParticipants: eventProvider.presentParticipantCount,
          targetActionCount: 5,
          action: () async {
            loggingService
                .log('Checking available for breakouts during the fallback.');
            await cloudFunctionsLiveMeetingService.checkAssignToBreakouts(
              CheckAssignToBreakoutsRequest(
                eventPath: eventPath,
                breakoutSessionId: currentBreakoutSessionId,
              ),
            );
          },
          delay: timeUntilBreakouts +
              Duration(milliseconds: 5000 + random.nextInt(30000)),
          checkIsActionCompleted: () async =>
              liveMeeting?.currentBreakoutSession?.breakoutRoomStatus !=
              BreakoutRoomStatus.pending,
        )..initialize();
      }

      if (eventProvider.event.eventType == EventType.hostless) {
        await firestoreLiveMeetingService.updateAvailableForBreakoutSessionId(
          event: eventProvider.event,
          breakoutSessionId:
              localLiveMeeting.currentBreakoutSession?.breakoutRoomSessionId ??
                  '',
        );
        final isMod =
            userDataService.getMembership(communityProvider.communityId).isMod;
        if (isMod) {
          final confirmJoiningBreakouts = await ConfirmDialog(
            mainText:
                'Would you like to participate in breakout room assignments?',
            confirmText: 'Yes, join',
            cancelText: 'No, skip',
          ).show();

          if (!confirmJoiningBreakouts) {
            await firestoreLiveMeetingService
                .updateAvailableForBreakoutSessionId(
              event: eventProvider.event,
              breakoutSessionId: '',
            );
          }
        }
      } else if (useBotControls) {
        await firestoreLiveMeetingService.updateAvailableForBreakoutSessionId(
          event: eventProvider.event,
          breakoutSessionId:
              localLiveMeeting.currentBreakoutSession?.breakoutRoomSessionId ??
                  '',
        );
      } else {
        await ConfirmDialog(
          mainText:
              'Host is sending you to a breakout room. Join breakout room?',
          confirmText: 'Yes, join',
          onConfirm: (context) => alertOnError(context, () async {
            await firestoreLiveMeetingService
                .updateAvailableForBreakoutSessionId(
              event: eventProvider.event,
              breakoutSessionId: localLiveMeeting
                      .currentBreakoutSession?.breakoutRoomSessionId ??
                  '',
            );
            Navigator.of(context).pop(true);
          }),
          cancelText: 'No, skip',
        ).show();
      }
    }
  }

  Future<GetMeetingJoinInfoResponse>? getCurrentMeetingJoinInfo() {
    if (_activeBreakoutRoomId == currentBreakoutRoomId &&
        _activeRoomJoinInfoFuture != null) {
      return _activeRoomJoinInfoFuture;
    }

    final localCurrentBreakoutRoomId = currentBreakoutRoomId;
    if (activeUiState == MeetingUiState.breakoutRoom &&
        localCurrentBreakoutRoomId != null) {
      return _activeRoomJoinInfoFuture =
          getBreakoutRoomFuture(roomId: localCurrentBreakoutRoomId);
    } else if (activeUiState == MeetingUiState.inMeeting) {
      return _activeRoomJoinInfoFuture = getMeetingJoinInfo();
    }

    return null;
  }

  Future<GetMeetingJoinInfoResponse> getMeetingJoinInfo() {
    _activeBreakoutRoomId = null;
    _activeRoomJoinInfoFuture = null;
    _breakoutLiveMeetingStream?.dispose();
    _breakoutLiveMeetingStream = null;

    return cloudFunctionsLiveMeetingService.getMeetingJoinInfo(
      GetMeetingJoinInfoRequest(
        eventPath: eventPath,
      ),
    );
  }

  Future<BreakoutRoom> reassignBreakoutRoom({
    required String userId,
    String? newRoomNumber,
  }) {
    return cloudFunctionsLiveMeetingService.reassignBreakoutRoom(
      ReassignBreakoutRoomRequest(
        eventPath:
            '${eventProvider.event.collectionPath}/${eventProvider.event.id}',
        breakoutRoomSessionId:
            liveMeeting?.currentBreakoutSession?.breakoutRoomSessionId ?? '',
        userId: userId,
        newRoomNumber: newRoomNumber,
      ),
    );
  }

  Future<void> leaveMeeting() async {
    if (_leftMeeting) return;

    _leftMeeting = true;
    notifyListeners();

    final localOnLeave = onLeave;
    if (localOnLeave != null) {
      localOnLeave();
    } else {
      final community = communityProvider.community;

      final donationsEnabledFuture = communityProvider.donationsEnabled();
      final prePostEnabledFuture = communityProvider.prePostEnabled();
      final donationsEnabled = await donationsEnabledFuture;
      final prePostEnabled = await prePostEnabledFuture;

      final postEventCardData = eventProvider.event.postEventCardData;

      final timeNow = clockService.now();
      final event = eventProvider.event;

      if (prePostEnabled && postEventCardData != null) {
        if (timeNow.difference(event.scheduledTime ?? timeNow).inMinutes >
            _postEventEmailThresholdInMinutes) {
          unawaited(
            cloudFunctionsEventService.eventEnded(
              EventEndedRequest(eventPath: eventPath),
            ),
          );
        }

        if (postEventCardData.hasData) {
          await PrePostEventDialogPage.show(
            prePostCardData: postEventCardData,
            event: eventProvider.event,
          );
        }
      }

      if (donationsEnabled &&
          (isMeetingStarted ||
              _meetingHadParticipants ||
              eventProvider.isLiveStream)) {
        await DonateWidget(
          community: community,
          headline: 'Donate to keep the conversation going!',
          subHeader: 'Support ${community.name ?? 'this space'}!',
        ).show();
      }

      if (isMeetingStarted || eventProvider.isLiveStream) {
        await MeetingRating().showInDialog(
          eventProvider: eventProvider,
          liveMeetingProvider: this,
          communityProvider: communityProvider,
        );
      }

      // We want to share community home page instead of event page.
      final pathToPage = '/space/${communityProvider.communityId}';

      await showCustomDialog(
        builder: (context) => AppShareDialog(
          title: 'SPREAD THE WORD',
          content: 'Who else would benefit from these events?',
          iconBackgroundColor: AppColor.white,
          appShareData: AppShareData(
            subject: 'Join an event with me on ${Environment.appName}!',
            body: "Let's have a conversation on ${Environment.appName}!",
            pathToPage: pathToPage,
            communityId: communityProvider.communityId,
          ),
        ),
      );

      final location = leaveLocation ??
          CommunityPageRoutes(
            communityDisplayId: communityProvider.displayId,
          ).communityHome;

      // ignore: unnecessary_non_null_assertion
      html.window.location.href = html.window.location.origin! +
          (location.state as BeamState).uri.toString();
    }
  }

  void enterBreakoutRoom({String? roomId}) {
    _userLeftBreakouts = false;
    if (roomId != null) {
      _breakoutRoomOverride = roomId;
      _activeRoomJoinInfoFuture = null;
      _loadBreakoutLiveMeetingStream(roomId);
    }

    notifyListeners();
  }

  void leaveBreakoutRoom() {
    _userLeftBreakouts = true;

    _activeBreakoutRoomId = null;
    _breakoutRoomOverride = null;
    _activeRoomJoinInfoFuture = null;

    _breakoutLiveMeetingStream?.dispose();
    _breakoutLiveMeetingStream = null;

    firestoreLiveMeetingService.updateMeetingPresence(
      event: eventProvider.event,
      isPresent: true,
    );

    _resetAudioVideoOn();

    notifyListeners();
  }

  void setMeetingProviderParticipants(
    List<MeetingProviderParticipant>? participants, {
    bool notify = true,
  }) {
    _meetingProviderParticipants = participants;
    if ((participants?.length ?? 0) > 1) {
      _meetingHadParticipants = true;
    }

    if (notify) notifyListeners();
  }

  Future<void> muteAllParticipants() {
    return Future.wait([
      for (final participant in meetingProviderParticipants!)
        if (participant.userId != userService.currentUserId) participant.mute(),
    ]);
  }

  Future<void> mute({String? userId}) async {
    await meetingProviderParticipants
        ?.firstWhereOrNull((p) => p.userId == userId)
        ?.mute();
  }

  void _loadBreakoutLiveMeetingStream(String roomId) {
    _breakoutLiveMeetingStream?.dispose();

    final event = eventProvider.event;
    final parentPath = firestoreLiveMeetingService.getBreakoutRoomPath(
      event: event,
      breakoutSessionId:
          liveMeeting?.currentBreakoutSession?.breakoutRoomSessionId ?? '',
      breakoutRoomId: roomId,
    );
    _breakoutLiveMeetingSubscription?.cancel();
    _breakoutLiveMeetingStream = firestoreLiveMeetingService.liveMeetingStream(
      parentDoc: parentPath,
      id: roomId,
    );
    _breakoutLiveMeetingSubscription =
        _breakoutLiveMeetingStream?.listen((_) => notifyListeners());
  }

  Future<GetMeetingJoinInfoResponse> getBreakoutRoomFuture({
    required String roomId,
  }) async {
    _activeBreakoutRoomId = roomId;
    _activeRoomJoinInfoFuture = null;

    _loadBreakoutLiveMeetingStream(roomId);

    final eventId = eventProvider.event.id;
    final breakoutRoomJoinInfo =
        cloudFunctionsLiveMeetingService.getBreakoutRoomJoinInfo(
      GetBreakoutRoomJoinInfoRequest(
        eventId: eventId,
        eventPath: eventProvider.event.fullPath,
        breakoutRoomId: roomId,
        enableAudio: shouldStartLocalAudioOn,
        enableVideo: shouldStartLocalVideoOn,
      ),
    );

    await firestoreLiveMeetingService.updateMeetingPresence(
      event: eventProvider.event,
      isPresent: true,
      currentBreakoutRoomId: _activeBreakoutRoomId,
    );

    return breakoutRoomJoinInfo;
  }

  Future<void> endBreakoutRooms() async {
    final confirmed = await ConfirmDialog(
      title: 'End Breakout Rooms',
      subText:
          'Are you sure you want to end breakout rooms for all participants? \n\n'
          'This will send all participants back to the main room immediately.',
    ).show();
    if (confirmed) {
      final updatedLiveMeeting =
          liveMeeting?.copyWith(currentBreakoutSession: null);

      await firestoreLiveMeetingService.update(
        liveMeetingPath:
            firestoreLiveMeetingService.getLiveMeetingPath(eventProvider.event),
        liveMeeting: updatedLiveMeeting!,
        keys: [
          LiveMeeting.kFieldCurrentBreakoutSession,
        ],
      );
    }
  }

  bool get audioTemporarilyDisabled => _audioTemporarilyDisabled;

  Future<void> setAudioTemporarilyDisabled({required bool disabled}) async {
    if (_audioTemporarilyDisabled == disabled ||
        (conferenceRoom?.room?.localParticipant == null)) {
      return;
    }

    if (shouldStartLocalAudioOn && disabled) {
      showToast('Everyone was muted while the video is playing.');
    }

    _audioTemporarilyDisabled = disabled;
    await conferenceRoom?.toggleAudioEnabled(
      updateProvider: false,
      setEnabled: shouldStartLocalAudioOn && !disabled,
    );
    if (disabled && (conferenceRoom?.isLocalSharingScreenActive ?? false)) {
      await conferenceRoom?.toggleScreenShare(setEnabled: false);
    }

    notifyListeners();
  }

  Future<void> confirmProposeKick(String userId) async {
    final user = await firestoreUserService.getPublicUser(userId: userId);
    final reason = await ConfirmTextInputDialogue(
      title: 'Propose to remove user?',
      subText:
          'Are you sure you want to start a vote to kick out ${user.displayName}? Please'
          ' only take this action if the participant is behaving inappropriately.',
      textLabel: 'Enter reason',
      textHint: 'e.g. They are trying to sabotage the event',
      cancelText: 'No, cancel',
      confirmText: 'Yes, poll participants',
    ).show();
    if (reason != null) {
      await cloudFunctionsLiveMeetingService.voteToKick(
        VoteToKickRequest(
          targetUserId: userId,
          eventPath: eventPath,
          liveMeetingPath: activeLiveMeetingPath,
          reason: reason,
          inFavor: true,
        ),
      );
    }
  }

  Future<void> startBreakouts({
    required int numPerRoom,
    required BreakoutAssignmentMethod assignmentMethod,
  }) async {
    final newBreakoutRoomSessionId = uuid.v1().toString();
    _handledBreakoutSessionIds.add(newBreakoutRoomSessionId);

    await cloudFunctionsLiveMeetingService.initiateBreakouts(
      InitiateBreakoutsRequest(
        eventPath: eventProvider.event.fullPath,
        breakoutSessionId: newBreakoutRoomSessionId,
        targetParticipantsPerRoom: numPerRoom,
        assignmentMethod: assignmentMethod,
        includeWaitingRoom: !eventProvider.event.isHosted,
      ),
    );
  }

  void refreshMeeting() {
    _activeRoomJoinInfoFuture = null;
    notifyListeners();
  }

  static LiveMeetingProvider read(BuildContext context) =>
      Provider.of<LiveMeetingProvider>(context, listen: false);

  static LiveMeetingProvider watch(BuildContext context) =>
      Provider.of<LiveMeetingProvider>(context);

  static LiveMeetingProvider? readOrNull(BuildContext context) =>
      providerOrNull(
        () => Provider.of<LiveMeetingProvider>(context, listen: false),
      );

  static LiveMeetingProvider? watchOrNull(BuildContext context) =>
      providerOrNull(() => Provider.of<LiveMeetingProvider>(context));
}
