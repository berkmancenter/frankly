import 'dart:convert';
import 'dart:math';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../../on_request_method.dart';
import 'stripe_client.dart';
import 'analytics_util.dart';
import '../../utils/firestore_utils.dart';
import 'stripe_util.dart';
import '../../utils/utils.dart';
import 'package:data_models/analytics/analytics_entities.dart';
import 'package:data_models/admin/billing_subscription.dart';
import 'package:data_models/admin/partner_agreement.dart';
import 'package:data_models/admin/payment_record.dart';
import 'package:data_models/utils/utils.dart';
import 'package:node_interop/util.dart';

abstract class AbstractStripeWebhooks extends OnRequestMethod<JsonMap> {
  AbstractStripeWebhooks(String name)
      : super(name, (jsonMap) => JsonMap(jsonMap));

  String getKey();

  @override
  Future<void> handleRequest(ExpressHttpRequest expressRequest) async {
    final webhookKey = getKey();
    final StripeClient stripe = stripeUtil.getClient();
    final String sig = expressRequest.headers['stripe-signature']!.join(',');

    final bodyBytes = getProperty(expressRequest.nativeInstance, 'rawBody');
    final body = utf8.decoder.convert(bodyBytes);
    final Map<String, dynamic> event =
        dartify(stripe.webhooks.constructEvent(body, sig, webhookKey));

    final response = await action(requestFromBody(event));
    expressRequest.response.write(response);
  }

  /// We received a payment
  Future<void> handlePaymentIntentSucceeded(JsonMap request) async {
    final object = request.json['data']['object'];
    final String paymentIntentId = object['id'];
    final int amountInCents = object['amount_received'];
    final int createdInt = object['created'];
    final DateTime createdDate =
        DateTime.fromMillisecondsSinceEpoch(createdInt * 1000);
    final metadata = object['metadata'];
    if (metadata['type'] == 'one_time_donation') {
      final String communityId = object['metadata']['communityId'];
      final String authUid = object['metadata']['authUid'];

      final paymentRef = firestore
          .collection('stripeUserData/$authUid/payments')
          .document(paymentIntentId);

      final paymentRecord = PaymentRecord(
        id: paymentIntentId,
        authUid: authUid,
        communityId: communityId,
        amountInCents: amountInCents,
        createdDate: createdDate,
        type: PaymentType.oneTimeDonation,
      );

      await paymentRef.setData(
        DocumentData.fromMap(
          firestoreUtils.toFirestoreJson(paymentRecord.toJson()),
        ),
      );

      analyticsUtil.logEvent(
        userId: authUid,
        event: AnalyticsDonateEvent(
          communityId: communityId,
          amount: amountInCents / 100.0,
        ),
      );
    } else {
      print('Unknown or empty payment type: ${metadata['type'] ?? '(empty)'}');
    }
  }

  /// Stripe initiated a transfer to a payment recipient (e.g. donation to a community, by way of us)
  Future<void> handleTransferCreated(JsonMap request) async {
    final object = request.json['data']['object'];

    final sourceTxId = object['source_transaction'];
    final paymentId = object['destination_payment'];
    final destinationId = object['destination'];

    if (paymentId != null && sourceTxId != null && destinationId != null) {
      final sourceTx = await stripeUtil.get(path: '/charges/$sourceTxId');

      final metadata = sourceTx['metadata'];
      if (metadata != null) {
        // Write additional metadata so that recipients can see payers' names and email addresses

        final type = metadata['type']?.toString();
        final name = metadata['name']?.toString();
        final email = metadata['email']?.toString();

        await stripeUtil.post(
          path: '/charges/$paymentId',
          params: {
            'metadata[type]': type!,
            'metadata[name]': name!,
            'metadata[email]': email!,
          },
          connectedAccount: destinationId,
        );
      }
    }
  }

  /// Subscription was updated (e.g. new subscription, upgrade, etc.)
  Future<void> handleSubscriptionModified(JsonMap request) async {
    final stripeSubscription = request.json['data']['object'];
    await _updateSubscriptionData(stripeSubscription);
  }

  /// Customer paid an invoice (includes subscription billing invoices)
  Future<void> handleInvoicePaid(JsonMap request) async {
    final object = request.json['data']['object'];

    // loop through each subscription item and process separately
    final List<dynamic> lines = object['lines']['data'];
    final subscriptionLines =
        lines.where((line) => line['subscription'] != null);
    for (final line in subscriptionLines) {
      final String subscriptionId = line['subscription'];
      final subscription =
          await stripeUtil.get(path: '/subscriptions/$subscriptionId');
      await _updateSubscriptionData(subscription);
    }
  }

