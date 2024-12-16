import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/firestore_event_function.dart';
import 'package:junto_functions/functions/firestore_helper.dart';
import 'package:junto_functions/functions/on_firestore_function.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/topic.dart';

import '../../utils/topic_utils.dart';

class OnTopic extends OnFirestoreFunction<Topic> {
  OnTopic()
      : super(
          [
            AppFirestoreFunctionData('TopicOnCreate', FirestoreEventType.onCreate),
          ],
          (snapshot) {
            return TopicUtils.topicFromSnapshot(snapshot).copyWith(id: snapshot.documentID);
          },
        );

  @override
  String get documentPath => 'junto/{juntoId}/topics/{topicId}';

  @override
  Future<void> onUpdate(
    Change<DocumentSnapshot> changes,
    Topic before,
    Topic after,
    DateTime updateTime,
    EventContext context,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<void> onCreate(
    DocumentSnapshot documentSnapshot,
    Topic parsedData,
    DateTime updateTime,
    EventContext context,
  ) async {
    print('Topic (${documentSnapshot.documentID}) has been created');

    final juntoId = context.params[FirestoreHelper.kJuntoId];
    if (juntoId == null) {
      throw ArgumentError.notNull('juntoId');
    }

    await onboardingStepsHelper.updateOnboardingSteps(
      juntoId,
      documentSnapshot,
      firestoreHelper,
      OnboardingStep.createGuide,
    );
  }

  @override
  Future<void> onDelete(
    DocumentSnapshot documentSnapshot,
    Topic parsedData,
    DateTime updateTime,
    EventContext context,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<void> onWrite(
    Change<DocumentSnapshot> changes,
    Topic before,
    Topic after,
    DateTime updateTime,
    EventContext context,
  ) {
    throw UnimplementedError();
  }
}
