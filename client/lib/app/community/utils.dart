import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:client/common_widgets/confirm_dialog.dart';
import 'package:client/common_widgets/sign_in_dialog.dart';
import 'package:client/app.dart';
import 'package:client/services/logging_service.dart';
import 'package:client/services/services.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/utils/dialog_provider.dart';
import 'package:client/utils/height_constained_text.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/community/membership.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart' as url_launcher;

Future<void> showAlert(BuildContext context, String alert) =>
    showCustomDialog<void>(
      context: context,
      builder: (innerContext) => AlertDialog(
        content: SingleChildScrollView(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: HeightConstrainedText(
                    alert,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Theme.of(context).primaryColor),
                onPressed: () => Navigator.of(innerContext).pop(),
              ),
            ],
          ),
        ),
      ),
    );

enum ToastType {
  success,
  neutral,
  failed,
}

/// Displays Toast message based on the [ToastType].
void showRegularToast(
  BuildContext context,
  String message, {
  required ToastType toastType,
  int durationInSeconds = 3,
}) {
  final Color backgroundColor;
  final Color textColor;
  AppAsset? iconPath;

  switch (toastType) {
    case ToastType.success:
      backgroundColor = AppColor.lightGreen;
      textColor = AppColor.darkGreen;
      iconPath = AppAsset.kCheckCircleSvg;
      break;
    case ToastType.neutral:
      backgroundColor = AppColor.darkBlue;
      textColor = AppColor.white;
      break;
    case ToastType.failed:
      backgroundColor = AppColor.lightRed;
      textColor = AppColor.redLightMode;
      iconPath = AppAsset.kExclamationSvg;
      break;
  }

  FToast().init(context).showToast(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: backgroundColor,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconPath != null) ...[
                SvgPicture.asset(
                  iconPath.path,
                  color: textColor,
                  width: 20,
                  height: 20,
                ),
                SizedBox(width: 10),
              ],
              Flexible(
                child: Text(
                  message,
                  style: AppTextStyle.subhead.copyWith(color: textColor),
                ),
              ),
            ],
          ),
        ),
        toastDuration: Duration(seconds: durationInSeconds),
        positionedToastBuilder: (context, child) {
          return Positioned(
            top: 16.0,
            left: 24.0,
            right: 24.0,
            child: child,
          );
        },
      );
}

Future<T?> alertOnError<T>(
  BuildContext context,
  Future<T> Function() action, {
  String? errorMessage,
}) async {
  try {
    return await action();
  } catch (e, s) {
    loggingService.log(e, logType: LogType.error);
    loggingService.log(s, logType: LogType.error);

    final sanitizedError = sanitizeError(e.toString());

    await showAlert(context, errorMessage ?? sanitizedError);
    return null;
  }
}

String sanitizeError(String error) {
  error = error
      .replaceAll('FirebaseError: ', '')
      .replaceAll(RegExp(r'\(.*\)'), '')
      .replaceAll(RegExp(r'\[.*\]'), '')
      .trim();

  if (error.contains('An account already exists with the same email address')) {
    return 'An account exists with the same email address but a different sign in method. Use Sign in with Email and click Forgot Password if you don’t know it. Or, Sign Up again using a different email.';
  }
  if (error.contains('The password is invalid')) {
    return 'Password is invalid. Click Forgot Password to reset it. Or, Sign Up again using a different email.';
  }
  if (error.contains('There is no user record')) {
    return 'No account found. Try signing in using a different email address. Or, Sign Up using this one.';
  }
  if (error
      .contains('The email address is already in use by another account')) {
    return 'You already created an account tied to this email address. Use Sign in with Email and click Forgot Password if you don’t know it. Or, Sign Up again using a different email.';
  }
  if (error.contains('Missing or insufficient permission')) {
    return 'Sorry, you aren\'t authorized to do that.';
  }
  if (error.trim().toLowerCase() == 'INTERNAL'.toLowerCase()) {
    return 'Sorry, something went wrong.';
  }

  return error;
}

