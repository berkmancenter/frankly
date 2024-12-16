import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_tabs/discussion_tabs.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_tabs/discussion_tabs_model.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/live_meeting_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/meeting_guide/meeting_guide_card_store.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/confirm_dialog.dart';
import 'package:junto/common_widgets/visible_exception.dart';
import 'package:junto/services/logging_service.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/analytics/analytics_entities.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/live_meeting.dart';
import 'package:junto_models/firestore/topic.dart';
import 'package:provider/provider.dart';

List<AgendaItem> defaultAgendaItems(String juntoId) => <AgendaItem>[
      AgendaItem(
        id: 'default-intro-0',
        title: 'Introductions',
        content: '''
_Introduce yourselves!  Each take one minute to answer one of the following questions._

* What's something you did recently that was a lot of fun?
* Who is your favorite cartoon character and why?
* What’s one thing you wish to accomplish before you die?
* What movie did you NOT like?
''',
      ),
    ];

class AgendaProviderParams {
  final String juntoId;
  final Discussion? discussion;
  final Topic? topic;
  final bool isNotOnDiscussionPage;
  final bool allowButtonForUserSubmittedAgenda;
  final bool agendaStartsCollapsed;
  final SubmitNotifier? saveNotifier;
  final Color backgroundColor;
  final Color? labelColor;
  final bool isLivestream;
  final Color? highlightColor;

  AgendaProviderParams({
    required this.juntoId,
    this.discussion,
    this.topic,
    this.isNotOnDiscussionPage = false,
    this.allowButtonForUserSubmittedAgenda = true,
    this.agendaStartsCollapsed = false,
    this.saveNotifier,
    required this.backgroundColor,
    required this.labelColor,
    required this.isLivestream,
    this.highlightColor,
  });
}

class AgendaProvider with ChangeNotifier {
  final LiveMeetingProvider? liveMeetingProvider;
  AgendaProviderParams _params;

  AgendaProvider({
    this.liveMeetingProvider,
    required AgendaProviderParams params,
  }) : _params = params;

  List<AgendaItem> _agendaItems = [];
  final _unsavedItems = <AgendaItem>[];
  Set<String> collapsedAgendaItemIds = {};
  LiveMeeting? _previousLiveMeeting;

  Discussion? get discussion => _params.discussion;

  List<AgendaItem> get agendaItems => _agendaItems;

  List<AgendaItem> get unsavedItems => _unsavedItems;

  LiveMeeting? get currentLiveMeeting => (liveMeetingProvider?.isInBreakout ?? false)
      ? liveMeetingProvider?.breakoutRoomLiveMeeting
      : liveMeetingProvider?.liveMeeting;

  AgendaProviderParams get params => _params;

  bool get inLiveMeeting => liveMeetingProvider != null;

  String get liveMeetingPath => liveMeetingProvider?.activeLiveMeetingPath ?? '';

  bool get isMeetingStarted =>
      currentLiveMeeting?.events.any((e) => e.event == LiveMeetingEventType.agendaItemStarted) ??
      false;

  bool get isMeetingFinished =>
      currentLiveMeeting?.events.lastOrNull?.event == LiveMeetingEventType.finishMeeting;

  bool get isInBreakouts => liveMeetingProvider?.isInBreakout ?? false;

  bool get canUserControlMeeting {
    final isAdmin = juntoUserDataService.getMembership(_params.juntoId).isAdmin;
    final isHost = discussion?.creatorId == userService.currentUserId;
    return !isInBreakouts && (isHost || isAdmin);
  }

  bool get allowButtonForUserSubmittedAgenda => _params.allowButtonForUserSubmittedAgenda;

  AgendaItem? get currentAgendaItem => _currentAgendaItemForLiveMeeting(currentLiveMeeting);

  void initialize() {
    liveMeetingProvider?.addListener(onLiveMeetingUpdate);

    _updateAgenda();

    if (_params.agendaStartsCollapsed) {
      collapsedAgendaItemIds.addAll(_agendaItems.map((item) => item.id));
    }
  }

