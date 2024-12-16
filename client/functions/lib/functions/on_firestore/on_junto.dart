import 'dart:async';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/firestore_event_function.dart';
import 'package:junto_functions/functions/on_firestore_function.dart';
import 'package:junto_models/firestore/junto.dart';

import '../../utils/firestore_utils.dart';

class OnJunto extends OnFirestoreFunction<Junto> {
  OnJunto()
      : super(
          [AppFirestoreFunctionData('JuntoOnCreate', FirestoreEventType.onCreate)],
          (snapshot) {
            return Junto.fromJson(firestoreUtils.fromFirestoreJson(snapshot.data.toMap())).copyWith(id: snapshot.documentID);
          },
        );

  @override
  String get documentPath => 'junto/{juntoId}';

  @override
  Future<void> onUpdate(
    Change<DocumentSnapshot> changes,
    Junto before,
    Junto after,
    DateTime updateTime,
    EventContext context,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<void> onCreate(
    DocumentSnapshot documentSnapshot,
    Junto parsedData,
    DateTime updateTime,
    EventContext context,
  ) async {
    print('Junto (${documentSnapshot.documentID}) has been created');

    final updateMap = {
      Junto.kFieldOnboardingSteps: [EnumToString.convertToString(OnboardingStep.brandSpace)]
    };

    return documentSnapshot.reference.updateData(UpdateData.fromMap(updateMap));
  }

  @override
  Future<void> onDelete(
    DocumentSnapshot documentSnapshot,
    Junto parsedData,
    DateTime updateTime,
    EventContext context,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<void> onWrite(
    Change<DocumentSnapshot> changes,
    Junto before,
    Junto after,
    DateTime updateTime,
    EventContext context,
  ) {
    throw UnimplementedError();
  }
}