Future<void> popOrShowError(
  BuildContext context,
  Future<void> Function() action,
) =>
    alertOnError(context, () async {
      await action();
      Navigator.of(context).pop();
    });

Future<T?> guardSignedIn<T>(
  Future<T> Function() action, {
  bool isPurchasingSubscription = false,
}) async {
  if (!userService.isSignedIn) {
    await SignInDialog.show(isPurchasingSubscription: isPurchasingSubscription);
  }

  if (userService.isSignedIn) {
    return action();
  }

  return null;
}

Future<T?> guardCommunityMember<T>(
  BuildContext context,
  Community community,
  Future<T> Function() action,
) {
  final communityId = community.id;

  return guardSignedIn<T?>(() async {
    await userDataService.memberships.first;
    if (!userDataService.getMembership(communityId).isMember) {
      final joinCommunity = await ConfirmDialog(
        title: 'Join ${community.name}?',
        mainText:
            'You must be a member of this space to participate. Would you like to join?',
        confirmText: 'Yes, Join!',
      ).show();

      if (!joinCommunity) return null;
    }

    await userDataService.changeCommunityMembership(
      userId: userService.currentUserId!,
      communityId: communityId,
      newStatus: MembershipStatus.member,
      allowMemberDowngrade: false,
    );
    return action();
  });
}

InputDecoration get noBorderInputDecoration => InputDecoration(
      border: InputBorder.none,
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
    );

bool isNullOrEmpty(String? value) => (value?.trim() ?? '').isEmpty;

// Note: Consider not swallowing all errors. Only a subset of error types.
Future<T?> swallowErrors<T>(
  FutureOr<T> Function() action, {
  String? errorMessage,
}) async {
  try {
    return await action();
  } catch (e, stackTrace) {
    loggingService.log('Error swallowed in tryCatch utility.');
    if (errorMessage != null) {
      loggingService.log(errorMessage);
    }
    loggingService.log(stackTrace);
    loggingService.log(e, logType: LogType.error, stackTrace: stackTrace);
  }
  return null;
}

T? swallowErrorsSync<T>(T Function() action) {
  try {
    return action();
  } catch (e, stackTrace) {
    loggingService.log('Error swallowed in tryCatchSync utility.');
    loggingService.log(e, logType: LogType.error, stackTrace: stackTrace);
  }
  return null;
}

Random random = Random();

String randomString() => random.nextInt(1000000).toString();

Future<void> launch(
  String url, {
  bool isWeb = true,
  bool targetIsSelf = false,
}) async {
  final webUrl =
      !isWeb || url.startsWith(RegExp('https?://')) ? url : 'https://$url';
  if (await url_launcher.canLaunch(webUrl)) {
    await url_launcher.launch(
      webUrl,
      webOnlyWindowName: targetIsSelf ? '_self' : '_blank',
    );
  } else {
    await showAlert(navigatorState.context, 'Failed to open link.');
  }
}

/// Checks whether website is accessed via mobile device or not (desktop/laptop).
bool isMobileDevice() {
  if (!kIsWeb) {
    return false;
  }

  final userAgent = html.window.navigator.userAgent.toString().toLowerCase();
  // Various Examples of the output
  // mozilla/5.0 (macintosh; intel mac os x 10_15_7) applewebkit/537.36 (khtml, like gecko) chrome/94.0.4606.71 safari/537.36
  // mozilla/5.0 (linux; android 6.0.1; moto g (4)) applewebkit/537.36 (khtml, like gecko) chrome/94.0.4606.71 mobile safari/537.36
  // mozilla/5.0 (iphone; cpu iphone os 13_2_3 like mac os x) applewebkit/605.1.15 (khtml, like gecko) version/13.0.3 mobile/15e148 safari/604.1

  return userAgent.contains('mobile') ||
      userAgent.contains('android') ||
      userAgent.contains('iphone');
}

