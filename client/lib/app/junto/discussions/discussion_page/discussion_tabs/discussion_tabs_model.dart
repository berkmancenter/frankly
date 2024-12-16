import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_tabs/discussion_tabs.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/live_meeting_provider.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/common_widgets/tabs/tab_controller.dart';
import 'package:junto/junto_app.dart';
import 'package:junto/services/firestore/firestore_utils.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion_message.dart';
import 'package:junto_models/firestore/topic.dart';
import 'package:provider/provider.dart';

/// This class holds logic defining what tabs should be shown on a discussion.
///
/// It is provided to consumers down the tree via provider so that they can see what the current
/// tab shoudl be and update it when users make changes.
class DiscussionTabsController extends StatefulWidget {
  final WidgetBuilder meetingAgendaBuilder;
  final bool enableAbout;
  final bool enableGuide;
  final bool enableUserSubmittedAgenda;
  final bool enableChat;
  final bool enablePrePostEvent;
  final bool enableMessages;
  final bool enableAdminPanel;
  final Widget child;

  const DiscussionTabsController({
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
  State<DiscussionTabsController> createState() => DiscussionTabsControllerState();
}

class DiscussionTabsControllerState extends State<DiscussionTabsController> {
  TabType? get _selectedTab => tabs.length > _selectedTabController.selectedIndex
      ? tabs[_selectedTabController.selectedIndex]
      : null;

  late SelectedTabController _selectedTabController;
  late Future<List<Topic>> _topicsFuture;

  BehaviorSubjectWrapper<List<DiscussionMessage>>? _discussionMessages;
  int get announcementsCount => _discussionMessages?.value?.length ?? 0;

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

  Future<List<Topic>> get topicsFuture => _topicsFuture;

  Stream<List<DiscussionMessage>> get discussionMessagesStream => _discussionMessagesStream;

  @override
  void initState() {
    super.initState();

    final liveMeetingProvider = LiveMeetingProvider.readOrNull(context);
    final guideTabIndex = _getTabIndex(liveMeetingProvider != null ? TabType.guide : TabType.about);
    _selectedTabController = SelectedTabController(
      initialTab: guideTabIndex >= 0 ? guideTabIndex : 0,
    );

    _selectedTabController.addListener(_onTabChanges);

    _topicsFuture = _loadAllTopics();
  }

  /// We load the discussion messages stream just in time because it is only accessible when the
  /// user becomes a participant in the conversation. Loading it too early will cause it to error.
  Stream<List<DiscussionMessage>> get _discussionMessagesStream {
    if (_discussionMessages == null) {
      final juntoProvider = JuntoProvider.read(context);
      final discussionProvider = DiscussionProvider.read(context);
      _discussionMessages = wrapInBehaviorSubject(firestoreDiscussionService
          .discussionReference(
            juntoId: juntoProvider.juntoId,
            topicId: discussionProvider.topicId,
            discussionId: discussionProvider.discussionId,
          )
          .collection('discussion-messages')
          .orderBy(DiscussionMessage.kFieldCreatedAt, descending: true)
          .snapshots()
          .asyncMap((snapshot) =>
              snapshot.docs.map((e) => DiscussionMessage.fromFirestore(fromFirestoreJson(e.data()), e.id)).toList()));
    }
    return _discussionMessages!.stream;
  }

  Future<List<Topic>> _loadAllTopics() async {
    final juntoProvider = JuntoProvider.read(context);
    final allTopics =
        await firestoreDatabase.allJuntoTopics(juntoProvider.juntoId, includeRemovedTopics: false);

    return allTopics;
  }

  Future<void> sendMessage(String message) async {
    final juntoProvider = JuntoProvider.read(context);
    final discussionProvider = DiscussionProvider.read(context);
    final DiscussionMessage discussionMessage = DiscussionMessage(
      creatorId: discussionProvider.discussion.creatorId,
      createdAt: clockService.now(),
      message: message,
    );

    await cloudFunctionsService.sendDiscussionMessage(SendDiscussionMessageRequest(
      juntoId: juntoProvider.juntoId,
      topicId: discussionProvider.topicId,
      discussionId: discussionProvider.discussionId,
      discussionMessage: discussionMessage,
    ));
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
    _discussionMessages?.dispose();
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
