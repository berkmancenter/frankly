import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:functions/functions/firestore_event_function.dart';
import 'package:functions/functions/firestore_helper.dart';
import 'package:functions/functions/on_firestore_function.dart';
import 'package:data_models/firestore/community.dart';
import 'package:data_models/firestore/template.dart';

import 'package:functions/utils/template_utils.dart';

class OnTemplate extends OnFirestoreFunction<Template> {
  OnTemplate()
      : super(
          [
            AppFirestoreFunctionData(
              'TemplateOnCreate',
              FirestoreEventType.onCreate,
            ),
          ],
          (snapshot) {
            return TemplateUtils.templateFromSnapshot(snapshot)
                .copyWith(id: snapshot.documentID);
          },
        );

  @override
  String get documentPath => 'community/{communityId}/templates/{templateId}';

  @override
  Future<void> onUpdate(
    Change<DocumentSnapshot> changes,
    Template before,
    Template after,
    DateTime updateTime,
    EventContext context,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<void> onCreate(
    DocumentSnapshot documentSnapshot,
    Template parsedData,
    DateTime updateTime,
    EventContext context,
  ) async {
    print('Template (${documentSnapshot.documentID}) has been created');

    final communityId = context.params[FirestoreHelper.kCommunityId];
    if (communityId == null) {
      throw ArgumentError.notNull('communityId');
    }

    await onboardingStepsHelper.updateOnboardingSteps(
      communityId,
      documentSnapshot,
      firestoreHelper,
      OnboardingStep.createGuide,
    );
  }

  @override
  Future<void> onDelete(
    DocumentSnapshot documentSnapshot,
    Template parsedData,
    DateTime updateTime,
    EventContext context,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<void> onWrite(
    Change<DocumentSnapshot> changes,
    Template before,
    Template after,
    DateTime updateTime,
    EventContext context,
  ) {
    throw UnimplementedError();
  }
}