  @override
  void dispose() {
    liveMeetingProvider?.removeListener(onLiveMeetingUpdate);
    super.dispose();
  }

  void update(AgendaProviderParams newParams) {
    final oldAgenda = _params.discussion?.agendaItems ?? _params.topic?.agendaItems ?? [];
    final newAgenda = newParams.discussion?.agendaItems ?? newParams.topic?.agendaItems ?? [];

    _params = newParams;

    if (!listEquals(oldAgenda, newAgenda)) {
      _updateAgenda();
    }

    notifyListeners();
  }

  void onLiveMeetingUpdate() {
    final isDifferentMeeting = _previousLiveMeeting?.meetingId != currentLiveMeeting?.meetingId;

    final liveMeetingChanged = isDifferentMeeting ||
        (_previousLiveMeeting?.events.length != currentLiveMeeting?.events.length);
    if (isMeetingStarted && liveMeetingChanged) {
      collapsedAgendaItemIds.clear();
      collapsedAgendaItemIds.addAll(agendaItems.map((item) => item.id).toSet()
        ..remove(_currentAgendaItemForLiveMeeting(currentLiveMeeting)?.id));
    } else if (!isMeetingStarted) {
      collapsedAgendaItemIds.clear();
    }

    _previousLiveMeeting = currentLiveMeeting;

    notifyListeners();
  }

  void startReorder() {
    collapsedAgendaItemIds.addAll(agendaItems
        .map((item) => item.id)
        .where((id) => !isCompleted(id) && !isCurrentAgendaItem(id)));
    notifyListeners();
  }

  void _updateAgenda() {
    final discussion = _params.discussion;
    if (discussion != null) {
      _agendaItems = discussion.agendaItems;
    } else if (_params.topic != null) {
      _agendaItems = _params.topic?.agendaItems ?? [];
    } else {
      _agendaItems = [];
    }

    final agendaItemIds = (_agendaItems).map((item) => item.id).toSet();

    final newlySaved = _unsavedItems
        .map((item) => item.id)
        .where(
          (id) => agendaItemIds.contains(id),
        )
        .toSet();
    _unsavedItems.removeWhere((item) => newlySaved.contains(item.id));
  }

