import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'abstract_stripe_webhooks.dart';
import '../../utils/utils.dart';

class StripeWebhooks extends AbstractStripeWebhooks {
  StripeWebhooks() : super('StripeWebhooks');

  @override
  String getKey() {
    return functions.config.get('stripe.webhook_key') as String;
  }

  @override
  Future<String> action(JsonMap request) async {
    final type = request.json['type'];
    if (type == 'payment_intent.succeeded') {
      await handlePaymentIntentSucceeded(request);
    } else if (type == 'transfer.created') {
      await handleTransferCreated(request);
    } else if (type == 'customer.subscription.created') {
      await handleSubscriptionModified(request);
    } else if (type == 'customer.subscription.updated') {
      await handleSubscriptionModified(request);
    } else if (type == 'customer.subscription.deleted') {
      await handleSubscriptionModified(request);
    } else if (type == 'invoice.paid') {
      await handleInvoicePaid(request);
    } else if (type == 'account.updated') {
      await handleAccountUpdated(request);
    } else {
      print('Unknown Stripe event type: ${request.json['type']}');
    }
    return Future.value('');
  }
}
