export interface RetryPolicy {
  /** Delay before the first retry. Doubles every consecutive failure. */
  baseMs: number;
  maxMs: number;
  /** Consecutive failures tolerated before the owner gives up (`failed` state). */
  maxAttempts: number;
  /** ±20 % so a room of clients doesn't reconnect in lockstep. Off in tests. */
  jitter: boolean;
}

export const defaultRetryPolicy: RetryPolicy = {
  baseMs: 500,
  maxMs: 15_000,
  maxAttempts: 8,
  jitter: true,
};

export function withRetryDefaults(partial?: Partial<RetryPolicy>): RetryPolicy {
  return { ...defaultRetryPolicy, ...partial };
}

/** Exponential backoff for the n-th (1-based) consecutive failure. */
export function backoffDelay(
  attempt: number,
  policy: RetryPolicy,
  random: () => number = Math.random,
): number {
  const exp = Math.min(policy.maxMs, policy.baseMs * 2 ** Math.max(0, attempt - 1));
  return policy.jitter ? Math.round(exp * (0.8 + random() * 0.4)) : exp;
}
