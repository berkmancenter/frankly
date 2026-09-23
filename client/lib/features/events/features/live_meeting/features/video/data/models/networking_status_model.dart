import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:client/services.dart';

class NetworkingStatusModel {
  // Suppress low-network-quality warnings for this long after joining, to avoid
  // false positives while the Agora connection is still ramping up.
  static const Duration _lowNetworkQualityWarningDelay = Duration(minutes: 2);

  /// Time when low network quality message can be shown. Onwards.
  final DateTime messageShowTimeThreshold =
      clockService.now().add(_lowNetworkQualityWarningDelay);

  bool isLowNetworkQuality = false;
  bool isLowNetworkQualityMessageDismissed = false;
  QualityType? networkQualityLevel;
  Timer? timer;
}
