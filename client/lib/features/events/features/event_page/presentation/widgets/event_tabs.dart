import 'package:client/core/utils/provider_utils.dart';
import 'package:flutter/material.dart';
import 'package:client/features/chat/data/providers/chat_model.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/event_page/presentation/event_tab_controller.dart';
import 'package:client/features/events/features/event_page/presentation/event_tabs_model.dart';
import 'package:client/features/events/features/live_meeting/data/providers/live_meeting_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/providers/meeting_agenda_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/providers/user_submitted_agenda_provider.dart';
import 'package:client/features/community/data/providers/community_provider.dart';

import 'package:data_models/events/event_message.dart';
import 'package:provider/provider.dart';

enum TabType {
  about,
  guide,
  messages,
  chat,
  suggestions,
  admin,
}

/// Class to define what event tabs are visible.
class EventTabsWrapper extends StatelessWidget {
  final bool enableGuide;
  final bool enableUserSubmittedAgenda;
  final bool enableMessages;
  final bool enableChat;
  final bool enablePrePostEvent;
  final bool enableAdminPanel;
  final dynamic Function(EventMessage)? onRemoveMessage;
  final WidgetBuilder meetingAgendaBuilder;
  final Widget child;

  const EventTabsWrapper({
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
    return EventTabsController(
      enableGuide: enableGuide,
      enableUserSubmittedAgenda: enableUserSubmittedAgenda,
      enableMessages: enableMessages,
      enablePrePostEvent: enablePrePostEvent,
      enableChat: enableChat,
      enableAdminPanel: enableAdminPanel,
      meetingAgendaBuilder: meetingAgendaBuilder,
      child: EventTabs._(
        onRemoveMessage: onRemoveMessage,
        child: child,
      ),
    );
  }
}

class EventTabs extends StatefulWidget {
  final Function(EventMessage)? onRemoveMessage;
  final Widget child;

  const EventTabs._({
    this.onRemoveMessage,
    required this.child,
  });

  @override
  _EventTabsState createState() => _EventTabsState();
}

class _EventTabsState extends State<EventTabs> {
  @override
  Widget build(BuildContext context) {
    final eventTabsControllerState = context.watch<EventTabsControllerState>();
    final existingChatModel = readProviderOrNull<ChatModel?>(context);

    final parentPath =
        LiveMeetingProvider.readOrNull(context)?.isInBreakout == true
            ? context.read<AgendaProvider>().liveMeetingPath
            : EventProvider.read(context).event.fullPath;

    final localChild =
        _buildUserSubmittedAgendaWrapper(eventTabsControllerState);

    if (existingChatModel != null) {
      return localChild;
    } else if (eventTabsControllerState.widget.enableChat) {
      return ChangeNotifierProvider<ChatModel>(
        key: Key(parentPath),
        create: (context) {
          return ChatModel(
            communityProvider: CommunityProvider.read(context),
            parentPath: parentPath,
            eventTabsControllerState: eventTabsControllerState,
          )..initialize();
        },
        builder: (context, _) => localChild,
      );
    } else {
      return localChild;
    }
  }

  Widget _buildUserSubmittedAgendaWrapper(
    EventTabsControllerState eventTabsControllerState,
  ) {
    final localChild = EventTabsDefinition(
      onRemoveMessage: widget.onRemoveMessage,
      child: widget.child,
    );

    if (eventTabsControllerState.widget.enableUserSubmittedAgenda) {
      final eventProvider = context.watch<EventProvider>();
      final suggestionsParentPath =
          LiveMeetingProvider.readOrNull(context)?.isInBreakout == true
              ? context.read<AgendaProvider>().liveMeetingPath
              : eventProvider.event.fullPath;
      return ChangeNotifierProvider<UserSubmittedAgendaProvider>(
        key: Key(suggestionsParentPath),
        create: (context) {
          return UserSubmittedAgendaProvider(
            parentPath: suggestionsParentPath,
            eventTabsControllerState: eventTabsControllerState,
          )..initialize();
        },
        builder: (context, __) => localChild,
      );
    }

    return localChild;
  }
}
