@JS()
library stripe;

import 'package:js/js.dart';
import 'package:node_interop/node.dart';
import 'package:node_interop/util.dart';

StripeClient createStripeClient(String privateKey) {
  return callConstructor(require('stripe'), [privateKey]) as StripeClient;
}

@JS()
@anonymous
abstract class StripeClient {
  external Webhooks get webhooks;
}

@JS()
@anonymous
abstract class Webhooks {
  external dynamic constructEvent(
      String body, String signature, String endpointSecret);
}
