import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class CustomPathUrlStrategy extends PathUrlStrategy {
  CustomPathUrlStrategy([
    this._platformLocation = const BrowserPlatformLocation(),
  ]) : super(_platformLocation);

  final PlatformLocation _platformLocation;

  @override
  String getPath() {
    if (_platformLocation.hash!.trim().isEmpty) {
      return super.getPath();
    }

    return HashUrlStrategy().getPath();
  }
}
