import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const List<Color> kOdometerColors = [
  Color.fromARGB(255, 181, 0, 0),
  Color.fromARGB(255, 190, 251, 155),
  Color.fromARGB(255, 155, 251, 227),
  Color.fromARGB(255, 136, 197, 255),
];

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
    color: Color.fromARGB(82, 0, 0, 0),
}
