import 'package:client/core/utils/transitions.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final appTheme = ThemeData(
  textTheme: textTheme,
  colorScheme: MaterialTheme.lightScheme().toColorScheme(),
  pageTransitionsTheme: NoTransitionsOnWeb(),
);

final textTheme = GoogleFonts.interTextTheme(
  TextTheme(
    /// displayColor is used for all display styles
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.normal,
      height: 64 / 57,
      letterSpacing: -0.25,
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.normal,
      height: 52 / 45,
      letterSpacing: 0,
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.normal,
      height: 44 / 36,
      letterSpacing: 0,
    ),

    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.normal,
      height: 40 / 32,
      letterSpacing: 0,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.normal,
      height: 36 / 28,
      letterSpacing: 0,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.normal,
      height: 32 / 24,
      letterSpacing: 0,
    ),

    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.normal,
      height: 28 / 22,
      letterSpacing: 0,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 24 / 16,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 20 / 14,
      letterSpacing: 0.1,
    ),

    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 20 / 14,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 16 / 12,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 16 / 11,
      letterSpacing: 0.5,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      height: 24 / 16,
      letterSpacing: 0.5,
    ),

    /// bodyMedium is the default text style for Material.
    /// https://api.flutter.dev/flutter/material/TextTheme/bodyMedium.html
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      height: 20 / 14,
      letterSpacing: 0.25,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      height: 16 / 12,
      letterSpacing: 0.4,
    ),
  ),
);

final iconTheme = IconThemeData(
  color: AppColor.black,
);
