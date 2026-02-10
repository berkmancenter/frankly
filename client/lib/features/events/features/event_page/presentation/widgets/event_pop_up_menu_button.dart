import 'package:flutter/material.dart';
import 'package:client/features/events/features/event_page/data/providers/event_permissions_provider.dart';
import 'package:client/features/events/features/event_page/data/providers/template_provider.dart';
import 'package:client/styles/styles.dart';
import 'package:data_models/events/event.dart';
import 'package:provider/provider.dart';
import 'package:client/core/localization/localization_helper.dart';

enum EventPopUpMenuSelection {
  refreshGuide,
  createGuideFromEvent,
  duplicateEvent,
  downloadChatData,
  downloadPollsSuggestionsData,
  downloadRegistrationData,
  cancelEvent,
}

class EventPopUpMenuButton extends StatefulWidget {
  final Event event;
  final void Function(EventPopUpMenuSelection) onSelected;
  final bool isMobile;

  const EventPopUpMenuButton({
    Key? key,
    required this.event,
    required this.onSelected,
    required this.isMobile,
  }) : super(key: key);

  @override
  State<EventPopUpMenuButton> createState() => _EventPopUpMenuButtonState();
}

class _EventPopUpMenuButtonState extends State<EventPopUpMenuButton> {
  var _isHovered = false;

  List<EventPopUpMenuSelection> _getMenuOptions(BuildContext context) {
    final eventHasTemplate = widget.event.templateId != defaultTemplateId;
    final permissions = context.watch<EventPermissionsProvider>();

    return <EventPopUpMenuSelection>[
      if (eventHasTemplate && permissions.canRefreshGuide)
        EventPopUpMenuSelection.refreshGuide,
      if (!eventHasTemplate) EventPopUpMenuSelection.createGuideFromEvent,
      if (permissions.canDuplicateEvent) EventPopUpMenuSelection.duplicateEvent,
      if (permissions.canDownloadRegistrationData) ...[
        EventPopUpMenuSelection.downloadRegistrationData,
        EventPopUpMenuSelection.downloadChatData,
        EventPopUpMenuSelection.downloadPollsSuggestionsData,
      ],
      if (permissions.canCancelEvent) EventPopUpMenuSelection.cancelEvent,
    ];
  }

  @override
  Widget build(BuildContext context) {
    const kIconSize = 40.0;
    const iconPadding = 10.0;

    final menuOptions = _getMenuOptions(context);
    return MouseRegion(
      onEnter: (_) {
        if (!_isHovered) {
          setState(() => _isHovered = true);
        }
      },
      onExit: (_) {
        if (_isHovered) {
          setState(() => _isHovered = false);
        }
      },
      child: PopupMenuButton<EventPopUpMenuSelection>(
        padding: EdgeInsets.zero,
        offset: Offset(0, kIconSize + 2 * iconPadding),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onSelected: (value) => widget.onSelected(value),
        tooltip: context.l10n.showOptions,
        iconSize: kIconSize,
        icon: Container(
          decoration: BoxDecoration(
            color: _isHovered
                ? context.theme.colorScheme.scrim.withScrimOpacity
                : context.theme.colorScheme.surfaceContainer,
            shape: BoxShape.circle,
          ),
          padding: EdgeInsets.all(iconPadding),
          child: Icon(
            Icons.more_horiz,
            size: 20,
            color: context.theme.colorScheme.onSurface,
          ),
        ),
        itemBuilder: (context) {
          return menuOptions.map(
            (e) {
              final icon = _getIconData(e);
              final text = _getText(e);

              return PopupMenuItem(
                value: e,
                padding: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        text,
                        style: context.theme.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              );
            },
          ).toList();
        },
      ),
    );
  }

  String _getText(EventPopUpMenuSelection eventPopUpMenuSelection) {
    switch (eventPopUpMenuSelection) {
      case EventPopUpMenuSelection.refreshGuide:
        return context.l10n.refreshGuide;
      case EventPopUpMenuSelection.createGuideFromEvent:
        return context.l10n.createTemplateFromEvent;
      case EventPopUpMenuSelection.duplicateEvent:
        return context.l10n.duplicateEvent;
      case EventPopUpMenuSelection.downloadRegistrationData:
        return context.l10n.downloadMembersRegistrationData;
      case EventPopUpMenuSelection.downloadChatData:
        return context.l10n.downloadChatData;
      case EventPopUpMenuSelection.downloadPollsSuggestionsData:
        return context.l10n.downloadPollsSuggestionsData;
      case EventPopUpMenuSelection.cancelEvent:
        return context.l10n.cancelEvent;
    }
  }

  IconData _getIconData(
    EventPopUpMenuSelection eventPopUpMenuSelection,
  ) {
    switch (eventPopUpMenuSelection) {
      case EventPopUpMenuSelection.refreshGuide:
        return Icons.refresh;
      case EventPopUpMenuSelection.createGuideFromEvent:
        return Icons.bookmark_add_outlined;
      case EventPopUpMenuSelection.duplicateEvent:
        return Icons.copy;
      case EventPopUpMenuSelection.downloadRegistrationData:
        return Icons.people_outline_outlined;
      case EventPopUpMenuSelection.downloadChatData:
        return Icons.message_outlined;
      case EventPopUpMenuSelection.downloadPollsSuggestionsData:
        return Icons.thumb_up_outlined;
      case EventPopUpMenuSelection.cancelEvent:
        return Icons.close;
    }
  }
}
