import 'package:client/app/community/utils.dart';
import 'package:client/services/cloud_functions_service.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/firestore/partner_agreement.dart';
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
    final communityId = partnerAgreement?.communityId;

    if (stripeAccountId == null) {
      await cloudFunctionsService.createStripeConnectedAccount(
        CreateStripeConnectedAccountRequest(agreementId: partnerAgreementId!),
      );
    }

    final String responsePath;
    if (isNullOrEmpty(communityId)) {
      responsePath = '/home';
    } else {
      responsePath = 'space/$communityId';
    }

    final response = await cloudFunctionsService.getStripeConnectedAccountLink(
      GetStripeConnectedAccountLinkRequest(
        agreementId: partnerAgreementId!,
        responsePath: responsePath,
      ),
    );

    universal_html.window.location.assign(response.url);
  }
}
