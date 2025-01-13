import 'package:flutter/material.dart';
import 'package:client/features/community/data/providers/community_permissions_provider.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/services.dart';
import 'package:data_models/community/community.dart';

class NavBarProvider extends ChangeNotifier {
  bool _hideNav = false;

  bool _hasResources = false;

  Community? _currentCommunity;

  Community? get currentCommunity => _currentCommunity;

  String? get currentCommunityDisplayId => _currentCommunity?.displayId;

  bool get hideNav => _hideNav;

  bool get showResources =>
      _hasResources ||
      CommunityPermissionsProvider.canEditCommunityFromId(
        _currentCommunity?.id ?? '',
      );

  void setCurrentCommunity(Community community) {
    _currentCommunity = community;
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
    if (!(CheckCurrentLocation.isEventPage ||
        CheckCurrentLocation.isInstantPage)) {
      if (hideNav) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          resetHideNav();
        });
      }
    }
  }
}
