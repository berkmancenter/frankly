import * as admin from 'firebase-admin';
import { OnFirestoreFunction, AppFirestoreFunctionData, FirestoreEventType } from '../../on_firestore_function';
import { firestoreUtils } from '../../utils/infra/firestore_utils';
import { onboardingStepsHelper } from '../../utils/onboarding_steps_helper';
import { firestoreHelper } from '../../utils/infra/on_firestore_helper';
import { OnboardingStep } from '../../types';

interface PartnerAgreement {
  id?: string;
  communityId?: string;
  stripeConnectedAccountId?: string;
  stripeConnectedAccountActive?: boolean;
  allowPayments?: boolean;
  initialUserId?: string;
  takeRate?: number;
  [key: string]: unknown;
}

type DocumentSnapshot = admin.firestore.DocumentSnapshot;

export class OnPartnerAgreements extends OnFirestoreFunction<PartnerAgreement> {
  constructor() {
    super(
      [
        { functionName: 'PartnerAgreementOnCreate', firestoreEventType: FirestoreEventType.onCreate },
        { functionName: 'PartnerAgreementOnUpdate', firestoreEventType: FirestoreEventType.onUpdate },
      ],
      (snapshot: DocumentSnapshot) => {
        return {
          ...(firestoreUtils.fromFirestoreJson(snapshot.data() ?? {}) as unknown as PartnerAgreement),
          id: snapshot.id,
        };
      }
    );
  }

  get documentPath(): string {
    return 'partner-agreements/{partnerAgreementId}';
  }

  async onUpdate(
    changes: import('firebase-functions').Change<DocumentSnapshot>,
    before: PartnerAgreement,
    after: PartnerAgreement,
    _updateTime: Date,
    context: import('firebase-functions').EventContext
  ): Promise<void> {
    console.log(`Partner Agreement (${before.id}) has been updated`);

    const beforeStripeId = before.stripeConnectedAccountId;
    const afterStripeId = after.stripeConnectedAccountId;

    if (beforeStripeId == null && afterStripeId != null) {
      const communityId = after.communityId;
      if (communityId) {
        await onboardingStepsHelper.updateOnboardingSteps(
          communityId,
          changes.after,
          firestoreHelper,
          OnboardingStep.createStripeAccount
        );
      }
    }
  }

  async onCreate(
    documentSnapshot: DocumentSnapshot,
    parsedData: PartnerAgreement,
    _updateTime: Date,
    _context: import('firebase-functions').EventContext
  ): Promise<void> {
    console.log(`Partner Agreement (${documentSnapshot.id}) has been created`);
    const communityId = (documentSnapshot.data() ?? {})['communityId'] as string | undefined;
    if (communityId) {
      await onboardingStepsHelper.updateOnboardingSteps(
        communityId,
        documentSnapshot,
        firestoreHelper,
        OnboardingStep.createStripeAccount
      );
    }
  }
}
