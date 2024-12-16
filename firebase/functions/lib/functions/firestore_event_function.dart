import 'package:firebase_functions_interop/firebase_functions_interop.dart';

/**
 * Helper classes and an enum for functions in the '/on_firestore' directory. This does not get deployed as a standalone firebase function.
 */

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
