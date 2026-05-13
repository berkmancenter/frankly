import * as functions from 'firebase-functions';
import { OnCallMethod } from '../../on_call_function';
import { firestore, firestoreUtils } from '../../utils/infra/firestore_utils';
import { stripeUtil } from './stripe_util';
import { orElseUnauthorized } from '../../utils/utils';

interface CancelStripeSubscriptionPlanRequest {
  communityId: string;
}

export class CancelStripeSubscriptionPlan extends OnCallMethod<CancelStripeSubscriptionPlanRequest> {
  constructor() {
    super(
      'CancelStripeSubscriptionPlan',
      (jsonMap) => jsonMap as CancelStripeSubscriptionPlanRequest,
      { runWithOptions: { timeoutSeconds: 60, memory: '1GB', minInstances: 0 } }
    );
  }

  async action(request: CancelStripeSubscriptionPlanRequest, context: functions.https.CallableContext): Promise<void> {
    orElseUnauthorized(context.auth?.uid != null);

    const subscriptionSnap = await firestore
      .collection(`/stripeUserData/${context.auth!.uid}/subscriptions`)
      .where('canceled', '==', false)
      .where('appliedCommunityId', '==', request.communityId)
      .get();
    orElseUnauthorized(!subscriptionSnap.empty, { logMessage: 'Resumable subscription not found for this community and billing manager' });

    const subscription = firestoreUtils.fromFirestoreJson(subscriptionSnap.docs[0].data()) as Record<string, unknown>;
    const stripeSubscription = await stripeUtil.get({
      path: `/subscriptions/${subscription['stripeSubscriptionId']}`,
    });

    const items = (stripeSubscription['items'] as Record<string, unknown>)?.['data'] as unknown[];
    orElseUnauthorized(items?.length > 0, { logMessage: `Subscription not found in Stripe: ${subscription['stripeSubscriptionId']}` });

    await stripeUtil.delete({
      path: `/subscriptions/${subscription['stripeSubscriptionId']}?invoice_now=true&prorate=true`,
    });
  }
}
