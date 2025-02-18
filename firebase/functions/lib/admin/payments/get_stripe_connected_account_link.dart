import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../../on_call_function.dart';
import '../../utils/infra/firestore_utils.dart';
import 'stripe_util.dart';
import '../../utils/utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/admin/partner_agreement.dart';

class GetStripeConnectedAccountLink
    extends OnCallMethod<GetStripeConnectedAccountLinkRequest> {
  GetStripeConnectedAccountLink()
      : super(
          'getStripeConnectedAccountLink',
          (json) => GetStripeConnectedAccountLinkRequest.fromJson(json),
        );

  @override
  Future<Map<String, dynamic>> action(
    GetStripeConnectedAccountLinkRequest request,
    CallableContext context,
  ) async {
    orElseUnauthorized(context.authUid != null);

    final agreementRef =
        firestore.document('partner-agreements/${request.agreementId}');
    final agreementDoc = await agreementRef.get();
    orElseUnauthorized(agreementDoc.exists);

    final agreement = PartnerAgreement.fromJson(agreementDoc.data.toMap());
    orElseUnauthorized(agreement.allowPayments == true);
    orElseUnauthorized(agreement.stripeConnectedAccountId != null);
    orElseUnauthorized(agreement.initialUserId == context.authUid);

    final domain = functions.config.get('app.domain') as String;

    final Map<String, String> params = {
      'account': agreement.stripeConnectedAccountId!,
      'type': 'account_onboarding',
      'return_url': 'https://$domain/${request.responsePath}',
      'refresh_url': 'https://$domain/${request.responsePath}',
    };

    final jsonResponse =
        await stripeUtil.post(path: '/account_links', params: params);
    return GetStripeConnectedAccountLinkResponse(url: jsonResponse['url'])
        .toJson();
  }

  // Sets minimum instances to 0
  @override
  void register(FirebaseFunctions functions) {
    functions[functionName] = functions
        .runWith(
          runWithOptions ??
              RuntimeOptions(
                timeoutSeconds: 60,
                memory: '1GB',
                minInstances: 0,
              ),
        )
        .https
        .onCall(callAction);
  }
}
