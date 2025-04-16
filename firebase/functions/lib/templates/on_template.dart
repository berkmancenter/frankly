import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../utils/infra/firestore_event_function.dart';
import '../utils/infra/on_firestore_helper.dart';
import '../on_firestore_function.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/templates/template.dart';

import '../utils/template_utils.dart';

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
