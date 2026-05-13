import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { OnCallMethod } from '../../on_call_function';
import { firestore, firestoreUtils } from '../../utils/infra/firestore_utils';
import { stripeUtil } from './stripe_util';
import { orElseUnauthorized } from '../../utils/utils';

interface CreateStripeConnectedAccountRequest {
  agreementId: string;
}

export class CreateStripeConnectedAccount extends OnCallMethod<CreateStripeConnectedAccountRequest> {
  constructor() {
    super(
      'createStripeConnectedAccount',
      (jsonMap) => jsonMap as CreateStripeConnectedAccountRequest,
      { runWithOptions: { timeoutSeconds: 60, memory: '1GB', minInstances: 0 } }
    );
  }

  async action(request: CreateStripeConnectedAccountRequest, context: functions.https.CallableContext): Promise<void> {
    orElseUnauthorized(context.auth?.uid != null);

    const agreementRef = firestore.doc(`partner-agreements/${request.agreementId}`);
    const agreementDoc = await agreementRef.get();

    orElseUnauthorized(agreementDoc.exists);

    const agreement = firestoreUtils.fromFirestoreJson(agreementDoc.data() ?? {}) as Record<string, unknown>;
    orElseUnauthorized(agreement['allowPayments'] === true);
    orElseUnauthorized(agreement['stripeConnectedAccountId'] == null);
    orElseUnauthorized(agreement['initialUserId'] == null);

    const params: Record<string, string> = {
      'type': 'express',
      'metadata[agreementId]': request.agreementId,
      'metadata[userId]': context.auth!.uid,
    };

    const jsonResponse = await stripeUtil.post({ path: '/accounts', params });
    const accountId = jsonResponse['id'] as string;

    await agreementRef.set(
      {
        stripeConnectedAccountId: accountId,
        initialUserId: context.auth!.uid,
      },
      { merge: true }
    );
  }
}
