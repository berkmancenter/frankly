import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_permissions_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/topic_provider.dart';
import 'package:junto/styles/app_asset.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:provider/provider.dart';

enum DiscussionPopUpMenuSelection {
  refreshGuide,
  createGuideFromEvent,
  duplicateEvent,
  downloadChatsAndSuggestions,
  downloadRegistrationData,
  cancelEvent,
}

class DiscussionPopUpMenuButton extends StatefulWidget {
  final Discussion discussion;
  final void Function(DiscussionPopUpMenuSelection) onSelected;
  final bool isMobile;

  const DiscussionPopUpMenuButton({
    Key? key,
    required this.discussion,
    required this.onSelected,
    required this.isMobile,
  }) : super(key: key);

  @override
  State<DiscussionPopUpMenuButton> createState() => _DiscussionPopUpMenuButtonState();
}

class _DiscussionPopUpMenuButtonState extends State<DiscussionPopUpMenuButton> {
  var _isHovered = false;

  List<DiscussionPopUpMenuSelection> _getMenuOptions(BuildContext context) {
    final discussionHasTopic = widget.discussion.topicId != defaultTopicId;
    final permissions = context.watch<DiscussionPermissionsProvider>();

    return <DiscussionPopUpMenuSelection>[
      if (discussionHasTopic && permissions.canRefreshGuide)
        DiscussionPopUpMenuSelection.refreshGuide,
      if (!discussionHasTopic) DiscussionPopUpMenuSelection.createGuideFromEvent,
      if (permissions.canDuplicateEvent) DiscussionPopUpMenuSelection.duplicateEvent,
      if (permissions.canDownloadRegistrationData) ...[
        DiscussionPopUpMenuSelection.downloadRegistrationData,
        DiscussionPopUpMenuSelection.downloadChatsAndSuggestions
      ],
      if (permissions.canCancelDiscussion) DiscussionPopUpMenuSelection.cancelEvent,
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
      child: PopupMenuButton<DiscussionPopUpMenuSelection>(
          padding: EdgeInsets.zero,
          offset: Offset(0, kIconSize + 2 * iconPadding),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          onSelected: (value) => widget.onSelected(value),
          tooltip: 'Show Options',
          iconSize: kIconSize,
          icon: Material(
            shape: CircleBorder(),
            color: _isHovered ? AppColor.grayTransparent.withOpacity(0.45) : AppColor.gray6,
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
                          style: AppTextStyle.bodyMedium.copyWith(color: AppColor.darkBlue),
                        ),
                      )
                    ],
                  ),
                );
              },
            ).toList();
          }),
    );
  }

  String _getText(DiscussionPopUpMenuSelection discussionPopUpMenuSelection) {
    switch (discussionPopUpMenuSelection) {
      case DiscussionPopUpMenuSelection.refreshGuide:
        return 'Refresh Guide';
      case DiscussionPopUpMenuSelection.createGuideFromEvent:
        return 'Create template from event';
      case DiscussionPopUpMenuSelection.duplicateEvent:
        return 'Duplicate Event';
      case DiscussionPopUpMenuSelection.downloadRegistrationData:
        return 'Download members registration data';
      case DiscussionPopUpMenuSelection.downloadChatsAndSuggestions:
        return 'Download chats and suggestions';
      case DiscussionPopUpMenuSelection.cancelEvent:
        return 'Cancel Event';
    }
  }

  AppAsset _getIconAsset(DiscussionPopUpMenuSelection discussionPopUpMenuSelection) {
    switch (discussionPopUpMenuSelection) {
      case DiscussionPopUpMenuSelection.refreshGuide:
        return AppAsset.kRefreshSvg;
      case DiscussionPopUpMenuSelection.createGuideFromEvent:
        return AppAsset.kPlusGuideSvg;
      case DiscussionPopUpMenuSelection.duplicateEvent:
        return AppAsset.kCopySvg;
      case DiscussionPopUpMenuSelection.downloadRegistrationData:
        return AppAsset.kSurveySvg;
      case DiscussionPopUpMenuSelection.downloadChatsAndSuggestions:
        return AppAsset.kThumbSvg;
      case DiscussionPopUpMenuSelection.cancelEvent:
        return AppAsset.kXSvg;
    }
  }
}
