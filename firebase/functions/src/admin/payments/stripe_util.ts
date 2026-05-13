import * as functions from 'firebase-functions';
import * as https from 'https';
import * as querystring from 'querystring';
import { firestore, firestoreUtils } from '../../utils/infra/firestore_utils';
import { firebaseAuthUtils } from '../../utils/infra/firebase_auth_utils';
import { getStripeClient } from './stripe_client';

export const stripeUtil = {
  get _secretKey(): string {
    return functions.config().stripe?.secret_key as string;
  },

  getClient() {
    return getStripeClient();
  },

  async getOrCreateCustomerStripeId({ uid }: { uid: string }): Promise<string> {
    const users = await firebaseAuthUtils.getUsers([uid]);
    if (users.length !== 1) throw new Error('User not found');
    const user = users[0];

    const stripeUserDataRef = firestore.doc(`stripeUserData/${user.uid}`);
    const stripeUserData = await stripeUserDataRef.get();

    if (stripeUserData.exists && stripeUserData.data()?.['stripeId']) {
      return stripeUserData.data()!['stripeId'] as string;
    }

    const params: Record<string, string> = {
      'email': (user as any).email,
      'metadata[uid]': user.uid,
    };

    const jsonResponse = await stripeUtil.post({ path: '/customers', params });
    const stripeId = jsonResponse['id'] as string;
    await stripeUserDataRef.set({ stripeId }, { merge: true });
    return stripeId;
  },

  async post({
    path,
    params,
    connectedAccount,
  }: {
    path: string;
    params: Record<string, string>;
    connectedAccount?: string;
  }): Promise<Record<string, unknown>> {
    return new Promise((resolve, reject) => {
      const body = querystring.stringify(params);
      const headers: Record<string, string> = {
        'Authorization': `Bearer ${stripeUtil._secretKey}`,
        'Content-Type': 'application/x-www-form-urlencoded',
        'Content-Length': `${Buffer.byteLength(body)}`,
      };
      if (connectedAccount) headers['Stripe-Account'] = connectedAccount;

      const req = https.request(
        { hostname: 'api.stripe.com', path: `/v1${path}`, method: 'POST', headers },
        (res) => {
          let data = '';
          res.on('data', (chunk) => (data += chunk));
          res.on('end', () => {
            const statusCode = res.statusCode ?? 500;
            if (statusCode < 200 || statusCode > 299) {
              console.error('Stripe POST error:', data);
              reject(new functions.https.HttpsError('internal', 'Internal error.'));
              return;
            }
            resolve(JSON.parse(data));
          });
        }
      );
      req.on('error', reject);
      req.write(body);
      req.end();
    });
  },

  async delete({
    path,
    connectedAccount,
  }: {
    path: string;
    connectedAccount?: string;
  }): Promise<Record<string, unknown>> {
    return new Promise((resolve, reject) => {
      const headers: Record<string, string> = {
        'Authorization': `Bearer ${stripeUtil._secretKey}`,
      };
      if (connectedAccount) headers['Stripe-Account'] = connectedAccount;

      const req = https.request(
        { hostname: 'api.stripe.com', path: `/v1${path}`, method: 'DELETE', headers },
        (res) => {
          let data = '';
          res.on('data', (chunk) => (data += chunk));
          res.on('end', () => {
            const statusCode = res.statusCode ?? 500;
            if (statusCode < 200 || statusCode > 299) {
              console.error('Stripe DELETE error:', data);
              reject(new functions.https.HttpsError('internal', 'Internal error.'));
              return;
            }
            resolve(JSON.parse(data));
          });
        }
      );
      req.on('error', reject);
      req.end();
    });
  },

  async get({
    path,
    connectedAccount,
  }: {
    path: string;
    connectedAccount?: string;
  }): Promise<Record<string, unknown>> {
    return new Promise((resolve, reject) => {
      const headers: Record<string, string> = {
        'Authorization': `Bearer ${stripeUtil._secretKey}`,
      };
      if (connectedAccount) headers['Stripe-Account'] = connectedAccount;

      const req = https.request(
        { hostname: 'api.stripe.com', path: `/v1${path}`, method: 'GET', headers },
        (res) => {
          let data = '';
          res.on('data', (chunk) => (data += chunk));
          res.on('end', () => {
            const statusCode = res.statusCode ?? 500;
            if (statusCode < 200 || statusCode > 299) {
              console.error('Stripe GET error:', data);
              reject(new functions.https.HttpsError('internal', 'Internal error.'));
              return;
            }
            resolve(JSON.parse(data));
          });
        }
      );
      req.on('error', reject);
      req.end();
    });
  },
};
