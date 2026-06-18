/// This is an auto-generated file from the Material 3
/// Plugin for Figma. The only thing that has been changed
/// is the util method toColorScheme, which only creates a very
/// limited palette by default and has been extended to fix that issue.

import 'package:flutter/material.dart';

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static MaterialScheme lightScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(0xff313030),
      surfaceTint: Color(0xff5f5e5e),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff403f3f),
      onPrimaryContainer: Color(0xffd7d3d3),
      secondary: Color(0xff615e56),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffe9e4da),
      onSecondaryContainer: Color(0xff4b4942),
      tertiary: Color(0xff595f60),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffc3c9c9),
      onTertiaryContainer: Color(0xff323839),
      error: Color(0xffa0000b),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffd92d29),
      onErrorContainer: Color(0xffffffff),
      background: Color(0xfffdf8f8),
      onBackground: Color(0xff1c1b1b),
      surface: Color(0xfffaf8f8),
      onSurface: Color(0xff1c1b1b),
      surfaceVariant: Color(0xffe0e3e3),
      onSurfaceVariant: Color(0xff444748),
      outline: Color(0xff747878),
      outlineVariant: Color(0xffc4c7c7),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inverseOnSurface: Color(0xfff4f0ef),
      inversePrimary: Color(0xffc8c6c5),
      primaryFixed: Color(0xffe5e2e1),
      onPrimaryFixed: Color(0xff1c1b1b),
      primaryFixedDim: Color(0xffc8c6c5),
      onPrimaryFixedVariant: Color(0xff474646),
      secondaryFixed: Color(0xffe7e2d8),
      onSecondaryFixed: Color(0xff1d1c16),
      secondaryFixedDim: Color(0xffcbc6bc),
      onSecondaryFixedVariant: Color(0xff49473f),
      tertiaryFixed: Color(0xffdee4e3),
      onTertiaryFixed: Color(0xff171d1d),
      tertiaryFixedDim: Color(0xffc2c8c8),
      onTertiaryFixedVariant: Color(0xff424848),
      surfaceDim: Color(0xffddd9d8),
      surfaceBright: Color(0xfffdf8f8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff7f3f2),
      surfaceContainer: Color(0xfff1edec),
      surfaceContainerHigh: Color(0xffebe7e6),
      surfaceContainerHighest: Color(0xffe5e2e1),
    );
  }

  ThemeData light() {
    return theme(lightScheme().toColorScheme());
  }

  static MaterialScheme darkScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(0xffc9c6c5),
      surfaceTint: Color(0xffc8c6c5),
      onPrimary: Color(0xff313030),
      primaryContainer: Color(0xff282727),
      onPrimaryContainer: Color(0xffb5b2b2),
      secondary: Color(0xffffffff),
      onSecondary: Color(0xff32302a),
      secondaryContainer: Color(0xffd9d4ca),
      onSecondaryContainer: Color(0xff413f38),
      tertiary: Color(0xffdfe5e5),
      onTertiary: Color(0xff2b3232),
      tertiaryContainer: Color(0xffb5bbbb),
      onTertiaryContainer: Color(0xff282e2f),
      error: Color(0xffffb4ab),
      onError: Color(0xff690004),
      errorContainer: Color(0xffb70f14),
      onErrorContainer: Color(0xffffffff),
      background: Color(0xff141313),
      onBackground: Color(0xffe5e2e1),
      surface: Color(0xff141313),
      onSurface: Color(0xffe5e2e1),
      surfaceVariant: Color(0xff444748),
      onSurfaceVariant: Color(0xffc4c7c7),
      outline: Color(0xff8e9192),
      outlineVariant: Color(0xff444748),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e1),
      inverseOnSurface: Color(0xff313030),
      inversePrimary: Color(0xff5f5e5e),
      primaryFixed: Color(0xffe5e2e1),
      onPrimaryFixed: Color(0xff1c1b1b),
      primaryFixedDim: Color(0xffc8c6c5),
      onPrimaryFixedVariant: Color(0xff474646),
      secondaryFixed: Color(0xffe7e2d8),
      onSecondaryFixed: Color(0xff1d1c16),
      secondaryFixedDim: Color(0xffcbc6bc),
      onSecondaryFixedVariant: Color(0xff49473f),
      tertiaryFixed: Color(0xffdee4e3),
      onTertiaryFixed: Color(0xff171d1d),
      tertiaryFixedDim: Color(0xffc2c8c8),
      onTertiaryFixedVariant: Color(0xff424848),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff3a3939),
      surfaceContainerLowest: Color(0xff0e0e0e),
      surfaceContainerLow: Color(0xff1c1b1b),
      surfaceContainer: Color(0xff201f1f),
      surfaceContainerHigh: Color(0xff2b2a2a),
      surfaceContainerHighest: Color(0xff353434),
    );
  }

  ThemeData dark() {
    return theme(darkScheme().toColorScheme());
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
      );

  List<ExtendedColor> get extendedColors => [];
}

