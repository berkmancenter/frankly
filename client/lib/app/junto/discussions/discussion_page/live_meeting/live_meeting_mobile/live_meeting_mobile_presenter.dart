import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:junto/app/junto/chat/chat_model.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_tabs/discussion_tabs.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_tabs/discussion_tabs_model.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/live_meeting_mobile/live_meeting_mobile_page.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/live_meeting_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/meeting_guide/meeting_guide_card_store.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/video/conference/agora_room.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/video/conference/conference_room.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/meeting_agenda_provider.dart';
import 'package:junto/app/junto/discussions/instant_unify/unify_america_controller.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/services/responsive_layout_service.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/meeting_guide.dart';
import 'package:provider/provider.dart';

import 'live_meeting_mobile_contract.dart';
import 'live_meeting_mobile_model.dart';

class LiveMeetingMobilePresenter {
  final LiveMeetingMobileView _view;
  final LiveMeetingMobileModel _model;
  final ResponsiveLayoutService _responsiveLayoutService;
  final DiscussionProvider _discussionProvider;
  final DiscussionTabsControllerState _discussionTabsControllerState;
  final ConferenceRoom? _conferenceRoom;
  final AgendaProvider _agendaProvider;
  final LiveMeetingProvider _liveMeetingProvider;
  final ChatModel? _chatModel;
  final MeetingGuideCardStore _meetingGuideCardStore;
  final UnifyAmericaController? _unifyAmericaController;

  LiveMeetingMobilePresenter(
    BuildContext context,
    this._view,
    this._model, {
    ResponsiveLayoutService? responsiveLayoutService,
    DiscussionProvider? discussionProvider,
    DiscussionTabsControllerState? discussionTabsControllerState,
    ConferenceRoom? conferenceRoom,
    ChatModel? chatModel,
    LiveMeetingProvider? liveMeetingProvider,
    AgendaProvider? agendaProvider,
    MeetingGuideCardStore? meetingGuideCardStore,
    UnifyAmericaController? unifyAmericaController,
  })  : _responsiveLayoutService =
            responsiveLayoutService ?? GetIt.instance<ResponsiveLayoutService>(),
        _discussionProvider = discussionProvider ?? context.read<DiscussionProvider>(),
        _discussionTabsControllerState =
            discussionTabsControllerState ?? context.read<DiscussionTabsControllerState>(),
        _conferenceRoom = conferenceRoom ?? ConferenceRoom.read(context),
        _liveMeetingProvider = liveMeetingProvider ?? context.read<LiveMeetingProvider>(),
        _chatModel = chatModel ?? providerOrNull(() => context.read<ChatModel>()),
        _agendaProvider = agendaProvider ?? context.read<AgendaProvider>(),
        _meetingGuideCardStore = meetingGuideCardStore ?? context.read<MeetingGuideCardStore>(),
        _unifyAmericaController = unifyAmericaController ?? UnifyAmericaController.read(context);

  bool get isUnifyAmerica => _unifyAmericaController != null;

  bool get canUserControlMeeting => _agendaProvider.canUserControlMeeting && !isUnifyAmerica;

  bool get isRaisedHandVisible =>
      _conferenceRoom != null && _agendaProvider.currentAgendaItem != null;

  bool isBottomSheetPresent() {
    switch (_model.bottomSheetState) {
      case LiveMeetingMobileBottomSheetState.fullyVisible:
      case LiveMeetingMobileBottomSheetState.partiallyVisible:
        return true;
      case LiveMeetingMobileBottomSheetState.hidden:
        return false;
    }
  }

  Stream<List<ParticipantAgendaItemDetails>>? getParticipantAgendaItemDetailsStream() {
    return _meetingGuideCardStore.participantAgendaItemDetailsStream;
  }

  bool isHandRaised() {
    return _meetingGuideCardStore.getHandIsRaised(userService.currentUserId!);
  }

  Future<void> toggleHandRaise() async {
    await firestoreMeetingGuideService.toggleHandRaise(
      agendaItemId: _meetingGuideCardStore.meetingGuideCardAgendaItem?.id ?? '',
      userId: userService.currentUserId!,
      liveMeetingPath: _agendaProvider.liveMeetingPath,
      isHandRaised: !isHandRaised(),
    );
  }

  List<String> getPresentParticipantIds() {
    return _liveMeetingProvider.presentParticipantIds;
  }

