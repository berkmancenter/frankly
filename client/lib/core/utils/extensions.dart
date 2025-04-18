import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/styles.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/chat/emotion.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/community/membership.dart';
import 'package:provider/provider.dart';

export 'package:data_models/events/event.dart';
export 'package:data_models/chat/emotion.dart';

extension DateTimeExtension on DateTime {
  /// More references for date formats - https://www.journaldev.com/17899/java-simpledateformat-java-date-format
  String getFormattedTime({String format = 'h:mm a'}) {
    final String formattedDateTime = DateFormat(format).format(this);
    return formattedDateTime;
  }
}

extension DurationExtension on Duration {
  /// Formats [Duration] in readable string (hh:mm:ss).
  String getFormattedTime({
    bool showHours = true,
    bool showMinutes = true,
    bool showSeconds = true,
  }) {
    if (!showHours && !showMinutes && !showSeconds) {
      throw AssertionError(
        'showHours or showMinutes or showSeconds must be true',
      );
    }

    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final String twoDigitMinutes = twoDigits(inMinutes.abs().remainder(60));
    final String twoDigitSeconds = twoDigits(inSeconds.abs().remainder(60));

    final sign = isNegative ? '-' : '';

    final time = [
      if (showHours) twoDigits(inHours.abs()),
      if (showMinutes) twoDigitMinutes,
      if (showSeconds) twoDigitSeconds,
    ].join(':');

    return '$sign$time';
  }
}

extension AgendaItemTypeUIExtension on AgendaItemType {
  AppAsset get svgIconPath {
    switch (this) {
      case AgendaItemType.text:
        return AppAsset.kTextSvg;
      case AgendaItemType.video:
        return AppAsset.video(true);
      case AgendaItemType.image:
        return AppAsset.kImageSvg;
      case AgendaItemType.poll:
        return AppAsset.kSurveySvg;
      case AgendaItemType.wordCloud:
        return AppAsset.kWordCloudSvg;
      case AgendaItemType.userSuggestions:
        return AppAsset.kThumbSvg;
    }
  }

  AppAsset get pngIconPath {
    switch (this) {
      case AgendaItemType.text:
        return AppAsset.kTextPng;
      case AgendaItemType.video:
        return AppAsset.video();
      case AgendaItemType.image:
        return AppAsset.kImagePng;
      case AgendaItemType.poll:
        return AppAsset.kSurveyPng;
      case AgendaItemType.wordCloud:
        return AppAsset.kWordCloudPng;
      case AgendaItemType.userSuggestions:
        return AppAsset.kThumbPng;
    }
  }
}

extension EmotionTypeExtension on EmotionType {
  AppAsset get imageAssetPath {
    switch (this) {
      case EmotionType.thumbsUp:
        return AppAsset('media/emoji-thumbs-up.png');
      case EmotionType.heart:
        return AppAsset('media/emoji-heart.png');
      case EmotionType.hundred:
        return AppAsset('media/emoji-hundred.png');
      case EmotionType.exclamation:
        return AppAsset('media/emoji-exclamation.png');
      case EmotionType.plusOne:
        return AppAsset('media/emoji-plus-one.png');
      case EmotionType.laughWithTears:
        return AppAsset('media/emoji-laugh-tears.png');
      case EmotionType.heartEyes:
        return AppAsset('media/emoji-heart-eyes.png');
    }
  }

  String get stringEmoji {
    switch (this) {
      case EmotionType.thumbsUp:
        return '👍';
      case EmotionType.heart:
        return '❤️';
      case EmotionType.hundred:
        return '💯';
      case EmotionType.exclamation:
        return '‼️';
      case EmotionType.plusOne:
        return '➕';
      case EmotionType.laughWithTears:
        return '😂';
      case EmotionType.heartEyes:
        return '😍';
    }
  }
}

extension MembershipStatusUIExtension on MembershipStatus {
  Widget icon(BuildContext context) {
    switch (this) {
      case MembershipStatus.member:
        return Icon(
          Icons.account_circle,
          color: context.theme.colorScheme.primary,
        );
      case MembershipStatus.admin:
        return Icon(
          Icons.local_police,
          color: context.theme.colorScheme.primary,
        );
      case MembershipStatus.facilitator:
        return ProxiedImage(
          null,
          asset: AppAsset('media/role-facilitator.png'),
        );
      case MembershipStatus.mod:
        return ProxiedImage(
          null,
          asset: AppAsset('media/role-mod.png'),
        );
      case MembershipStatus.owner:
        return Icon(
          Icons.local_police,
          color: context.theme.colorScheme.primary,
        );
      case MembershipStatus.nonmember:
        return ProxiedImage(
          null,
          asset: AppAsset('media/role-nonmember.png'),
        );
      default:
        return Icon(
          Icons.account_circle,
          color: context.theme.colorScheme.primary,
        );
    }
  }

