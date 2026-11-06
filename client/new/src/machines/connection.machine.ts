import { assign, emit, fromCallback, setup, type EventObject, type SnapshotFrom } from 'xstate';
import type { CloseReason, RealtimeTransport, ServerMessage } from '@/api/realtime';
import { backoffDelay, withRetryDefaults, type RetryPolicy } from './retry';

/**
 * Connection machine — owns one realtime socket for one channel.
 *
 *   idle ──CONNECT──▶ active ┬─ connecting ──open──▶ connected
 *                            └─ (socket.closed / connect timeout) ──▶ backoff ──▶ active …
 *                                                     backoff ──(attempts exhausted)──▶ failed
 *
 * Design notes
 *  - The socket is an *invoked actor* of the `active` state, so leaving `active` (backoff,
 *    DISCONNECT, or the actor being stopped on unmount) closes the handle. There is no
 *    imperative cleanup to forget.
 *  - Server messages are re-published with XState's `emit`. Consumers (the realtime scope)
 *    subscribe with `actor.on('message', …)`; the machine never touches the query cache itself.
 *  - It is parameterized by `input` ({ transport, channel }); a different channel is a
 *    different actor, which is why scopes key their provider by channel.
 */

export interface ConnectionInput {
  transport: RealtimeTransport;
  channel: string;
  /** Start connecting immediately. Otherwise wait for `CONNECT`. */
  autoConnect?: boolean;
  retry?: Partial<RetryPolicy>;
  /** A socket that has not opened after this long counts as a failed attempt. */
  connectTimeoutMs?: number;
}

export interface ConnectionContext {
  transport: RealtimeTransport;
  channel: string;
  autoConnect: boolean;
  retry: RetryPolicy;
  connectTimeoutMs: number;
  /** Consecutive failed attempts since the last successful open. */
  attempt: number;
  everConnected: boolean;
  lastError: CloseReason | null;
}

export type ConnectionEvent =
  | { type: 'CONNECT' }
  | { type: 'DISCONNECT' }
  | { type: 'RETRY_NOW' }
  | { type: 'socket.open' }
  | { type: 'socket.closed'; reason: CloseReason }
  | { type: 'socket.message'; message: ServerMessage };

export type ConnectionEmitted =
  | { type: 'message'; message: ServerMessage }
  /** `reconnect` is true for every open after the first: consumers use it to resync. */
  | { type: 'opened'; reconnect: boolean }
  | { type: 'closed'; reason: CloseReason };

const socket = fromCallback<EventObject, { transport: RealtimeTransport; channel: string }>(
  ({ input, sendBack }) => {
    const handle = input.transport.connect(input.channel, {
      onOpen: () => sendBack({ type: 'socket.open' }),
      onMessage: (message) => sendBack({ type: 'socket.message', message }),
      onClose: (reason) => sendBack({ type: 'socket.closed', reason }),
    });
    return () => handle.close();
  },
);

export const connectionMachine = setup({
  types: {
    context: {} as ConnectionContext,
    events: {} as ConnectionEvent,
    input: {} as ConnectionInput,
    emitted: {} as ConnectionEmitted,
  },
  actors: { socket },
  delays: {
    retryDelay: ({ context }) => backoffDelay(context.attempt, context.retry),
    connectTimeout: ({ context }) => context.connectTimeoutMs,
  },
  guards: {
    autoConnect: ({ context }) => context.autoConnect,
    exhausted: ({ context }) => context.attempt >= context.retry.maxAttempts,
  },
}).createMachine({
  id: 'connection',
  context: ({ input }) => ({
    transport: input.transport,
    channel: input.channel,
    autoConnect: input.autoConnect ?? true,
    retry: withRetryDefaults(input.retry),
    connectTimeoutMs: input.connectTimeoutMs ?? 10_000,
    attempt: 0,
    everConnected: false,
    lastError: null,
  }),
  initial: 'boot',
  on: {
    DISCONNECT: {
      target: '.idle',
      actions: assign({ attempt: 0, lastError: null }),
    },
  },
  states: {
    boot: {
      always: [{ guard: 'autoConnect', target: 'active' }, { target: 'idle' }],
    },
    idle: {
      on: { CONNECT: 'active' },
    },
    active: {
      invoke: {
        id: 'socket',
        src: 'socket',
        input: ({ context }) => ({ transport: context.transport, channel: context.channel }),
      },
      initial: 'connecting',
      on: {
        'socket.closed': {
          target: 'backoff',
          actions: [
            assign({ lastError: ({ event }) => event.reason }),
            emit(({ event }) => ({ type: 'closed' as const, reason: event.reason })),
          ],
        },
      },
      states: {
        connecting: {
          after: {
            connectTimeout: {
              target: '#connection.backoff',
              actions: assign({ lastError: 'network' as const }),
            },
          },
          on: { 'socket.open': 'connected' },
        },
        connected: {
          entry: [
            // `emit` runs first so it still sees `everConnected` from before this open.
            emit(({ context }) => ({ type: 'opened' as const, reconnect: context.everConnected })),
            assign({ attempt: 0, lastError: null, everConnected: true }),
          ],
          on: {
            'socket.message': {
              actions: emit(({ event }) => ({ type: 'message' as const, message: event.message })),
            },
          },
        },
      },
    },
    backoff: {
      entry: assign({ attempt: ({ context }) => context.attempt + 1 }),
      always: { guard: 'exhausted', target: 'failed' },
      after: { retryDelay: 'active' },
      on: { RETRY_NOW: 'active' },
    },
    failed: {
      on: {
        RETRY_NOW: { target: 'active', actions: assign({ attempt: 0 }) },
        CONNECT: { target: 'active', actions: assign({ attempt: 0 }) },
      },
    },
  },
});

export type ConnectionSnapshot = SnapshotFrom<typeof connectionMachine>;

export type ConnectionStatus = 'idle' | 'connecting' | 'connected' | 'reconnecting' | 'failed';

/** UI-facing summary of the machine's state. */
export function selectConnectionStatus(snapshot: ConnectionSnapshot): ConnectionStatus {
  if (snapshot.matches('failed')) return 'failed';
  if (snapshot.matches('backoff')) return 'reconnecting';
  if (snapshot.matches({ active: 'connected' })) return 'connected';
  if (snapshot.matches({ active: 'connecting' })) {
    return snapshot.context.everConnected || snapshot.context.attempt > 0
      ? 'reconnecting'
      : 'connecting';
  }
  return 'idle';
}

export const selectIsConnected = (s: ConnectionSnapshot) => s.matches({ active: 'connected' });
