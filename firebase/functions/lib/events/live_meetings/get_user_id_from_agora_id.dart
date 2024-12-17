import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../../on_call_function.dart';
import '../../utils/firestore_utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/user/public_user_info.dart';

import '../../utils/utils.dart';

class GetUserIdFromAgoraId extends OnCallMethod<GetUserIdFromAgoraIdRequest> {
  GetUserIdFromAgoraId()
      : super(
          'GetUserIdFromAgoraId',
          (jsonMap) => GetUserIdFromAgoraIdRequest.fromJson(jsonMap),
        );

  @override
  Future<Map<String, dynamic>> action(
    GetUserIdFromAgoraIdRequest request,
    CallableContext context,
  ) async {
    orElseUnauthorized(context.authUid != null);

    final docs = await firestore
        .collection('publicUser')
        .where("agoraId", isEqualTo: request.agoraId)
        .get();

    final userDoc = docs.documents.firstOrNull;
    if (!(userDoc?.exists ?? false)) {
      throw HttpsError(
        HttpsError.notFound,
        'User with agora ID ${request.agoraId} not found',
        null,
      );
    }

    final userInfo = PublicUserInfo.fromJson(
      firestoreUtils.fromFirestoreJson(userDoc?.data.toMap() ?? {}),
    );

    return GetUserIdFromAgoraIdResponse(
      userId: userInfo.id,
    ).toJson();
  }
}
