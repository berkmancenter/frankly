import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';

class JuntoUiMigration extends StatelessWidget {
  final bool whiteBackground;
  final Widget child;

  const JuntoUiMigration({
    this.whiteBackground = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = whiteBackground ? AppColor.darkBlue : AppColor.white;
    final mobile = responsiveLayoutService.isMobile(context);

    return Theme(
      data: Theme.of(context).copyWith(
        brightness: whiteBackground ? Brightness.light : Brightness.dark,
        textTheme: GoogleFonts.poppinsTextTheme(
          TextTheme(
            headlineLarge: TextStyle(
              fontSize: mobile ? 24 : 42.0,
              fontWeight: FontWeight.bold,
              letterSpacing: .5,
            ),
            headlineMedium: TextStyle(
              fontSize: mobile ? 20 : 30.0,
            ),
            titleMedium: TextStyle(
              fontSize: mobile ? 16 : 20,
            ),
            // Divider
            titleSmall: TextStyle(
              fontSize: mobile ? 14 : 16,
              fontWeight: FontWeight.w400,
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
            ),
            // Sidebar
            bodyMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
            labelMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ).apply(
            displayColor: textColor,
            bodyColor: textColor,
          ),
        ),
        iconTheme: IconThemeData(
          color: textColor,
        ),
      ),
      child: DefaultTextStyle(
        style: body.copyWith(color: textColor),
        child: child,
      ),
    );
  }
}
