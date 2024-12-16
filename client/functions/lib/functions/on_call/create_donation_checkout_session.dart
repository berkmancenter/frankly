import 'dart:math';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/on_call_function.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_functions/utils/stripe_util.dart';
import 'package:junto_functions/utils/subscription_plan_util.dart';
import 'package:junto_functions/utils/utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/partner_agreement.dart';

class CreateDonationCheckoutSession
    extends OnCallMethod<CreateDonationCheckoutSessionRequest> {
  CreateDonationCheckoutSession()
      : super(
          'createDonationCheckoutSession',
          (jsonMap) => CreateDonationCheckoutSessionRequest.fromJson(jsonMap),
        );

  @override
  Future<Map<String, dynamic>> action(
      CreateDonationCheckoutSessionRequest request,
      CallableContext context) async {
    final amountInCents = request.amountInCents;
    if (amountInCents <= 0) {
      throw HttpsError(HttpsError.invalidArgument, 'invalid argument',
          'AmountInCents must be greater than zero.');
    }

    final juntoId = request.juntoId;
    final prodDomain = functions.config.get('app.prod_domain') as String;
    final devDomain = functions.config.get('app.dev_domain') as String;
    final orgName = functions.config.get('app.legal_entity_name') as String;

    final String customerId =
        await stripeUtil.getOrCreateCustomerStripeId(uid: context!.authUid!);
    final domain = isDev ? devDomain : prodDomain;

    final juntoSnapshot = await firestore.document('/junto/$juntoId').get();
    orElseNotFound(juntoSnapshot.exists);
    final junto = Junto.fromJson(
        firestoreUtils.fromFirestoreJson(juntoSnapshot.data.toMap()));

    // The next lines set text ("statement descriptor") on customer credit card statement line.
    // Max length of full descriptor is 22.
    // The full descriptor is [Shortened descriptor] + '* ' + dynamic suffix.
    // Set [Shortened descriptor] value at https://dashboard.stripe.com/settings/account
    // Length constraint on suffix is therefore (22 - "JUNTO* ".length)
    // There are also character requirements.
    // See https://stripe.com/docs/statement-descriptors

    // Replace non-whitelisted characters with '-'
    final sanitized =
        junto.name?.replaceAll(RegExp('[^a-zA-Z0-9 .]'), '-') ?? '';

    // Trim to correct length
    final trimmed = sanitized.substring(0, min(sanitized.length, 15));

    // Replace with generic descriptor if calculated descriptor has no letters
    final descriptor =
        RegExp('^[^a-zA-Z]*\$').hasMatch(trimmed) ? 'Donation' : trimmed;

    PartnerAgreement? agreement;
    final agreementDocs = await firestore
        .collection('partner-agreements')
        .where(
          PartnerAgreement.kFieldJuntoId,
          isEqualTo: juntoId,
        )
        .get();
    if (agreementDocs.documents.isNotEmpty) {
      agreement = PartnerAgreement.fromJson(firestoreUtils
          .fromFirestoreJson(agreementDocs.documents.first.data.toMap()));
    }

    // use negotiated take rate, if any; otherwise fall back to subscription plan take rate
    final double takeRate = agreement?.takeRate ??
        (await subscriptionPlanUtil.calculateCapabilities(juntoId)).takeRate!;

    final useConnectedAccount = agreement != null &&
        agreement.allowPayments == true &&
        agreement.stripeConnectedAccountId != null &&
        takeRate >= 0 &&
        takeRate < 1;

    final user =
        (await firestoreUtils.getUsers([context!.authUid!].toList())).first;

    final Map<String, String> params = {
      'success_url': 'https://$domain/space/$juntoId?donation=success',
      'cancel_url': 'https://$domain/space/$juntoId?donation=cancel',
      'payment_method_types[0]': 'card',
      'line_items[0][amount]': '$amountInCents',
      'line_items[0][currency]': 'usd',
      'line_items[0][name]': 'Donation for ${junto.name}',
      'line_items[0][quantity]': '1',
      'line_items[0][description]':
          'A portion of this payment may be retained by $orgName per agreement with the recipient organization.',
      'submit_type': 'donate',
      'mode': 'payment',
      'customer': customerId,
      'payment_intent_data[metadata][type]': 'one_time_donation',
      'payment_intent_data[metadata][authUid]': context!.authUid!,
      'payment_intent_data[metadata][juntoId]': juntoId,
      'payment_intent_data[metadata][email]': user.email,
      'payment_intent_data[metadata][name]': user.displayName,
      'payment_intent_data[setup_future_usage]':
          'on_session', // link payment method to customer
      'payment_intent_data[statement_descriptor_suffix]': descriptor,
    };

    if (juntoId == 'allsides-talks') {
      params['success_url'] = 'https://www.allsides.com/talks/feedback';
      params['cancel_url'] = 'https://www.allsides.com/talks/feedback';
    }

    if (useConnectedAccount) {
      params['payment_intent_data[transfer_data][destination]'] =
          agreement!.stripeConnectedAccountId!;
      params['payment_intent_data[application_fee_amount]'] =
          (amountInCents * takeRate).floor().toString();
    }

    final jsonResponse =
        await stripeUtil.post(path: '/checkout/sessions', params: params);

    final String sessionId = jsonResponse['id'];
    return CreateDonationCheckoutSessionResponse(sessionId: sessionId).toJson();
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
