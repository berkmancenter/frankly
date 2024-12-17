import 'package:firebase_functions_interop/firebase_functions_interop.dart';

/// Parent class for various firebase functions with multiple types (on_request, on_database, etc). This does not get deployed as a standalone firebase function.
abstract class CloudFunction {
  String get functionName;

  void register(FirebaseFunctions functions);
}
