import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../on_call_function.dart';
import 'package:data_models/cloud_functions/requests.dart';

class GetServerTimestamp extends OnCallMethod<GetServerTimestampRequest> {
  GetServerTimestamp()
      : super(
          GetServerTimestampRequest.functionName,
          (jsonMap) => GetServerTimestampRequest.fromJson(jsonMap),
        );

  @override
  Future<Map<String, dynamic>> action(
    GetServerTimestampRequest request,
    CallableContext context,
  ) async {
    final result =
        GetServerTimestampResponse(serverTimestamp: DateTime.now().toUtc())
            .toJson();
    print(result);
    return result;
  }

  @override
  void register(FirebaseFunctions functions) {
    functions[functionName] = functions
        .runWith(
          runWithOptions ??
              RuntimeOptions(
                timeoutSeconds: 60,
                memory: '1GB',
                minInstances: 1,
              ),
        )
        .https
        .onCall(callAction);
  }
}
