import * as functions from 'firebase-functions';
import { AbstractStripeWebhooks } from './abstract_stripe_webhooks';

type JsonMap = Record<string, unknown>;

export class StripeConnectedAccountWebhooks extends AbstractStripeWebhooks {
  constructor() {
    super('StripeConnectedAccountWebhooks');
  }

  getKey(): string {
    return functions.config().stripe?.connected_account_webhook_key as string;
  }

  async action(request: JsonMap): Promise<string> {
    const type = request['type'] as string;
    if (type === 'account.updated') {
      await this.handleAccountUpdated(request);
    } else {
      console.log(`Unknown Stripe event type: ${type}`);
    }
    return '';
  }
}
