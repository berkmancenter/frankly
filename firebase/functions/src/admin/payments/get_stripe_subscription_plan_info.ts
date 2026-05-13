import * as functions from 'firebase-functions';
import { OnCallMethod } from '../../on_call_function';
import { stripeUtil } from './stripe_util';
import { orElseUnauthorized, orElseNotFound } from '../../utils/utils';

interface GetStripeSubscriptionPlanInfoRequest {
  type: string;
}

export class GetStripeSubscriptionPlanInfo extends OnCallMethod<GetStripeSubscriptionPlanInfoRequest> {
  constructor() {
    super(
      'GetStripeSubscriptionPlanInfo',
      (json) => json as GetStripeSubscriptionPlanInfoRequest,
      { runWithOptions: { timeoutSeconds: 60, memory: '1GB', minInstances: 0 } }
    );
  }

  async action(request: GetStripeSubscriptionPlanInfoRequest, _context: functions.https.CallableContext): Promise<Record<string, unknown>> {
    const productsJson = await stripeUtil.get({ path: '/products?active=true' });
    const products = (productsJson['data'] as unknown[]) ?? [];
    const matchingProducts = products.filter((p: any) => p['metadata']?.['plan_type'] === request.type);
    orElseNotFound(matchingProducts.length > 0, { logMessage: `Product not found in Stripe: ${request.type}` });

    const product = matchingProducts[0] as Record<string, unknown>;
    const name = product['name'] as string;

    const pricesJson = await stripeUtil.get({ path: `/prices?active=true&product=${product['id']}` });
    const prices = ((pricesJson['data'] as unknown[]) ?? []).sort((a: any, b: any) => a['unit_amount'] - b['unit_amount']);
    orElseNotFound(prices.length > 0, { logMessage: `Pricing data not set in Stripe for product: ${product['id']}` });

    return {
      plan: request.type,
      priceInCents: (prices[0] as any)['unit_amount'],
      stripePriceId: (prices[0] as any)['id'],
      name,
    };
  }
}
