import Stripe from 'stripe';
import * as functions from 'firebase-functions';

export function createStripeClient(privateKey: string): Stripe {
  return new Stripe(privateKey, { apiVersion: '2020-08-27' });
}

let _client: Stripe | undefined;

export function getStripeClient(): Stripe {
  const secretKey = functions.config().stripe?.secret_key as string;
  _client = _client ?? createStripeClient(secretKey);
  return _client;
}
