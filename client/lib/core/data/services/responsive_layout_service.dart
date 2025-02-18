import 'package:flutter/material.dart';

class ResponsiveLayoutService {
  static const double _kMobileThreshold = 1000;
  static const double _kMinSupportedSize = 350;
  static const double _kBottomNavBarThreshold = 1000;

  final MediaQueryData? _mediaQueryData;

  ResponsiveLayoutService({MediaQueryData? mediaQueryData})
      : _mediaQueryData = mediaQueryData;

  bool isMobile(BuildContext context) {
    final MediaQueryData mediaQueryData =
        _mediaQueryData ?? MediaQuery.of(context);
    return mediaQueryData.size.width < _kMobileThreshold;
  }

  bool showBottomNavBar(BuildContext context) {
    final MediaQueryData mediaQueryData =
        _mediaQueryData ?? MediaQuery.of(context);
    return mediaQueryData.size.width < _kBottomNavBarThreshold;
  }

  /// Identifies if we support UI from size perspective.
  ///
  /// Officially smallest most active screen size starts with ~365 in width.
  bool isMaxSupportedMobileSize(BuildContext context) {
    final MediaQueryData mediaQueryData =
        _mediaQueryData ?? MediaQuery.of(context);
    return mediaQueryData.size.width <= _kMinSupportedSize;
  }

  /// Returns dynamic size.
  ///
  /// If screen size is mobile, it returns 66% ([scale]) of the [originalValue].
  double getDynamicSize(
    BuildContext context,
    double originalValue, {
    double? mobileSize,
    double? scale,
  }) {
    scale ??= 2 / 3;
    mobileSize ??= originalValue * scale;
    final value = isMobile(context) ? mobileSize : originalValue;

    return value.roundToDouble();
  }
}
