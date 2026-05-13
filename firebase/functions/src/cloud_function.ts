import * as functions from 'firebase-functions';

/**
 * Base interface for all Cloud Functions.
 * Corresponds to Dart's abstract class CloudFunction.
 */
export interface CloudFunction {
  readonly functionName: string;
  register(functions: typeof import('firebase-functions')): functions.HttpsFunction | functions.CloudFunction<unknown> | void;
}
