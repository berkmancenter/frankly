import 'dart:async';
import 'dart:io';

import 'package:firebase_functions_interop/firebase_functions_interop.dart'
    hide CloudFunction;
import '../../cloud_function.dart';
import '../../utils/infra/firestore_utils.dart';
import 'package:data_models/community/community.dart';

/// Generic logic for returning a calendar feed. Functions that implement this should expect the
/// space id to be present as the second request path parameter, as in '/space/[space_id]/xyz'.
abstract class AbstractCalendarFeed implements CloudFunction {
  Future<String> generateData({required Community community});
  ContentType getContentType();

  Future<void> expressAction(ExpressHttpRequest expressRequest) async {
    try {
      if (expressRequest.requestedUri.pathSegments.length != 3) {
        throw Exception("Bad path");
      }
      final communityId = expressRequest.requestedUri.pathSegments[1];

      final communityDocs = await firestore
          .collection('community')
          .where(Community.kFieldDisplayIds, arrayContains: communityId)
          .get();
      if (communityDocs.isEmpty) {
        expressRequest.response.statusCode = HttpStatus.notFound;
        return expressRequest.response.close();
      }
      final community =
          Community.fromJson(communityDocs.documents.first.data.toMap());

      final data = await generateData(community: community);

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
