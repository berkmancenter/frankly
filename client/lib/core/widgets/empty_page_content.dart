import 'package:flutter/material.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/styles/styles.dart';
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
    this.buttonType = ActionButtonType.filled,
    this.isBackgroundDark = false,
    this.isBackgroundPrimaryColor = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonColor = context.theme.colorScheme.primary;

    return Container(
      height: 311,
      width: 524,
      padding: const EdgeInsets.all(10),
      decoration: showContainer
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: context.theme.colorScheme.surfaceContainerLowest,
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
            style: context.theme.textTheme.titleLarge!.copyWith(
              color: isBackgroundDark
                  ? context.theme.colorScheme.surface
                  : context.theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: 205,
            child: HeightConstrainedText(
              subtitleText ??
                  context.l10n.whenNewItemsAdded(type.name),
              style: context.theme.textTheme.labelLarge!.copyWith(
                color: isBackgroundDark
                    ? context.theme.colorScheme.surface
                    : context.theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          if (onButtonPress != null)
            ActionButton(
              text: buttonText ?? type.buttonText(context),
              color: buttonColor,
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
