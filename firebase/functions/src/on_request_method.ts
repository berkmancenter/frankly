import * as functions from 'firebase-functions';
import { scheduledFunctions } from './utils/infra/scheduled_functions';

export interface RuntimeOptions {
  timeoutSeconds?: number;
  memory?: string;
  minInstances?: number;
}

/**
 * Abstract base class for onRequest Cloud Functions (HTTP triggered).
 * Corresponds to Dart's OnRequestMethod<T>.
 */
export abstract class OnRequestMethod<T> {
  readonly functionName: string;
  readonly requestFromBody: (body: unknown) => T;
  readonly runWithOptions?: RuntimeOptions;

  constructor(
    functionName: string,
    requestFromBody: (body: unknown) => T,
    opts?: { runWithOptions?: RuntimeOptions }
  ) {
    this.functionName = functionName;
    this.requestFromBody = requestFromBody;
    this.runWithOptions = opts?.runWithOptions;
  }

  abstract action(request: T): Promise<string>;

  async handleRequest(req: functions.https.Request, res: import('express').Response): Promise<void> {
    const request = this.requestFromBody(req.body);
    console.log(request);
    const response = await this.action(request);
    res.send(response);
  }

  async expressAction(req: functions.https.Request, res: import('express').Response): Promise<void> {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Credentials', 'true');

    if (req.method === 'OPTIONS') {
      res.setHeader('Access-Control-Allow-Methods', 'GET');
      res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
      res.setHeader('Access-Control-Max-Age', '3600');
      res.status(204).send('');
      return;
    }

    console.log(req.body);
    try {
      await this.handleRequest(req, res);
    } catch (e) {
      console.error('Error during action', e);
      res.status(500).send(String(e));
    }
  }

  async schedule(request: T, scheduledTime: Date): Promise<void> {
    console.log(`Scheduling ${this.functionName} call for ${scheduledTime}`);
    return scheduledFunctions.enqueueCall(
      this.functionName,
      JSON.stringify(request),
      scheduledTime
    );
  }

  register(): functions.HttpsFunction {
    const opts = this.runWithOptions ?? { timeoutSeconds: 60, memory: '1GB', minInstances: 0 };
    return functions
      .runWith(opts as functions.RuntimeOptions)
      .https.onRequest((req, res) => this.expressAction(req, res));
  }
}
