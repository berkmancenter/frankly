import 'package:client/core/routing/locations.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart' as url_launcher;

NavigatorState get navigatorState => routerDelegate.navigatorKey.currentState!;
Future<void> launch(
  String url, {
  bool isWeb = true,
  bool targetIsSelf = false,
}) async {
  final webUrl =
      !isWeb || url.startsWith(RegExp('https?://')) ? url : 'https://$url';
  final uri = Uri.parse(webUrl);
  if (await url_launcher.canLaunchUrl(uri)) {
    await url_launcher.launchUrl(
      uri,
      webOnlyWindowName: targetIsSelf ? '_self' : '_blank',
    );
  } else if (navigatorState.mounted) {
      await showAlert(navigatorState.context, 'Failed to open link.');
  }
}
