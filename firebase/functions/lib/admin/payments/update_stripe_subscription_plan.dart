import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../../on_call_function.dart';
import '../../utils/firestore_utils.dart';
import 'stripe_util.dart';
import '../../utils/utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/firestore/billing_subscription.dart';

/// Update a subscription for a community to a new plan type (by way of a given Stripe price
/// identifier)
class UpdateStripeSubscriptionPlan
    extends OnCallMethod<UpdateStripeSubscriptionPlanRequest> {
  UpdateStripeSubscriptionPlan()
      : super(
          'UpdateStripeSubscriptionPlan',
          (jsonMap) => UpdateStripeSubscriptionPlanRequest.fromJson(jsonMap),
        );

  @override
  Future<void> action(
    UpdateStripeSubscriptionPlanRequest request,
    CallableContext context,
  ) async {
    orElseUnauthorized(context.authUid != null);

    // Effectively authorize user by looking for subscriptions only within their subscriptions
    // collection in stripeUserData.
    final subscriptionSnapshot = await firestore
        .collection('/stripeUserData/${context.authUid}/subscriptions')
        .where(BillingSubscription.kFieldCanceled, isEqualTo: false)
        .where(
          BillingSubscription.kFieldAppliedCommunityId,
          isEqualTo: request.communityId,
        )
        .get();
    orElseUnauthorized(
      subscriptionSnapshot.isNotEmpty,
      logMessage:
          'Resumable subscription not found for this community and billing manager',
    );
    final subscription = BillingSubscription.fromJson(
      subscriptionSnapshot.documents[0].data.toMap(),
    );

    final stripeSubscription = await stripeUtil.get(
      path: '/subscriptions/${subscription.stripeSubscriptionId}',
    );

    final List<dynamic> items = stripeSubscription['items']['data'];
    orElseUnauthorized(
      items.isNotEmpty,
      logMessage:
          'Subscription not found in Stripe: ${subscription.stripeSubscriptionId}',
    );

    final Map<String, String> params = {
      'cancel_at_period_end': 'false',
      'billing_cycle_anchor': 'now',
      'proration_behavior': 'create_prorations',
      'items[0][id]': stripeSubscription['items']['data'][0]['id'],
      'items[0][price]': request.stripePriceId,
    };

    await stripeUtil.post(
      path: '/subscriptions/${subscription.stripeSubscriptionId}',
      params: params,
    );
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
