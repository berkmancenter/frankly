import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/data/providers/meeting_guide_card_store.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/providers/meeting_agenda_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/data/services/firestore_meeting_guide_service.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/meeting_guide.dart';
import 'package:provider/provider.dart';

import 'views/meeting_guide_card_item_poll_contract.dart';
import '../data/models/meeting_guide_card_item_poll_model.dart';

class MeetingGuideCardItemPollPresenter {
  final MeetingGuideCardItemPollView _view;
  final MeetingGuideCardItemPollModel _model;
  final AgendaProvider _agendaProvider;
  final FirestoreMeetingGuideService _firestoreMeetingGuideService;
  final MeetingGuideCardStore _meetingGuideCardStore;
  final UserService _userService;

  MeetingGuideCardItemPollPresenter(
    BuildContext context,
    this._view,
    this._model, {
    AgendaProvider? agendaProvider,
    EventProvider? eventProvider,
    FirestoreMeetingGuideService? testFirestoreMeetingGuideService,
    MeetingGuideCardStore? meetingGuideCardStore,
    UserService? userService,
  })  : _agendaProvider = agendaProvider ?? context.read<AgendaProvider>(),
        _firestoreMeetingGuideService = testFirestoreMeetingGuideService ??
            GetIt.instance<FirestoreMeetingGuideService>(),
        _meetingGuideCardStore =
            meetingGuideCardStore ?? context.read<MeetingGuideCardStore>(),
        _userService = userService ?? context.read<UserService>();

  AgendaItem? getCurrentAgendaItem() {
    return _meetingGuideCardStore.meetingGuideCardAgendaItem;
  }

  Stream<List<ParticipantAgendaItemDetails>>?
      getParticipantAgendaItemDetailsStream() {
    return _meetingGuideCardStore.participantAgendaItemDetailsStream;
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
    await _firestoreMeetingGuideService.voteOnPoll(
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
