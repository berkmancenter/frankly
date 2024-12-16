import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:junto_functions/functions/firestore_helper.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_models/firestore/junto.dart';

class OnboardingStepsHelper {
  /// Updates [Junto.onboardingSteps].
  ///
  /// If [onboardingStep] already exists - does nothing;
  /// If [onboardingStep] doesn't exist - adds that step.
  Future<void> updateOnboardingSteps(
    String juntoId,
    DocumentSnapshot documentSnapshot,
    FirestoreHelper firestoreHelper,
    OnboardingStep onboardingStep,
  ) async {
    // Check if we need to update onboarding steps in Junto
    final pathToDocument = firestoreHelper.getPathToJuntoDocument(juntoId: juntoId);
    final juntoSnap = await firestore.document(pathToDocument).get();
    final List<dynamic>? onboardingSteps = juntoSnap.data.toMap()[Junto.kFieldOnboardingSteps];
    if (onboardingSteps == null) {
      print('OnboardingSteps is null. Path: ${documentSnapshot.reference.path}');
      return;
    }

    final stringOnboardingStep = EnumToString.convertToString(onboardingStep);
    final hasOnboardingStep = onboardingSteps.any((element) => element == stringOnboardingStep);

    if (!hasOnboardingStep) {
      print('This is the very first document in ${documentSnapshot.reference.path}.'
          ' Include it to Junto ($juntoId) onboarding steps.');
      final updateMap = {
        Junto.kFieldOnboardingSteps: [...onboardingSteps, stringOnboardingStep]
      };

      await juntoSnap.reference.updateData(UpdateData.fromMap(updateMap));
    }
  }
}
