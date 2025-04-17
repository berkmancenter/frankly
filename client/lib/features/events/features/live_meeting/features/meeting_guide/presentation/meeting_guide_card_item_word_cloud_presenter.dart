import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/data/providers/meeting_guide_card_store.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/views/agenda_item_card.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/providers/meeting_agenda_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/data/services/firestore_meeting_guide_service.dart';
import 'package:client/core/data/services/responsive_layout_service.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/meeting_guide.dart';
import 'package:provider/provider.dart';

import 'views/meeting_guide_card_item_word_cloud_contract.dart';
import '../data/models/meeting_guide_card_item_word_cloud_model.dart';

class MeetingGuideCardItemWordCloudPresenter {
  final MeetingGuideCardItemWordCloudView _view;
  final MeetingGuideCardItemWordCloudModel _model;
  final AgendaProvider _agendaProvider;
  final EventProvider _eventProvider;
  final FirestoreMeetingGuideService _firestoreMeetingGuideService;
  final MeetingGuideCardStore _meetingGuideCardStore;
  final ResponsiveLayoutService _responsiveLayoutService;
  final UserService _userService;

  MeetingGuideCardItemWordCloudPresenter(
    BuildContext context,
    this._view,
    this._model, {
    AgendaProvider? agendaProvider,
    EventProvider? eventProvider,
    FirestoreMeetingGuideService? testFirestoreMeetingGuideService,
    MeetingGuideCardStore? meetingGuideCardStore,
    ResponsiveLayoutService? testResponsiveLayoutService,
    UserService? userService,
  })  : _agendaProvider = agendaProvider ?? context.read<AgendaProvider>(),
        _eventProvider = eventProvider ?? context.read<EventProvider>(),
        _firestoreMeetingGuideService = testFirestoreMeetingGuideService ??
            GetIt.instance<FirestoreMeetingGuideService>(),
        _meetingGuideCardStore =
            meetingGuideCardStore ?? context.read<MeetingGuideCardStore>(),
        _responsiveLayoutService = testResponsiveLayoutService ??
            GetIt.instance<ResponsiveLayoutService>(),
        _userService = userService ?? context.read<UserService>();

  AgendaItem? getCurrentAgendaItem() {
    return _meetingGuideCardStore.meetingGuideCardAgendaItem;
  }

  Stream<List<ParticipantAgendaItemDetails>>?
      getParticipantAgendaItemDetailsStream() {
    return _meetingGuideCardStore.participantAgendaItemDetailsStream;
  }

  bool isMobile(BuildContext context) {
    return _responsiveLayoutService.isMobile(context);
  }

  String getUserId() {
    return _userService.currentUserId ?? '';
  }

  Future<void> addWordCloudResponse(String response) async {
    await _firestoreMeetingGuideService.addWordCloudResponse(
      agendaItemId: _meetingGuideCardStore.meetingGuideCardAgendaItem?.id ?? '',
      userId: _userService.currentUserId ?? '',
      liveMeetingPath: _agendaProvider.liveMeetingPath,
      response: response,
    );
  }

  Future<void> removeWordCloudResponse(String response) async {
    await _firestoreMeetingGuideService.removeWordCloudResponse(
      agendaItemId: _meetingGuideCardStore.meetingGuideCardAgendaItem?.id ?? '',
      userId: _userService.currentUserId ?? '',
      liveMeetingPath: _agendaProvider.liveMeetingPath,
      response: response,
    );
  }

  Event getEvent() {
    return _eventProvider.event;
  }

  bool inLiveMeeting() {
    return _agendaProvider.inLiveMeeting;
  }

  void updateWordCloudView(WordCloudViewType wordCloudView) {
    _model.wordCloudViewType = wordCloudView;
    _view.updateView();
  }
}
