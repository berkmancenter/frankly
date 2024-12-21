import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:client/app/community/community_permissions_provider.dart';
import 'package:client/app/community/community_provider.dart';
import 'package:client/routing/locations.dart';
import 'package:client/services/cloud_functions_service.dart';
import 'package:client/services/firestore/firestore_agreements_service.dart';
import 'package:client/services/responsive_layout_service.dart';
import 'package:client/services/shared_preferences_service.dart';
import 'package:client/services/user_service.dart';
import 'package:client/utils/payment_utils.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/admin/partner_agreement.dart';
import 'package:provider/provider.dart';
import 'package:client/utils/extensions.dart';

import 'nav_bar_contract.dart';
import 'nav_bar_model.dart';

class NavBarPresenter {
  final NavBarView _view;
  final NavBarModel _model;
  final CommunityPermissionsProvider? _communityPermissionsProvider;
  final ResponsiveLayoutService _responsiveLayoutService;
  final UserService _userService;
  final CommunityProvider? _communityProvider;
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
    CommunityProvider? communityProvider,
    SharedPreferencesService? sharedPreferencesService,
    PaymentUtils? paymentUtils,
    CloudFunctionsService? cloudFunctionsService,
    FirestoreAgreementsService? firestoreAgreementsService,
  })  : _communityPermissionsProvider = communityPermissionsProvider ??
            context.readOrNull<CommunityPermissionsProvider>(),
        _responsiveLayoutService = responsiveLayoutService ??
            GetIt.instance<ResponsiveLayoutService>(),
        _userService = userService ?? context.read<UserService>(),
        _communityProvider =
            communityProvider ?? context.readOrNull<CommunityProvider>(),
        _sharedPreferencesService = sharedPreferencesService ??
            GetIt.instance<SharedPreferencesService>(),
        _paymentUtils = paymentUtils ?? GetIt.instance<PaymentUtils>(),
        _cloudFunctionsService =
            cloudFunctionsService ?? GetIt.instance<CloudFunctionsService>(),
        _firestoreAgreementsService = firestoreAgreementsService ??
            GetIt.instance<FirestoreAgreementsService>();

  void init() {
    _model.isOnboardingTooltipShown =
        _sharedPreferencesService.isOnboardingOverviewTooltipShown();
    _view.updateView();
  }

  bool isCommunityLocation() {
    return routerDelegate.currentBeamLocation is CommunityLocation;
  }

  bool isCommunityHomePage() {
    return CheckCurrentLocation.isCommunityHomePage;
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
    return _communityProvider?.getCurrentOnboardingStep();
  }

  void closeOnboardingTooltip() {
    _sharedPreferencesService.updateOnboardingOverviewTooltipVisibility(false);
    _model.isOnboardingTooltipShown = false;
    _view.updateView();
  }

  int getCompletedStepCount() {
    return _communityProvider?.community.onboardingSteps.length ?? 0;
  }

  Community? getCommunity() {
    return _communityProvider?.community;
  }

  void updateAdminButtonXPosition() {
    final previousPosition = _model.adminButtonXPosition;
    final newPosition = _model.adminButtonKey.globalPosition?.dx;

    if (previousPosition != newPosition) {
      _model.adminButtonXPosition = newPosition;

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _view.updateView();
      });
    }
  }

  bool isAdminButtonVisible() {
    final community = _communityProvider?.community;
    final canEditCommunity =
        _communityPermissionsProvider?.canEditCommunity ?? false;
    final isCommunityLocation =
        routerDelegate.currentBeamLocation is CommunityLocation;

    return community != null && canEditCommunity && isCommunityLocation;
  }

  bool isOnboardingOverviewEnabled() {
    return _communityProvider?.community.isOnboardingOverviewEnabled ?? false;
  }

  Future<void> proceedToConnectWithStripePage() async {
    final communityId = _communityProvider?.communityId ?? '';
    final PartnerAgreement? partnerAgreement = await _firestoreAgreementsService
        .getAgreementForCommunityStream(communityId)
        .first;

    await _paymentUtils.proceedToConnectWithStripePage(
      partnerAgreement,
      partnerAgreement?.id,
      _cloudFunctionsService,
    );
  }
}
