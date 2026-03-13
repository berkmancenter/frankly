import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:data_models/utils/utils_web.dart';

/// Singleton firebase app that is set by main().
///
/// We usually use getit, but it was failing due to null safety issues.
late App Function() _firebaseAppFactory;
App? _firebaseAppSingleton;

void setFirebaseAppFactory(App Function() factory) {
  _firebaseAppFactory = factory;
}

App get firebaseApp => _firebaseAppSingleton ??= _firebaseAppFactory();
Firestore get firestore => firebaseApp.firestore();

/// Use a global singleton to allow mocking in tests
FirestoreUtils firestoreUtils = FirestoreUtils();

class FirestoreUtils {
  Future<T> getFirestoreObject<T>({
    required String path,
    required T Function(Map<String, dynamic>) constructor,
    Transaction? transaction,
  }) async {
    final ref = firestore.document(path);
    final snapshot =
        transaction == null ? await ref.get() : await transaction.get(ref);
    return constructor(fromFirestoreJson(snapshot.data.toMap()));
  }

  Map<String, dynamic> fromFirestoreJson(Map<String, dynamic> json) {
    var formattedJson = <String, dynamic>{};

    json.forEach((key, value) {
      if (value is Timestamp) {
        formattedJson[key] = value.toDateTime();
      } else if (value is Map) {
        formattedJson[key] = fromFirestoreJson(value as Map<String, dynamic>);
      } else if (value is List) {
        formattedJson[key] = value.map((v) {
          if (v is Map) {
            return fromFirestoreJson(v as Map<String, dynamic>);
          } else {
            return v;
          }
        }).toList();
      } else {
        formattedJson[key] = value;
      }
    });

    return formattedJson;
  }

  Map<String, dynamic> toFirestoreJson(Map<String, dynamic> json) {
    var formattedJson = <String, dynamic>{};

    json.forEach((key, value) {
      if (value == serverTimestampValue) {
        formattedJson[key] = Firestore.fieldValues.serverTimestamp();
      }
      // Check if the value is a DateTime object
      else if (value is DateTime) {
        formattedJson[key] = Timestamp.fromDateTime(value);
      } else if (value is Map) {
        formattedJson[key] = toFirestoreJson(value as Map<String, dynamic>);
      } else if (value is List) {
        formattedJson[key] = value.map((v) {
          if (v is Map) {
            return toFirestoreJson(v as Map<String, dynamic>);
          } else {
            return v;
          }
        }).toList();
      } else {
        formattedJson[key] = value;
      }
    });

    return formattedJson;
  }
}

extension DocumentQueryExtended on DocumentQuery {
  DocumentQuery whereNotEqual(String field, {String? notEqualTo}) {
    // ignore: invalid_use_of_protected_member
    final query = nativeInstance.where(field, '!=', notEqualTo);
    return DocumentQuery(query, firestore);
  }
}
