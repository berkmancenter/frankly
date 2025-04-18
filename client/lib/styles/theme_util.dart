import 'package:flutter/material.dart';

extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
}

extension ColorExtension on Color {
  // 32% opacity as defined in the Utilities section of the
  // M3 design system.
  Color get withScrimOpacity => withAlpha(82);
}
