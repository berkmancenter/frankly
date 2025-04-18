import 'dart:math';
import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';

class PresetColorTheme {
  final Color lightColor;
  final Color darkColor;

  const PresetColorTheme({required this.lightColor, required this.darkColor});
}

/// A utility class to help calculate the perceived contrast between two colors
/// and other methods related to the creation and use of custom color schemes
class ThemeUtils {
  List<PresetColorTheme> presetColorThemes(BuildContext context) => [
        PresetColorTheme(
          lightColor: context.theme.colorScheme.surface,
          darkColor: context.theme.colorScheme.primary,
        ),
        PresetColorTheme(
          lightColor: Color(0xFFDEF8FF),
          darkColor: Color(0xFF203EA0),
        ),
        PresetColorTheme(
          lightColor: Color(0xFFE1F4EE),
          darkColor: Color(0xFF006442),
        ),
        PresetColorTheme(
          lightColor: Color(0xFF76F1A4),
          darkColor: Color(0xFF0F200F),
        ),
        PresetColorTheme(
          lightColor: Color(0xFFF9EB0F),
          darkColor: Color(0xFF000000),
        ),
        PresetColorTheme(
          lightColor: Color(0xFFFFA800),
          darkColor: Color(0xFF320243),
        ),
        PresetColorTheme(
          lightColor: Color(0xFFFF6258),
          darkColor: Color(0xFF001D58),
        ),
        PresetColorTheme(
          lightColor: Color(0xFFEAF3FD),
          darkColor: Color(0xFF900E2D),
        ),
        PresetColorTheme(
          lightColor: Color(0xFFFBE5D6),
          darkColor: Color(0xFF660D6B),
        ),
        PresetColorTheme(
          lightColor: Color(0xFFEFEFEF),
          darkColor: Color(0xFF222222),
        ),
      ];

  Color lightColorFromTheme(BuildContext context, int theme) =>
      presetColorThemes(context)[theme].lightColor;

  Color darkColorFromTheme(BuildContext context, int theme) =>
      presetColorThemes(context)[theme].darkColor;

  static String convertToHexString(Color color) =>
      color.toString().substring(10, 16);

  String darkColorStringFromTheme(BuildContext context, int theme) =>
      convertToHexString(darkColorFromTheme(context, theme));

  String lightColorStringFromTheme(BuildContext context, int theme) =>
      convertToHexString(lightColorFromTheme(context, theme));

  static bool isColorValid(String? color) =>
      color != null &&
      color.length == 6 &&
      RegExp(r'^[0-9a-fA-F]*$').hasMatch(color);

  static bool isColorComboValid(
    BuildContext context,
    String? lightColorString,
    String? darkColorString,
  ) {
    bool colorStringsValid =
        isColorValid(lightColorString) && isColorValid(darkColorString);

    if (!colorStringsValid) return false;

    final lightColor = parseColor(lightColorString)!;
    final darkColor = parseColor(darkColorString)!;

    bool validRatio = isContrastRatioValid(context, lightColor, darkColor);
    bool lightDarkCorrect = isFirstColorLighter(
      parseColor(lightColorString)!,
      parseColor(darkColorString)!,
    );

    final darkColorIsDarkEnough = isContrastRatioValid(
      context,
      darkColor,
      context.theme.colorScheme.surface,
    );
    final lightColorIsLightEnough =
        isContrastRatioValid(context, lightColor, AppColor.gray1);

    return validRatio &&
        lightDarkCorrect &&
        darkColorIsDarkEnough &&
        lightColorIsLightEnough;
  }

  static bool isFirstColorLighter(Color firstColor, Color secondColor) =>
      firstColor.computeLuminance() > secondColor.computeLuminance();

  static bool isContrastRatioValid(
    BuildContext context,
    Color firstColor,
    Color secondColor,
  ) {
    final val = calculateContrastRatio(
      firstColor,
      secondColor,
    );

    return val > 4.5;
  }

  /// This formula, along with that in computeLuminance, is from official w3 contrast ratio documentation:
  /// https://www.w3.org/TR/2008/REC-WCAG20-20081211/#contrast-ratiodef
  /// more info:
  /// https://stackoverflow.com/questions/9733288/how-to-programmatically-calculate-the-contrast-ratio-between-two-colors
  static double calculateContrastRatio(Color color1, Color color2) {
    var lum1 = color1.computeLuminance();
    var lum2 = color2.computeLuminance();

    var brightest = max(lum1, lum2);
    var darkest = min(lum1, lum2);

    return (brightest + 0.05) / (darkest + 0.05);
  }

  /// Returns a color from a six character hexadecimal string, RRGGBB
  static Color? parseColor(String? toParse) {
    final parsedColor = int.tryParse('0XFF${toParse?.toUpperCase()}');
    if (isColorValid(toParse) && parsedColor != null) {
      return Color(parsedColor);
    }
    return null;
  }
}

extension ThemeDataExtension on ThemeData {
  bool get isDark => brightness == Brightness.dark;

  bool get isLight => brightness == Brightness.light;
}
