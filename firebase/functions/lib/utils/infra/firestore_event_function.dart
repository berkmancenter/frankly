import 'package:firebase_functions_interop/firebase_functions_interop.dart';

/// Helper classes and an enum for on_firestore triggered functions.
/// This does not get deployed as a standalone Cloud Function.

enum FirestoreEventType {
  onCreate,
  onUpdate,
  onWrite,
  onDelete,
}

class AppFirestoreFunctionData {
  final String functionName;
  final FirestoreEventType firestoreEventType;

  AppFirestoreFunctionData(this.functionName, this.firestoreEventType);
}

abstract class FirestoreEventFunction {
  List<AppFirestoreFunctionData> get appFirestoreFunctionData;

  void register(FirebaseFunctions functions);
}
