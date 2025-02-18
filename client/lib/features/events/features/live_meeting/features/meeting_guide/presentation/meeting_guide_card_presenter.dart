import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/event_page/presentation/widgets/event_tabs.dart';
import 'package:client/features/events/features/event_page/presentation/event_tabs_model.dart';
import 'package:client/features/events/features/live_meeting/data/providers/live_meeting_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/data/providers/meeting_guide_card_store.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/providers/meeting_agenda_provider.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/features/user/data/services/user_data_service.dart';
import 'package:client/core/data/services/responsive_layout_service.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/events/live_meetings/meeting_guide.dart';
import 'package:data_models/community/membership.dart';
import 'package:provider/provider.dart';

import 'views/meeting_guide_card_contract.dart';
import '../data/models/meeting_guide_card_model.dart';

class MeetingGuideCardPresenter {
  //ignore: unused_field
  final MeetingGuideCardView _view;
  //ignore: unused_field
  final MeetingGuideCardModel _model;
  final AgendaProvider _agendaProvider;
  final EventTabsControllerState _eventTabsModel;
  final UserDataService _userDataService;
  final CommunityProvider _communityProvider;
  final LiveMeetingProvider _liveMeetingProvider;
  final MeetingGuideCardStore _meetingGuideCardStore;
  final ResponsiveLayoutService _responsiveLayoutService;
  final UserService _userService;
  final EventProvider _eventProvider;

  MeetingGuideCardPresenter(
    BuildContext context,
    this._view,
    this._model, {
    AgendaProvider? agendaProvider,
    EventTabsControllerState? eventTabsModel,
    UserDataService? userDataService,
    CommunityProvider? communityProvider,
    LiveMeetingProvider? liveMeetingProvider,
    MeetingGuideCardStore? meetingGuideCardStore,
    ResponsiveLayoutService? testResponsiveLayoutService,
    UserService? userService,
    EventProvider? eventProvider,
  })  : _agendaProvider = agendaProvider ?? context.read<AgendaProvider>(),
        _eventTabsModel =
            eventTabsModel ?? context.read<EventTabsControllerState>(),
        _userDataService = userDataService ?? context.read<UserDataService>(),
        _communityProvider =
            communityProvider ?? context.read<CommunityProvider>(),
        _liveMeetingProvider =
            liveMeetingProvider ?? context.read<LiveMeetingProvider>(),
        _meetingGuideCardStore =
            meetingGuideCardStore ?? context.read<MeetingGuideCardStore>(),
        _responsiveLayoutService = testResponsiveLayoutService ??
            GetIt.instance<ResponsiveLayoutService>(),
        _userService = userService ?? context.read<UserService>(),
        _eventProvider = eventProvider ?? context.read<EventProvider>();

  bool get canUserControlMeeting => _agendaProvider.canUserControlMeeting;

  AgendaItem? getCurrentAgendaItem() {
    return _meetingGuideCardStore.meetingGuideCardAgendaItem;
  }

  Stream<List<ParticipantAgendaItemDetails>>?
      getParticipantAgendaItemDetailsStream() {
    return _meetingGuideCardStore.participantAgendaItemDetailsStream;
  }

  bool isCardPending() {
    return _meetingGuideCardStore.meetingGuideCardIsPending;
  }

  bool isHandRaised() {
    return _meetingGuideCardStore.getHandIsRaised(_userService.currentUserId!);
  }

  bool getGuideCardTakeOver() {
    return _meetingGuideCardStore.guideCardTakeover;
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

  bool isMobile(BuildContext context) {
    return _responsiveLayoutService.isMobile(context);
  }

  bool isHostOfTheMeeting() {
    return _liveMeetingProvider.isHost && !_agendaProvider.isInBreakouts;
  }

  String getUserId() {
    return _userService.currentUserId ?? '';
  }

  Community getCommunity() {
    return _communityProvider.community;
  }

  bool isMember(String communityId) {
    return _userDataService.isMember(communityId: communityId);
  }

  Membership getMembership() {
    return _userDataService.getMembership(_communityProvider.community.id);
  }

  List<AgendaItem> getAgendaItems() {
    return _agendaProvider.agendaItems;
  }

  bool isHost() {
    return _liveMeetingProvider.isHost;
  }

  List<String> getPresentParticipantIds() {
    return _liveMeetingProvider.presentParticipantIds;
  }

  void openTab(TabType tabType) {
    _eventTabsModel.openTab(tabType);
  }

  Future<void> goToPreviousAgendaItem() async {
    return _meetingGuideCardStore.goToPreviousAgendaItem();
  }

  String getTitle(AgendaItem agendaItem) {
    final agendaItemType = agendaItem.type;

    switch (agendaItemType) {
      case AgendaItemType.text:
      case AgendaItemType.video:
      case AgendaItemType.image:
        return agendaItem.title ?? '';
      case AgendaItemType.poll:
      case AgendaItemType.wordCloud:
        return agendaItem.content ?? '';
      case AgendaItemType.userSuggestions:
        return agendaItem.title ?? 'Suggestions';
    }
  }

  bool isReadyToAdvance(
    List<ParticipantAgendaItemDetails>? participantAgendaItemDetailsList,
  ) {
    return _meetingGuideCardStore.isReadyToAdvance(
      participantAgendaItemDetailsList,
      _userService.currentUserId,
    );
  }

  int getTemplateIndex(List<AgendaItem> agendaItems, AgendaItem? currentItem) {
    return agendaItems.indexWhere((a) => a.id == currentItem?.id) + 1;
  }

  bool isBackButtonShown() {
    final templateIndex =
        getTemplateIndex(getAgendaItems(), getCurrentAgendaItem());
    return (templateIndex > 1 || isMeetingFinished());
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

  bool isControlledByHost() {
    final isAdmin =
        _userDataService.getMembership(_communityProvider.community.id).isAdmin;
    return !_agendaProvider.isInBreakouts &&
        (_liveMeetingProvider.isHost || isAdmin);
  }

  Duration? getTimeRemainingInCard() {
    return _meetingGuideCardStore.getTimeRemainingInCard;
  }

  bool isHosted() {
    return _eventProvider.event.isHosted && !_agendaProvider.isInBreakouts;
  }

  Future<void> moveForward(String currentAgendaItemId) async {
    await _agendaProvider.moveForward(currentAgendaItemId: currentAgendaItemId);
  }
}
