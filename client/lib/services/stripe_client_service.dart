import 'package:universal_html/html.dart' as html;
import 'package:universal_html/js_util.dart' as js_util;

class StripeClientService {
  void redirectToCheckout({required String sessionId}) {
    final stripeObj = js_util.getProperty(html.window, 'stripe');
    js_util.callMethod(stripeObj, 'redirectToCheckout', [
      js_util.jsify({'sessionId': sessionId}),
    ]);
  }
}