  List<String> get permissions {
    switch (this) {
      case MembershipStatus.attendee:
        return ['Has attended an event, but has not become a community member'];
      case MembershipStatus.member:
        return ['Participates as the community allows'];
      case MembershipStatus.admin:
        return [
          'All mod capabilities',
          'Access all community settings',
          'Manages data (including billing & memberships)',
        ];
      case MembershipStatus.facilitator:
        return [
          'All member capabilities',
          'Hosts events',
          'Evenly spread among breakouts when applicable',
        ];
      case MembershipStatus.mod:
        return [
          'Moderates community',
          'Manages content (guides, resources)',
          'Acts as admin within events',
        ];
      case MembershipStatus.owner:
        return ['All admin capabilities', 'Can add/remove other admin'];
      default:
        return [];
    }
  }
}

extension OnboardingStepExtension on OnboardingStep {
  String get value => describeEnum(this);

  int get positionInOnboarding {
    switch (this) {
      case OnboardingStep.brandSpace:
        return 1;
      case OnboardingStep.createGuide:
        return 2;
      case OnboardingStep.hostEvent:
        return 3;
      case OnboardingStep.inviteSomeone:
        return 4;
      case OnboardingStep.createStripeAccount:
        return 5;
    }
  }

  AppAsset get titleIconPath {
    switch (this) {
      case OnboardingStep.brandSpace:
        return AppAsset.kEmojiSparklePng;
      case OnboardingStep.createGuide:
        return AppAsset.kEmojiNotepadPng;
      case OnboardingStep.hostEvent:
        return AppAsset.kEmojiMegaphonePng;
      case OnboardingStep.inviteSomeone:
        return AppAsset.kEmojiCalendarPng;
      case OnboardingStep.createStripeAccount:
        return AppAsset.kEmojiYellowHeartPng;
    }
  }

  String get title {
    switch (this) {
      case OnboardingStep.brandSpace:
        return 'Looking good';
      case OnboardingStep.createGuide:
        return 'Looking good';
      case OnboardingStep.hostEvent:
        return 'Get people talking';
      case OnboardingStep.inviteSomeone:
        return 'Get it on the books';
      case OnboardingStep.createStripeAccount:
        return 'Start processing payments';
    }
  }

  String get sectionTitle {
    switch (this) {
      case OnboardingStep.brandSpace:
        return 'Brand your space';
      case OnboardingStep.createGuide:
        return 'Create a template';
      case OnboardingStep.hostEvent:
        return 'Schedule an event';
      case OnboardingStep.inviteSomeone:
        return 'Invite your people';
      case OnboardingStep.createStripeAccount:
        return 'Link your Stripe account';
    }
  }
}

extension GlobalKeyExtension on GlobalKey {
  /// Retrieves [Offset] of the widget (top left).
  Offset? get globalPosition {
    final renderBox = currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return null;
    }

    return renderBox.localToGlobal(Offset.zero);
  }
}

extension BuildContextExtension on BuildContext {
  T? watchOrNull<T>() {
    try {
      return watch<T>();
    } on ProviderNotFoundException catch (_) {
      loggingService.log('watchOrNull: ${T.runtimeType} provider is null');
      return null;
    }
  }

  T? readOrNull<T>() {
    try {
      return read<T>();
    } on ProviderNotFoundException catch (_) {
      loggingService.log('readOrNull: ${T.runtimeType} provider is null');
      return null;
    }
  }
}

extension IterableExtension<T> on Iterable<T?> {
  Iterable<T> get withoutNulls {
    return <T>[
      for (final element in this)
        if (element != null) element,
    ];
  }
}

extension NonNullIterableExtension<T> on Iterable<T> {
  Iterable<T> intersperse(value) {
    return [
      for (final i in this) ...[
        if (i != first) value,
        i,
      ],
    ];
  }
}
