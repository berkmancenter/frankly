import 'package:client/core/utils/navigation_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/event_page/presentation/widgets/event_tabs.dart';
import 'package:client/features/events/features/live_meeting/data/providers/live_meeting_provider.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/widgets/tabs/tab_controller.dart';
import 'package:client/core/utils/firestore_utils.dart';
import 'package:client/services.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event_message.dart';
import 'package:data_models/templates/template.dart';
import 'package:provider/provider.dart';

/// This class holds logic defining what tabs should be shown on a event.
///
/// It is provided to consumers down the tree via provider so that they can see what the current
/// tab shoudl be and update it when users make changes.
class EventTabsController extends StatefulWidget {
  final WidgetBuilder meetingAgendaBuilder;
  final bool enableAbout;
  final bool enableGuide;
  final bool enableUserSubmittedAgenda;
  final bool enableChat;
  final bool enablePrePostEvent;
  final bool enableMessages;
  final bool enableAdminPanel;
  final Widget child;

  const EventTabsController({
    this.enableAbout = true,
    this.enableGuide = true,
    this.enableChat = false,
    this.enablePrePostEvent = false,
    this.enableMessages = false,
    this.enableUserSubmittedAgenda = false,
    this.enableAdminPanel = false,
    required this.meetingAgendaBuilder,
    required this.child,
  });

  @override
  State<EventTabsController> createState() => EventTabsControllerState();
}

class EventTabsControllerState extends State<EventTabsController> {
  TabType? get _selectedTab =>
      tabs.length > _selectedTabController.selectedIndex
          ? tabs[_selectedTabController.selectedIndex]
          : null;

  late SelectedTabController _selectedTabController;
  late Future<List<Template>> _templatesFuture;

  BehaviorSubjectWrapper<List<EventMessage>>? _eventMessages;
  int get announcementsCount => _eventMessages?.value?.length ?? 0;

  SelectedTabController get selectedTabController => _selectedTabController;
  bool _expanded = false;
  bool get expanded => _expanded;
  set expanded(bool value) {
    setState(() => _expanded = value);

    _onTabChanges();
  }

  bool _isNewPrerequisite = false;
  bool get isNewPrerequisite => _isNewPrerequisite;
  set isNewPrerequisite(bool value) {
    setState(() => _isNewPrerequisite = value);
  }

  Future<List<Template>> get templatesFuture => _templatesFuture;

  Stream<List<EventMessage>> get eventMessagesStream => _eventMessagesStream;

  @override
  void initState() {
    super.initState();

    final liveMeetingProvider = LiveMeetingProvider.readOrNull(context);
    final guideTabIndex = _getTabIndex(
      liveMeetingProvider != null ? TabType.guide : TabType.about,
    );
    _selectedTabController = SelectedTabController(
      initialTab: guideTabIndex >= 0 ? guideTabIndex : 0,
    );

    _selectedTabController.addListener(_onTabChanges);

    _templatesFuture = _loadAllTemplates();
  }

  /// We load the event messages stream just in time because it is only accessible when the
  /// user becomes a participant in the event. Loading it too early will cause it to error.
  Stream<List<EventMessage>> get _eventMessagesStream {
    if (_eventMessages == null) {
      final communityProvider = CommunityProvider.read(context);
      final eventProvider = EventProvider.read(context);
      _eventMessages = wrapInBehaviorSubject(
        firestoreEventService
            .eventReference(
              communityId: communityProvider.communityId,
              templateId: eventProvider.templateId,
              eventId: eventProvider.eventId,
            )
            .collection('event-messages')
            .orderBy(EventMessage.kFieldCreatedAt, descending: true)
            .snapshots()
            .asyncMap(
              (snapshot) => snapshot.docs
                  .map(
                    (e) => EventMessage.fromFirestore(
                      fromFirestoreJson(e.data()),
                      e.id,
                    ),
                  )
                  .toList(),
            ),
      );
    }
    return _eventMessages!.stream;
  }

  Future<List<Template>> _loadAllTemplates() async {
    final communityProvider = CommunityProvider.read(context);
    final allTemplates = await firestoreDatabase.allCommunityTemplates(
      communityProvider.communityId,
      includeRemovedTemplates: false,
    );

    return allTemplates;
  }

  Future<void> sendMessage(String message) async {
    final communityProvider = CommunityProvider.read(context);
    final eventProvider = EventProvider.read(context);
    final EventMessage eventMessage = EventMessage(
      creatorId: eventProvider.event.creatorId,
      createdAt: clockService.now(),
      message: message,
    );

    await cloudFunctionsEventService.sendEventMessage(
      SendEventMessageRequest(
        communityId: communityProvider.communityId,
        templateId: eventProvider.templateId,
        eventId: eventProvider.eventId,
        eventMessage: eventMessage,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // If our list of available tabs changes, reset the selected tab.
    //
    // In the future we should update this to only change if our current tab is no longer available
    if (_previousTabs != null && !listEquals(_previousTabs, tabs)) {
      _selectedTabController = SelectedTabController(initialTab: 0);
      expanded = false;
    }

    _previousTabs = tabs;
  }

  @override
  void dispose() {
    super.dispose();
    _eventMessages?.dispose();
    _selectedTabController.removeListener(_onTabChanges);
  }

  void _onTabChanges() {
    FocusScope.of(navigatorState.context).unfocus();
  }

  List<TabType> get tabs => [
        if (widget.enableAbout) TabType.about,
        if (widget.enableGuide) TabType.guide,
        if (widget.enableUserSubmittedAgenda) TabType.suggestions,
        if (widget.enableChat) TabType.chat,
        if (widget.enableMessages) TabType.messages,
        if (widget.enableAdminPanel) TabType.admin,
      ];

  List<TabType>? _previousTabs;

  int get numTabs => tabs.length;

  int _getTabIndex(TabType tabType) => tabs.indexWhere((t) => t == tabType);

  bool isChatTab() => isTabOpen(TabType.chat);

  bool isSuggestedAgendaItemsTab() => isTabOpen(TabType.suggestions);

  bool isTabOpen(TabType type) => _selectedTab == type && _expanded;

  void openTab(TabType tabType) {
    setState(() {
      _expanded = true;
      final tabIndex = _getTabIndex(tabType);
      _selectedTabController.setTabIndex(tabIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: this,
      updateShouldNotify: (_, __) => true,
      child: widget.child,
    );
  }
}
