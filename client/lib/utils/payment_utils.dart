import 'package:junto/app/junto/utils.dart';
import 'package:junto/services/cloud_functions_service.dart';
import 'package:junto/services/logging_service.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/partner_agreement.dart';
import 'package:universal_html/html.dart' as universal_html;

class PaymentUtils {
  bool isStripeAccountAlreadyCreated(PartnerAgreement? partnerAgreement) {
    return partnerAgreement?.stripeConnectedAccountId != null;
  }

  Future<void> proceedToConnectWithStripePage(
    PartnerAgreement? partnerAgreement,
    String? partnerAgreementId,
    CloudFunctionsService cloudFunctionsService,
  ) async {
    partnerAgreementId ??= partnerAgreement?.id;
    final stripeAccountId = partnerAgreement?.stripeConnectedAccountId;
    final juntoId = partnerAgreement?.juntoId;

    if (stripeAccountId == null && partnerAgreementId != null) {
      await cloudFunctionsService.createStripeConnectedAccount(
        CreateStripeConnectedAccountRequest(agreementId: partnerAgreementId),
      );
    }

    if (partnerAgreementId == null) {
      loggingService.log(
        'PaymentUtils.proceedToConnectWithStripePage: partnerAgreementId is null',
        logType: LogType.error,
      );
      return;
    }

    final String responsePath;
    if (isNullOrEmpty(juntoId)) {
      responsePath = '/home';
    } else {
      responsePath = 'space/$juntoId';
    }

    final response = await cloudFunctionsService
        .getStripeConnectedAccountLink(GetStripeConnectedAccountLinkRequest(
      agreementId: partnerAgreementId,
      responsePath: responsePath,
    ));

    universal_html.window.location.assign(response.url);
  }
}
