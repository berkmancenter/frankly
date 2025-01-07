import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:client/app/community/community_provider.dart';
import 'package:client/environment.dart';
import 'package:client/services/cloud_functions_service.dart';
import 'package:client/services/firestore/firestore_agreements_service.dart';
import 'package:client/services/responsive_layout_service.dart';
import 'package:client/utils/payment_utils.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/admin/partner_agreement.dart';
import 'package:provider/provider.dart';

import 'overview_contract.dart';
import 'overview_model.dart';

class OverviewPresenter {
  final OverviewView _view;
  final OverviewModel _model;
  final CommunityProvider _communityProvider;
  final ResponsiveLayoutService _responsiveLayoutService;
  final PaymentUtils _paymentUtils;
  final CloudFunctionsService _cloudFunctionsService;
  final FirestoreAgreementsService _firestoreAgreementsService;

  OverviewPresenter(
    BuildContext context,
    this._view,
    this._model, {
    CommunityProvider? communityProvider,
    ResponsiveLayoutService? responsiveLayoutService,
    PaymentUtils? paymentUtils,
    CloudFunctionsService? cloudFunctionsService,
    FirestoreAgreementsService? firestoreAgreementsService,
  })  : _communityProvider =
            communityProvider ?? context.read<CommunityProvider>(),
        _responsiveLayoutService = responsiveLayoutService ??
            GetIt.instance<ResponsiveLayoutService>(),
        _paymentUtils = paymentUtils ?? GetIt.instance<PaymentUtils>(),
        _cloudFunctionsService =
            cloudFunctionsService ?? GetIt.instance<CloudFunctionsService>(),
        _firestoreAgreementsService = firestoreAgreementsService ??
            GetIt.instance<FirestoreAgreementsService>();

  void init() {
    _model.expandedOnboardingStep = getCurrentOnboardingStep();
    _view.updateView();
  }

  OnboardingStep? getCurrentOnboardingStep() {
    return _communityProvider.getCurrentOnboardingStep();
  }

  String getSubtitle(OnboardingStep onboardingStep) {
    switch (onboardingStep) {
      case OnboardingStep.brandSpace:
        return 'Make it yours with custom colors, images, and logos';
      case OnboardingStep.createGuide:
        return 'What do you want to talk about? Choose a template and structure the event. ';
      case OnboardingStep.hostEvent:
        return 'You can host or let members talk directly to each other. ';
      case OnboardingStep.inviteSomeone:
        return 'Follow along for upcoming events, resources, and more.';
      case OnboardingStep.createStripeAccount:
        return 'Enable donations for your community.';
    }
  }

  String? getLearnMoreUrl(OnboardingStep onboardingStep) {
    switch (onboardingStep) {
      case OnboardingStep.brandSpace:
        return null;
      case OnboardingStep.createGuide:
        return Environment.createTemplateHelpUrl;
      case OnboardingStep.hostEvent:
        return Environment.createEventHelpUrl;
      case OnboardingStep.inviteSomeone:
      case OnboardingStep.createStripeAccount:
        return null;
    }
    return null;
  }

  void toggleExpansion(OnboardingStep? onboardingStep) {
    if (_model.expandedOnboardingStep == onboardingStep ||
        onboardingStep == null) {
      _model.expandedOnboardingStep = null;
    } else {
      _model.expandedOnboardingStep = onboardingStep;
    }
    _view.updateView();
  }

  bool isOnboardingStepExpanded(OnboardingStep onboardingStep) {
    return _model.expandedOnboardingStep == onboardingStep;
  }

  bool isOnboardingStepCompleted(OnboardingStep onboardingStep) {
    return _communityProvider.isOnboardingStepCompleted(onboardingStep);
  }

  int getCompletedStepCount() {
    return _communityProvider.community.onboardingSteps.length;
  }

  Community getCommunity() {
    return _communityProvider.community;
  }

  bool isMobile(BuildContext context) {
    return _responsiveLayoutService.isMobile(context);
  }

  Future<void> proceedToConnectWithStripePage() async {
    final communityId = _communityProvider.communityId;
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
