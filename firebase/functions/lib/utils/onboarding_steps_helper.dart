import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'infra/on_firestore_helper.dart';
import 'infra/firestore_utils.dart';
import 'package:data_models/community/community.dart';

class OnboardingStepsHelper {
  /// Legacy step names that should be treated as equivalent to their renamed counterparts.
  /// This prevents duplicate steps from being added after renames.
  static const _legacyStepAliases = {
    'createTemplate': ['createGuide'],
  };

  /// Updates [Community.onboardingSteps].
  ///
  /// If [onboardingStep] already exists - does nothing;
  /// If [onboardingStep] doesn't exist - adds that step.
  /// Also checks for legacy step names to avoid duplicates after renames.
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

    // Check for the current step name and any legacy aliases
    final legacyAliases = _legacyStepAliases[stringOnboardingStep] ?? [];
    final hasOnboardingStep = onboardingSteps.any(
      (element) => element == stringOnboardingStep || legacyAliases.contains(element),
    );

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
