import * as functions from 'firebase-functions';
import { AbstractStripeWebhooks } from './abstract_stripe_webhooks';

type JsonMap = Record<string, unknown>;

export class StripeWebhooks extends AbstractStripeWebhooks {
  constructor() {
    super('StripeWebhooks');
  }

  getKey(): string {
    return functions.config().stripe?.webhook_key as string;
  }

  async action(request: JsonMap): Promise<string> {
    const type = request['type'] as string;
    if (type === 'payment_intent.succeeded') {
      await this.handlePaymentIntentSucceeded(request);
    } else if (type === 'transfer.created') {
      await this.handleTransferCreated(request);
    } else if (type === 'customer.subscription.created') {
      await this.handleSubscriptionModified(request);
    } else if (type === 'customer.subscription.updated') {
      await this.handleSubscriptionModified(request);
    } else if (type === 'customer.subscription.deleted') {
      await this.handleSubscriptionModified(request);
    } else if (type === 'invoice.paid') {
      await this.handleInvoicePaid(request);
    } else if (type === 'account.updated') {
      await this.handleAccountUpdated(request);
    } else {
      console.log(`Unknown Stripe event type: ${type}`);
    }
    return '';
  }
}
