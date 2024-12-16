import 'package:flutter/material.dart';
import 'package:junto/app/junto/chat/chat_model.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_tabs/discussion_tab_controller.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_tabs/discussion_tabs_model.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/live_meeting_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/meeting_agenda_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/user_submitted_agenda/user_submitted_agenda_provider.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto_models/firestore/discussion_message.dart';
import 'package:provider/provider.dart';

enum TabType {
  about,
  guide,
  messages,
  chat,
  suggestions,
  admin,
}

/// Class to define what discussion tabs are visible.
class DiscussionTabsWrapper extends StatelessWidget {
  final bool enableGuide;
  final bool enableUserSubmittedAgenda;
  final bool enableMessages;
  final bool enableChat;
  final bool enablePrePostEvent;
  final bool enableAdminPanel;
  final dynamic Function(DiscussionMessage)? onRemoveMessage;
  final WidgetBuilder meetingAgendaBuilder;
  final Widget child;

  const DiscussionTabsWrapper({
    this.onRemoveMessage,
    this.enableGuide = true,
    this.enableMessages = false,
    this.enableUserSubmittedAgenda = false,
    this.enablePrePostEvent = false,
    this.enableChat = false,
    this.enableAdminPanel = false,
    required this.meetingAgendaBuilder,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DiscussionTabsController(
      enableGuide: enableGuide,
      enableUserSubmittedAgenda: enableUserSubmittedAgenda,
      enableMessages: enableMessages,
      enablePrePostEvent: enablePrePostEvent,
      enableChat: enableChat,
      enableAdminPanel: enableAdminPanel,
      meetingAgendaBuilder: meetingAgendaBuilder,
      child: DiscussionTabs._(
        child: child,
        onRemoveMessage: onRemoveMessage,
      ),
    );
  }
}

class DiscussionTabs extends StatefulWidget {
  final Function(DiscussionMessage)? onRemoveMessage;
  final Widget child;

  const DiscussionTabs._({
    this.onRemoveMessage,
    required this.child,
  });

  @override
  _DiscussionTabsState createState() => _DiscussionTabsState();
}

class _DiscussionTabsState extends State<DiscussionTabs> {
  @override
  Widget build(BuildContext context) {
    final discussionTabsControllerState = context.watch<DiscussionTabsControllerState>();
    final existingChatModel = readProviderOrNull<ChatModel?>(context);

    final parentPath = LiveMeetingProvider.readOrNull(context)?.isInBreakout == true
        ? context.read<AgendaProvider>().liveMeetingPath
        : DiscussionProvider.read(context).discussion.fullPath;

    final localChild = _buildUserSubmittedAgendaWrapper(discussionTabsControllerState);

    if (existingChatModel != null) {
      return localChild;
    } else if (discussionTabsControllerState.widget.enableChat) {
      return ChangeNotifierProvider<ChatModel>(
        key: Key(parentPath),
        create: (context) {
          return ChatModel(
            juntoProvider: JuntoProvider.read(context),
            parentPath: parentPath,
            discussionTabsControllerState: discussionTabsControllerState,
          )..initialize();
        },
        builder: (context, _) => localChild,
      );
    } else {
      return localChild;
    }
  }

  Widget _buildUserSubmittedAgendaWrapper(
      DiscussionTabsControllerState discussionTabsControllerState) {
    final localChild = DiscussionTabsDefinition(
      onRemoveMessage: widget.onRemoveMessage,
      child: widget.child,
    );

    if (discussionTabsControllerState.widget.enableUserSubmittedAgenda) {
      final discussionProvider = context.watch<DiscussionProvider>();
      final suggestionsParentPath = LiveMeetingProvider.readOrNull(context)?.isInBreakout == true
          ? context.read<AgendaProvider>().liveMeetingPath
          : discussionProvider.discussion.fullPath;
      return ChangeNotifierProvider<UserSubmittedAgendaProvider>(
        key: Key(suggestionsParentPath),
        create: (context) {
          return UserSubmittedAgendaProvider(
            parentPath: suggestionsParentPath,
            discussionTabsControllerState: discussionTabsControllerState,
          )..initialize();
        },
        builder: (context, __) => localChild,
      );
    }

    return localChild;
  }
}
