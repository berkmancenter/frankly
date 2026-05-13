import * as functions from 'firebase-functions';
import { HttpsError } from 'firebase-functions/lib/providers/https';

export class JsonMap {
  readonly json: Record<string, unknown>;
  constructor(json: Record<string, unknown>) {
    this.json = json;
  }
}

export function isNullOrEmpty(value?: string | null): boolean {
  return value == null || value.trim() === '';
}

export function orElseUnauthorized(condition: boolean, opts?: { logMessage?: string }): void {
  if (!condition) {
    const msg = opts?.logMessage;
    console.log(msg ? `Throwing unauthorized exception: ${msg}` : 'Throwing unauthorized exception');
    throw new HttpsError('failed-precondition', 'unauthorized');
  }
}

export function orElseNotFound(condition: boolean, opts?: { logMessage?: string }): void {
  if (!condition) {
    const msg = opts?.logMessage;
    console.log(msg ? `Throwing not found exception: ${msg}` : 'Throwing not found exception');
    throw new HttpsError('not-found', 'not found');
  }
}

export function orElseInvalidArgument(condition: boolean): void {
  if (!condition) {
    console.log('Throwing invalid argument exception');
    throw new HttpsError('invalid-argument', 'invalid argument');
  }
}

export function withoutNulls<T>(arr: (T | null | undefined)[]): T[] {
  return arr.filter((x): x is T => x != null);
}

/** Returns a subset of a JSON object containing only the specified keys */
export function jsonSubset(keys: Iterable<string>, json: Record<string, unknown>): Record<string, unknown> {
  const result: Record<string, unknown> = {};
  for (const key of keys) {
    if (key in json) {
      result[key] = json[key];
    }
  }
  return result;
}

export function firstAndLastInitial(displayName?: string | null): string | null {
  if (!displayName) return null;
  const parts = displayName.trim().split(/\s+/);
  if (parts.length === 0) return null;
  const first = parts[0].charAt(0).toUpperCase();
  const last = parts.length > 1 ? parts[parts.length - 1].charAt(0).toUpperCase() : '';
  return last ? `${first}${last}` : first;
}

export function uidToInt(uid: string): number {
  let hash = 0;
  for (let i = 0; i < uid.length; i++) {
    hash = ((hash << 5) - hash) + uid.charCodeAt(i);
    hash |= 0;
  }
  return Math.abs(hash) % 1000000;
}

export const functions_config = functions.config;
