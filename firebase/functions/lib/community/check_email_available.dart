import 'package:data_models/cloud_functions/requests.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:functions/on_call_function.dart';
import 'package:functions/utils/infra/firestore_utils.dart';
import 'package:functions/utils/infra/firebase_auth_utils.dart';

class _CheckEmailAvailableRequest implements SerializeableRequest {
  final String email;

  _CheckEmailAvailableRequest({required this.email});

  factory _CheckEmailAvailableRequest.fromJson(Map<String, dynamic> json) {
    return _CheckEmailAvailableRequest(email: (json['email'] ?? '').toString());
  }

  @override
  Map<String, dynamic> toJson() => {'email': email};
}

class CheckEmailAvailable extends OnCallMethod<_CheckEmailAvailableRequest> {
  static const callableName = 'checkEmailAvailable';

  CheckEmailAvailable()
      : super(
          callableName,
          (jsonMap) =>
              _CheckEmailAvailableRequest.fromJson(firestoreUtils.fromFirestoreJson(jsonMap)),
        );

  @override
  Future<dynamic> action(
    _CheckEmailAvailableRequest request,
    CallableContext context,
  ) async {
    final authUid = context.authUid;
    if (authUid == null) {
      throw HttpsError(HttpsError.failedPrecondition, 'unauthorized', null);
    }

    final normalizedEmail = request.email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      throw HttpsError(HttpsError.failedPrecondition, 'invalid-email', null);
    }

    final isAvailable = await firebaseAuthUtils.isEmailAvailableForUser(
      normalizedEmail,
      authUid,
    );

    return {'available': isAvailable};
  }
}
