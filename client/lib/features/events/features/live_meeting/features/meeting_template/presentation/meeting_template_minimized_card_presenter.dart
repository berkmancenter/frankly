import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/live_meeting/data/providers/live_meeting_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_template/data/providers/meeting_template_card_store.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/providers/meeting_agenda_provider.dart';
import 'package:client/features/user/data/services/user_data_service.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/meeting_template.dart';
import 'package:provider/provider.dart';

import 'views/meeting_template_minimized_card_contract.dart';
import '../data/models/meeting_template_minimized_card_model.dart';

class MeetingTemplateMinimizedCardPresenter {
  //ignore:unused_field
  final MeetingTemplateMinimizedCardView _view;

  //ignore:unused_field
  final MeetingTemplateMinimizedCardModel _model;
  final MeetingTemplateCardStore _meetingTemplateCardStore;
  final LiveMeetingProvider _liveMeetingProvider;
  final AgendaProvider _agendaProvider;
  final UserService _userService;
  final UserDataService _userDataService;
  final EventProvider _eventProvider;

  MeetingTemplateMinimizedCardPresenter(
    BuildContext context,
    this._view,
    this._model, {
    MeetingTemplateCardStore? meetingTemplateCardStore,
    LiveMeetingProvider? liveMeetingProvider,
    AgendaProvider? agendaProvider,
    UserService? userService,
    UserDataService? userDataService,
    EventProvider? eventProvider,
  })  : _meetingTemplateCardStore =
            meetingTemplateCardStore ?? context.read<MeetingTemplateCardStore>(),
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
    return _meetingTemplateCardStore.getHandIsRaised(_userService.currentUserId!);
  }

  AgendaItem? getCurrentItem() {
    return _meetingTemplateCardStore.meetingTemplateCardAgendaItem;
  }

  bool isMeetingFinished() {
    final AgendaItem? currentItem =
        _meetingTemplateCardStore.meetingTemplateCardAgendaItem;
    final isMeetingStarted = _agendaProvider.isMeetingStarted;
    final meetingTemplateCardIsPending =
        _meetingTemplateCardStore.meetingTemplateCardIsPending;

    return currentItem == null &&
        isMeetingStarted &&
        !meetingTemplateCardIsPending;
  }

  String? getCurrentAgendaModelItemId() {
    return _meetingTemplateCardStore.currentAgendaModelItemId;
  }

  Stream<List<ParticipantAgendaItemDetails>>?
      getParticipantAgendaItemDetailsStream() {
    return _meetingTemplateCardStore.participantAgendaItemDetailsStream;
  }

  bool readyToAdvance(
    List<ParticipantAgendaItemDetails>? participantAgendaItemDetailsList,
  ) {
    return _meetingTemplateCardStore.isReadyToAdvance(
      participantAgendaItemDetailsList,
      _userService.currentUserId,
    );
  }

  bool isHosted() {
    return _eventProvider.event.eventType == EventType.hosted;
  }
}
