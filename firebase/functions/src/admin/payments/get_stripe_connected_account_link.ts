import * as functions from 'firebase-functions';
import { OnCallMethod } from '../../on_call_function';
import { firestore, firestoreUtils } from '../../utils/infra/firestore_utils';
import { stripeUtil } from './stripe_util';
import { orElseUnauthorized } from '../../utils/utils';

interface GetStripeConnectedAccountLinkRequest {
  agreementId: string;
  responsePath: string;
}

export class GetStripeConnectedAccountLink extends OnCallMethod<GetStripeConnectedAccountLinkRequest> {
  constructor() {
    super(
      'getStripeConnectedAccountLink',
      (json) => json as GetStripeConnectedAccountLinkRequest,
      { runWithOptions: { timeoutSeconds: 60, memory: '1GB', minInstances: 0 } }
    );
  }

  async action(request: GetStripeConnectedAccountLinkRequest, context: functions.https.CallableContext): Promise<Record<string, unknown>> {
    orElseUnauthorized(context.auth?.uid != null);

    const agreementRef = firestore.doc(`partner-agreements/${request.agreementId}`);
    const agreementDoc = await agreementRef.get();
    orElseUnauthorized(agreementDoc.exists);

    const agreement = firestoreUtils.fromFirestoreJson(agreementDoc.data() ?? {}) as Record<string, unknown>;
    orElseUnauthorized(agreement['allowPayments'] === true);
    orElseUnauthorized(agreement['stripeConnectedAccountId'] != null);
    orElseUnauthorized(agreement['initialUserId'] === context.auth?.uid);

    const domain = functions.config().app?.domain as string;

    const params: Record<string, string> = {
      'account': agreement['stripeConnectedAccountId'] as string,
      'type': 'account_onboarding',
      'return_url': `https://${domain}/${request.responsePath}`,
      'refresh_url': `https://${domain}/${request.responsePath}`,
    };

    const jsonResponse = await stripeUtil.post({ path: '/account_links', params });
    return { url: jsonResponse['url'] };
  }
}
