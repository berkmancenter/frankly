import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:client/features/events/features/event_page/data/providers/event_permissions_provider.dart';
import 'package:client/features/events/features/event_page/data/providers/template_provider.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/styles.dart';
import 'package:data_models/events/event.dart';
import 'package:provider/provider.dart';

enum EventPopUpMenuSelection {
  refreshGuide,
  createGuideFromEvent,
  duplicateEvent,
  downloadChatsAndSuggestions,
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
        EventPopUpMenuSelection.downloadChatsAndSuggestions,
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
        tooltip: 'Show Options',
        iconSize: kIconSize,
        icon: Material(
          shape: CircleBorder(),
          color: _isHovered
              ? context.theme.colorScheme.scrim.withScrimOpacity
              : context.theme.colorScheme.surface,
          child: Padding(
            padding: EdgeInsets.all(iconPadding),
            child: Icon(
              Icons.more_horiz,
              size: 20,
              color: AppColor.darkerBlue,
            ),
          ),
        ),
        itemBuilder: (context) {
          return menuOptions.map(
            (e) {
              final iconAsset = _getIconAsset(e);
              final text = _getText(e);

              return PopupMenuItem(
                value: e,
                padding: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      iconAsset.path,
                      width: 20,
                      height: 20,
                      color: AppColor.darkerBlue,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        text,
                        style: AppTextStyle.bodyMedium
                            .copyWith(color: context.theme.colorScheme.primary),
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
        return 'Refresh Guide';
      case EventPopUpMenuSelection.createGuideFromEvent:
        return 'Create template from event';
      case EventPopUpMenuSelection.duplicateEvent:
        return 'Duplicate Event';
      case EventPopUpMenuSelection.downloadRegistrationData:
        return 'Download members registration data';
      case EventPopUpMenuSelection.downloadChatsAndSuggestions:
        return 'Download chats and suggestions';
      case EventPopUpMenuSelection.cancelEvent:
        return 'Cancel Event';
    }
  }

  AppAsset _getIconAsset(
    EventPopUpMenuSelection eventPopUpMenuSelection,
  ) {
    switch (eventPopUpMenuSelection) {
      case EventPopUpMenuSelection.refreshGuide:
        return AppAsset.kRefreshSvg;
      case EventPopUpMenuSelection.createGuideFromEvent:
        return AppAsset.kPlusGuideSvg;
      case EventPopUpMenuSelection.duplicateEvent:
        return AppAsset.kCopySvg;
      case EventPopUpMenuSelection.downloadRegistrationData:
        return AppAsset.kSurveySvg;
      case EventPopUpMenuSelection.downloadChatsAndSuggestions:
        return AppAsset.kThumbSvg;
      case EventPopUpMenuSelection.cancelEvent:
        return AppAsset.kXSvg;
    }
  }
}
