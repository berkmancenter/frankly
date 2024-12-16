import 'dart:async';
import 'dart:io';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/junto_cloud_function.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_models/firestore/junto.dart';

/// Generic logic for returning a calendar feed. Functions that implement this should expect the
/// space id to be present as the second request path parameter, as in '/space/[space_id]/xyz'.
abstract class AbstractCalendarFeed implements JuntoCloudFunction {
  Future<String> generateData({required Junto junto});
  ContentType getContentType();

  Future<void> expressAction(ExpressHttpRequest expressRequest) async {
    try {
      if (expressRequest.requestedUri.pathSegments.length != 3) {
        throw Exception("Bad path");
      }
      final juntoId = expressRequest.requestedUri.pathSegments[1];

      final juntoDocs = await firestore
          .collection('junto')
          .where(Junto.kFieldDisplayIds, arrayContains: juntoId)
          .get();
      if (juntoDocs.isEmpty) {
        expressRequest.response.statusCode = HttpStatus.notFound;
        return expressRequest.response.close();
      }
      final junto = Junto.fromJson(juntoDocs.documents.first.data.toMap());

      final data = await generateData(junto: junto);

      expressRequest.response.headers.contentType = getContentType();
      expressRequest.response.write(data);
    } catch (e, stacktrace) {
      print('Error during action');
      print(e);
      print(stacktrace);
      expressRequest.response.statusCode = HttpStatus.internalServerError;
    }
    await expressRequest.response.close();
  }

  @override
  void register(FirebaseFunctions functions) {
    functions[functionName] = functions.https.onRequest(expressAction);
  }
}
