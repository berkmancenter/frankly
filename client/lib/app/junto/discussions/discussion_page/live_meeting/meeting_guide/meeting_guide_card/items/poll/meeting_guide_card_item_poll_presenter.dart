import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/meeting_guide/meeting_guide_card_store.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/meeting_agenda_provider.dart';
import 'package:junto/services/firestore/firestore_meeting_guide_service.dart';
import 'package:junto/services/user_service.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/meeting_guide.dart';
import 'package:provider/provider.dart';

import 'meeting_guide_card_item_poll_contract.dart';
import 'meeting_guide_card_item_poll_model.dart';

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
    DiscussionProvider? discussionProvider,
    FirestoreMeetingGuideService? testFirestoreMeetingGuideService,
    MeetingGuideCardStore? meetingGuideCardStore,
    UserService? userService,
  })  : _agendaProvider = agendaProvider ?? context.read<AgendaProvider>(),
        _firestoreMeetingGuideService =
            testFirestoreMeetingGuideService ?? GetIt.instance<FirestoreMeetingGuideService>(),
        _meetingGuideCardStore = meetingGuideCardStore ?? context.read<MeetingGuideCardStore>(),
        _userService = userService ?? context.read<UserService>();

  AgendaItem? getCurrentAgendaItem() {
    return _meetingGuideCardStore.meetingGuideCardAgendaItem;
  }

  Stream<List<ParticipantAgendaItemDetails>>? getParticipantAgendaItemDetailsStream() {
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
        response: response);
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

  String? getCurrentVote(List<ParticipantAgendaItemDetails>? participantAgendaItemDetailsList) {
    return participantAgendaItemDetailsList
        ?.firstWhereOrNull((element) => element.userId == _userService.currentUserId)
        ?.pollResponse;
  }
}
