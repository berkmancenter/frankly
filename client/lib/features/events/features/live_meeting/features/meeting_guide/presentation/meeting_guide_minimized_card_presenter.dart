import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/live_meeting/data/providers/live_meeting_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/data/providers/meeting_guide_card_store.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/providers/meeting_agenda_provider.dart';
import 'package:client/features/user/data/services/user_data_service.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/meeting_guide.dart';
import 'package:provider/provider.dart';

import 'views/meeting_guide_minimized_card_contract.dart';
import '../data/models/meeting_guide_minimized_card_model.dart';

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
