import * as functions from 'firebase-functions';
import { OnRequestMethod } from '../../on_request_method';
import { firestore, firestoreUtils } from '../../utils/infra/firestore_utils';
import { analyticsUtil } from './analytics_util';
import { stripeUtil } from './stripe_util';

type JsonMap = Record<string, unknown>;

export abstract class AbstractStripeWebhooks extends OnRequestMethod<JsonMap> {
  constructor(name: string) {
    super(name, (jsonMap) => jsonMap as JsonMap);
  }

  abstract getKey(): string;

  override async handleRequest(req: functions.https.Request, res: import('express').Response): Promise<void> {
    const webhookKey = this.getKey();
    const stripe = stripeUtil.getClient();
    const sig = req.headers['stripe-signature'] as string;
    const rawBody = (req as any).rawBody ?? Buffer.from(JSON.stringify(req.body));

    const event = stripe.webhooks.constructEvent(rawBody, sig, webhookKey) as unknown as Record<string, unknown>;

    const response = await this.action(event);
    res.send(response);
  }

  async handlePaymentIntentSucceeded(request: JsonMap): Promise<void> {
    const object = (request['data'] as Record<string, unknown>)['object'] as Record<string, unknown>;
    const paymentIntentId = object['id'] as string;
    const amountInCents = object['amount_received'] as number;
    const createdInt = object['created'] as number;
    const createdDate = new Date(createdInt * 1000);
    const metadata = object['metadata'] as Record<string, string>;

    if (metadata['type'] === 'one_time_donation') {
      const communityId = metadata['communityId'];
      const authUid = metadata['authUid'];

      const paymentRef = firestore.doc(`stripeUserData/${authUid}/payments/${paymentIntentId}`);
      await paymentRef.set(
        firestoreUtils.toFirestoreJson({
          id: paymentIntentId,
          authUid,
          communityId,
          amountInCents,
          createdDate,
          type: 'oneTimeDonation',
        })
      );

      analyticsUtil.logEvent({
        userId: authUid,
        event: { type: 'Donate', communityId, amount: amountInCents / 100.0 },
      });
    } else {
      console.log(`Unknown or empty payment type: ${metadata['type'] ?? '(empty)'}`);
    }
  }

  async handleTransferCreated(request: JsonMap): Promise<void> {
    const object = (request['data'] as Record<string, unknown>)['object'] as Record<string, unknown>;
    const sourceTxId = object['source_transaction'] as string | undefined;
    const paymentId = object['destination_payment'] as string | undefined;
    const destinationId = object['destination'] as string | undefined;

    if (paymentId && sourceTxId && destinationId) {
      const sourceTx = await stripeUtil.get({ path: `/charges/${sourceTxId}` });
      const metadata = sourceTx['metadata'] as Record<string, string> | undefined;
      if (metadata) {
        await stripeUtil.post({
          path: `/charges/${paymentId}`,
          params: {
            'metadata[type]': metadata['type'] ?? '',
            'metadata[name]': metadata['name'] ?? '',
            'metadata[email]': metadata['email'] ?? '',
          },
          connectedAccount: destinationId,
        });
      }
    }
  }

  async handleSubscriptionModified(request: JsonMap): Promise<void> {
    const stripeSubscription = (request['data'] as Record<string, unknown>)['object'] as Record<string, unknown>;
    await this._updateSubscriptionData(stripeSubscription);
  }

  async handleInvoicePaid(request: JsonMap): Promise<void> {
    const object = (request['data'] as Record<string, unknown>)['object'] as Record<string, unknown>;
    const lines = ((object['lines'] as Record<string, unknown>)['data'] as unknown[]) ?? [];
    const subscriptionLines = lines.filter((line: any) => line['subscription'] != null);

    for (const line of subscriptionLines) {
      const subscriptionId = (line as any)['subscription'] as string;
      const subscription = await stripeUtil.get({ path: `/subscriptions/${subscriptionId}` });
      await this._updateSubscriptionData(subscription);
    }
  }

  async handleAccountUpdated(request: JsonMap): Promise<void> {
    const object = (request['data'] as Record<string, unknown>)['object'] as Record<string, unknown>;
    const capabilities = object['capabilities'] as Record<string, string>;
    const hasTransfers = capabilities['transfers'] === 'active';

    const agreementSnapshots = await firestore
      .collection('partner-agreements')
      .where('stripeConnectedAccountId', '==', object['id'])
      .get();

    for (const agreementDoc of agreementSnapshots.docs) {
      const agreement = firestoreUtils.fromFirestoreJson(agreementDoc.data()) as Record<string, unknown>;
      if (agreement['stripeConnectedAccountActive'] !== hasTransfers) {
        await agreementDoc.ref.update({ stripeConnectedAccountActive: hasTransfers });
      }
    }
  }

  private async _updateSubscriptionData(stripeSubscription: Record<string, unknown>): Promise<void> {
    if (['incomplete', 'incomplete_expired'].includes(stripeSubscription['status'] as string)) return;

    const stripeSubscriptionId = stripeSubscription['id'] as string;
    const stripeCustomerId = stripeSubscription['customer'] as string;
    const stripeCustomer = await stripeUtil.get({ path: `/customers/${stripeCustomerId}` });
    const userId = (stripeCustomer['metadata'] as Record<string, string>)?.['uid'];

    const currentPeriodEnd = stripeSubscription['current_period_end'] as number;
    const cancelTime = stripeSubscription['ended_at'] as number | null;
    const periodEnd = cancelTime ? Math.min(currentPeriodEnd, cancelTime) : currentPeriodEnd;
    const periodEndDateTime = new Date(periodEnd * 1_000_000 / 1000);

    const stripeProductId = ((stripeSubscription['plan'] as Record<string, unknown>)?.['product']) as string;
    const stripeProduct = await stripeUtil.get({ path: `/products/${stripeProductId}` });
    const metadata = stripeProduct['metadata'] as Record<string, string>;
    const type = metadata?.['plan_type'];

    if (!userId) {
      console.log(`'uid' not set on Stripe customer '${stripeCustomerId}'. Ignoring.`);
      return;
    }
    if (!type) {
      console.log(`'plan_type' not set on Stripe subscription product '${stripeProductId}'. Ignoring.`);
      return;
    }

    const appliedCommunityId = (stripeSubscription['metadata'] as Record<string, string>)?.['appliedCommunityId'];
    const firestoreSubscriptionRef = firestore.doc(
      `stripeUserData/${userId}/subscriptions/${stripeSubscriptionId}`
    );

    await firestoreSubscriptionRef.set(
      firestoreUtils.toFirestoreJson({
        stripeSubscriptionId,
        type,
        activeUntil: periodEndDateTime,
        appliedCommunityId,
        canceled: stripeSubscription['status'] === 'canceled',
        willCancelAtPeriodEnd: stripeSubscription['cancel_at_period_end'],
      }),
      { merge: true }
    );

    analyticsUtil.logEvent({
      userId,
      event: {
        type: 'UpdateCommunitySubscription',
        communityId: appliedCommunityId,
        planType: type,
        subscriptionId: stripeSubscriptionId,
        isCanceled: cancelTime != null,
      },
    });
  }

  override register(): functions.HttpsFunction {
    const opts = this.runWithOptions ?? { timeoutSeconds: 60, memory: '1GB', minInstances: 0 };
    return functions
      .runWith(opts as functions.RuntimeOptions)
      .https.onRequest((req, res) => this.expressAction(req, res));
  }
}
