import * as functions from 'firebase-functions';
import { OnCallMethod } from '../../on_call_function';
import { firestore, firestoreUtils } from '../../utils/infra/firestore_utils';
import { stripeUtil } from './stripe_util';
import { orElseUnauthorized, orElseNotFound } from '../../utils/utils';

interface CreateSubscriptionCheckoutSessionRequest {
  appliedCommunityId: string;
  returnRedirectPath: string;
  type: string;
}

export class CreateSubscriptionCheckoutSession extends OnCallMethod<CreateSubscriptionCheckoutSessionRequest> {
  constructor() {
    super(
      'CreateSubscriptionCheckoutSession',
      (jsonMap) => jsonMap as CreateSubscriptionCheckoutSessionRequest,
      { runWithOptions: { timeoutSeconds: 60, memory: '1GB', minInstances: 0 } }
    );
  }

  async action(
    request: CreateSubscriptionCheckoutSessionRequest,
    context: functions.https.CallableContext
  ): Promise<Record<string, unknown>> {
    orElseUnauthorized(context.auth?.uid != null);

    const domain = functions.config().app?.domain as string;

    const communitySnap = await firestore.doc(`community/${request.appliedCommunityId}`).get();
    orElseUnauthorized(communitySnap.exists, { logMessage: 'Community to which subscription would apply not found' });
    const community = communitySnap.data() as Record<string, unknown>;
    orElseUnauthorized(
      community['creatorId'] === context.auth?.uid,
      { logMessage: 'User is not billing manager' }
    );

    const subscriptionSnap = await firestore
      .collection(`/stripeUserData/${context.auth!.uid}/subscriptions`)
      .where('canceled', '==', false)
      .where('appliedCommunityId', '==', request.appliedCommunityId)
      .get();
    orElseUnauthorized(subscriptionSnap.empty, { logMessage: 'Resumable subscription already found for this community and billing manager' });

    const customerId = await stripeUtil.getOrCreateCustomerStripeId({ uid: context.auth!.uid });
    const priceId = await this._getProductPrice(request.type);

    const params: Record<string, string> = {
      'success_url': `https://${domain}/${request.returnRedirectPath}`,
      'cancel_url': `https://${domain}/${request.returnRedirectPath}`,
      'payment_method_types[0]': 'card',
      'line_items[0][price]': priceId,
      'line_items[0][quantity]': '1',
      'mode': 'subscription',
      'customer': customerId,
      'subscription_data[metadata][appliedCommunityId]': request.appliedCommunityId,
    };

    const jsonResponse = await stripeUtil.post({ path: '/checkout/sessions', params });
    return { sessionId: jsonResponse['id'] };
  }

  private async _getProductPrice(type: string): Promise<string> {
    const productsResponse = await stripeUtil.get({ path: '/products' });
    const products = (productsResponse['data'] as unknown[]) ?? [];
    const product = products.find((p: any) => p['metadata']?.['plan_type'] === type);
    orElseNotFound(product != null, { logMessage: `Stripe product not found for plan type: ${type}` });
    const productId = (product as any)['id'] as string;

    const pricesResponse = await stripeUtil.get({ path: `/prices?active=true&product=${productId}` });
    const prices = ((pricesResponse['data'] as unknown[]) ?? []).sort(
      (a: any, b: any) => a['unit_amount'] - b['unit_amount']
    );
    orElseNotFound(prices.length > 0, { logMessage: `Pricing data not set in Stripe for product: ${productId}` });
    return (prices[0] as any)['id'] as string;
  }
}
