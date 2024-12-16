import 'package:flutter/material.dart';
import 'package:junto/app/junto/community_permissions_provider.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/firestore/junto.dart';

class NavBarProvider extends ChangeNotifier {
  bool _hideNav = false;

  bool _hasResources = false;

  Junto? _currentJunto;

  Junto? get currentJunto => _currentJunto;

  String? get currentJuntoDisplayId => _currentJunto?.displayId;

  bool get hideNav => _hideNav;

  bool get showResources =>
      _hasResources || CommunityPermissionsProvider.canEditCommunityFromId(_currentJunto?.id ?? '');

  void setCurrentJunto(Junto junto) {
    _currentJunto = junto;
    notifyListeners();
  }

  void setHasResources(bool value) {
    _hasResources = value;
    notifyListeners();
  }

  void forceHideNav() {
    _hideNav = true;
    notifyListeners();
  }

  void resetHideNav() {
    _hideNav = false;
    notifyListeners();
  }

  bool collapseNav(BuildContext context) {
    return responsiveLayoutService.isMobile(context);
  }

  /// This is to fix a bug where navigating back from the AV check page would not reset the 'hide nav' flag
  void checkIfShouldResetNav() {
    if (!(CheckCurrentLocation.isDiscussionPage ||
        CheckCurrentLocation.isInstantPage ||
        CheckCurrentLocation.isUnifyAmericaPage)) {
      if (hideNav) {
        WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
          resetHideNav();
        });
      }
    }
  }
}
