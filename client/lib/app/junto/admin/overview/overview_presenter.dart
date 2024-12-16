import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/services/cloud_functions_service.dart';
import 'package:junto/services/firestore/firestore_agreements_service.dart';
import 'package:junto/services/responsive_layout_service.dart';
import 'package:junto/utils/payment_utils.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/partner_agreement.dart';
import 'package:provider/provider.dart';

import 'overview_contract.dart';
import 'overview_model.dart';

class OverviewPresenter {
  final OverviewView _view;
  final OverviewModel _model;
  final JuntoProvider _juntoProvider;
  final ResponsiveLayoutService _responsiveLayoutService;
  final PaymentUtils _paymentUtils;
  final CloudFunctionsService _cloudFunctionsService;
  final FirestoreAgreementsService _firestoreAgreementsService;

  OverviewPresenter(
    BuildContext context,
    this._view,
    this._model, {
    JuntoProvider? juntoProvider,
    ResponsiveLayoutService? responsiveLayoutService,
    PaymentUtils? paymentUtils,
    CloudFunctionsService? cloudFunctionsService,
    FirestoreAgreementsService? firestoreAgreementsService,
  })  : _juntoProvider = juntoProvider ?? context.read<JuntoProvider>(),
        _responsiveLayoutService =
            responsiveLayoutService ?? GetIt.instance<ResponsiveLayoutService>(),
        _paymentUtils = paymentUtils ?? GetIt.instance<PaymentUtils>(),
        _cloudFunctionsService = cloudFunctionsService ?? GetIt.instance<CloudFunctionsService>(),
        _firestoreAgreementsService =
            firestoreAgreementsService ?? GetIt.instance<FirestoreAgreementsService>();

  void init() {
    _model.expandedOnboardingStep = getCurrentOnboardingStep();
    _view.updateView();
  }

  OnboardingStep? getCurrentOnboardingStep() {
    return _juntoProvider.getCurrentOnboardingStep();
  }

  String getSubtitle(OnboardingStep onboardingStep) {
    switch (onboardingStep) {
      case OnboardingStep.brandSpace:
        return 'Make it yours with custom colors, images, and logos';
      case OnboardingStep.createGuide:
        return 'What do you want to talk about? Choose a template and structure the event. ';
      case OnboardingStep.hostConversation:
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
        return 'https://rebootingsocialmedia.notion.site/Creating-and-Managing-Events-552a42e4a09549b788e1901536a25965';
      case OnboardingStep.hostConversation:
        return 'https://rebootingsocialmedia.notion.site/Creating-and-Managing-Events-552a42e4a09549b788e1901536a25965';
      case OnboardingStep.inviteSomeone:
      case OnboardingStep.createStripeAccount:
        return null;
    }
  }

  void toggleExpansion(OnboardingStep? onboardingStep) {
    if (_model.expandedOnboardingStep == onboardingStep || onboardingStep == null) {
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
    return _juntoProvider.isOnboardingStepCompleted(onboardingStep);
  }

  int getCompletedStepCount() {
    return _juntoProvider.junto.onboardingSteps.length;
  }

  Junto getJunto() {
    return _juntoProvider.junto;
  }

  bool isMobile(BuildContext context) {
    return _responsiveLayoutService.isMobile(context);
  }

  Future<void> proceedToConnectWithStripePage() async {
    final juntoId = _juntoProvider.juntoId;
    final PartnerAgreement? partnerAgreement =
        await _firestoreAgreementsService.getAgreementForJuntoStream(juntoId).first;

    await _paymentUtils.proceedToConnectWithStripePage(
      partnerAgreement,
      partnerAgreement?.id,
      _cloudFunctionsService,
    );
  }
}
