import { createContext, useContext } from 'react';

/**
 * Authoritative business time ("is the event live yet?", countdowns, `createdAt` stamps).
 *
 * This is the port of Flutter's `clockService.now()`. Two rules carried over from that codebase:
 *   - Use `useClock().now()` for absolute-time conditions, so tests can inject a clock.
 *   - Use `performance.now()` (or plain `Date.now()` deltas) to measure *elapsed durations*;
 *     any skew correction cancels out in a subtraction, so there is nothing to mock.
 *
 * The clock is provided through React context (not a module singleton) so a subtree — or a
 * test — can run on its own time.
 */
export interface Clock {
  now(): Date;
}

export const systemClock: Clock = { now: () => new Date() };

export const ClockContext = createContext<Clock>(systemClock);

export function useClock(): Clock {
  return useContext(ClockContext);
}
