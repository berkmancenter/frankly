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
    surfaceDim: AppColor.gray400,
    onSurface: AppColor.black,
  ),
  textTheme: textTheme,
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

const hoverColor = AppColor.gray700;

extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
}

final themedDivider = Divider(
  color: AppColor.gray200,
);
