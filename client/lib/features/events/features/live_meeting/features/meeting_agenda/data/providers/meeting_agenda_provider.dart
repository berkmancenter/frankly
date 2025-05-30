import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:client/features/events/features/event_page/presentation/widgets/event_tabs.dart';
import 'package:client/features/events/features/event_page/presentation/event_tabs_model.dart';
import 'package:client/features/events/features/live_meeting/data/providers/live_meeting_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/data/providers/meeting_guide_card_store.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/confirm_dialog.dart';
import 'package:client/core/utils/visible_exception.dart';
import 'package:client/core/data/services/logging_service.dart';
import 'package:client/services.dart';
import 'package:data_models/analytics/analytics_entities.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:data_models/templates/template.dart';
import 'package:provider/provider.dart';
import 'package:client/core/localization/localization_helper.dart';

List<AgendaItem> defaultAgendaItems(String communityId) {
  final l10n = appLocalizationService.getLocalization();
  return <AgendaItem>[
    AgendaItem(
      id: 'default-intro-0',
      title: l10n.introductions,
      content: l10n.introductionContent,
    ),
  ];
}

class AgendaProviderParams {
  final String communityId;
  final Event? event;
  final Template? template;
  final bool isNotOnEventPage;
  final bool allowButtonForUserSubmittedAgenda;
  final bool agendaStartsCollapsed;
  final SubmitNotifier? saveNotifier;

  final Color? labelColor;
  final bool isLivestream;
  final Color? highlightColor;

