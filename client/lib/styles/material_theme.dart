import 'package:flutter/material.dart';

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static MaterialScheme lightScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(0xff000000),
      surfaceTint: Color(0xff5f5e5e),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff262626),
      onPrimaryContainer: Color(0xffb3b1b0),
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
      surface: Color(0xfffdf8f8),
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

  static MaterialScheme lightMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(0xff000000),
      surfaceTint: Color(0xff5f5e5e),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff262626),
      onPrimaryContainer: Color(0xffdfdcdb),
      secondary: Color(0xff45433c),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff77746c),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff3e4444),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff6f7676),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff8c0008),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffd92d29),
      onErrorContainer: Color(0xffffffff),
      background: Color(0xfffdf8f8),
      onBackground: Color(0xff1c1b1b),
      surface: Color(0xfffdf8f8),
      onSurface: Color(0xff1c1b1b),
      surfaceVariant: Color(0xffe0e3e3),
      onSurfaceVariant: Color(0xff404344),
      outline: Color(0xff5c6060),
      outlineVariant: Color(0xff787b7c),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inverseOnSurface: Color(0xfff4f0ef),
      inversePrimary: Color(0xffc8c6c5),
      primaryFixed: Color(0xff767474),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff5d5c5b),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff77746c),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff5e5c54),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff6f7676),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff575d5d),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffddd9d8),
      surfaceBright: Color(0xfffdf8f8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff7f3f2),
      surfaceContainer: Color(0xfff1edec),
      surfaceContainerHigh: Color(0xffebe7e6),
      surfaceContainerHighest: Color(0xffe5e2e1),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme lightHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(0xff000000),
      surfaceTint: Color(0xff5f5e5e),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff262626),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff24221c),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff45433c),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff1d2324),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff3e4444),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff4e0002),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff8c0008),
      onErrorContainer: Color(0xffffffff),
      background: Color(0xfffdf8f8),
      onBackground: Color(0xff1c1b1b),
      surface: Color(0xfffdf8f8),
      onSurface: Color(0xff000000),
      surfaceVariant: Color(0xffe0e3e3),
      onSurfaceVariant: Color(0xff212425),
      outline: Color(0xff404344),
      outlineVariant: Color(0xff404344),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inverseOnSurface: Color(0xffffffff),
      inversePrimary: Color(0xffeeebeb),
      primaryFixed: Color(0xff434342),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff2d2d2c),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff45433c),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff2e2d26),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff3e4444),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff282e2e),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffddd9d8),
      surfaceBright: Color(0xfffdf8f8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff7f3f2),
      surfaceContainer: Color(0xfff1edec),
      surfaceContainerHigh: Color(0xffebe7e6),
      surfaceContainerHighest: Color(0xffe5e2e1),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme().toColorScheme());
  }

  static MaterialScheme darkScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(0xffc8c6c5),
      surfaceTint: Color(0xffc8c6c5),
      onPrimary: Color(0xff313030),
      primaryContainer: Color(0xff0b0b0b),
      onPrimaryContainer: Color(0xff9d9b9a),
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

  static MaterialScheme darkMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(0xffcdcaca),
      surfaceTint: Color(0xffc8c6c5),
      onPrimary: Color(0xff161616),
      primaryContainer: Color(0xff929090),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffffffff),
      onSecondary: Color(0xff32302a),
      secondaryContainer: Color(0xffd9d4ca),
      onSecondaryContainer: Color(0xff211f19),
      tertiary: Color(0xffdfe5e5),
      onTertiary: Color(0xff262c2c),
      tertiaryContainer: Color(0xffb5bbbb),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffbab1),
      onError: Color(0xff370001),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      background: Color(0xff141313),
      onBackground: Color(0xffe5e2e1),
      surface: Color(0xff141313),
      onSurface: Color(0xfffefaf9),
      surfaceVariant: Color(0xff444748),
      onSurfaceVariant: Color(0xffc8cbcc),
      outline: Color(0xffa0a3a4),
      outlineVariant: Color(0xff808484),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e1),
      inverseOnSurface: Color(0xff2b2a2a),
      inversePrimary: Color(0xff484848),
      primaryFixed: Color(0xffe5e2e1),
      onPrimaryFixed: Color(0xff111111),
      primaryFixedDim: Color(0xffc8c6c5),
      onPrimaryFixedVariant: Color(0xff363636),
      secondaryFixed: Color(0xffe7e2d8),
      onSecondaryFixed: Color(0xff12110c),
      secondaryFixedDim: Color(0xffcbc6bc),
      onSecondaryFixedVariant: Color(0xff38362f),
      tertiaryFixed: Color(0xffdee4e3),
      onTertiaryFixed: Color(0xff0c1213),
      tertiaryFixedDim: Color(0xffc2c8c8),
      onTertiaryFixedVariant: Color(0xff313738),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff3a3939),
      surfaceContainerLowest: Color(0xff0e0e0e),
      surfaceContainerLow: Color(0xff1c1b1b),
      surfaceContainer: Color(0xff201f1f),
      surfaceContainerHigh: Color(0xff2b2a2a),
      surfaceContainerHighest: Color(0xff353434),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme darkHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(0xfffdfaf9),
      surfaceTint: Color(0xffc8c6c5),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffcdcaca),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffffffff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffd9d4ca),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xfff6fcfc),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffc6cccc),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xfffff9f9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffbab1),
      onErrorContainer: Color(0xff000000),
      background: Color(0xff141313),
      onBackground: Color(0xffe5e2e1),
      surface: Color(0xff141313),
      onSurface: Color(0xffffffff),
      surfaceVariant: Color(0xff444748),
      onSurfaceVariant: Color(0xfff9fbfb),
      outline: Color(0xffc8cbcc),
      outlineVariant: Color(0xffc8cbcc),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e1),
      inverseOnSurface: Color(0xff000000),
      inversePrimary: Color(0xff2a2a2a),
      primaryFixed: Color(0xffe9e6e5),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffcdcaca),
      onPrimaryFixedVariant: Color(0xff161616),
      secondaryFixed: Color(0xffebe6dc),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffcfcac1),
      onSecondaryFixedVariant: Color(0xff181610),
      tertiaryFixed: Color(0xffe2e8e8),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffc6cccc),
      onTertiaryFixedVariant: Color(0xff111718),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff3a3939),
      surfaceContainerLowest: Color(0xff0e0e0e),
      surfaceContainerLow: Color(0xff1c1b1b),
      surfaceContainer: Color(0xff201f1f),
      surfaceContainerHigh: Color(0xff2b2a2a),
      surfaceContainerHighest: Color(0xff353434),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme().toColorScheme());
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
