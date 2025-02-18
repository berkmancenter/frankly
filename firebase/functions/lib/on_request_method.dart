import 'dart:async';
import 'dart:convert';

import 'package:firebase_functions_interop/firebase_functions_interop.dart'
    hide CloudFunction;
import 'cloud_function.dart';
import 'utils/infra/scheduled_functions.dart';
import 'package:data_models/cloud_functions/requests.dart';

/// Class for onRequest methods. These are HTTP requests that are mostly called
/// from the Cloud Function scheduler.
///
/// Request types should be defined in the data_models floder.
abstract class OnRequestMethod<T extends SerializeableRequest>
    implements CloudFunction {
  @override
  final String functionName;

  /// Function that converts request JSON into a request object.
  T Function(dynamic body) requestFromBody;

  final RuntimeOptions? runWithOptions;

  OnRequestMethod(
    this.functionName,
    this.requestFromBody, {
    this.runWithOptions,
  });

  Future<void> handleRequest(ExpressHttpRequest expressRequest) async {
    final request = requestFromBody(expressRequest.body);

    // Print request for debug purposes
    print(request);

    final response = await action(request);
    expressRequest.response.write(response);
  }

  Future<String> action(T request);

  Future<void> expressAction(ExpressHttpRequest expressRequest) async {
    expressRequest.response.headers.set('Access-Control-Allow-Origin', '*');
    expressRequest.response.headers
        .set('Access-Control-Allow-Credentials', 'true');

    if (expressRequest.method == 'OPTIONS') {
      // Send response to OPTIONS requests
      expressRequest.response.headers
          .set('Access-Control-Allow-Methods', 'GET');
      expressRequest.response.headers
          .set('Access-Control-Allow-Headers', 'Content-Type');
      expressRequest.response.headers.set('Access-Control-Max-Age', '3600');
      expressRequest.response.statusCode = 204;
      await expressRequest.response.close();
      return;
    }

    print(expressRequest.body);
    try {
      await handleRequest(expressRequest);
    } catch (e, stacktrace) {
      print('Error during action');
      print(e);
      print(stacktrace);
      expressRequest.response.addError(e, stacktrace);
    }

    await expressRequest.response.close();
  }

  Future<void> schedule(T request, DateTime scheduledTime) {
    print('Scheduling $functionName call for $scheduledTime');
    return scheduledFunctions.enqueueCall(
      functionName,
      jsonEncode(request.toJson()),
      scheduledTime,
    );
  }

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
