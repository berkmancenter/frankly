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
  if (await url_launcher.canLaunch(webUrl)) {
    await url_launcher.launch(
      webUrl,
      webOnlyWindowName: targetIsSelf ? '_self' : '_blank',
    );
  } else {
    await showAlert(navigatorState.context, 'Failed to open link.');
  }
}
