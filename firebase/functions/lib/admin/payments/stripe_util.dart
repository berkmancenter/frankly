import 'dart:convert';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'stripe_client.dart';
import '../../utils/firestore_utils.dart';
import 'package:node_http/node_http.dart' as http;

final stripeUtil = StripeUtil();

class StripeUtil {
  StripeClient? _client;

  String get _secretKey => functions.config.get('stripe.secret_key') as String;

  StripeClient getClient() => _client ??= createStripeClient(_secretKey);

  Future<String> getOrCreateCustomerStripeId({required String uid}) async {
    final users = await firestoreUtils.getUsers([uid]);
    if (users.length != 1) {
      throw Exception('User not found');
    }
    final user = users[0];

    final stripeUserDataDoc = firestore.document('stripeUserData/${user.uid}');

    final stripeUserData = await stripeUserDataDoc.get();

    // find existing stripe id
    if (stripeUserData.exists) {
      if (stripeUserData.data.has('stripeId')) {
        return stripeUserData.data.getString('stripeId');
      }
    }

    // not found; create new stripe id
    final Map<String, String> params = {
      'email': user.email,
      'metadata[uid]': user.uid,
    };

    final jsonResponse = await post(path: '/customers', params: params);
    final String stripeId = jsonResponse['id'];
    await stripeUserDataDoc.setData(
      DocumentData.fromMap({'stripeId': stripeId}),
      SetOptions(merge: true),
    );

    return stripeId;
  }

  Future<Map<String, dynamic>> post({
    required String path,
    required Map<String, String> params,
    String? connectedAccount,
  }) async {
    final headers = {
      'Authorization': 'Bearer $_secretKey',
      if (connectedAccount != null) 'Stripe-Account': connectedAccount,
    };

    final response = await http.post(
      Uri.parse('https://api.stripe.com/v1$path'),
      headers: headers,
      body: params,
    );
    if (response.statusCode < 200 || response.statusCode > 299) {
      print('Stripe POST error:');
      print(response.body);
      throw HttpsError(HttpsError.internal, 'Internal error.', null);
    }

    return const JsonDecoder().convert(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> delete({
    required String path,
    String? connectedAccount,
  }) async {
    final headers = {
      'Authorization': 'Bearer $_secretKey',
      if (connectedAccount != null) 'Stripe-Account': connectedAccount,
    };

    final response = await http
        .delete(Uri.parse('https://api.stripe.com/v1$path'), headers: headers);
    if (response.statusCode < 200 || response.statusCode > 299) {
      print('Stripe POST error:');
      print(response.body);
      throw HttpsError(HttpsError.internal, 'Internal error.', null);
    }

    return const JsonDecoder().convert(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> get({
    required String path,
    String? connectedAccount,
  }) async {
    final headers = {'Authorization': 'Bearer $_secretKey'};
    if (connectedAccount != null) {
      headers['Stripe-Account'] = connectedAccount;
    }

    final response = await http.get(
      Uri.parse('https://api.stripe.com/v1$path'),
      headers: headers,
    );
    if (response.statusCode < 200 || response.statusCode > 299) {
      print('Stripe GET error:');
      print(response.body);
      throw HttpsError(HttpsError.internal, 'Internal error.', null);
    }

    return const JsonDecoder().convert(response.body) as Map<String, dynamic>;
  }
}
