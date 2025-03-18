import 'package:client/core/utils/transitions.dart';
import 'package:client/styles/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final appTheme = ThemeData(
  useMaterial3: true,
  primaryColor: AppColor.black,
  brightness: Brightness.light,
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: AppColor.black,
    onPrimary: AppColor.white,
    secondary: AppColor.white,
    primaryContainer: AppColor.gray900,
    onPrimaryContainer: AppColor.white,
    secondaryContainer: AppColor.gray600,
    onSecondaryContainer: AppColor.white,
    errorContainer: AppColor.red200,
    onErrorContainer: AppColor.red500,
    onSecondary: AppColor.black,
    error: AppColor.red200,
    onError: AppColor.white,
    surface: AppColor.gray50,
    surfaceContainer: AppColor.white,
    surfaceDim: AppColor.gray400,
    onSurface: AppColor.black,
  ),
  textTheme: textTheme,
  pageTransitionsTheme: NoTransitionsOnWeb(),
  dividerTheme: dividerTheme,
  iconButtonTheme: iconButtonTheme,
  disabledColor: AppColor.gray100,
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

final dividerTheme = DividerThemeData(
  color: AppColor.gray200,
  space: 0.0,
);

final iconButtonTheme = IconButtonThemeData(
  style: ButtonStyle(
    overlayColor: WidgetStateProperty.all(AppColor.gray700),
    elevation: WidgetStateProperty.all(0),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    backgroundColor:
        WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return AppColor.gray100;
      }
      return AppColor.black; // Defer to the widget's default.
    }),

    /// Setting a custom disabled text color must be done explicitly as of 2020.
    /// See official Flutter doc here for detail: https://docs.google.com/document/d/1yohSuYrvyya5V1hB6j9pJskavCdVq9sVeTqSoEPsWH0/edit?tab=t.0
    /// The below method is taken from the docs.
    foregroundColor:
        WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
      if (states.contains(WidgetState.disabled)) {
        return AppColor.gray400;
      }
      return AppColor.white; // Defer to the widget's default.
    }),
  ),
);

final floatingActionButtonTheme = FloatingActionButtonThemeData(
  backgroundColor: AppColor.black,
  foregroundColor: AppColor.white,
  hoverColor: AppColor.gray700,
);
