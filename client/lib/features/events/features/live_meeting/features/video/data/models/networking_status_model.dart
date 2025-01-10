import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:client/services.dart';

class NetworkingStatusModel {
  /// Time when low network quality message can be shown. Onwards.
  final DateTime messageShowTimeThreshold =
      clockService.now().add(Duration(minutes: 2));

  bool isLowNetworkQuality = false;
  bool isLowNetworkQualityMessageDismissed = false;
  QualityType? networkQualityLevel;
  Timer? timer;
}