  AgendaProviderParams({
    required this.communityId,
    this.event,
    this.template,
    this.isNotOnEventPage = false,
    this.allowButtonForUserSubmittedAgenda = true,
    this.agendaStartsCollapsed = false,
    this.saveNotifier,
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

  Event? get event => _params.event;

  List<AgendaItem> get agendaItems => _agendaItems;

  List<AgendaItem> get unsavedItems => _unsavedItems;

  LiveMeeting? get currentLiveMeeting =>
      (liveMeetingProvider?.isInBreakout ?? false)
          ? liveMeetingProvider?.breakoutRoomLiveMeeting
          : liveMeetingProvider?.liveMeeting;

  AgendaProviderParams get params => _params;

  bool get inLiveMeeting => liveMeetingProvider != null;

  String get liveMeetingPath =>
      liveMeetingProvider?.activeLiveMeetingPath ?? '';

  bool get isMeetingStarted =>
      currentLiveMeeting?.events
          .any((e) => e.event == LiveMeetingEventType.agendaItemStarted) ??
      false;

  bool get isMeetingFinished =>
      currentLiveMeeting?.events.lastOrNull?.event ==
      LiveMeetingEventType.finishMeeting;

  bool get isInBreakouts => liveMeetingProvider?.isInBreakout ?? false;

  bool get canUserControlMeeting {
    final isAdmin = userDataService.getMembership(_params.communityId).isAdmin;
    final isHost = event?.creatorId == userService.currentUserId;
    return !isInBreakouts && (isHost || isAdmin);
  }

  bool get allowButtonForUserSubmittedAgenda =>
      _params.allowButtonForUserSubmittedAgenda;

  AgendaItem? get currentAgendaItem =>
      _currentAgendaItemForLiveMeeting(currentLiveMeeting);

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
    final oldAgenda =
        _params.event?.agendaItems ?? _params.template?.agendaItems ?? [];
    final newAgenda =
        newParams.event?.agendaItems ?? newParams.template?.agendaItems ?? [];

    _params = newParams;

    if (!listEquals(oldAgenda, newAgenda)) {
      _updateAgenda();
    }

    notifyListeners();
  }

  void onLiveMeetingUpdate() {
    final isDifferentMeeting =
        _previousLiveMeeting?.meetingId != currentLiveMeeting?.meetingId;

    final liveMeetingChanged = isDifferentMeeting ||
        (_previousLiveMeeting?.events.length !=
            currentLiveMeeting?.events.length);
    if (isMeetingStarted && liveMeetingChanged) {
      collapsedAgendaItemIds.clear();
      collapsedAgendaItemIds.addAll(
        agendaItems.map((item) => item.id).toSet()
          ..remove(_currentAgendaItemForLiveMeeting(currentLiveMeeting)?.id),
      );
    } else if (!isMeetingStarted) {
      collapsedAgendaItemIds.clear();
    }

    _previousLiveMeeting = currentLiveMeeting;

    notifyListeners();
  }

  void startReorder() {
    collapsedAgendaItemIds.addAll(
      agendaItems
          .map((item) => item.id)
          .where((id) => !isCompleted(id) && !isCurrentAgendaItem(id)),
    );
    notifyListeners();
  }

  void _updateAgenda() {
    final event = _params.event;
    if (event != null) {
      _agendaItems = event.agendaItems;
    } else if (_params.template != null) {
      _agendaItems = _params.template?.agendaItems ?? [];
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

    final event = _params.event;
    if (event == null) {
      final communityId = _params.communityId;
      final templateId = _params.template?.id;

      if (templateId == null) {
        loggingService.log(
          'AgendaProvider.deleteAgendaItem: templateId is null',
          logType: LogType.error,
        );
        return;
      }

      // Update on template
      await firestoreDatabase.deleteTemplateAgendaItem(
        communityId: communityId,
        templateId: templateId,
        itemId: itemId,
      );
    } else if (event.agendaItems.isEmpty) {
      await firestoreEventService.setAgendaItemsLegacy(
        event: event,
        agendaItems: [],
      );
    } else {
      await firestoreEventService.deleteTemplateAgendaItem(
        event: event,
        itemId: itemId,
      );
    }

    _agendaItems.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  Future<void> upsertAgendaItem({required AgendaItem updatedItem}) async {
    final event = _params.event;
    if (event == null) {
      final communityId = _params.communityId;
      final templateId = _params.template?.id;

      if (templateId == null) {
        loggingService.log(
          'AgendaProvider.upsertAgendaItem: templateId is null',
          logType: LogType.error,
        );
        return;
      }

      // Update on template
      await firestoreDatabase.upsertTemplateAgendaItem(
        communityId: communityId,
        templateId: templateId,
        updatedItem: updatedItem,
      );
    } else {
      // Update just this agenda entry
      await firestoreEventService.upsertAgendaItem(
        event: event,
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
    final event = _params.event;

    if (event == null) {
      final communityId = _params.communityId;
      final templateId = _params.template?.id;

      if (templateId == null) {
        loggingService.log(
          'AgendaProvider.saveReorder: templateId is null',
          logType: LogType.error,
        );
        return;
      }

      await firestoreDatabase.updateTemplateAgendaOrdering(
        communityId: communityId,
        templateId: templateId,
        ordering: agendaIdsOrder,
      );
    } else {
      await firestoreEventService.updateAgendaOrdering(
        event: event,
        ordering: agendaIdsOrder,
      );
    }
  }

  Future<void> startMeeting() async {
    var firstAgendaItem = (agendaItems).firstOrNull;

    final outerMeetingCurrentAgendaItem =
        _currentAgendaItemForLiveMeeting(liveMeetingProvider?.liveMeeting);
    if (liveMeetingProvider?.isInBreakout == true &&
        outerMeetingCurrentAgendaItem != null) {
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
    final currentAgendaItemIndex =
        agendaItems.indexWhere((a) => a.id == agendaItemId);
    if (currentAgendaItemIndex < 0) {
      throw VisibleException('Meeting Guide entry not found.');
    }

    final nextAgendaItem =
        agendaItems.skip(currentAgendaItemIndex + 1).firstOrNull;

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
      final communityId = event?.communityId;
      final eventId = event?.id;
      final templateId = event?.templateId;

      if (communityId == null || eventId == null) {
        loggingService.log(
          'AgendaProvider.finishAgendaItem: communityId or eventId is null',
          logType: LogType.error,
        );
        return;
      }
      final LiveMeetingEvent? firstAgendaItem = currentLiveMeeting?.events
          .where((e) => e.event == LiveMeetingEventType.agendaItemStarted)
          .firstOrNull;
      final DateTime? startTime = firstAgendaItem?.timestamp;
      if (startTime == null) {
        loggingService.log(
          'Error determining event start time when logging analytics. Duration will be set to zero.',
          logType: LogType.error,
        );
      }
      final int durationInSeconds =
          startTime == null ? 0 : serverTime.difference(startTime).inSeconds;

      analytics.logEvent(
        AnalyticsCompleteEventEvent(
          communityId: communityId,
          eventId: eventId,
          asHost: (event?.eventType != EventType.hostless) &&
              event?.creatorId == userService.currentUserId,
          templateId: templateId,
          duration: durationInSeconds,
        ),
      );
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

    if (events.isNotEmpty &&
        events.last.event == LiveMeetingEventType.finishMeeting) {
      return null;
    }

    final currentAgendaItem = events
        .lastWhereOrNull(
          (e) => e.event == LiveMeetingEventType.agendaItemStarted,
        )
        ?.agendaItem;

    return agendaItems.firstWhereOrNull((a) => a.id == currentAgendaItem);
  }

  bool isCurrentAgendaItem(String agendaItemId) {
    if (!isMeetingStarted) return false;

    final currentAgendaItem =
        _currentAgendaItemForLiveMeeting(currentLiveMeeting)?.id;
    return currentAgendaItem == agendaItemId;
  }

  bool isCompleted(String agendaItemId) {
    if (!isMeetingStarted) return false;

    final meetingTimingEvents = (currentLiveMeeting?.events ?? [])
        .where(
          (e) => [
            LiveMeetingEventType.agendaItemStarted,
            LiveMeetingEventType.finishMeeting,
          ].contains(e.event),
        )
        .toList();

    final agendaItemStartedEventIndex = meetingTimingEvents.lastIndexWhere(
      (event) =>
          event.agendaItem == agendaItemId &&
          event.event == LiveMeetingEventType.agendaItemStarted,
    );

    return agendaItemStartedEventIndex != -1 &&
        agendaItemStartedEventIndex + 1 < meetingTimingEvents.length;
  }

  Duration timeInSection(String agendaItemId) {
    final localCurrentLiveMeeting = currentLiveMeeting;
    if (localCurrentLiveMeeting == null ||
        localCurrentLiveMeeting.events.isEmpty) {
      return Duration.zero;
    }

    var totalDuration = Duration.zero;
    final meetingTimingEvents = localCurrentLiveMeeting.events
        .where(
          (e) => [
            LiveMeetingEventType.agendaItemStarted,
            LiveMeetingEventType.finishMeeting,
          ].contains(e.event),
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
      final tabController =
          Provider.of<EventTabsControllerState>(context, listen: false);
      tabController.openTab(TabType.suggestions);
    } on ProviderNotFoundException {
      loggingService
          .log('View suggestions clicked outside of event page. Doing nothing');
    }
  }

  Future<void> checkReadyToAdvance({String? agendaItemId}) async {
    final eventPath = event?.fullPath;
    if (eventPath == null) {
      loggingService.log(
        'AgendaProvider.checkReadyToAdvance: eventPath is null',
        logType: LogType.error,
      );
      return;
    }

    await cloudFunctionsLiveMeetingService.checkAdvanceMeetingGuide(
      CheckAdvanceMeetingGuideRequest(
        eventPath: eventPath,
        breakoutSessionId: (liveMeetingProvider?.isInBreakout ?? false)
            ? liveMeetingProvider
                ?.liveMeeting?.currentBreakoutSession?.breakoutRoomSessionId
            : null,
        breakoutRoomId: (liveMeetingProvider?.isInBreakout ?? false)
            ? liveMeetingProvider?.currentBreakoutRoomId
            : null,
        userReadyAgendaId: agendaItemId,
        presentIds: liveMeetingProvider?.presentParticipantIds ?? [],
      ),
    );
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
    final agendaItemsDelete =
        cloudFunctionsLiveMeetingService.resetParticipantAgendaItems(
      request: ResetParticipantAgendaItemsRequest(
        liveMeetingPath: liveMeetingPath,
      ),
    );

    await Future.wait([liveMeetingUpdate, agendaItemsDelete]);
  }

  Future<void> updateWaitingRoomInfo(WaitingRoomInfo info) async {
    final event = _params.event;
    if (event == null) {
      loggingService.log(
        'AgendaProvider.updateWaitingRoomInfo: event is null',
        logType: LogType.error,
      );
      return;
    }

    await firestoreEventService.updateEvent(
      event: event.copyWith(waitingRoomInfo: info),
      keys: [Event.kFieldWaitingRoomInfo],
    );
  }

  Future<void> moveForward({required String currentAgendaItemId}) async {
    final timeInState = timeInSection(currentAgendaItemId);
    final doubleCheckDuration =
        currentAgendaItemId == MeetingGuideCardStore.startAgendaItemId
            ? Duration(seconds: 15)
            : Duration(seconds: 30);
    final suppressWarning = currentAgendaItem?.type == AgendaItemType.poll ||
        currentAgendaItem?.type == AgendaItemType.video;

    if (timeInState < doubleCheckDuration &&
        !suppressWarning &&
        !canUserControlMeeting) {
      final confirmed = await ConfirmDialog(
        mainText:
            'This agenda item just started! Are you sure you want to move on?',
        cancelText: appLocalizationService.getLocalization().cancel,
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
    if (liveMeetingProvider?.isInBreakout == true &&
        outerMeetingCurrentAgendaItem != null) {
      return outerMeetingCurrentAgendaItem;
    }
    return agendaItems.firstOrNull;
  }
}