  /// Stripe account data has changed. Used also by StripeConnectedAccountWebhooks
  Future<void> handleAccountUpdated(JsonMap request) async {
    final object = request.json['data']['object'];
    final capabilities = object['capabilities'];

    // Account is active (can receive funds) if the 'transfers' capability is active
    final hasTransfers = capabilities['transfers'] == 'active';

    final agreementSnapshots = await firestore
        .collection('partner-agreements')
        .where(
          PartnerAgreement.kFieldStripeConnectedAccountId,
          isEqualTo: object['id'],
        )
        .get();

    for (final agreementDoc in agreementSnapshots.documents) {
      final agreement = PartnerAgreement.fromJson(agreementDoc.data.toMap());
      if (agreement.stripeConnectedAccountActive != hasTransfers) {
        final updated =
            agreement.copyWith(stripeConnectedAccountActive: hasTransfers);
        await agreementDoc.reference.updateData(
          UpdateData.fromMap(
            jsonSubset(
              [PartnerAgreement.kFieldStripeConnectedAccountActive],
              firestoreUtils.toFirestoreJson(updated.toJson()),
            ),
          ),
        );
      }
    }
  }

  /// Update subscription in Firestore
  Future<void> _updateSubscriptionData(Map stripeSubscription) async {
    // Don't update if it's a subscription that hasn't been started yet
    if (['incomplete', 'incomplete_expired']
        .contains(stripeSubscription['status'])) {
      return;
    }

    String stripeSubscriptionId = stripeSubscription['id'];
    String stripeCustomerId = stripeSubscription['customer'];
    final stripeCustomer =
        await stripeUtil.get(path: '/customers/$stripeCustomerId');
    String? userId = stripeCustomer['metadata']['uid'];

    // `current_period_end` is the time when the subscription should expire, unless it is renewed
    int currentPeriodEnd = stripeSubscription['current_period_end'];
    int? cancelTime = stripeSubscription['ended_at'];
    int periodEnd = cancelTime != null
        ? min(currentPeriodEnd, cancelTime)
        : currentPeriodEnd;
    final periodEndDateTime =
        DateTime.fromMicrosecondsSinceEpoch(periodEnd * 1000000);

    // Get product object so we know what kind of subscription this is
    final String stripeProductId = stripeSubscription['plan']['product'];
    final stripeProduct =
        await stripeUtil.get(path: '/products/$stripeProductId');
    final metadata = stripeProduct['metadata'];
    final String? type = metadata['plan_type'];

    // Warn and return on missing metadata
    if (userId == null) {
      print(
        '\'uid\' not set on Stripe customer \'$stripeCustomerId\'. Ignoring.',
      );
      return;
    } else if (type == null) {
      print(
        '\'plan_type\' not set on Stripe subscription product \'$stripeProductId\'. Ignoring.',
      );
      return;
    }

    // Store needed info in firestore
    final firestoreSubscriptionRef = firestore
        .document('stripeUserData/$userId/subscriptions/$stripeSubscriptionId');
    final appliedCommunityId =
        stripeSubscription['metadata']['appliedCommunityId'] as String?;
    final subscription = BillingSubscription(
      stripeSubscriptionId: stripeSubscriptionId,
      type: type,
      activeUntil: periodEndDateTime,
      appliedCommunityId: appliedCommunityId,
      canceled: (stripeSubscription['status'] == 'canceled'),
      willCancelAtPeriodEnd: stripeSubscription['cancel_at_period_end'],
    );
    await firestoreSubscriptionRef.setData(
      DocumentData.fromMap(
        jsonSubset(
          [
            BillingSubscription.kFieldStripeSubscriptionId,
            BillingSubscription.kFieldType,
            BillingSubscription.kFieldActiveUntil,
            BillingSubscription.kFieldAppliedCommunityId,
            BillingSubscription.kFieldCanceled,
            BillingSubscription.kFieldWillCancelAtPeriodEnd,
          ],
          firestoreUtils.toFirestoreJson(subscription.toJson()),
        ),
      ),
      SetOptions(merge: true),
    );

    analyticsUtil.logEvent(
      userId: userId,
      event: AnalyticsUpdateCommunitySubscriptionEvent(
        communityId: appliedCommunityId,
        planType: type,
        subscriptionId: stripeSubscriptionId,
        isCanceled: cancelTime != null,
      ),
    );
  }

  // Set minimum instances to 0
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
        .onRequest(expressAction);
  }
}
