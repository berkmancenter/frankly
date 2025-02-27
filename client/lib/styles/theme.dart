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
  pageTransitionsTheme: NoTransitionsOnWeb(),
);
