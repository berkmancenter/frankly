import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/live_meeting_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/meeting_guide/meeting_guide_card_store.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/meeting_agenda_provider.dart';
import 'package:junto/services/junto_user_data_service.dart';
import 'package:junto/services/user_service.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/meeting_guide.dart';
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
  final JuntoUserDataService _juntoUserDataService;
  final DiscussionProvider _discussionProvider;

  MeetingGuideMinimizedCardPresenter(
    BuildContext context,
    this._view,
    this._model, {
    MeetingGuideCardStore? meetingGuideCardStore,
    LiveMeetingProvider? liveMeetingProvider,
    AgendaProvider? agendaProvider,
    UserService? userService,
    JuntoUserDataService? juntoUserDataService,
    DiscussionProvider? discussionProvider,
  })  : _meetingGuideCardStore = meetingGuideCardStore ?? context.read<MeetingGuideCardStore>(),
        _liveMeetingProvider = liveMeetingProvider ?? context.read<LiveMeetingProvider>(),
        _agendaProvider = agendaProvider ?? context.read<AgendaProvider>(),
        _userService = userService ?? GetIt.instance<UserService>(),
        _juntoUserDataService = juntoUserDataService ?? GetIt.instance<JuntoUserDataService>(),
        _discussionProvider = discussionProvider ?? context.read<DiscussionProvider>();

  bool canUserControlMeeting() {
    final isAdmin =
        _juntoUserDataService.getMembership(_discussionProvider.discussion.juntoId).isAdmin;
    return !_agendaProvider.isInBreakouts && (_liveMeetingProvider.isHost || isAdmin);
  }

  bool isHandRaised() {
    return _meetingGuideCardStore.getHandIsRaised(_userService.currentUserId!);
  }

  AgendaItem? getCurrentItem() {
    return _meetingGuideCardStore.meetingGuideCardAgendaItem;
  }

  bool isMeetingFinished() {
    final AgendaItem? currentItem = _meetingGuideCardStore.meetingGuideCardAgendaItem;
    final isMeetingStarted = _agendaProvider.isMeetingStarted;
    final meetingGuideCardIsPending = _meetingGuideCardStore.meetingGuideCardIsPending;

    return currentItem == null && isMeetingStarted && !meetingGuideCardIsPending;
  }

  String? getCurrentAgendaModelItemId() {
    return _meetingGuideCardStore.currentAgendaModelItemId;
  }

  Stream<List<ParticipantAgendaItemDetails>>? getParticipantAgendaItemDetailsStream() {
    return _meetingGuideCardStore.participantAgendaItemDetailsStream;
  }

  bool readyToAdvance(List<ParticipantAgendaItemDetails>? participantAgendaItemDetailsList) {
    return _meetingGuideCardStore.isReadyToAdvance(
      participantAgendaItemDetailsList,
      _userService.currentUserId,
    );
  }

  bool isHosted() {
    return _discussionProvider.discussion.discussionType == DiscussionType.hosted;
  }
}
