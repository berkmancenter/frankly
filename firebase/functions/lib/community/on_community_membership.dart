import 'dart:async';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../utils/infra/firestore_event_function.dart';
import '../utils/infra/on_firestore_helper.dart';
import '../on_firestore_function.dart';
import '../utils/infra/firestore_utils.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/community/membership.dart';

class OnCommunityMembership extends OnFirestoreFunction<Membership> {
  OnCommunityMembership()
      : super(
          [
            AppFirestoreFunctionData(
              'CommunityMembershipOnCreate',
              FirestoreEventType.onCreate,
            ),
          ],
          (snapshot) {
            return Membership.fromJson(
              firestoreUtils.fromFirestoreJson(snapshot.data.toMap()),
            );
          },
        );

  @override
  String get documentPath =>
      'memberships/{membershipId}/community-membership/{communityMembershipId}';

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
    print(
      'Community Membership (${documentSnapshot.documentID}) has been created',
    );

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
    final communityId = membership.communityId;
    const onboardingStep = OnboardingStep.inviteSomeone;
    final communityDoc =
        firestoreHelper.getPathToCommunityDocument(communityId: communityId);
    final communitySnap = await firestore.document(communityDoc).get();
    if (!communitySnap.exists) {
      print('Community ($communityId) does not exist');
      return;
    }

    if (!communitySnap.data.has(Community.kFieldOnboardingSteps)) {
      print(
        'Community ($communityId) has no field ${Community.kFieldOnboardingSteps}',
      );
      return;
    }
    final List<dynamic> onboardingSteps =
        communitySnap.data.toMap()[Community.kFieldOnboardingSteps];
    final stringOnboardingStep = EnumToString.convertToString(onboardingStep);

    if (onboardingSteps.any((element) => element == stringOnboardingStep)) {
      print(
        '$onboardingStep is already in Community ($communityId) ${Community.kFieldOnboardingSteps}',
      );
      return;
    }

    final communityMemberships = await firestore
        .collectionGroup(FirestoreHelper.kCommunityMemberships)
        .where(Membership.kFieldCommunityId, isEqualTo: communityId)
        .get();
    final amIInCommunity = communityMemberships.documents.any(
      (documentSnapshot) =>
          documentSnapshot.data.getString(Membership.kFieldUserId) ==
          membership.userId,
    );
    if (!amIInCommunity) {
      print(
        'User (${membership.userId}) is not in community ($communityId). Something is wrong',
      );
      return;
    }

    if (!communitySnap.data.has(Community.kFieldCreatorId)) {
      print(
        'Community ($communityId) has no field ${Community.kFieldCreatorId}',
      );
      return;
    }
    final communityCreatorId =
        communitySnap.data.getString(Community.kFieldCreatorId);
    if (communityCreatorId == membership.userId) {
      print(
        'User (${membership.userId}) is a creator of the Community ($communityId)',
      );
      return;
    }

    // Update Community with new step
    final updateMap = {
      Community.kFieldOnboardingSteps: [
        ...onboardingSteps,
        stringOnboardingStep,
      ],
    };

    await communitySnap.reference.updateData(UpdateData.fromMap(updateMap));

    print(
      '$onboardingStep has been added to Community ($communityId) ${Community.kFieldOnboardingSteps}',
    );
  }
}
