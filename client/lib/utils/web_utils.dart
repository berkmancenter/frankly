@JS()
library web_utils;

import 'dart:ui' as ui;

import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';
import 'package:cloud_functions_web/cloud_functions_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:js/js.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/utils/driver_binding.dart';
import 'package:junto/utils/junto_path_url_strategy.dart';
import 'package:platform_detect/platform_detect.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:timezone/browser.dart' as tz;
import 'package:universal_html/html.dart' as html;
import 'package:universal_html/js.dart' as universal_js;

@JS()
external dynamic checkCanAutoplay();

String? getTimezone() {
  final timeZoneObject =
      universal_js.context['Intl']?.callMethod('DateTimeFormat')?.callMethod('resolvedOptions');

  return timeZoneObject != null ? timeZoneObject['timeZone'] as String : null;
}

var _initialized = false;
Future<void> initializeTimezones() {
  return swallowErrors(() async {
    final prefix = Uri.base.host.contains('localhost') ? '' : 'assets/';
    await tz.initializeTimeZone('${prefix}assets/latest_all.tzf');
    _initialized = true;
  });
}

String? getTimezoneAbbreviation(DateTime time) {
  if (!_initialized) return '';

  return swallowErrorsSync(() {
        final location = tz.getLocation(getTimezone() ?? '');
        return tz.TZDateTime.from(time, location).timeZone.abbreviation;
      }) ??
      '';
}

void setURLPathStrategy() {
  setUrlStrategy(JuntoPathUrlStrategy());
}

void enableDriverBinding() {
  DriverBinding();
}

bool get isWKWebView => browser.isWKWebView;

class JuntoPointerInterceptor extends StatelessWidget {
  final Widget child;

  const JuntoPointerInterceptor({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PointerInterceptor(child: child);
  }
}

void registerWebViewFactory(String key, html.Element Function(int) factory) {
  // ignore: undefined_prefixed_name
  ui.platformViewRegistry.registerViewFactory(key, factory);
}

HttpsCallablePlatform? getHttpsCallableWeb(String functionName) {
  final isLocalhost = html.window.location.origin.contains('localhost');
  final origin = isLocalhost ? 'https://gen-hls-bkc-7627.web.app' : null;
  print('Function ($functionName) origin ($origin)');
  final callable = FirebaseFunctionsWeb(
    region: 'us-central1',
    app: FirebaseFunctionsWeb.instance.app,
  ).httpsCallable(origin, functionName, HttpsCallableOptions());

  return callable;
}

void stopMediaTrack(html.MediaStreamTrack track) {
  track.stop();
}
