import * as functions from 'firebase-functions';
import { OnCallMethod } from '../../on_call_function';
import { firestore, firestoreUtils } from '../../utils/infra/firestore_utils';
import { firebaseAuthUtils } from '../../utils/infra/firebase_auth_utils';
import { stripeUtil } from './stripe_util';
import { orElseUnauthorized, orElseNotFound } from '../../utils/utils';

interface CreateDonationCheckoutSessionRequest {
  amountInCents: number;
  communityId: string;
}

export class CreateDonationCheckoutSession extends OnCallMethod<CreateDonationCheckoutSessionRequest> {
  constructor() {
    super(
      'createDonationCheckoutSession',
      (jsonMap) => jsonMap as CreateDonationCheckoutSessionRequest,
      { runWithOptions: { timeoutSeconds: 60, memory: '1GB', minInstances: 0 } }
    );
  }

  async action(
    request: CreateDonationCheckoutSessionRequest,
    context: functions.https.CallableContext
  ): Promise<Record<string, unknown>> {
    const amountInCents = request.amountInCents;
    if (amountInCents <= 0) {
      throw new functions.https.HttpsError('invalid-argument', 'AmountInCents must be greater than zero.');
    }

    const communityId = request.communityId;
    const orgName = functions.config().app?.legal_entity_name as string;

    const customerId = await stripeUtil.getOrCreateCustomerStripeId({ uid: context.auth!.uid });
    const domain = functions.config().app?.domain as string;

    const communitySnap = await firestore.doc(`/community/${communityId}`).get();
    orElseNotFound(communitySnap.exists);
    const community = firestoreUtils.fromFirestoreJson(communitySnap.data() ?? {}) as Record<string, unknown>;

    const sanitized = ((community['name'] as string) ?? '').replace(/[^a-zA-Z0-9 .]/g, '-');
    const trimmed = sanitized.substring(0, Math.min(sanitized.length, 15));
    const descriptor = /^[^a-zA-Z]*$/.test(trimmed) ? 'Donation' : trimmed;

    let agreement: Record<string, unknown> | undefined;
    const agreementDocs = await firestore
      .collection('partner-agreements')
      .where('communityId', '==', communityId)
      .get();
    if (!agreementDocs.empty) {
      agreement = firestoreUtils.fromFirestoreJson(agreementDocs.docs[0].data()) as Record<string, unknown>;
    }

    // Use default take rate = 0 if no agreement
    const takeRate = (agreement?.['takeRate'] as number | undefined) ?? 0;

    const useConnectedAccount =
      agreement != null &&
      agreement['allowPayments'] === true &&
      agreement['stripeConnectedAccountId'] != null &&
      takeRate >= 0 &&
      takeRate < 1;

    const user = (await firebaseAuthUtils.getUsers([context.auth!.uid])).pop();

    const params: Record<string, string> = {
      'success_url': `https://${domain}/space/${communityId}?donation=success`,
      'cancel_url': `https://${domain}/space/${communityId}?donation=cancel`,
      'payment_method_types[0]': 'card',
      'line_items[0][amount]': `${amountInCents}`,
      'line_items[0][currency]': 'usd',
      'line_items[0][name]': `Donation for ${community['name'] ?? ''}`,
      'line_items[0][quantity]': '1',
      'line_items[0][description]': `A portion of this payment may be retained by ${orgName} per agreement with the recipient organization.`,
      'submit_type': 'donate',
      'mode': 'payment',
      'customer': customerId,
      'payment_intent_data[metadata][type]': 'one_time_donation',
      'payment_intent_data[metadata][authUid]': context.auth!.uid,
      'payment_intent_data[metadata][communityId]': communityId,
      'payment_intent_data[metadata][email]': (user as any)?.email ?? '',
      'payment_intent_data[metadata][name]': (user as any)?.displayName ?? '',
      'payment_intent_data[setup_future_usage]': 'on_session',
      'payment_intent_data[statement_descriptor_suffix]': descriptor,
    };

    if (useConnectedAccount) {
      params['payment_intent_data[transfer_data][destination]'] = agreement!['stripeConnectedAccountId'] as string;
      params['payment_intent_data[application_fee_amount]'] = `${Math.floor(amountInCents * takeRate)}`;
    }

    const jsonResponse = await stripeUtil.post({ path: '/checkout/sessions', params });
    return { sessionId: jsonResponse['id'] };
  }
}
