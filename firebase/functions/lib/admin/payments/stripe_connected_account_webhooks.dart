import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'abstract_stripe_webhooks.dart';
import '../../utils/utils.dart';

class StripeConnectedAccountWebhooks extends AbstractStripeWebhooks {
  StripeConnectedAccountWebhooks() : super('StripeConnectedAccountWebhooks');

  @override
  String getKey() {
    return functions.config.get('stripe.connected_account_webhook_key')
        as String;
  }

  @override
  Future<String> action(JsonMap request) async {
    final type = request.json['type'];
    if (type == 'account.updated') {
      await handleAccountUpdated(request);
    } else {
      print('Unknown Stripe event type: ${request.json['type']}');
    }
    return Future.value('');
  }
}
