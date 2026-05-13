import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';
import { OnFirestoreFunction, FirestoreEventType } from '../on_firestore_function';
import { firestoreUtils } from '../utils/infra/firestore_utils';
import { onboardingStepsHelper } from '../utils/onboarding_steps_helper';
import { firestoreHelper, FirestoreHelper } from '../utils/infra/on_firestore_helper';
import { TemplateUtils } from '../utils/template_utils';
import { OnboardingStep } from '../types';

interface Template {
  id?: string;
  [key: string]: unknown;
}

type DocumentSnapshot = admin.firestore.DocumentSnapshot;

export class OnTemplate extends OnFirestoreFunction<Template> {
  constructor() {
    super(
      [{ functionName: 'TemplateOnCreate', firestoreEventType: FirestoreEventType.onCreate }],
      (snapshot: DocumentSnapshot) => ({
        ...TemplateUtils.templateFromSnapshot(snapshot),
        id: snapshot.id,
      } as unknown as Template)
    );
  }

  get documentPath(): string {
    return 'community/{communityId}/templates/{templateId}';
  }

  async onCreate(
    documentSnapshot: DocumentSnapshot,
    _parsedData: Template,
    _updateTime: Date,
    context: functions.EventContext
  ): Promise<void> {
    console.log(`Template (${documentSnapshot.id}) has been created`);
    const communityId = context.params[FirestoreHelper.kCommunityId];
    if (!communityId) throw new Error('communityId is null');

    await onboardingStepsHelper.updateOnboardingSteps(
      communityId,
      documentSnapshot,
      firestoreHelper,
      OnboardingStep.createTemplate
    );
  }
}
