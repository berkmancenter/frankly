import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_tabs/discussion_tabs.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_tabs/discussion_tabs_model.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/live_meeting_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/meeting_guide/meeting_guide_card_store.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/meeting_agenda_provider.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/services/junto_user_data_service.dart';
import 'package:junto/services/responsive_layout_service.dart';
import 'package:junto/services/user_service.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/meeting_guide.dart';
import 'package:junto_models/firestore/membership.dart';
import 'package:provider/provider.dart';

import 'meeting_guide_card_contract.dart';
import 'meeting_guide_card_model.dart';

class MeetingGuideCardPresenter {
  //ignore: unused_field
  final MeetingGuideCardView _view;
  //ignore: unused_field
  final MeetingGuideCardModel _model;
  final AgendaProvider _agendaProvider;
  final DiscussionTabsControllerState _discussionTabsModel;
  final JuntoUserDataService _juntoUserDataService;
  final JuntoProvider _juntoProvider;
  final LiveMeetingProvider _liveMeetingProvider;
  final MeetingGuideCardStore _meetingGuideCardStore;
  final ResponsiveLayoutService _responsiveLayoutService;
  final UserService _userService;
  final DiscussionProvider _discussionProvider;

  MeetingGuideCardPresenter(
    BuildContext context,
    this._view,
    this._model, {
    AgendaProvider? agendaProvider,
    DiscussionTabsControllerState? discussionTabsModel,
    JuntoUserDataService? juntoUserDataService,
    JuntoProvider? juntoProvider,
    LiveMeetingProvider? liveMeetingProvider,
    MeetingGuideCardStore? meetingGuideCardStore,
    ResponsiveLayoutService? testResponsiveLayoutService,
    UserService? userService,
    DiscussionProvider? discussionProvider,
  })  : _agendaProvider = agendaProvider ?? context.read<AgendaProvider>(),
        _discussionTabsModel = discussionTabsModel ?? context.read<DiscussionTabsControllerState>(),
        _juntoUserDataService = juntoUserDataService ?? context.read<JuntoUserDataService>(),
        _juntoProvider = juntoProvider ?? context.read<JuntoProvider>(),
        _liveMeetingProvider = liveMeetingProvider ?? context.read<LiveMeetingProvider>(),
        _meetingGuideCardStore = meetingGuideCardStore ?? context.read<MeetingGuideCardStore>(),
        _responsiveLayoutService =
            testResponsiveLayoutService ?? GetIt.instance<ResponsiveLayoutService>(),
        _userService = userService ?? context.read<UserService>(),
        _discussionProvider = discussionProvider ?? context.read<DiscussionProvider>();

  bool get canUserControlMeeting => _agendaProvider.canUserControlMeeting;

  AgendaItem? getCurrentAgendaItem() {
    return _meetingGuideCardStore.meetingGuideCardAgendaItem;
  }

  Stream<List<ParticipantAgendaItemDetails>>? getParticipantAgendaItemDetailsStream() {
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

  Junto getJunto() {
    return _juntoProvider.junto;
  }

  bool isMember(String juntoId) {
    return _juntoUserDataService.isMember(juntoId: juntoId);
  }

  Membership getMembership() {
    return _juntoUserDataService.getMembership(_juntoProvider.junto.id);
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
    _discussionTabsModel.openTab(tabType);
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

  bool isReadyToAdvance(List<ParticipantAgendaItemDetails>? participantAgendaItemDetailsList) {
    return _meetingGuideCardStore.isReadyToAdvance(
      participantAgendaItemDetailsList,
      _userService.currentUserId,
    );
  }

  int getTopicIndex(List<AgendaItem> agendaItems, AgendaItem? currentItem) {
    return agendaItems.indexWhere((a) => a.id == currentItem?.id) + 1;
  }

  bool isBackButtonShown() {
    final topicIndex = getTopicIndex(getAgendaItems(), getCurrentAgendaItem());
    return (topicIndex > 1 || isMeetingFinished());
  }

  int readyToMoveOnCount(
    List<ParticipantAgendaItemDetails>? participantAgendaItemDetailsList,
    Set<String> presentParticipantIds,
  ) {
    return (participantAgendaItemDetailsList ?? [])
        .where((p) => (p.readyToAdvance ?? false) && presentParticipantIds.contains(p.userId))
        .length;
  }

  bool isControlledByHost() {
    final isAdmin = _juntoUserDataService.getMembership(_juntoProvider.junto.id).isAdmin;
    return !_agendaProvider.isInBreakouts && (_liveMeetingProvider.isHost || isAdmin);
  }

  Duration? getTimeRemainingInCard() {
    return _meetingGuideCardStore.getTimeRemainingInCard;
  }

  bool isHosted() {
    return _discussionProvider.discussion.isHosted && !_agendaProvider.isInBreakouts;
  }

  Future<void> moveForward(String currentAgendaItemId) async {
    await _agendaProvider.moveForward(currentAgendaItemId: currentAgendaItemId);
  }
}
