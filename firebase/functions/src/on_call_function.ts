import * as functions from 'firebase-functions';
import { firestoreUtils } from './utils/infra/firestore_utils';

export interface RuntimeOptions {
  timeoutSeconds?: number;
  memory?: string;
  minInstances?: number;
}

/**
 * Abstract base class for onCall Cloud Functions.
 * Corresponds to Dart's OnCallMethod<T>.
 *
 * Usage: extend this class and implement action().
 */
export abstract class OnCallMethod<T> {
  readonly functionName: string;
  readonly requestFromData: (data: unknown) => T;
  readonly runWithOptions?: RuntimeOptions;

  constructor(
    functionName: string,
    requestFromData: (data: unknown) => T,
    opts?: { runWithOptions?: RuntimeOptions }
  ) {
    this.functionName = functionName;
    this.requestFromData = requestFromData;
    this.runWithOptions = opts?.runWithOptions;
  }

  abstract action(request: T, context: functions.https.CallableContext): Promise<unknown>;

  async callAction(data: unknown, context: functions.https.CallableContext): Promise<unknown> {
    try {
      console.log('getting request');
      const request = this.requestFromData(firestoreUtils.fromFirestoreJson(data as Record<string, unknown>));
      console.log(request);
      const result = await this.action(request, context);
      return result ?? {};
    } catch (e) {
      console.error(`Error during action ${this.functionName}`, e);
      throw e;
    }
  }

  register(): functions.HttpsFunction {
    const opts = this.runWithOptions ?? { timeoutSeconds: 60, memory: '1GB', minInstances: 0 };
    return functions
      .runWith(opts as functions.RuntimeOptions)
      .https.onCall((data, context) => this.callAction(data, context));
  }
}