class MaterialScheme {
  const MaterialScheme({
    required this.brightness,
    required this.primary,
    required this.surfaceTint,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.background,
    required this.onBackground,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.shadow,
    required this.scrim,
    required this.inverseSurface,
    required this.inverseOnSurface,
    required this.inversePrimary,
    required this.primaryFixed,
    required this.onPrimaryFixed,
    required this.primaryFixedDim,
    required this.onPrimaryFixedVariant,
    required this.secondaryFixed,
    required this.onSecondaryFixed,
    required this.secondaryFixedDim,
    required this.onSecondaryFixedVariant,
    required this.tertiaryFixed,
    required this.onTertiaryFixed,
    required this.tertiaryFixedDim,
    required this.onTertiaryFixedVariant,
    required this.surfaceDim,
    required this.surfaceBright,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
  });

  final Brightness brightness;
  final Color primary;
  final Color surfaceTint;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color shadow;
  final Color scrim;
  final Color inverseSurface;
  final Color inverseOnSurface;
  final Color inversePrimary;
  final Color primaryFixed;
  final Color onPrimaryFixed;
  final Color primaryFixedDim;
  final Color onPrimaryFixedVariant;
  final Color secondaryFixed;
  final Color onSecondaryFixed;
  final Color secondaryFixedDim;
  final Color onSecondaryFixedVariant;
  final Color tertiaryFixed;
  final Color onTertiaryFixed;
  final Color tertiaryFixedDim;
  final Color onTertiaryFixedVariant;
  final Color surfaceDim;
  final Color surfaceBright;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
}

extension MaterialSchemeUtils on MaterialScheme {
  /// This util has been modified from the default export to include all colors
  /// in the ColorScheme class.
  ColorScheme toColorScheme() {
    return ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      primaryFixed: primaryFixed,
      primaryFixedDim: primaryFixedDim,
      onPrimaryFixed: onPrimaryFixed,
      onPrimaryFixedVariant: onPrimaryFixedVariant,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      secondaryFixed: secondaryFixed,
      secondaryFixedDim: secondaryFixedDim,
      onSecondaryFixed: onSecondaryFixed,
      onSecondaryFixedVariant: onSecondaryFixedVariant,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      tertiaryFixed: tertiaryFixed,
      tertiaryFixedDim: tertiaryFixedDim,
      onTertiaryFixed: onTertiaryFixed,
      onTertiaryFixedVariant: onTertiaryFixedVariant,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      surface: surface,
      onSurface: onSurface,
      surfaceDim: surfaceDim,
      surfaceBright: surfaceBright,
      onSurfaceVariant: onSurfaceVariant,
      surfaceContainerLowest: surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceContainerHighest: surfaceContainerHighest,
      inverseSurface: inverseSurface,
      onInverseSurface: inverseOnSurface,
      inversePrimary: inversePrimary,
      outline: outline,
      outlineVariant: outlineVariant,
      scrim: scrim,
      shadow: shadow,
      surfaceTint: surfaceTint,
    );
  }
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
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
