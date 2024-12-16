import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/meeting_rating.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/video/conference/conference_room.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/pre_post_discussion_dialog/pre_post_discussion_dialog_page.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/app/junto/widgets/share/app_share.dart';
import 'package:junto/common_widgets/confirm_dialog.dart';
import 'package:junto/common_widgets/confirm_text_input_dialogue.dart';
import 'package:junto/common_widgets/donate_widget.dart';
import 'package:junto/common_widgets/navbar/nav_bar_provider.dart';
import 'package:junto/junto_app.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/services/firestore/firestore_utils.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/dialog_provider.dart';
import 'package:junto/utils/hostless_action_fallback_controller.dart';
import 'package:junto/utils/platform_utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/discussion_proposal.dart';
import 'package:junto_models/firestore/live_meeting.dart';
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
  final JuntoProvider juntoProvider;
  final DiscussionProvider discussionProvider;
  final NavBarProvider navBarProvider;
  final bool isInstant;
  final BeamLocation? leaveLocation;
  final Function()? onLeave;
  final bool isUnifyAmerica;
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
    required this.juntoProvider,
    required this.discussionProvider,
    required this.navBarProvider,
    this.isInstant = false,
    this.leaveLocation,
    this.onLeave,
    this.isUnifyAmerica = false,
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

  bool get showGuideCard => discussionProvider.discussion.agendaItems.isNotEmpty;

  List<MeetingProviderParticipant>? get meetingProviderParticipants => _meetingProviderParticipants;

  Stream<LiveMeeting>? get liveMeetingStream => _liveMeetingStream.stream;

  Stream<LiveMeeting>? get breakoutRoomLiveMeetingStream => _breakoutLiveMeetingStream?.stream;

  LiveMeeting? get liveMeeting => _liveMeetingStream.stream.valueOrNull;

  LiveMeeting? get breakoutRoomLiveMeeting => _breakoutLiveMeetingStream?.stream.valueOrNull;

  /// Returns the live meeting object for the active meeting or breakout room.
  LiveMeeting? get activeLiveMeeting => isInBreakout ? breakoutRoomLiveMeeting : liveMeeting;

  List<String> get presentParticipantIds {
    return meetingProviderParticipants?.map((p) => p.userId).toList() ?? [];
  }

  bool get leftMeeting => _leftMeeting;

  bool get isInBreakout => currentBreakoutRoomId != null;

  bool get breakoutsActive =>
      liveMeeting?.currentBreakoutSession?.breakoutRoomStatus == BreakoutRoomStatus.active;

  bool get userLeftBreakouts => _userLeftBreakouts;

  String? get breakoutRoomOverride => _breakoutRoomOverride;

  String? get currentBreakoutRoomId {
    if (_userLeftBreakouts) return null;
    return breakoutRoomOverride ?? assignedBreakoutRoomId;
  }

  bool get isHost => discussionProvider.discussion.creatorId == userService.currentUserId;

  bool get isMeetingStarted =>
      liveMeeting?.events.any((e) => e.event == LiveMeetingEventType.agendaItemStarted) ?? false;

  String get discussionPath => discussionProvider.discussion.fullPath;

  String? get assignedBreakoutRoomId =>
      _assignedBreakoutRoomStream?.stream.valueOrNull?.firstOrNull?.roomId;

  bool get assignedBreakoutRoomIsLoading => _assignedBreakoutRoomStream?.stream.valueOrNull == null;

  bool get shouldBeInBreakout =>
      currentBreakoutRoomId != null &&
      liveMeeting?.currentBreakoutSession?.breakoutRoomStatus == BreakoutRoomStatus.active;

  bool get shouldBeInLiveStream => discussionProvider.isLiveStream && !shouldBeInBreakout;

  bool get audioDefaultOn => sharedPreferencesService.getMicOnByDefault();

  bool get videoDefaultOn => sharedPreferencesService.getCameraOnByDefault();

  bool get shouldBeInWaitingRoom {
    final isHostless = discussionProvider.discussion.discussionType == DiscussionType.hostless;
    final hostlessInWaitingRoom = isHostless && !shouldBeInBreakout;

    final isLiveStream = discussionProvider.discussion.discussionType == DiscussionType.livestream;
    final isBeforeStartTime =
        !discussionProvider.discussion.timeUntilScheduledStart(clockService.now()).isNegative;
    final waitingRoomInfo = discussionProvider.discussion.waitingRoomInfo;
    final hasWaitingRoom = waitingRoomInfo != null &&
        (!isNullOrEmpty(waitingRoomInfo.content) ||
            !isNullOrEmpty(waitingRoomInfo.introMediaItem?.url));
    final livestreamInWaitingRoom = isLiveStream && isBeforeStartTime && hasWaitingRoom;

    return hostlessInWaitingRoom || livestreamInWaitingRoom;
  }

  /// Returns the path to the live meeting document for the active meeting or breakout room.
  String get activeLiveMeetingPath => isInBreakout
      ? firestoreLiveMeetingService.getBreakoutLiveMeetingPath(
          discussion: discussionProvider.discussion,
          breakoutSessionId: liveMeeting?.currentBreakoutSession?.breakoutRoomSessionId ?? '',
          breakoutRoomId: currentBreakoutRoomId ?? '',
        )
      : firestoreLiveMeetingService.getLiveMeetingPath(discussionProvider.discussion);

  LiveMeetingViewType? _liveMeetingViewType;

  LiveMeetingViewType? get liveMeetingViewType {
    if (isUnifyAmerica) return LiveMeetingViewType.bradyBunch;

    return _liveMeetingViewType;
  }

  void updateLiveMeetingViewType(LiveMeetingViewType type) {
    _liveMeetingViewType = type;
    notifyListeners();
  }

  ConferenceRoom? get conferenceRoom => _conferenceRoom;

  set conferenceRoom(ConferenceRoom? value) {
    if (_conferenceRoom != null) conferenceRoomNotifier.remove(_conferenceRoom!);
    if (value != null) conferenceRoomNotifier.add(value);
    _conferenceRoom = value;

    Future(() => notifyListeners());
  }

  bool _isMeetingCardMinimized = false;

  bool get isMeetingCardMinimized => _isMeetingCardMinimized;

  Future<void> updateGuideCardIsMinimized({required bool isMinimized}) async {
    final userCanMinimizeMeeting = discussionProvider.discussion.isHosted && isHost;
    if (userCanMinimizeMeeting) {
      await firestoreLiveMeetingService.updateGuideCardIsMinimized(
        discussion: discussionProvider.discussion,
        isCardMinimized: isMinimized,
      );
    }
    _isMeetingCardMinimized = isMinimized;
    notifyListeners();
  }

  void _resetAudioVideoOn() {
    shouldStartLocalAudioOn = shouldStartLocalAudioOn && discussionProvider.discussion.isHosted;
    shouldStartLocalVideoOn = shouldStartLocalVideoOn && discussionProvider.discussion.isHosted;
  }

  Stream<List<DiscussionProposal>> get proposals {
    final path = firestoreLiveMeetingService.getLiveMeetingPath(discussionProvider.discussion);
    return firestoreLiveMeetingService.getProposals(liveMeetingPath: path);
  }

  void initialize() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      updateQueryParameterToJoinDiscussion();
    });

    _liveMeetingViewType = discussionProvider.defaultStageView
        ? LiveMeetingViewType.stage
        : LiveMeetingViewType.bradyBunch;

    shouldStartLocalAudioOn = audioDefaultOn;
    shouldStartLocalVideoOn = videoDefaultOn;

    _resetAudioVideoOn();

    _liveMeetingStream = firestoreLiveMeetingService.liveMeetingStream(
      parentDoc: discussionPath,
      id: discussionProvider.discussion.id,
    );

    _liveMeetingSubscription = _liveMeetingStream.stream.listen(_onLiveMeetingChange);
    _selfParticipantSubscription =
        discussionProvider.selfParticipantStream?.listen((currentParticipant) {
      if (currentParticipant.status == ParticipantStatus.banned) {
        leaveMeeting();
      }

      if (currentParticipant.muteOverride && (conferenceRoom?.audioEnabled ?? false)) {
        conferenceRoom?.toggleAudioEnabled(setEnabled: false);
        showToast('You have been muted by the host.');
      }

      _checkShowBreakoutDialog();
    });

    firestoreLiveMeetingService.updateMeetingPresence(
      discussion: discussionProvider.discussion,
      isPresent: true,
    );

    _onUnloadSubscription = html.window.onBeforeUnload.listen((event) {
      firestoreLiveMeetingService.updateMeetingPresence(
        discussion: discussionProvider.discussion,
        isPresent: false,
      );
    });

    _updateTimersBeforeStart();
    canAutoplayLookupFuture = _checkIfCanAutoplay();

    _presenceUpdater = Timer.periodic(Duration(seconds: 5), (_) {
      if (_activeBreakoutRoomId != null &&
          discussionProvider.selfParticipant?.currentBreakoutRoomId != _activeBreakoutRoomId) {
        firestoreLiveMeetingService.updateMeetingPresence(
          discussion: discussionProvider.discussion,
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
        discussionProvider.discussion.timeUntilScheduledStart(clockService.now());
    if (!timeUntilScheduledStart.isNegative) {
      _scheduledStartTimer = Timer(timeUntilScheduledStart + Duration(milliseconds: 100), () {
        notifyListeners();
      });
    }
    final timeUntilWaitingRoomFinished =
        discussionProvider.discussion.timeUntilWaitingRoomFinished(clockService.now());
    if (timeUntilWaitingRoomFinished != timeUntilScheduledStart &&
        !timeUntilWaitingRoomFinished.isNegative) {
      _meetingStartTimer = Timer(timeUntilWaitingRoomFinished + Duration(milliseconds: 100), () {
        notifyListeners();
      });
    }

    if (!timeUntilWaitingRoomFinished.isNegative &&
        discussionProvider.discussion.discussionType == DiscussionType.hostless) {
      // Setup a check that hostless is done
      _hostlessGoToBreakoutsFallbackController?.cancel();
      _hostlessGoToBreakoutsFallbackController = HostlessActionFallbackController(
        totalParticipants: discussionProvider.presentParticipantCount,
        targetActionCount: 5,
        action: () async {
          loggingService.log('Checking hostless during the fallback.');
          await cloudFunctionsService.checkHostlessGoToBreakouts(CheckHostlessGoToBreakoutsRequest(
            discussionPath: discussionPath,
          ));
        },
        delay: timeUntilWaitingRoomFinished + Duration(milliseconds: 5000 + random.nextInt(20000)),
        checkIsActionCompleted: () async =>
            liveMeeting?.currentBreakoutSession?.breakoutRoomStatus != null &&
            liveMeeting?.currentBreakoutSession?.breakoutRoomStatus != BreakoutRoomStatus.inactive,
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
        discussion: discussionProvider.discussion, isPresent: false);

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
        liveMeeting.isMeetingCardMinimized != _previousLiveMeeting?.isMeetingCardMinimized) {
      _isMeetingCardMinimized = liveMeeting.isMeetingCardMinimized;

      if (_previousLiveMeeting?.isMeetingCardMinimized != null) {
        if (_isMeetingCardMinimized) {
          showToast('Guide agenda item minimized by host for all participants.',
              hideOnMobile: true);
        } else {
          showToast('Guide agenda item expanded by host for all participants.', hideOnMobile: true);
        }
      }
    }

    _previousLiveMeeting = liveMeeting;

    notifyListeners();
  }

  void _checkLoadBreakoutsStream(LiveMeeting liveMeeting) {
    if (_previousLiveMeeting?.currentBreakoutSession?.breakoutRoomStatus ==
            BreakoutRoomStatus.pending &&
        liveMeeting.currentBreakoutSession?.breakoutRoomStatus != BreakoutRoomStatus.pending) {
      ConfirmDialog.confirmDialogDismisser.dismiss();
    }

    if (liveMeeting.currentBreakoutSession?.breakoutRoomStatus == BreakoutRoomStatus.active &&
        liveMeeting.currentBreakoutSession?.breakoutRoomSessionId !=
            _currentBreakoutRoomsStreamSession) {
      _currentBreakoutRoomsStreamSession =
          liveMeeting.currentBreakoutSession?.breakoutRoomSessionId;
      _isMeetingCardMinimized = false;

      _assignedBreakoutRoomStream = firestoreLiveMeetingService.assignedBreakoutRoomsStream(
        discussion: discussionProvider.discussion,
        breakoutRoomSessionId: liveMeeting.currentBreakoutSession?.breakoutRoomSessionId ?? '',
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
        discussionProvider.selfParticipant?.availableForBreakoutSessionId;
    final currentBreakoutSession = liveMeeting?.currentBreakoutSession;
    final currentBreakoutSessionId = currentBreakoutSession?.breakoutRoomSessionId;
    if (currentBreakoutSessionId != null &&
        currentBreakoutSession != null &&
        localLiveMeeting.currentBreakoutSession?.breakoutRoomStatus == BreakoutRoomStatus.pending &&
        !_handledBreakoutSessionIds.contains(currentBreakoutSessionId) &&
        currentlyAvailableForBreakoutId != currentBreakoutSessionId) {
      _checkAssignToBreakoutsTimer?.cancel();
      _handledBreakoutSessionIds.add(currentBreakoutSessionId);

      // Setup check to assign breakouts
      final timeUntilBreakouts = currentBreakoutSession.scheduledTime?.difference(DateTime.now());
      if (timeUntilBreakouts != null) {
        _pendingBreakoutsFallbackController?.cancel();
        _pendingBreakoutsFallbackController = HostlessActionFallbackController(
          totalParticipants: discussionProvider.presentParticipantCount,
          targetActionCount: 5,
          action: () async {
            loggingService.log('Checking available for breakouts during the fallback.');
            await cloudFunctionsService.checkAssignToBreakouts(CheckAssignToBreakoutsRequest(
              discussionPath: discussionPath,
              breakoutSessionId: currentBreakoutSessionId,
            ));
          },
          delay: timeUntilBreakouts + Duration(milliseconds: 5000 + random.nextInt(30000)),
          checkIsActionCompleted: () async =>
              liveMeeting?.currentBreakoutSession?.breakoutRoomStatus != BreakoutRoomStatus.pending,
        )..initialize();
      }

      if (discussionProvider.discussion.discussionType == DiscussionType.hostless) {
        await firestoreLiveMeetingService.updateAvailableForBreakoutSessionId(
          discussion: discussionProvider.discussion,
          breakoutSessionId: localLiveMeeting.currentBreakoutSession?.breakoutRoomSessionId ?? '',
        );
        final isMod = juntoUserDataService.getMembership(juntoProvider.juntoId).isMod;
        if (isMod) {
          final confirmJoiningBreakouts = await ConfirmDialog(
            mainText: 'Would you like to participate in breakout room assignments?',
            confirmText: 'Yes, join',
            cancelText: 'No, skip',
          ).show();

          if (!confirmJoiningBreakouts) {
            await firestoreLiveMeetingService.updateAvailableForBreakoutSessionId(
              discussion: discussionProvider.discussion,
              breakoutSessionId: '',
            );
          }
        }
      } else if (useBotControls) {
        await firestoreLiveMeetingService.updateAvailableForBreakoutSessionId(
          discussion: discussionProvider.discussion,
          breakoutSessionId: localLiveMeeting.currentBreakoutSession?.breakoutRoomSessionId ?? '',
        );
      } else {
        await ConfirmDialog(
          mainText: 'Host is sending you to a breakout room. Join breakout room?',
          confirmText: 'Yes, join',
          onConfirm: (context) => alertOnError(context, () async {
            await firestoreLiveMeetingService.updateAvailableForBreakoutSessionId(
              discussion: discussionProvider.discussion,
              breakoutSessionId:
                  localLiveMeeting.currentBreakoutSession?.breakoutRoomSessionId ?? '',
            );
            Navigator.of(context).pop(true);
          }),
          cancelText: 'No, skip',
        ).show();
      }
    }
  }

  Future<GetMeetingJoinInfoResponse>? getCurrentMeetingJoinInfo() {
    if (_activeBreakoutRoomId == currentBreakoutRoomId && _activeRoomJoinInfoFuture != null) {
      return _activeRoomJoinInfoFuture;
    }

    final localCurrentBreakoutRoomId = currentBreakoutRoomId;
    if (activeUiState == MeetingUiState.breakoutRoom && localCurrentBreakoutRoomId != null) {
      return _activeRoomJoinInfoFuture = getBreakoutRoomFuture(roomId: localCurrentBreakoutRoomId);
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

    return cloudFunctionsService.getMeetingJoinInfo(GetMeetingJoinInfoRequest(
      discussionPath: discussionPath,
    ));
  }

  Future<BreakoutRoom> reassignBreakoutRoom({
    required String userId,
    String? newRoomNumber,
  }) {
    return cloudFunctionsService.reassignBreakoutRoom(ReassignBreakoutRoomRequest(
      discussionPath:
          '${discussionProvider.discussion.collectionPath}/${discussionProvider.discussion.id}',
      breakoutRoomSessionId: liveMeeting?.currentBreakoutSession?.breakoutRoomSessionId ?? '',
      userId: userId,
      newRoomNumber: newRoomNumber,
    ));
  }

  Future<void> leaveMeeting() async {
    if (_leftMeeting) return;

    _leftMeeting = true;
    notifyListeners();

    final localOnLeave = onLeave;
    if (localOnLeave != null) {
      localOnLeave();
    } else {
      final junto = juntoProvider.junto;

      final donationsEnabledFuture = juntoProvider.donationsEnabled();
      final prePostEnabledFuture = juntoProvider.prePostEnabled();
      final donationsEnabled = await donationsEnabledFuture;
      final prePostEnabled = await prePostEnabledFuture;

      final postEventCardData = discussionProvider.discussion.postEventCardData;

      final timeNow = clockService.now();
      final discussion = discussionProvider.discussion;

      if (prePostEnabled && postEventCardData != null) {
        if (timeNow.difference(discussion.scheduledTime ?? timeNow).inMinutes >
            _postEventEmailThresholdInMinutes) {
          unawaited(
            cloudFunctionsService.discussionEnded(
              DiscussionEndedRequest(discussionPath: discussionPath),
            ),
          );
        }

        if (postEventCardData.hasData) {
          await PrePostDiscussionDialogPage.show(
            prePostCardData: postEventCardData,
            discussion: discussionProvider.discussion,
            isMeetingOfAmerica: discussionProvider.juntoProvider.isMeetingOfAmerica,
          );
        }
      }

      if (donationsEnabled &&
          (isMeetingStarted || _meetingHadParticipants || discussionProvider.isLiveStream)) {
        await DonateWidget(
          junto: junto,
          headline: 'Donate to keep the conversation going!',
          subHeader: 'Support ${junto.name ?? 'this space'}!',
        ).show();
      }

      final ratingSurveyUrl = junto.ratingSurveyUrl;

      if (junto.id == 'allsides-talks' && ratingSurveyUrl != null && ratingSurveyUrl.isNotEmpty) {
        unawaited(launch(ratingSurveyUrl, targetIsSelf: true));
        return;
      }

      if (isMeetingStarted || discussionProvider.isLiveStream) {
        await MeetingRating().showInDialog(
          discussionProvider: discussionProvider,
          liveMeetingProvider: this,
          juntoProvider: juntoProvider,
        );
      }

      // We want to share junto home page instead of conversation page.
      final pathToPage = '/space/${juntoProvider.juntoId}';

      await showJuntoDialog(
        builder: (context) => AppShareDialog(
          title: 'SPREAD THE WORD',
          content: 'Who else would benefit from these conversations?',
          iconBackgroundColor: AppColor.white,
          appShareData: AppShareData(
            subject: 'Join an event with me on Frankly!',
            body: "Let's have a conversation on Frankly!",
            pathToPage: pathToPage,
            juntoId: juntoProvider.juntoId,
          ),
        ),
      );

      final location = leaveLocation ??
          JuntoPageRoutes(
            juntoDisplayId: juntoProvider.displayId,
          ).juntoHome;

      // ignore: unnecessary_non_null_assertion
      html.window.location.href =
          html.window.location.origin! + (location.state as BeamState).uri.toString();
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
      discussion: discussionProvider.discussion,
      isPresent: true,
    );

    _resetAudioVideoOn();

    notifyListeners();
  }

  void setMeetingProviderParticipants(List<MeetingProviderParticipant>? participants,
      {bool notify = true}) {
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
    await meetingProviderParticipants?.firstWhereOrNull((p) => p.userId == userId)?.mute();
  }

  void _loadBreakoutLiveMeetingStream(String roomId) {
    _breakoutLiveMeetingStream?.dispose();

    final discussion = discussionProvider.discussion;
    final parentPath = firestoreLiveMeetingService.getBreakoutRoomPath(
      discussion: discussion,
      breakoutSessionId: liveMeeting?.currentBreakoutSession?.breakoutRoomSessionId ?? '',
      breakoutRoomId: roomId,
    );
    _breakoutLiveMeetingSubscription?.cancel();
    _breakoutLiveMeetingStream = firestoreLiveMeetingService.liveMeetingStream(
      parentDoc: parentPath,
      id: roomId,
    );
    _breakoutLiveMeetingSubscription = _breakoutLiveMeetingStream?.listen((_) => notifyListeners());
  }

  Future<GetMeetingJoinInfoResponse> getBreakoutRoomFuture({required String roomId}) async {
    _activeBreakoutRoomId = roomId;
    _activeRoomJoinInfoFuture = null;

    _loadBreakoutLiveMeetingStream(roomId);

    final discussionId = discussionProvider.discussion.id;
    final breakoutRoomJoinInfo =
        cloudFunctionsService.getBreakoutRoomJoinInfo(GetBreakoutRoomJoinInfoRequest(
      discussionId: discussionId,
      discussionPath: discussionProvider.discussion.fullPath,
      breakoutRoomId: roomId,
      enableAudio: shouldStartLocalAudioOn,
      enableVideo: shouldStartLocalVideoOn,
    ));

    await firestoreLiveMeetingService.updateMeetingPresence(
      discussion: discussionProvider.discussion,
      isPresent: true,
      currentBreakoutRoomId: _activeBreakoutRoomId,
    );

    return breakoutRoomJoinInfo;
  }

  Future<void> endBreakoutRooms() async {
    final confirmed = await ConfirmDialog(
      title: 'End Breakout Rooms',
      subText: 'Are you sure you want to end breakout rooms for all participants? \n\n'
          'This will send all participants back to the main room immediately.',
    ).show();
    if (confirmed) {
      final updatedLiveMeeting = liveMeeting?.copyWith(currentBreakoutSession: null);

      await firestoreLiveMeetingService.update(
        liveMeetingPath:
            firestoreLiveMeetingService.getLiveMeetingPath(discussionProvider.discussion),
        liveMeeting: updatedLiveMeeting!,
        keys: [
          LiveMeeting.kFieldCurrentBreakoutSession,
        ],
      );
    }
  }

  bool get audioTemporarilyDisabled => _audioTemporarilyDisabled;

  Future<void> setAudioTemporarilyDisabled({required bool disabled}) async {
    if (_audioTemporarilyDisabled == disabled || (conferenceRoom?.room?.localParticipant == null)) {
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
      subText: 'Are you sure you want to start a vote to kick out ${user.displayName}? Please'
          ' only take this action if the participant is behaving inappropriately.',
      textLabel: 'Enter reason',
      textHint: 'e.g. They are trying to sabotage the event',
      cancelText: 'No, cancel',
      confirmText: 'Yes, poll participants',
    ).show();
    if (reason != null) {
      await cloudFunctionsService.voteToKick(VoteToKickRequest(
        targetUserId: userId,
        discussionPath: discussionPath,
        liveMeetingPath: activeLiveMeetingPath,
        reason: reason,
        inFavor: true,
      ));
    }
  }

  Future<void> startBreakouts({
    required int numPerRoom,
    required BreakoutAssignmentMethod assignmentMethod,
  }) async {
    final newBreakoutRoomSessionId = uuid.v1().toString();
    _handledBreakoutSessionIds.add(newBreakoutRoomSessionId);

    await cloudFunctionsService.initiateBreakouts(
      InitiateBreakoutsRequest(
        discussionPath: discussionProvider.discussion.fullPath,
        breakoutSessionId: newBreakoutRoomSessionId,
        targetParticipantsPerRoom: numPerRoom,
        assignmentMethod: assignmentMethod,
        includeWaitingRoom: !discussionProvider.discussion.isHosted,
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
      providerOrNull(() => Provider.of<LiveMeetingProvider>(context, listen: false));

  static LiveMeetingProvider? watchOrNull(BuildContext context) =>
      providerOrNull(() => Provider.of<LiveMeetingProvider>(context));
}
