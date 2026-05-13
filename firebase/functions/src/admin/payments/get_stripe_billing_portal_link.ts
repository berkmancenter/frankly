import * as functions from 'firebase-functions';
import { OnCallMethod } from '../../on_call_function';
import { stripeUtil } from './stripe_util';
import { orElseUnauthorized } from '../../utils/utils';

interface GetStripeBillingPortalLinkRequest {
  responsePath: string;
}

export class GetStripeBillingPortalLink extends OnCallMethod<GetStripeBillingPortalLinkRequest> {
  constructor() {
    super(
      'getStripeBillingPortalLink',
      (json) => json as GetStripeBillingPortalLinkRequest,
      { runWithOptions: { timeoutSeconds: 60, memory: '1GB', minInstances: 0 } }
    );
  }

  async action(request: GetStripeBillingPortalLinkRequest, context: functions.https.CallableContext): Promise<Record<string, unknown>> {
    orElseUnauthorized(context.auth?.uid != null);

    const stripeCustomerId = await stripeUtil.getOrCreateCustomerStripeId({ uid: context.auth!.uid });
    const domain = functions.config().app?.domain as string;

    const params: Record<string, string> = {
      'customer': stripeCustomerId,
      'return_url': `https://${domain}/${request.responsePath}`,
    };

    const jsonResponse = await stripeUtil.post({ path: '/billing_portal/sessions', params });
    return { url: jsonResponse['url'] };
  }
}
