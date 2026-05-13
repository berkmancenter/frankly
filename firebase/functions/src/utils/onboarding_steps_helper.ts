import * as admin from 'firebase-admin';
import { firestore, firestoreUtils } from './infra/firestore_utils';
import { Community, OnboardingStep, Membership } from '../types';
import { FirestoreHelper } from './infra/on_firestore_helper';

const legacyStepAliases: Record<string, string[]> = {
  createTemplate: ['createGuide'],
};

export class OnboardingStepsHelper {
  async updateOnboardingSteps(
    communityId: string,
    documentSnapshot: admin.firestore.DocumentSnapshot,
    firestoreHelperInstance: FirestoreHelper,
    onboardingStep: OnboardingStep
  ): Promise<void> {
    const pathToDocument = firestoreHelperInstance.getPathToCommunityDocument({ communityId });
    const communitySnap = await firestore.doc(pathToDocument).get();
    const communityData = communitySnap.data();
    if (!communityData) {
      console.log(`OnboardingSteps is null. Path: ${documentSnapshot.ref.path}`);
      return;
    }

    const onboardingSteps: string[] = communityData['onboardingSteps'] ?? [];
    const stringOnboardingStep = onboardingStep.toString();
    const legacyAliases = legacyStepAliases[stringOnboardingStep] ?? [];
    const hasOnboardingStep = onboardingSteps.some(
      (element) => element === stringOnboardingStep || legacyAliases.includes(element)
    );

    if (!hasOnboardingStep) {
      console.log(
        `This is the very first document in ${documentSnapshot.ref.path}. ` +
          `Include it to Community (${communityId}) onboarding steps.`
      );
      await communitySnap.ref.update({
        onboardingSteps: [...onboardingSteps, stringOnboardingStep],
      });
    }
  }
}

export const onboardingStepsHelper = new OnboardingStepsHelper();
