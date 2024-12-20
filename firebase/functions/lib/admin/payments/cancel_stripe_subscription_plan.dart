import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../../on_call_function.dart';
import '../../utils/firestore_utils.dart';
import 'stripe_util.dart';
import '../../utils/utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/firestore/billing_subscription.dart';

/// Cancel a Stripe subscription. Ends benefits and refunds prorated balance immediately
class CancelStripeSubscriptionPlan
    extends OnCallMethod<CancelStripeSubscriptionPlanRequest> {
  CancelStripeSubscriptionPlan()
      : super(
          'CancelStripeSubscriptionPlan',
          (jsonMap) => CancelStripeSubscriptionPlanRequest.fromJson(jsonMap),
        );

  @override
  Future<void> action(
    CancelStripeSubscriptionPlanRequest request,
    CallableContext context,
  ) async {
    orElseUnauthorized(context.authUid != null);

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

    await stripeUtil.delete(
      path:
          '/subscriptions/${subscription.stripeSubscriptionId}?invoice_now=true&prorate=true',
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
