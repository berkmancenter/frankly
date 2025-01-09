import 'package:flutter/material.dart';

class NavBarModel {
  final GlobalKey adminButtonKey;

  late bool isOnboardingTooltipShown;

  double? adminButtonXPosition;

  NavBarModel({GlobalKey? adminButtonKey})
      : adminButtonKey = adminButtonKey ?? GlobalKey();
}
