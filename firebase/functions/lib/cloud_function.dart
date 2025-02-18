import 'package:firebase_functions_interop/firebase_functions_interop.dart';

/// Parent class for various Cloud Functions with multiple types
/// (on_request, on_firestore, and on_call).
///
/// This does not get deployed as a standalone Cloud Function.
abstract class CloudFunction {
  String get functionName;

  void register(FirebaseFunctions functions);
}
