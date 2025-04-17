import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../on_call_function.dart';
import 'package:data_models/cloud_functions/requests.dart';

class Body extends SerializeableRequest {
  final dynamic body;

  Body(this.body);

  @override
  String toString() => body.toString();
}

class ServerTimestamp extends OnCallMethod<Body> {
  ServerTimestamp() : super('serverTimestamp', (body) => Body(body));

  @override
  Future<Map<String, String>> action(
    Body request,
    CallableContext context,
  ) async {
    return <String, String>{
      'date': DateTime.now().toUtc().toIso8601String(),
    };
  }
}