void throwTestException() {
  if (kDebugMode) {
    throw TestException();
  }
}

bool isEmailValid(String email) {
  if (email.contains('@') && email.contains('.')) {
    return true;
  }

  return false;
}

class TestException implements Exception {
  @override
  String toString() => 'This is a test exception';
}

class ContentHorizontalPadding extends StatelessWidget {
  final Widget child;

  const ContentHorizontalPadding({required this.child});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBody(child: child);
  }
}

class ConstrainedBody extends StatelessWidget {
  final double maxWidth;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  static const double defaultMaxWidth = AppSize.kPageContentMaxWidthDesktop;
  static const double outerPadding = 20;

  const ConstrainedBody({
    this.maxWidth = defaultMaxWidth,
    this.padding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: outerPadding),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

class HeaderHorizontalPadding extends StatelessWidget {
  final Widget child;

  const HeaderHorizontalPadding({required this.child});

  EdgeInsets _padding(BuildContext context) => EdgeInsets.symmetric(
        horizontal: responsiveLayoutService.isMobile(context) ? 18 : 30,
      );

  @override
  Widget build(BuildContext context) {
    return Padding(padding: _padding(context), child: child);
  }
}

T? providerOrNull<T>(T Function() getProvider) {
  try {
    return getProvider();
  } on ProviderNotFoundException {
    return null;
  }
}

T? readProviderOrNull<T>(BuildContext context) {
  try {
    return Provider.of<T>(context, listen: false);
  } on ProviderNotFoundException {
    return null;
  }
}

T? watchProviderOrNull<T>(BuildContext context) {
  try {
    return Provider.of<T>(context);
  } on ProviderNotFoundException {
    return null;
  }
}

extension ThemeDataExtension on ThemeData {
  bool get isDark => brightness == Brightness.dark;

  bool get isLight => brightness == Brightness.light;
}

String durationString(Duration duration, {bool readAsHuman = false}) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  final String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  if (duration.inHours > 0) {
    final timeString = readAsHuman
        ? '${duration.inHours} hr ${int.parse(twoDigitMinutes) > 0 ? '$twoDigitMinutes min' : ''}'
        : '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';

    return timeString;
  } else {
    return readAsHuman
        ? '$twoDigitMinutes min'
        : '$twoDigitMinutes:$twoDigitSeconds';
  }
}

List<T> ifNotNull<T>(T item) => [if (item != null) item];

class CustomLoadingIndicator extends StatelessWidget {
  final double strokeWidth;
  final Color? color;

  const CustomLoadingIndicator({
    this.strokeWidth = 4.0,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: color,
      ),
    );
  }
}

int differenceInDays(DateTime a, DateTime b) {
  return dateTimeWithoutTime(a).difference(dateTimeWithoutTime(b)).inDays;
}

DateTime dateTimeWithoutTime(DateTime d) {
  return DateTime(d.year, d.month, d.day);
}

String dateTimeFormat({required DateTime date}) {
  var formattedDate = DateFormat('MMM d yyyy, h:mma').format(date);
  return formattedDate;
}

const int titleMaxCharactersLength = 80;
const int taglineMaxCharactersLength = 100;
const int answersCharactersLength = 40;
const int categoryCharactersMaxLength = 40;
const int agendaTitleCharactersLength = 50;
const int agendaSuggestionCharactersLength = 50;

String generateRandomImageUrl({int? seed, int? resolution}) =>
    'https://picsum.photos/seed/${seed ?? Random().nextInt(1000)}/${resolution ?? 512}';

String getFileName(String fileUrl) {
  if (isNullOrEmpty(fileUrl)) {
    return fileUrl;
  }

  String fileName = fileUrl.split('/').last;

  return fileName;
}

extension CommunityIterableExtension<T> on Iterable<T?> {
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
