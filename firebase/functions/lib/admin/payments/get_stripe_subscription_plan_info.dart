import 'dart:async';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../../on_call_function.dart';
import 'stripe_util.dart';
import '../../utils/utils.dart';
import 'package:data_models/cloud_functions/requests.dart';

/// Get metadata (including price) for a Stripe subscription plan given its plan type code
class GetStripeSubscriptionPlanInfo
    extends OnCallMethod<GetStripeSubscriptionPlanInfoRequest> {
  GetStripeSubscriptionPlanInfo()
      : super(
          'GetStripeSubscriptionPlanInfo',
          (json) => GetStripeSubscriptionPlanInfoRequest.fromJson(json),
        );

  @override
  Future<Map<String, dynamic>> action(
    GetStripeSubscriptionPlanInfoRequest request,
    CallableContext context,
  ) async {
    final productsJson = await stripeUtil.get(path: '/products?active=true');
    final products = List.from(productsJson['data']);
    final matchingProducts = products.where(
      (product) =>
          product['metadata']['plan_type'] ==
          EnumToString.convertToString(request.type),
    );
    orElseNotFound(
      matchingProducts.isNotEmpty,
      logMessage: 'Product not found in Stripe: ${request.type}',
    );
    final product = matchingProducts.first;
    final name = product['name'];

    final pricesJson = await stripeUtil.get(
      path: '/prices?active=true&product=${product['id']}',
    );
    final prices = List.from(pricesJson['data']);
    orElseNotFound(
      prices.isNotEmpty,
      logMessage:
          'Pricing data not set in Stripe for product: ${product['id']}',
    );
    prices.sort((a, b) => a['unit_amount'].compareTo(b['unit_amount']));
    final priceInCents = prices[0]['unit_amount'];
    final stripePriceId = prices[0]['id'];

    return GetStripeSubscriptionPlanInfoResponse(
      plan: request.type,
      priceInCents: priceInCents,
      stripePriceId: stripePriceId,
      name: name,
    ).toJson();
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