  Future<void> toggleVideo() async {
    await _conferenceRoom?.toggleVideoEnabled();
  }

  Future<void> toggleAudio() async {
    await _conferenceRoom?.toggleAudioEnabled();
  }

  void toggleBottomSheetState(LiveMeetingMobileBottomSheetState liveMeetingMobileBottomSheetState) {
    _model.bottomSheetState = liveMeetingMobileBottomSheetState;
    _view.updateView();
  }

  bool isMobile(BuildContext context) {
    return _responsiveLayoutService.isMobile(context);
  }

  Future<void> sendMessage(String message) async {
    await _chatModel?.createChatMessage(text: message);
  }

  bool isVideoOn() {
    return _conferenceRoom?.videoEnabled == true;
  }

  bool isMicOn() {
    return _conferenceRoom?.audioEnabled == true;
  }

  Future<void> leaveMeeting(BuildContext context) async {
    await _liveMeetingProvider.leaveMeeting();
  }

  bool isScreenShareEnabled() {
    return false; //_discussionProvider.discussion.discussionSettings?.allowScreenshare == true;
  }

  Future<void> toggleScreenShare() async {
    await _conferenceRoom?.toggleScreenShare();
  }

  bool isAudioTemporarilyDisabled() {
    return _liveMeetingProvider.audioTemporarilyDisabled;
  }

  bool isLocalSharingScreenActive() {
    return _conferenceRoom?.isLocalSharingScreenActive == true;
  }

  bool isScreenSharingActive() {
    return _conferenceRoom?.screenSharer != null;
  }

  String? screenSharerUserId() {
    return _conferenceRoom?.screenSharerUserId;
  }

  List<AgoraParticipant> getParticipants() {
    return _conferenceRoom?.participants ?? [];
  }

  bool isReadyToAdvance(List<ParticipantAgendaItemDetails>? participantAgendaItemDetailsList) {
    return _meetingGuideCardStore.isReadyToAdvance(
      participantAgendaItemDetailsList,
      userService.currentUserId,
    );
  }

  int getTopicIndex(List<AgendaItem> agendaItems, AgendaItem? currentItem) {
    return agendaItems.indexWhere((a) => a.id == currentItem?.id) + 1;
  }

  AgendaItem? getCurrentAgendaItem() {
    return _meetingGuideCardStore.meetingGuideCardAgendaItem;
  }

  List<AgendaItem> getAgendaItems() {
    return _agendaProvider.agendaItems;
  }

  bool isBackButtonShown() {
    if (!isHosted()) return false;

    final topicIndex = getTopicIndex(getAgendaItems(), getCurrentAgendaItem());
    return (topicIndex > 1 || isMeetingFinished());
  }

  String? getCurrentAgendaItemId() {
    return _meetingGuideCardStore.currentAgendaModelItemId;
  }

  bool isMeetingStarted() {
    return _agendaProvider.isMeetingStarted;
  }

  bool isMeetingFinished() {
    return _agendaProvider.isMeetingFinished;
  }

  int readyToMoveOnCount(
    List<ParticipantAgendaItemDetails>? participantAgendaItemDetailsList,
    Set<String> presentParticipantIds,
  ) {
    return (participantAgendaItemDetailsList ?? [])
        .where((p) => (p.readyToAdvance ?? false) && presentParticipantIds.contains(p.userId))
        .length;
  }

  bool get isDismissableTabOpen {
    final fullScreenTabs = [TabType.chat, TabType.suggestions, TabType.admin];
    return fullScreenTabs.any((tab) => _discussionTabsControllerState.isTabOpen(tab));
  }

  void dismissFullBottomSheet() {
    _model.bottomSheetState = LiveMeetingMobileBottomSheetState.hidden;
    _view.updateView();
  }

  void openGuide() {
    if (_agendaProvider.agendaItems.isEmpty) {
      _model.bottomSheetState = LiveMeetingMobileBottomSheetState.hidden;
    } else {
      _model.bottomSheetState = LiveMeetingMobileBottomSheetState.partiallyVisible;
      _discussionTabsControllerState.openTab(TabType.guide);
    }
    _view.updateView();
  }

  bool isHosted() {
    return _discussionProvider.discussion.isHosted && !_agendaProvider.isInBreakouts;
  }

  bool isCardPending() {
    return _meetingGuideCardStore.meetingGuideCardIsPending;
  }
}
