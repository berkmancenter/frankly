import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Single source of truth for our styles
// https://flutter.dev/docs/development/ui/layout/building-adaptive-apps#single-source-of-truth-for-styling
class AppColor {
  /// Swatches.
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color red200 = Color(0xFFF7C5C5);
  static const Color red500 = Color(0xFFC41C1C);
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFE5E5E5);
  static const Color gray300 = Color(0xFFD4D4D4);
  static const Color gray400 = Color(0xFFA3A3A3);
  static const Color gray500 = Color(0xFF737373);
  static const Color gray600 = Color(0xFF525252);
  static const Color gray700 = Color(0xFF404040);
  static const Color gray800 = Color(0xFF262626);
  static const Color gray900 = Color(0xFF171717);

  /// Designer-defined colors.
  /// Text colors.
  static const Color textPrimary = gray900;
  static const Color textSecondary = gray700;
  static const Color textTertiary = gray500;
  static const Color textDisabled = gray300;

  /// Component colors - Primary.
  static const Color primaryPlainActiveBg = gray200;
  static const Color primaryPlainColor = gray500;
  static const Color primaryPlainDisabled = gray400;
  static const Color primaryPlainHover = gray100;

  /// Legacy colors.
  static const Color darkGreen = Color(0xFF4E7E61);
  static const Color brightGreen = Color(0xFF9BFBC2);
  static const Color lightGreen = Color(0xFFDEF5E7);
  static const Color darkerBlue = Color(0xFF27304C);
  static const Color accentBlue = Color(0xFF203EA0);
  static const Color accentBlueLight = Color(0xFF77E2FF);
  static const Color redLightMode = Color(0xFF900E2D);
  static const Color redDarkMode = Color(0xFFFF6868);
  static const Color pink = Color(0xFFFFDFDF);
  static const Color gray1 = Color(0xFF262734);
  static const Color gray2 = Color(0xFF474752);
  static const Color gray3 = Color(0xFF757584);
  static const Color gray4 = Color(0xFFB2B9C5);
  static const Color gray5 = Color(0xFFD1D7DF);
  static const Color grayTransparent = Color(0x88757584);
  static const Color transparent = Color(0x00000000);
  static const Color lightRed = Color(0xFFFFDFDF);
  static const Color darkRed = Color(0xFF350F18);
  static const Color lightYellow = Color(0xFFFFF9E8);
  static const Color darkYellow = Color(0xFF946C00);
  static Color grayHoverColor = Color(0x88757584).withOpacity(0.09);
  static const List<Color> odometerColors = [
    Color(0xffFF6868),
    Color(0xff9BFBC2),
    Color(0xff9BFBC2),
    Color(0xff5EADF5),
  ];
}

/// Class that holds custom [TextStyle]s.
///
/// [height] is calculated by taking original [height] and dividing by [fontSize].
/// For example, Line Height in Figma is 20 and Font Size is 10.
/// [height] will become 20/10 => 2.
class AppTextStyle {
  static TextStyle headline1 = GoogleFonts.poppins(
    textStyle: TextStyle(
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.normal,
      fontSize: 40,
      height: 1.1,
    ),
  );

  static TextStyle headline2 = GoogleFonts.poppins(
    textStyle: TextStyle(
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.normal,
      fontSize: 30,
      height: 1.1,
    ),
  );

  static TextStyle headline2Light = GoogleFonts.poppins(
    textStyle: TextStyle(
      fontWeight: FontWeight.w300,
      fontStyle: FontStyle.normal,
      fontSize: 34,
      height: 1.1,
    ),
  );

  static TextStyle headline3 = GoogleFonts.poppins(
    textStyle: TextStyle(
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.normal,
      fontSize: 24,
      height: 1.1,
    ),
  );

  static TextStyle headline4 = GoogleFonts.poppins(
    textStyle: TextStyle(
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.normal,
      fontSize: 18,
      height: 1.2,
    ),
  );

  static TextStyle headlineSmall = GoogleFonts.poppins(
    textStyle: TextStyle(
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.normal,
      fontSize: 12,
      height: 1.2,
    ),
  );

  static TextStyle subhead = GoogleFonts.poppins(
    textStyle: TextStyle(
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      fontSize: 18,
      height: 1.5,
    ),
  );

  static TextStyle eyebrow = GoogleFonts.poppins(
    textStyle: TextStyle(
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      fontSize: 16,
      height: 1.5,
    ),
  );

  static TextStyle eyebrowSmall = GoogleFonts.poppins(
    textStyle: TextStyle(
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      fontSize: 14,
      height: 1.5,
    ),
  );

  static TextStyle body = GoogleFonts.poppins(
    textStyle: TextStyle(
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      fontSize: 16,
      height: 1.5,
    ),
  );

  static TextStyle bodyMedium = GoogleFonts.poppins(
    textStyle: TextStyle(
      fontWeight: FontWeight.w600,
      fontStyle: FontStyle.normal,
      fontSize: 16,
      height: 1.5,
    ),
  );

  static TextStyle bodySmall = GoogleFonts.poppins(
    textStyle: TextStyle(
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      fontSize: 14,
      height: 1,
    ),
  );

  static TextStyle timeLarge = GoogleFonts.poppins(
    textStyle: TextStyle(
      fontWeight: FontWeight.w200,
      fontStyle: FontStyle.normal,
      fontSize: 126,
      height: 1.2,
    ),
  );
}

class AppSize {
  static const kMaxCarouselSize = 524.0;
  static const kNavBarHeight = 84.0;
  static const kBottomNavBarHeight = 75.0;
  static const kSidebarWidth = 376.0;

  static const kPageContentMaxWidthDesktop = 1100.0;
  static const kHomeContentMaxWidthMobile = 550.0;

  static const kHomePageCommunityIconSize = 32.0;
}

class AppDecoration {
  static const BoxShadow lightBoxShadow = BoxShadow(
    blurRadius: 6,
    offset: Offset(2, 2),
    color: AppColor.grayTransparent,
  );
}
