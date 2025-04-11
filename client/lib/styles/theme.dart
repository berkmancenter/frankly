import 'package:client/core/utils/transitions.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final appTheme = ThemeData(
  textTheme: textTheme,
  colorScheme: MaterialTheme.lightScheme().toColorScheme(),
  pageTransitionsTheme: NoTransitionsOnWeb(),
);

final textTheme = GoogleFonts.poppinsTextTheme(
  TextTheme(
    /// displayColor is used for all display styles
    displayLarge: null,
    displayMedium: null,
    displaySmall: null,

    /// headlineLarge: displayColor
    headlineLarge: AppTextStyle.headline1,

    /// headlineMedium: displayColor
    headlineMedium: AppTextStyle.headline2,
    headlineSmall: AppTextStyle.headline3,
    titleLarge: AppTextStyle.headline4,
    titleMedium: AppTextStyle.headlineSmall,
    titleSmall: AppTextStyle.subhead,
    bodyLarge: AppTextStyle.eyebrow,

    /// bodyMedium is the default text style for Material.
    /// https://api.flutter.dev/flutter/material/TextTheme/bodyMedium.html
    bodyMedium: AppTextStyle.body,

    /// bodySmall: displayColor
    bodySmall: AppTextStyle.bodySmall,
    labelMedium: AppTextStyle.bodySmall,
  ).apply(
    displayColor: AppColor.black,
    bodyColor: AppColor.black,
  ),
);

final iconTheme = IconThemeData(
  color: AppColor.black,
);
