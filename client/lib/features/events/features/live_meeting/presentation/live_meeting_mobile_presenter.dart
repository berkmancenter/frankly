import 'package:client/core/utils/provider_utils.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:client/features/chat/data/providers/chat_model.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/event_page/presentation/widgets/event_tabs.dart';
import 'package:client/features/events/features/event_page/presentation/event_tabs_model.dart';
import 'package:client/features/events/features/live_meeting/presentation/views/live_meeting_mobile_page.dart';
import 'package:client/features/events/features/live_meeting/data/providers/live_meeting_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/data/providers/meeting_guide_card_store.dart';
import 'package:client/features/events/features/live_meeting/features/video/data/providers/agora_room.dart';
import 'package:client/features/events/features/live_meeting/features/video/data/providers/conference_room.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/providers/meeting_agenda_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/data/services/responsive_layout_service.dart';
import 'package:client/services.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/meeting_guide.dart';
import 'package:provider/provider.dart';

import 'views/live_meeting_mobile_contract.dart';
import '../data/models/live_meeting_mobile_model.dart';

class LiveMeetingMobilePresenter {
  final LiveMeetingMobileView _view;
  final LiveMeetingMobileModel _model;
  final ResponsiveLayoutService _responsiveLayoutService;
  final EventProvider _eventProvider;
  final EventTabsControllerState _eventTabsControllerState;
  final ConferenceRoom? _conferenceRoom;
  final AgendaProvider _agendaProvider;
  final LiveMeetingProvider _liveMeetingProvider;
  final ChatModel? _chatModel;
  final MeetingGuideCardStore _meetingGuideCardStore;

  LiveMeetingMobilePresenter(
    BuildContext context,
    this._view,
    this._model, {
    ResponsiveLayoutService? responsiveLayoutService,
    EventProvider? eventProvider,
    EventTabsControllerState? eventTabsControllerState,
    ConferenceRoom? conferenceRoom,
    ChatModel? chatModel,
    LiveMeetingProvider? liveMeetingProvider,
    AgendaProvider? agendaProvider,
    MeetingGuideCardStore? meetingGuideCardStore,
  })  : _responsiveLayoutService = responsiveLayoutService ??
            GetIt.instance<ResponsiveLayoutService>(),
        _eventProvider = eventProvider ?? context.read<EventProvider>(),
        _eventTabsControllerState = eventTabsControllerState ??
            context.read<EventTabsControllerState>(),
        _conferenceRoom = conferenceRoom ?? ConferenceRoom.read(context),
        _liveMeetingProvider =
            liveMeetingProvider ?? context.read<LiveMeetingProvider>(),
        _chatModel =
            chatModel ?? providerOrNull(() => context.read<ChatModel>()),
        _agendaProvider = agendaProvider ?? context.read<AgendaProvider>(),
        _meetingGuideCardStore =
            meetingGuideCardStore ?? context.read<MeetingGuideCardStore>();

  bool get canUserControlMeeting => _agendaProvider.canUserControlMeeting;

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

  Stream<List<ParticipantAgendaItemDetails>>?
      getParticipantAgendaItemDetailsStream() {
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

  void toggleBottomSheetState(
    LiveMeetingMobileBottomSheetState liveMeetingMobileBottomSheetState,
  ) {
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
    return false; //_eventProvider.event.eventSettings?.allowScreenshare == true;
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

  bool isReadyToAdvance(
    List<ParticipantAgendaItemDetails>? participantAgendaItemDetailsList,
  ) {
    return _meetingGuideCardStore.isReadyToAdvance(
      participantAgendaItemDetailsList,
      userService.currentUserId,
    );
  }

  int getTemplateIndex(List<AgendaItem> agendaItems, AgendaItem? currentItem) {
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

    final templateIndex =
        getTemplateIndex(getAgendaItems(), getCurrentAgendaItem());
    return (templateIndex > 1 || isMeetingFinished());
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
        .where(
          (p) =>
              (p.readyToAdvance ?? false) &&
              presentParticipantIds.contains(p.userId),
        )
        .length;
  }

  bool get isDismissableTabOpen {
    final fullScreenTabs = [TabType.chat, TabType.suggestions, TabType.admin];
    return fullScreenTabs
        .any((tab) => _eventTabsControllerState.isTabOpen(tab));
  }

  void dismissFullBottomSheet() {
    _model.bottomSheetState = LiveMeetingMobileBottomSheetState.hidden;
    _view.updateView();
  }

  void openGuide() {
    if (_agendaProvider.agendaItems.isEmpty) {
      _model.bottomSheetState = LiveMeetingMobileBottomSheetState.hidden;
    } else {
      _model.bottomSheetState =
          LiveMeetingMobileBottomSheetState.partiallyVisible;
      _eventTabsControllerState.openTab(TabType.guide);
    }
    _view.updateView();
  }

  bool isHosted() {
    return _eventProvider.event.isHosted && !_agendaProvider.isInBreakouts;
  }

  bool isCardPending() {
    return _meetingGuideCardStore.meetingGuideCardIsPending;
  }
}
