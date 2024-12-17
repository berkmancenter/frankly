import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'firestore_helper.dart';
import 'firestore_utils.dart';
import 'package:data_models/firestore/community.dart';

class OnboardingStepsHelper {
  /// Updates [Community.onboardingSteps].
  ///
  /// If [onboardingStep] already exists - does nothing;
  /// If [onboardingStep] doesn't exist - adds that step.
  Future<void> updateOnboardingSteps(
    String communityId,
    DocumentSnapshot documentSnapshot,
    FirestoreHelper firestoreHelper,
    OnboardingStep onboardingStep,
  ) async {
    // Check if we need to update onboarding steps in Community
    final pathToDocument =
        firestoreHelper.getPathToCommunityDocument(communityId: communityId);
    final communitySnap = await firestore.document(pathToDocument).get();
    final List<dynamic>? onboardingSteps =
        communitySnap.data.toMap()[Community.kFieldOnboardingSteps];
    if (onboardingSteps == null) {
      print(
        'OnboardingSteps is null. Path: ${documentSnapshot.reference.path}',
      );
      return;
    }

    final stringOnboardingStep = EnumToString.convertToString(onboardingStep);
    final hasOnboardingStep =
        onboardingSteps.any((element) => element == stringOnboardingStep);

    if (!hasOnboardingStep) {
      print(
          'This is the very first document in ${documentSnapshot.reference.path}.'
          ' Include it to Community ($communityId) onboarding steps.');
      final updateMap = {
        Community.kFieldOnboardingSteps: [
          ...onboardingSteps,
          stringOnboardingStep,
        ],
      };

      await communitySnap.reference.updateData(UpdateData.fromMap(updateMap));
    }
  }
}
