import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class NoTransitionsOnWeb extends PageTransitionsTheme {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // 在 Web 上禁用頁面轉場動畫
    if (kIsWeb) {
      return child;
    }
    // 其他平台使用默認轉場
    return super.buildTransitions(
      route,
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }
} 