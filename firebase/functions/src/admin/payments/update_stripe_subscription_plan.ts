import * as functions from 'firebase-functions';
import { OnCallMethod } from '../../on_call_function';
import { firestore, firestoreUtils } from '../../utils/infra/firestore_utils';
import { stripeUtil } from './stripe_util';
import { orElseUnauthorized } from '../../utils/utils';

interface UpdateStripeSubscriptionPlanRequest {
  communityId: string;
  stripePriceId: string;
}

export class UpdateStripeSubscriptionPlan extends OnCallMethod<UpdateStripeSubscriptionPlanRequest> {
  constructor() {
    super(
      'UpdateStripeSubscriptionPlan',
      (jsonMap) => jsonMap as UpdateStripeSubscriptionPlanRequest,
      { runWithOptions: { timeoutSeconds: 60, memory: '1GB', minInstances: 0 } }
    );
  }

  async action(request: UpdateStripeSubscriptionPlanRequest, context: functions.https.CallableContext): Promise<void> {
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

    const params: Record<string, string> = {
      'cancel_at_period_end': 'false',
      'billing_cycle_anchor': 'now',
      'proration_behavior': 'create_prorations',
      'items[0][id]': (items[0] as any)['id'],
      'items[0][price]': request.stripePriceId,
    };

    await stripeUtil.post({
      path: `/subscriptions/${subscription['stripeSubscriptionId']}`,
      params,
    });
  }
}
