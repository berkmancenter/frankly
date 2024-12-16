import 'dart:async';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/firestore_event_function.dart';
import 'package:junto_functions/functions/firestore_helper.dart';
import 'package:junto_functions/functions/on_firestore_function.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/membership.dart';

class OnJuntoMembership extends OnFirestoreFunction<Membership> {
  OnJuntoMembership()
      : super(
          [
            AppFirestoreFunctionData('JuntoMembershipOnCreate', FirestoreEventType.onCreate),
          ],
          (snapshot) {
            return Membership.fromJson(firestoreUtils.fromFirestoreJson(snapshot.data.toMap()));
          },
        );

  @override
  String get documentPath => 'memberships/{membershipId}/junto-membership/{juntoMembershipId}';

  @override
  Future<void> onUpdate(
    Change<DocumentSnapshot> changes,
    Membership before,
    Membership after,
    DateTime updateTime,
    EventContext context,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<void> onCreate(
    DocumentSnapshot documentSnapshot,
    Membership parsedData,
    DateTime updateTime,
    EventContext context,
  ) async {
    print('Junto Membership (${documentSnapshot.documentID}) has been created');

    await updateOnboardingSteps(parsedData, documentSnapshot);
  }

  @override
  Future<void> onDelete(
    DocumentSnapshot documentSnapshot,
    Membership parsedData,
    DateTime updateTime,
    EventContext context,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<void> onWrite(
    Change<DocumentSnapshot> changes,
    Membership before,
    Membership after,
    DateTime updateTime,
    EventContext context,
  ) {
    throw UnimplementedError();
  }

  Future<void> updateOnboardingSteps(
    Membership membership,
    DocumentSnapshot originalDocumentSnapshot,
  ) async {
    final juntoId = membership.juntoId;
    const onboardingStep = OnboardingStep.inviteSomeone;
    final juntoDoc = firestoreHelper.getPathToJuntoDocument(juntoId: juntoId);
    final juntoSnap = await firestore.document(juntoDoc).get();
    if (!juntoSnap.exists) {
      print('Junto ($juntoId) does not exist');
      return;
    }

    if (!juntoSnap.data.has(Junto.kFieldOnboardingSteps)) {
      print('Junto ($juntoId) has no field ${Junto.kFieldOnboardingSteps}');
      return;
    }
    final List<dynamic> onboardingSteps = juntoSnap.data.toMap()[Junto.kFieldOnboardingSteps];
    final stringOnboardingStep = EnumToString.convertToString(onboardingStep);

    if (onboardingSteps.any((element) => element == stringOnboardingStep)) {
      print('$onboardingStep is already in Junto ($juntoId) ${Junto.kFieldOnboardingSteps}');
      return;
    }

    final juntoMemberships = await firestore
        .collectionGroup(FirestoreHelper.kJuntoMemberships)
        .where(Membership.kFieldJuntoId, isEqualTo: juntoId)
        .get();
    final amIInJunto = juntoMemberships.documents.any((documentSnapshot) =>
        documentSnapshot.data.getString(Membership.kFieldUserId) == membership.userId);
    if (!amIInJunto) {
      print('User (${membership.userId}) is not in junto ($juntoId). Something is wrong');
      return;
    }

    if (!juntoSnap.data.has(Junto.kFieldCreatorId)) {
      print('Junto ($juntoId) has no field ${Junto.kFieldCreatorId}');
      return;
    }
    final juntoCreatorId = juntoSnap.data.getString(Junto.kFieldCreatorId);
    if (juntoCreatorId == membership.userId) {
      print('User (${membership.userId}) is a creator of the Junto ($juntoId)');
      return;
    }

    // Update Junto with new step
    final updateMap = {
      Junto.kFieldOnboardingSteps: [...onboardingSteps, stringOnboardingStep]
    };

    await juntoSnap.reference.updateData(UpdateData.fromMap(updateMap));

    print('$onboardingStep has been added to Junto ($juntoId) ${Junto.kFieldOnboardingSteps}');
  }
}
