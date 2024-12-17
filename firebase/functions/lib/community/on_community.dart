import 'dart:async';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../firestore_event_function.dart';
import '../on_firestore_function.dart';
import 'package:data_models/community/community.dart';

import '../utils/firestore_utils.dart';

class OnCommunity extends OnFirestoreFunction<Community> {
  OnCommunity()
      : super(
          [
            AppFirestoreFunctionData(
              'CommunityOnCreate',
              FirestoreEventType.onCreate,
            ),
          ],
          (snapshot) {
            return Community.fromJson(
              firestoreUtils.fromFirestoreJson(snapshot.data.toMap()),
            ).copyWith(id: snapshot.documentID);
          },
        );

  @override
  String get documentPath => 'community/{communityId}';

  @override
  Future<void> onUpdate(
    Change<DocumentSnapshot> changes,
    Community before,
    Community after,
    DateTime updateTime,
    EventContext context,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<void> onCreate(
    DocumentSnapshot documentSnapshot,
    Community parsedData,
    DateTime updateTime,
    EventContext context,
  ) async {
    print('Community (${documentSnapshot.documentID}) has been created');

    final updateMap = {
      Community.kFieldOnboardingSteps: [
        EnumToString.convertToString(OnboardingStep.brandSpace),
      ],
    };

    return documentSnapshot.reference.updateData(UpdateData.fromMap(updateMap));
  }

  @override
  Future<void> onDelete(
    DocumentSnapshot documentSnapshot,
    Community parsedData,
    DateTime updateTime,
    EventContext context,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<void> onWrite(
    Change<DocumentSnapshot> changes,
    Community before,
    Community after,
    DateTime updateTime,
    EventContext context,
  ) {
    throw UnimplementedError();
  }
}
