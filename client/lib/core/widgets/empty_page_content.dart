import 'package:flutter/material.dart';
import 'package:client/core/widgets/action_button.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/core/localization/localization_helper.dart';

class EmptyPageContent extends StatelessWidget {
  final void Function()? onButtonPress;
  final EmptyPageType type;
  final String? titleText;
  final String? subtitleText;
  final String? buttonText;
  final bool showContainer;
  final ActionButtonType buttonType;
  final bool isBackgroundDark;
  final bool isBackgroundPrimaryColor;

  const EmptyPageContent({
    required this.type,
    this.onButtonPress,
    this.titleText,
    this.subtitleText,
    this.buttonText,
    this.showContainer = true,
    this.buttonType = ActionButtonType.flat,
    this.isBackgroundDark = false,
    this.isBackgroundPrimaryColor = false,
    Key? key,
  }) : super(key: key);

  Color _getColor({bool subtitle = false}) {
    if (isBackgroundDark) {
      return AppColor.gray6;
    } else if (isBackgroundPrimaryColor) {
      return AppColor.gray1;
    } else if (subtitle) {
      return AppColor.gray3;
    } else {
      return AppColor.gray2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = Theme.of(context).colorScheme.primary;
    final isFlat = buttonType == ActionButtonType.flat;
    return Container(
      height: 311,
      width: 524,
      padding: const EdgeInsets.all(10),
      decoration: showContainer
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColor.white,
            )
          : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HeightConstrainedText(
            type.icon,
            style: TextStyle(fontSize: 62),
          ),
          SizedBox(height: 10),
          HeightConstrainedText(
            titleText ?? context.l10n.noItems(type.name),
            style: AppTextStyle.headline4.copyWith(color: _getColor()),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: 205,
            child: HeightConstrainedText(
              subtitleText ?? context.l10n.whenNewItemsAdded(type.name),
              style: AppTextStyle.eyebrowSmall
                  .copyWith(color: _getColor(subtitle: true)),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          if (onButtonPress != null)
            ActionButton(
              text: buttonText ?? type.buttonText(context),
              textStyle: AppTextStyle.body
                  .copyWith(color: isFlat ? AppColor.white : buttonColor),
              color: isFlat ? buttonColor : null,
              onPressed: onButtonPress,
              borderRadius: BorderRadius.circular(10),
              type: buttonType,
              borderSide: BorderSide(color: buttonColor),
            ),
        ],
      ),
    );
  }
}

enum EmptyPageType {
  posts,
  events,
  announcements,
  resources,
  templates,
  chats,
  suggestions,
}

extension EmptyPageTypeData on EmptyPageType {
  String get icon {
    switch (this) {
      case EmptyPageType.posts:
        return '💬';
      case EmptyPageType.events:
        return '🗓';
      case EmptyPageType.announcements:
        return '📣';
      case EmptyPageType.resources:
        return '📋';
      case EmptyPageType.templates:
        return '📒';
      case EmptyPageType.chats:
        return '👋';
      case EmptyPageType.suggestions:
        return '👍';
    }
  }

  String buttonText(BuildContext context) {
    switch (this) {
      case EmptyPageType.posts:
        return context.l10n.createAPost;
      case EmptyPageType.events:
        return context.l10n.createAnEvent;
      case EmptyPageType.announcements:
        return context.l10n.createAnAnnouncement;
      case EmptyPageType.resources:
        return context.l10n.createAResource;
      case EmptyPageType.templates:
        return context.l10n.createATemplate;
      case EmptyPageType.chats:
        throw UnimplementedError('No empty page chat button');
      case EmptyPageType.suggestions:
        throw UnimplementedError('No empty page suggestion button');
    }
  }
}
