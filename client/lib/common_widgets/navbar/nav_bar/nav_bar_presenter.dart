import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:junto/app/junto/community_permissions_provider.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/services/cloud_functions_service.dart';
import 'package:junto/services/firestore/firestore_agreements_service.dart';
import 'package:junto/services/responsive_layout_service.dart';
import 'package:junto/services/shared_preferences_service.dart';
import 'package:junto/services/user_service.dart';
import 'package:junto/utils/payment_utils.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/partner_agreement.dart';
import 'package:provider/provider.dart';
import 'package:junto/utils/extensions.dart';

import 'nav_bar_contract.dart';
import 'nav_bar_model.dart';

class NavBarPresenter {
  final NavBarView _view;
  final NavBarModel _model;
  final CommunityPermissionsProvider? _communityPermissionsProvider;
  final ResponsiveLayoutService _responsiveLayoutService;
  final UserService _userService;
  final JuntoProvider? _juntoProvider;
  final SharedPreferencesService _sharedPreferencesService;
  final PaymentUtils _paymentUtils;
  final CloudFunctionsService _cloudFunctionsService;
  final FirestoreAgreementsService _firestoreAgreementsService;

  NavBarPresenter(
    BuildContext context,
    this._view,
    this._model, {
    CommunityPermissionsProvider? communityPermissionsProvider,
    ResponsiveLayoutService? responsiveLayoutService,
    UserService? userService,
    JuntoProvider? juntoProvider,
    SharedPreferencesService? sharedPreferencesService,
    PaymentUtils? paymentUtils,
    CloudFunctionsService? cloudFunctionsService,
    FirestoreAgreementsService? firestoreAgreementsService,
  })  : _communityPermissionsProvider =
            communityPermissionsProvider ?? context.readOrNull<CommunityPermissionsProvider>(),
        _responsiveLayoutService =
            responsiveLayoutService ?? GetIt.instance<ResponsiveLayoutService>(),
        _userService = userService ?? context.read<UserService>(),
        _juntoProvider = juntoProvider ?? context.readOrNull<JuntoProvider>(),
        _sharedPreferencesService =
            sharedPreferencesService ?? GetIt.instance<SharedPreferencesService>(),
        _paymentUtils = paymentUtils ?? GetIt.instance<PaymentUtils>(),
        _cloudFunctionsService = cloudFunctionsService ?? GetIt.instance<CloudFunctionsService>(),
        _firestoreAgreementsService =
            firestoreAgreementsService ?? GetIt.instance<FirestoreAgreementsService>();

  void init() {
    _model.isOnboardingTooltipShown = _sharedPreferencesService.isOnboardingOverviewTooltipShown();
    _view.updateView();
  }

  bool isJuntoLocation() {
    return routerDelegate.currentBeamLocation is JuntoLocation;
  }

  bool isJuntoHomePage() {
    return CheckCurrentLocation.isJuntoHomePage;
  }

  bool canViewCommunityLinks() {
    return _communityPermissionsProvider?.canViewCommunityLinks ?? false;
  }

  bool showBottomNavBar(BuildContext context) {
    return _responsiveLayoutService.showBottomNavBar(context);
  }

  bool isMobile(BuildContext context) {
    return _responsiveLayoutService.isMobile(context);
  }

  bool isSignedIn() {
    return _userService.isSignedIn;
  }

  OnboardingStep? getCurrentOnboardingStep() {
    return _juntoProvider?.getCurrentOnboardingStep();
  }

  void closeOnboardingTooltip() {
    _sharedPreferencesService.updateOnboardingOverviewTooltipVisibility(false);
    _model.isOnboardingTooltipShown = false;
    _view.updateView();
  }

  int getCompletedStepCount() {
    return _juntoProvider?.junto.onboardingSteps.length ?? 0;
  }

  Junto? getJunto() {
    return _juntoProvider?.junto;
  }

  void updateAdminButtonXPosition() {
    final previousPosition = _model.adminButtonXPosition;
    final newPosition = _model.adminButtonKey.globalPosition?.dx;

    if (previousPosition != newPosition) {
      _model.adminButtonXPosition = newPosition;

      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        _view.updateView();
      });
    }
  }

  bool isAdminButtonVisible() {
    final junto = _juntoProvider?.junto;
    final canEditCommunity = _communityPermissionsProvider?.canEditCommunity ?? false;
    final isJuntoLocation = routerDelegate.currentBeamLocation is JuntoLocation;

    return junto != null && canEditCommunity && isJuntoLocation;
  }

  bool isOnboardingOverviewEnabled() {
    return _juntoProvider?.junto.isOnboardingOverviewEnabled ?? false;
  }

  Future<void> proceedToConnectWithStripePage() async {
    final juntoId = _juntoProvider?.juntoId ?? '';
    final PartnerAgreement? partnerAgreement =
        await _firestoreAgreementsService.getAgreementForJuntoStream(juntoId).first;

    await _paymentUtils.proceedToConnectWithStripePage(
      partnerAgreement,
      partnerAgreement?.id,
      _cloudFunctionsService,
    );
  }
}
