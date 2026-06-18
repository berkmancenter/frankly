import 'package:client/core/utils/transitions.dart';
import 'package:flutter/material.dart';

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff313030),
      surfaceTint: Color(0xff5f5e5e),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff403f3f),
      onPrimaryContainer: Color(0xffd7d3d3),
      primaryFixed: Color(0xffe5e2e1),
      onPrimaryFixed: Color(0xff1c1b1b),
      primaryFixedDim: Color(0xffc8c6c5),
      onPrimaryFixedVariant: Color(0xff474646),
      secondary: Color(0xff615e56),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffe9e4da),
      onSecondaryContainer: Color(0xff4b4942),
      secondaryFixed: Color(0xffe7e2d8),
      onSecondaryFixed: Color(0xff1d1c16),
      secondaryFixedDim: Color(0xffcbc6bc),
      onSecondaryFixedVariant: Color(0xff49473f),
      tertiary: Color(0xff595f60),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffc3c9c9),
      onTertiaryContainer: Color(0xff323839),
      tertiaryFixed: Color(0xffdee4e3),
      onTertiaryFixed: Color(0xff171d1d),
      tertiaryFixedDim: Color(0xffc2c8c8),
      onTertiaryFixedVariant: Color(0xff424848),
      error: Color(0xffa0000b),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffFFEDEA),
      onErrorContainer: Color(0xff313030),
      surface: Color(0xfffaf8f8),
      onSurface: Color(0xff1c1b1b),
      surfaceDim: Color(0xffddd9d8),
      surfaceBright: Color(0xfffdf8f8),
      onSurfaceVariant: Color(0xff444748),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff7f3f2),
      surfaceContainer: Color(0xfff1edec),
      surfaceContainerHigh: Color(0xffebe7e6),
      surfaceContainerHighest: Color(0xffe5e2e1),
      inverseSurface: Color(0xff313030),
      onInverseSurface: Color(0xfff4f0ef),
      inversePrimary: Color(0xffc8c6c5),
      outline: Color(0xff747878),
      outlineVariant: Color(0xffc4c7c7),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
    );
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffc9c6c5),
      surfaceTint: Color(0xffc8c6c5),
      onPrimary: Color(0xff313030),
      primaryContainer: Color(0xff282727),
      onPrimaryContainer: Color(0xffb5b2b2),
      primaryFixed: Color(0xffe5e2e1),
      onPrimaryFixed: Color(0xff1c1b1b),
      primaryFixedDim: Color(0xffc8c6c5),
      onPrimaryFixedVariant: Color(0xff474646),
      secondary: Color(0xffffffff),
      onSecondary: Color(0xff32302a),
      secondaryContainer: Color(0xffd9d4ca),
      onSecondaryContainer: Color(0xff413f38),
      secondaryFixed: Color(0xffe7e2d8),
      onSecondaryFixed: Color(0xff1d1c16),
      secondaryFixedDim: Color(0xffcbc6bc),
      onSecondaryFixedVariant: Color(0xff49473f),
      tertiary: Color(0xffdfe5e5),
      onTertiary: Color(0xff2b3232),
      tertiaryContainer: Color(0xffb5bbbb),
      onTertiaryContainer: Color(0xff282e2f),
      tertiaryFixed: Color(0xffdee4e3),
      onTertiaryFixed: Color(0xff171d1d),
      tertiaryFixedDim: Color(0xffc2c8c8),
      onTertiaryFixedVariant: Color(0xff424848),
      error: Color(0xffffb4ab),
      onError: Color(0xff690004),
      errorContainer: Color(0xffb70f14),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xff141313),
      onSurface: Color(0xffe5e2e1),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff3a3939),
      onSurfaceVariant: Color(0xffc4c7c7),
      surfaceContainerLowest: Color(0xff0e0e0e),
      surfaceContainerLow: Color(0xff1c1b1b),
      surfaceContainer: Color(0xff201f1f),
      surfaceContainerHigh: Color(0xff2b2a2a),
      surfaceContainerHighest: Color(0xff353434),
      inverseSurface: Color(0xffe5e2e1),
      onInverseSurface: Color(0xff313030),
      inversePrimary: Color(0xff5f5e5e),
      outline: Color(0xff8e9192),
      outlineVariant: Color(0xff444748),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
    );
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        textTheme: textTheme.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
        scaffoldBackgroundColor: colorScheme.surface,
        canvasColor: colorScheme.surface,
        pageTransitionsTheme: NoTransitionsOnWeb(),
      );
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
