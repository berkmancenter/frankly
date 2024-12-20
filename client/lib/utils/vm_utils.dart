import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

String? getTimezone() => null;

Future<void> initializeTimezones() async {}

String? getTimezoneAbbreviation(DateTime dateTime) => null;

void setURLPathStrategy() {}
void enableDriverBinding() {}

bool checkCanAutoplay() => true;

// WKWebview is an embedded web view in apps.
bool get isWKWebView => false;

class CustomPointerInterceptor extends StatelessWidget {
  final Widget child;

  const CustomPointerInterceptor({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

void registerWebViewFactory(String key, dynamic Function(dynamic) factory) {}

HttpsCallablePlatform? getHttpsCallableWeb(String functionName) => null;

void stopMediaTrack(html.MediaStreamTrack track) {}
