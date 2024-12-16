import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:client/app/community/events/event_page/event_provider.dart';
import 'package:client/app/community/events/event_page/live_meeting/live_meeting_provider.dart';
import 'package:client/app/community/events/event_page/live_meeting/meeting_guide/meeting_guide_card_store.dart';
import 'package:client/app/community/events/event_page/meeting_agenda/meeting_agenda_provider.dart';
import 'package:client/services/user_data_service.dart';
import 'package:client/services/user_service.dart';
import 'package:data_models/firestore/event.dart';
import 'package:data_models/firestore/meeting_guide.dart';
import 'package:provider/provider.dart';

import 'meeting_guide_minimized_card_contract.dart';
import 'meeting_guide_minimized_card_model.dart';

class MeetingGuideMinimizedCardPresenter {
  //ignore:unused_field
  final MeetingGuideMinimizedCardView _view;

  //ignore:unused_field
  final MeetingGuideMinimizedCardModel _model;
  final MeetingGuideCardStore _meetingGuideCardStore;
  final LiveMeetingProvider _liveMeetingProvider;
  final AgendaProvider _agendaProvider;
  final UserService _userService;
  final UserDataService _userDataService;
  final EventProvider _eventProvider;

  MeetingGuideMinimizedCardPresenter(
    BuildContext context,
    this._view,
    this._model, {
    MeetingGuideCardStore? meetingGuideCardStore,
    LiveMeetingProvider? liveMeetingProvider,
    AgendaProvider? agendaProvider,
    UserService? userService,
    UserDataService? userDataService,
    EventProvider? eventProvider,
  })  : _meetingGuideCardStore =
            meetingGuideCardStore ?? context.read<MeetingGuideCardStore>(),
        _liveMeetingProvider =
            liveMeetingProvider ?? context.read<LiveMeetingProvider>(),
        _agendaProvider = agendaProvider ?? context.read<AgendaProvider>(),
        _userService = userService ?? GetIt.instance<UserService>(),
        _userDataService = userDataService ?? GetIt.instance<UserDataService>(),
        _eventProvider = eventProvider ?? context.read<EventProvider>();

  bool canUserControlMeeting() {
    final isAdmin = _userDataService
        .getMembership(_eventProvider.event.communityId)
        .isAdmin;
    return !_agendaProvider.isInBreakouts &&
        (_liveMeetingProvider.isHost || isAdmin);
  }

  bool isHandRaised() {
    return _meetingGuideCardStore.getHandIsRaised(_userService.currentUserId!);
  }

  AgendaItem? getCurrentItem() {
    return _meetingGuideCardStore.meetingGuideCardAgendaItem;
  }

  bool isMeetingFinished() {
    final AgendaItem? currentItem =
        _meetingGuideCardStore.meetingGuideCardAgendaItem;
    final isMeetingStarted = _agendaProvider.isMeetingStarted;
    final meetingGuideCardIsPending =
        _meetingGuideCardStore.meetingGuideCardIsPending;

    return currentItem == null &&
        isMeetingStarted &&
        !meetingGuideCardIsPending;
  }

  String? getCurrentAgendaModelItemId() {
    return _meetingGuideCardStore.currentAgendaModelItemId;
  }

  Stream<List<ParticipantAgendaItemDetails>>?
      getParticipantAgendaItemDetailsStream() {
    return _meetingGuideCardStore.participantAgendaItemDetailsStream;
  }

  bool readyToAdvance(
    List<ParticipantAgendaItemDetails>? participantAgendaItemDetailsList,
  ) {
    return _meetingGuideCardStore.isReadyToAdvance(
      participantAgendaItemDetailsList,
      _userService.currentUserId,
    );
  }

  bool isHosted() {
    return _eventProvider.event.eventType == EventType.hosted;
  }
}