  void deleteUnsavedItem(String itemId) {
    loggingService.log('AgendaProvider.deleteUnsavedItem: ID: $itemId');
    _unsavedItems.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  Future<void> deleteAgendaItem(String itemId) async {
    final unsaved = _unsavedItems.firstWhereOrNull((item) => item.id == itemId);
    if (unsaved != null) {
      _unsavedItems.removeWhere((item) => item.id == itemId);
      notifyListeners();
      return;
    }

    final discussion = _params.discussion;
    if (discussion == null) {
      final juntoId = _params.juntoId;
      final topicId = _params.topic?.id;

      if (topicId == null) {
        loggingService.log(
          'AgendaProvider.deleteAgendaItem: topicId is null',
          logType: LogType.error,
        );
        return;
      }

      // Update on topic
      await firestoreDatabase.deleteTopicAgendaItem(
        juntoId: juntoId,
        topicId: topicId,
        itemId: itemId,
      );
    } else if (discussion.agendaItems.isEmpty) {
      await firestoreDiscussionService.setAgendaItemsLegacy(
        discussion: discussion,
        agendaItems: [],
      );
    } else {
      await firestoreDiscussionService.deleteTopicAgendaItem(
        discussion: discussion,
        itemId: itemId,
      );
    }

    _agendaItems.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  Future<void> upsertAgendaItem({required AgendaItem updatedItem}) async {
    final discussion = _params.discussion;
    if (discussion == null) {
      final juntoId = _params.juntoId;
      final topicId = _params.topic?.id;

      if (topicId == null) {
        loggingService.log(
          'AgendaProvider.upsertAgendaItem: topicId is null',
          logType: LogType.error,
        );
        return;
      }

      // Update on topic
      await firestoreDatabase.upsertTopicAgendaItem(
        juntoId: juntoId,
        topicId: topicId,
        updatedItem: updatedItem,
      );
    } else {
      // Update just this agenda entry
      await firestoreDiscussionService.upsertAgendaItem(
        discussion: discussion,
        updatedItem: updatedItem,
      );
    }

    final index = agendaItems.indexWhere((item) => item.id == updatedItem.id);
    if (index < 0) {
      agendaItems.add(updatedItem);
    } else {
      agendaItems[index] = updatedItem;
    }
    _unsavedItems.removeWhere((item) => item.id == updatedItem.id);
    notifyListeners();
  }

  /// Adds new [AgendaItem] to [_unsavedItems] list.
  ///
  /// If [AgendaItem] is provided, copy of the item will be added to the list (with only changed ID).
  /// If [AgendaItem] is not provided, brand new item will be added to te list.
  void addNewUnsavedItem({AgendaItem? agendaItem}) {
    final AgendaItem newAgendaItem;
    final id = clockService.now().millisecondsSinceEpoch.toString();

    if (agendaItem == null) {
      newAgendaItem = AgendaItem(id: id, nullableType: AgendaItemType.text);
    } else {
      newAgendaItem = agendaItem.copyWith(id: id);
    }

    _unsavedItems.add(newAgendaItem);
    notifyListeners();
  }

  Future<void> saveReorder() async {
    final agendaIdsOrder = agendaItems.map((item) => item.id).toList();
    final discussion = _params.discussion;

    if (discussion == null) {
      final juntoId = _params.juntoId;
      final topicId = _params.topic?.id;

      if (topicId == null) {
        loggingService.log(
          'AgendaProvider.saveReorder: topicId is null',
          logType: LogType.error,
        );
        return;
      }

      await firestoreDatabase.updateTopicAgendaOrdering(
        juntoId: juntoId,
        topicId: topicId,
        ordering: agendaIdsOrder,
      );
    } else {
      await firestoreDiscussionService.updateAgendaOrdering(
        discussion: discussion,
        ordering: agendaIdsOrder,
      );
    }
  }

  Future<void> startMeeting() async {
    var firstAgendaItem = (agendaItems).firstOrNull;

    final outerMeetingCurrentAgendaItem =
        _currentAgendaItemForLiveMeeting(liveMeetingProvider?.liveMeeting);
    if (liveMeetingProvider?.isInBreakout == true && outerMeetingCurrentAgendaItem != null) {
      firstAgendaItem = outerMeetingCurrentAgendaItem;
    }

    if (firstAgendaItem == null) {
      throw VisibleException('There is no meeting guide for this meeting');
    }

    final serverTime = clockService.now();
    await firestoreLiveMeetingService.addMeetingEvent(
      liveMeetingPath: liveMeetingPath,
      meetingEvent: LiveMeetingEvent(
        agendaItem: firstAgendaItem.id,
        event: LiveMeetingEventType.agendaItemStarted,
        timestamp: serverTime.toUtc(),
      ),
    );
  }

  Future<void> finishAgendaItem(String agendaItemId) async {
    final currentAgendaItemIndex = agendaItems.indexWhere((a) => a.id == agendaItemId);
    if (currentAgendaItemIndex < 0) {
      throw VisibleException('Meeting Guide entry not found.');
    }

    final nextAgendaItem = agendaItems.skip(currentAgendaItemIndex + 1).firstOrNull;

    final serverTime = clockService.now();
    await firestoreLiveMeetingService.addMeetingEvent(
      liveMeetingPath: liveMeetingPath,
      meetingEvent: LiveMeetingEvent(
        event: nextAgendaItem == null
            ? LiveMeetingEventType.finishMeeting
            : LiveMeetingEventType.agendaItemStarted,
        agendaItem: nextAgendaItem?.id,
        timestamp: serverTime.toUtc(),
      ),
    );

    if (nextAgendaItem == null) {
      final juntoId = discussion?.juntoId;
      final discussionId = discussion?.id;
      final guideId = discussion?.topicId;

      if (juntoId == null || discussionId == null) {
        loggingService.log(
          'AgendaProvider.finishAgendaItem: juntoId or discussionId is null',
          logType: LogType.error,
        );
        return;
      }

      analytics.logEvent(AnalyticsCompleteDiscussionEvent(
        juntoId: juntoId,
        discussionId: discussionId,
        asHost: (discussion?.discussionType != DiscussionType.hostless) &&
            discussion?.creatorId == userService.currentUserId,
        guideId: guideId,
      ));
    }
  }

  Future<void> goToPreviousAgendaItem(String? previousAgendaItemId) async {
    if (previousAgendaItemId != null) {
      final serverTime = clock.now();
      await firestoreLiveMeetingService.addMeetingEvent(
        liveMeetingPath: liveMeetingPath,
        meetingEvent: LiveMeetingEvent(
          event: LiveMeetingEventType.agendaItemStarted,
          agendaItem: previousAgendaItemId,
          timestamp: serverTime.toUtc(),
        ),
      );
    }
  }

  AgendaItem? _currentAgendaItemForLiveMeeting(LiveMeeting? liveMeeting) {
    final events = liveMeeting?.events ?? [];

    if (events.isNotEmpty && events.last.event == LiveMeetingEventType.finishMeeting) {
      return null;
    }

    final currentAgendaItem = events
        .lastWhereOrNull((e) => e.event == LiveMeetingEventType.agendaItemStarted)
        ?.agendaItem;

    return agendaItems.firstWhereOrNull((a) => a.id == currentAgendaItem);
  }

  bool isCurrentAgendaItem(String agendaItemId) {
    if (!isMeetingStarted) return false;

    final currentAgendaItem = _currentAgendaItemForLiveMeeting(currentLiveMeeting)?.id;
    return currentAgendaItem == agendaItemId;
  }

  bool isCompleted(String agendaItemId) {
    if (!isMeetingStarted) return false;

    final meetingTimingEvents = (currentLiveMeeting?.events ?? [])
        .where((e) => [LiveMeetingEventType.agendaItemStarted, LiveMeetingEventType.finishMeeting]
            .contains(e.event))
        .toList();

    final agendaItemStartedEventIndex = meetingTimingEvents.lastIndexWhere((event) =>
        event.agendaItem == agendaItemId && event.event == LiveMeetingEventType.agendaItemStarted);

    return agendaItemStartedEventIndex != -1 &&
        agendaItemStartedEventIndex + 1 < meetingTimingEvents.length;
  }

  Duration timeInSection(String agendaItemId) {
    final localCurrentLiveMeeting = currentLiveMeeting;
    if (localCurrentLiveMeeting == null || localCurrentLiveMeeting.events.isEmpty) {
      return Duration.zero;
    }

    var totalDuration = Duration.zero;
    final meetingTimingEvents = localCurrentLiveMeeting.events
        .where(
          (e) => [LiveMeetingEventType.agendaItemStarted, LiveMeetingEventType.finishMeeting]
              .contains(e.event),
        )
        .toList();

    for (int i = 0; i < meetingTimingEvents.length; i++) {
      final curEvent = meetingTimingEvents[i];
      if (curEvent.agendaItem != agendaItemId ||
          curEvent.event != LiveMeetingEventType.agendaItemStarted) {
        continue;
      }

      final endTime = i + 1 < meetingTimingEvents.length
          ? meetingTimingEvents[i + 1].timestamp
          : clockService.now().toUtc();

      totalDuration = totalDuration + endTime!.difference(curEvent.timestamp!);
    }

    return totalDuration;
  }

  void viewSuggestions(BuildContext context) {
    try {
      final tabController = Provider.of<DiscussionTabsControllerState>(context, listen: false);
      tabController.openTab(TabType.suggestions);
    } on ProviderNotFoundException {
      loggingService.log('View suggestions clicked outside of event page. Doing nothing');
    }
  }

  Future<void> checkReadyToAdvance({String? agendaItemId}) async {
    final discussionPath = discussion?.fullPath;
    if (discussionPath == null) {
      loggingService.log(
        'AgendaProvider.checkReadyToAdvance: discussionPath is null',
        logType: LogType.error,
      );
      return;
    }

    await cloudFunctionsService.checkAdvanceMeetingGuide(CheckAdvanceMeetingGuideRequest(
      discussionPath: discussionPath,
      breakoutSessionId: (liveMeetingProvider?.isInBreakout ?? false)
          ? liveMeetingProvider?.liveMeeting?.currentBreakoutSession?.breakoutRoomSessionId
          : null,
      breakoutRoomId: (liveMeetingProvider?.isInBreakout ?? false)
          ? liveMeetingProvider?.currentBreakoutRoomId
          : null,
      userReadyAgendaId: agendaItemId,
      presentIds: liveMeetingProvider?.presentParticipantIds ?? [],
    ));
  }

  Future<void> resetMeeting() async {
    final localCurrentLiveMeeting = currentLiveMeeting;
    if (localCurrentLiveMeeting == null) {
      loggingService.log(
        'AgendaProvider.resetMeeting: localCurrentLiveMeeting is null',
        logType: LogType.error,
      );
      return;
    }

    final liveMeetingUpdate = firestoreLiveMeetingService.update(
      liveMeetingPath: liveMeetingPath,
      liveMeeting: localCurrentLiveMeeting.copyWith(events: []),
      keys: [LiveMeeting.kFieldEvents],
    );
    final agendaItemsDelete = cloudFunctionsService.resetParticipantAgendaItems(
      request: ResetParticipantAgendaItemsRequest(
        liveMeetingPath: liveMeetingPath,
      ),
    );

    await Future.wait([liveMeetingUpdate, agendaItemsDelete]);
  }

  Future<void> updateWaitingRoomInfo(WaitingRoomInfo info) async {
    final discussion = _params.discussion;
    if (discussion == null) {
      loggingService.log(
        'AgendaProvider.updateWaitingRoomInfo: discussion is null',
        logType: LogType.error,
      );
      return;
    }

    await firestoreDiscussionService.updateDiscussion(
      discussion: discussion.copyWith(waitingRoomInfo: info),
      keys: [Discussion.kFieldWaitingRoomInfo],
    );
  }

  Future<void> moveForward({required String currentAgendaItemId}) async {
    final timeInState = timeInSection(currentAgendaItemId);
    final doubleCheckDuration = currentAgendaItemId == MeetingGuideCardStore.startAgendaItemId
        ? Duration(seconds: 15)
        : Duration(seconds: 30);
    final suppressWarning = currentAgendaItem?.type == AgendaItemType.poll ||
        currentAgendaItem?.type == AgendaItemType.video;

    if (timeInState < doubleCheckDuration && !suppressWarning && !canUserControlMeeting) {
      final confirmed = await ConfirmDialog(
        mainText: 'This agenda item just started! Are you sure you want to move on?',
      ).show();
      if (!confirmed) return;
    }
    if (canUserControlMeeting) {
      if (currentAgendaItemId == MeetingGuideCardStore.startAgendaItemId) {
        await startMeeting();
      } else {
        await finishAgendaItem(currentAgendaItemId);
      }
    } else {
      await checkReadyToAdvance(
        agendaItemId: currentAgendaItemId,
      );
    }
  }

  static AgendaProvider read(BuildContext context) {
    return Provider.of<AgendaProvider>(context, listen: false);
  }

  static AgendaProvider watch(BuildContext context) {
    return Provider.of<AgendaProvider>(context);
  }

  AgendaItem? getHostlessStartCard() {
    final outerMeetingCurrentAgendaItem =
        _currentAgendaItemForLiveMeeting(liveMeetingProvider?.liveMeeting);
    if (liveMeetingProvider?.isInBreakout == true && outerMeetingCurrentAgendaItem != null) {
      return outerMeetingCurrentAgendaItem;
    }
    return agendaItems.firstOrNull;
  }
}
