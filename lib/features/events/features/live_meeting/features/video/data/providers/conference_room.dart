import 'dart:js_util' as js_util;
import 'package:flutter/foundation.dart';

stream.getTracks().forEach((track) {
  if (kIsWeb) {
    // Web 平台
    try {
      js_util.callMethod(track, 'stop', []);
    } catch (e) {
      print('無法停止媒體軌道: $e');
    }
  } else {
    // 非 Web 平台
    print('在非 Web 平台上不需要停止軌道');
  }
}); 