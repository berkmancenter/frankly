import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_template/data/providers/meeting_template_card_store.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/providers/meeting_agenda_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_template/data/services/firestore_meeting_template_service.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/meeting_template.dart';
import 'package:provider/provider.dart';

import 'views/meeting_template_card_item_poll_contract.dart';
import '../data/models/meeting_template_card_item_poll_model.dart';

class MeetingTemplateCardItemPollPresenter {
  final MeetingTemplateCardItemPollView _view;
  final MeetingTemplateCardItemPollModel _model;
  final AgendaProvider _agendaProvider;
  final FirestoreMeetingTemplateService _firestoreMeetingTemplateService;
  final MeetingTemplateCardStore _meetingTemplateCardStore;
  final UserService _userService;

  MeetingTemplateCardItemPollPresenter(
    BuildContext context,
    this._view,
    this._model, {
    AgendaProvider? agendaProvider,
    EventProvider? eventProvider,
    FirestoreMeetingTemplateService? testFirestoreMeetingTemplateService,
    MeetingTemplateCardStore? meetingTemplateCardStore,
    UserService? userService,
  })  : _agendaProvider = agendaProvider ?? context.read<AgendaProvider>(),
        _firestoreMeetingTemplateService = testFirestoreMeetingTemplateService ??
            GetIt.instance<FirestoreMeetingTemplateService>(),
        _meetingTemplateCardStore =
            meetingTemplateCardStore ?? context.read<MeetingTemplateCardStore>(),
        _userService = userService ?? context.read<UserService>();

  AgendaItem? getCurrentAgendaItem() {
    return _meetingTemplateCardStore.meetingTemplateCardAgendaItem;
  }

  Stream<List<ParticipantAgendaItemDetails>>?
      getParticipantAgendaItemDetailsStream() {
    return _meetingTemplateCardStore.participantAgendaItemDetailsStream;
  }

  String getUserId() {
    return _userService.currentUserId ?? '';
  }

  Future<void> voteOnPoll(
    String agendaItemId,
    String userId,
    String liveMeetingPath,
    String response,
  ) async {
    await _firestoreMeetingTemplateService.voteOnPoll(
      agendaItemId: agendaItemId,
      userId: userId,
      liveMeetingPath: liveMeetingPath,
      response: response,
    );
  }

  String getLiveMeetingPath() {
    return _agendaProvider.liveMeetingPath;
  }

  void showQuestions(String currentCardAgendaItemId) {
    _model.isShowingQuestions = true;
    _model.pollShowResultsFor.remove(currentCardAgendaItemId);
    _view.updateView();
  }

  void showResults(String currentCardAgendaItemId) {
    _model.isShowingQuestions = false;
    _model.pollShowResultsFor.add(currentCardAgendaItemId);
    _view.updateView();
  }

  String? getCurrentVote(
    List<ParticipantAgendaItemDetails>? participantAgendaItemDetailsList,
  ) {
    return participantAgendaItemDetailsList
        ?.firstWhereOrNull(
          (element) => element.userId == _userService.currentUserId,
        )
        ?.pollResponse;
  }
}
