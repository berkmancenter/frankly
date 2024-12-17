import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart'
    show EventContext, Change, FirebaseFunctions, RuntimeOptions;
import 'firestore_event_function.dart';
import 'utils/firestore_helper.dart';
import 'utils/onboarding_steps_helper.dart';
import 'package:data_models/cloud_functions/requests.dart';

/// Parent class for functions in the '/on_firestore' directory. This does not get deployed as a standalone firebase function.
abstract class OnFirestoreFunction<T extends SerializeableRequest>
    implements FirestoreEventFunction {
  @override
  final List<AppFirestoreFunctionData> appFirestoreFunctionData;
  final T Function(DocumentSnapshot) documentFromJson;
  final FirestoreHelper firestoreHelper = FirestoreHelper();
  final OnboardingStepsHelper onboardingStepsHelper = OnboardingStepsHelper();

  OnFirestoreFunction(this.appFirestoreFunctionData, this.documentFromJson);

  String get documentPath;

  Future<void> onCreate(
    DocumentSnapshot documentSnapshot,
    T parsedData,
    DateTime updateTime,
    EventContext context,
  );

  Future<void> onUpdate(
    Change<DocumentSnapshot> changes,
    T before,
    T after,
    DateTime updateTime,
    EventContext context,
  );

  Future<void> onWrite(
    Change<DocumentSnapshot> changes,
    T before,
    T after,
    DateTime updateTime,
    EventContext context,
  );

  Future<void> onDelete(
    DocumentSnapshot documentSnapshot,
    T parsedData,
    DateTime updateTime,
    EventContext context,
  );

  FutureOr<void> firestoreOnCreate(
    String functionName,
    DocumentSnapshot data,
    EventContext context,
  ) async {
    try {
      final parsedData = documentFromJson(data);
      return await onCreate(
        data,
        parsedData,
        context.timestamp.toUtc(),
        context,
      );
    } catch (e, s) {
      print(
        'Error during action $functionName. \nException: $e, \nStackTrace: $s.',
      );
      rethrow;
    }
  }

  FutureOr<void> firestoreOnUpdate(
    String functionName,
    Change<DocumentSnapshot> changes,
    EventContext context,
  ) async {
    print('starting firestore action for update');
    try {
      final after = documentFromJson(changes.after);
      final before = documentFromJson(changes.before);

      return await onUpdate(
        changes,
        before,
        after,
        context.timestamp.toUtc(),
        context,
      );
    } catch (e, s) {
      print(
        'Error during action $functionName. \nException: $e, \nStackTrace: $s.',
      );
      rethrow;
    }
  }

  FutureOr<void> firestoreOnWrite(
    String functionName,
    Change<DocumentSnapshot> changes,
    EventContext context,
  ) async {
    print('starting firestore action for update');
    try {
      final after = documentFromJson(changes.after);
      final before = documentFromJson(changes.before);

      return await onUpdate(
        changes,
        before,
        after,
        context.timestamp.toUtc(),
        context,
      );
    } catch (e, s) {
      print(
        'Error during action $functionName. \nException: $e, \nStackTrace: $s.',
      );
      rethrow;
    }
  }

  FutureOr<void> firestoreOnDelete(
    String functionName,
    DocumentSnapshot data,
    EventContext context,
  ) async {
    try {
      final parsedData = documentFromJson(data);
      return await onDelete(
        data,
        parsedData,
        context.timestamp.toUtc(),
        context,
      );
    } catch (e, s) {
      print(
        'Error during action $functionName. \nException: $e, \nStackTrace: $s.',
      );
      rethrow;
    }
  }

  @override
  void register(FirebaseFunctions functions) {
    for (var data in appFirestoreFunctionData) {
      final functionName = data.functionName;
      final eventType = data.firestoreEventType;

      switch (eventType) {
        case FirestoreEventType.onCreate:
          functions[functionName] = functions
              .runWith(
                RuntimeOptions(
                  timeoutSeconds: 60,
                  memory: '1GB',
                  minInstances: int.parse(
                    functions.config
                        .get('functions.on_firestore.min_instances'),
                  ),
                ),
              )
              .firestore
              .document(documentPath)
              .onCreate(
                (data, context) =>
                    firestoreOnCreate(functionName, data, context),
              );
          break;
        case FirestoreEventType.onUpdate:
          functions[functionName] = functions
              .runWith(
                RuntimeOptions(
                  timeoutSeconds: 60,
                  memory: '1GB',
                  minInstances: int.parse(
                    functions.config
                        .get('functions.on_firestore.min_instances'),
                  ),
                ),
              )
              .firestore
              .document(documentPath)
              .onUpdate(
                (changes, context) =>
                    firestoreOnUpdate(functionName, changes, context),
              );
          break;
        case FirestoreEventType.onWrite:
          functions[functionName] = functions
              .runWith(
                RuntimeOptions(
                  timeoutSeconds: 60,
                  memory: '1GB',
                  minInstances: int.parse(
                    functions.config
                        .get('functions.on_firestore.min_instances'),
                  ),
                ),
              )
              .firestore
              .document(documentPath)
              .onWrite(
                (changes, context) =>
                    firestoreOnWrite(functionName, changes, context),
              );
          break;
        case FirestoreEventType.onDelete:
          functions[functionName] = functions
              .runWith(
                RuntimeOptions(
                  timeoutSeconds: 60,
                  memory: '1GB',
                  minInstances: int.parse(
                    functions.config
                        .get('functions.on_firestore.min_instances'),
                  ),
                ),
              )
              .firestore
              .document(documentPath)
              .onDelete(
                (data, context) =>
                    firestoreOnDelete(functionName, data, context),
              );
          break;
      }
    }
  }
}
