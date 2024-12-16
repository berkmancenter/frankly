import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/on_call_function.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_functions/utils/stripe_util.dart';
import 'package:junto_functions/utils/utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/billing_subscription.dart';
import 'package:junto_models/firestore/junto.dart';

/// Create a checkout session for the purchase of a given subscription type for a given community.
/// Returns a session id which should be handed off to Stripe client library which will handle the
/// redirects.
class CreateSubscriptionCheckoutSession
    extends OnCallMethod<CreateSubscriptionCheckoutSessionRequest> {
  CreateSubscriptionCheckoutSession()
      : super(
            'CreateSubscriptionCheckoutSession',
            (jsonMap) =>
                CreateSubscriptionCheckoutSessionRequest.fromJson(jsonMap));

  @override
  Future<Map<String, dynamic>> action(
      CreateSubscriptionCheckoutSessionRequest request,
      CallableContext context) async {
    orElseUnauthorized(context?.authUid != null);

    final prodDomain = functions.config.get('app.prod_domain') as String;
    final devDomain = functions.config.get('app.dev_domain') as String;
    final domain = isDev ? devDomain : prodDomain;

    // For now, only allow community creator to create a new subscription
    final juntoSnapshot =
        await firestore.document('junto/${request.appliedJuntoId}').get();
    orElseUnauthorized(juntoSnapshot.exists,
        logMessage: 'Community to which subscription would apply not found');
    final juntoCreatorId = Junto.fromJson(juntoSnapshot.data.toMap()).creatorId;
    orElseUnauthorized(juntoCreatorId == context?.authUid,
        logMessage: 'User is not billing manager');

    // Don't allow multiple subscriptions for the same user and community; should modify existing
    final subscriptionSnapshot = await firestore
        .collection('/stripeUserData/${context?.authUid}/subscriptions')
        .where(BillingSubscription.kFieldCanceled, isEqualTo: false)
        .where(BillingSubscription.kFieldAppliedJuntoId,
            isEqualTo: request.appliedJuntoId)
        .get();
    orElseUnauthorized(subscriptionSnapshot.isEmpty,
        logMessage:
            'Resumable subscription already found for this community and billing manager');

    final customerId =
        await stripeUtil.getOrCreateCustomerStripeId(uid: context!.authUid!);
    final priceId =
        await _getProductPrice(EnumToString.convertToString(request.type));

    final Map<String, String> params = {
      'success_url': 'https://$domain/${request.returnRedirectPath}',
      'cancel_url': 'https://$domain/${request.returnRedirectPath}',
      'payment_method_types[0]': 'card',
      'line_items[0][price]': priceId,
      'line_items[0][quantity]': '1',
      'mode': 'subscription',
      'customer': customerId,
      'subscription_data[metadata][appliedJuntoId]': request.appliedJuntoId,
    };

    final jsonResponse =
        await stripeUtil.post(path: '/checkout/sessions', params: params);

    final String sessionId = jsonResponse['id'];
    return CreateSubscriptionCheckoutSessionResponse(sessionId: sessionId)
        .toJson();
  }

  /// Given a plan type, return the id of the Stripe price object associated with it
  Future<String> _getProductPrice(String type) async {
    final productsResponse = await stripeUtil.get(path: '/products');
    final products = productsResponse["data"] as List;
    final product = products
        .where((product) => product["metadata"]["plan_type"] == type)
        .firstOrNull;
    orElseNotFound(product != null,
        logMessage: 'Stripe product not found for plan type: $type');
    final productId = product['id'];

    final pricesResponse =
        await stripeUtil.get(path: '/prices?active=true&product=$productId');
    final prices = pricesResponse["data"] as List;
    orElseNotFound(prices.isNotEmpty,
        logMessage: 'Stripe price not found for product: $productId');
    return prices[0]['id'];
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
