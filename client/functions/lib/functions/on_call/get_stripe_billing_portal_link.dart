import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/on_call_function.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_functions/utils/stripe_util.dart';
import 'package:junto_functions/utils/utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';

class GetStripeBillingPortalLink
    extends OnCallMethod<GetStripeBillingPortalLinkRequest> {
  GetStripeBillingPortalLink()
      : super('getStripeBillingPortalLink',
            (json) => GetStripeBillingPortalLinkRequest.fromJson(json));

  @override
  Future<Map<String, dynamic>> action(GetStripeBillingPortalLinkRequest request,
      CallableContext context) async {
    orElseUnauthorized(context?.authUid != null);

    final stripeCustomerId =
        await stripeUtil.getOrCreateCustomerStripeId(uid: context!.authUid!);
    final prodDomain = functions.config.get('app.prod_domain') as String;
    final devDomain = functions.config.get('app.dev_domain') as String;
    final domain = isDev ? devDomain : prodDomain;

    final Map<String, String> params = {
      'customer': stripeCustomerId,
      'return_url': 'https://$domain/${request.responsePath}',
    };

    final jsonResponse =
        await stripeUtil.post(path: '/billing_portal/sessions', params: params);
    return GetStripeBillingPortalLinkResponse(url: jsonResponse['url'])
        .toJson();
  }

  // Sets minimum instances to 0
  @override
  void register(FirebaseFunctions functions) {
    functions[functionName] = functions
        .runWith(runWithOptions ??
            RuntimeOptions(
              timeoutSeconds: 60,
              memory: '1GB',
              minInstances: 0,
            ))
        .https
        .onCall(callAction);
  }
}
