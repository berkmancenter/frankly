import { afterEach, describe, expect, it } from 'vitest';
import { createActor, SimulatedClock } from 'xstate';
import type {
  CloseReason,
  RealtimeTransport,
  ServerMessage,
  TransportHandlers,
} from '@/api/realtime';
import { connectionMachine, selectConnectionStatus } from '../connection.machine';

interface FakeSocket {
  channel: string;
  handlers: TransportHandlers;
  closed: boolean;
}

function fakeTransport() {
  const sockets: FakeSocket[] = [];
  const transport: RealtimeTransport = {
    connect(channel, handlers) {
      const socket: FakeSocket = { channel, handlers, closed: false };
      sockets.push(socket);
      return {
        close() {
          socket.closed = true;
        },
      };
    },
  };
  const last = () => sockets[sockets.length - 1]!;
  return { transport, sockets, last };
}

const retry = { baseMs: 100, maxMs: 1000, maxAttempts: 3, jitter: false };

function start(autoConnect = true) {
  const t = fakeTransport();
  const clock = new SimulatedClock();
  const actor = createActor(connectionMachine, {
    clock,
    input: { transport: t.transport, channel: 'event:1', autoConnect, retry, connectTimeoutMs: 5000 },
  });
  actor.start();
  const status = () => selectConnectionStatus(actor.getSnapshot());
  return { ...t, clock, actor, status };
}

const active: ReturnType<typeof start>[] = [];
const run = (autoConnect = true) => {
  const h = start(autoConnect);
  active.push(h);
  return h;
};
afterEach(() => {
  for (const h of active.splice(0)) h.actor.stop();
});

describe('connectionMachine', () => {
  it('waits for CONNECT when autoConnect is false', () => {
    const h = run(false);
    expect(h.status()).toBe('idle');
    expect(h.sockets).toHaveLength(0);
    h.actor.send({ type: 'CONNECT' });
    expect(h.status()).toBe('connecting');
    expect(h.last().channel).toBe('event:1');
  });

  it('connects, then forwards server messages as emitted events', () => {
    const h = run();
    const opened: boolean[] = [];
    const messages: ServerMessage[] = [];
    h.actor.on('opened', (e) => opened.push(e.reconnect));
    h.actor.on('message', (e) => messages.push(e.message));

    expect(h.status()).toBe('connecting');
    h.last().handlers.onOpen();
    expect(h.status()).toBe('connected');
    expect(opened).toEqual([false]);

    const msg: ServerMessage = { type: 'presence.left', userId: 'u1' };
    h.last().handlers.onMessage(msg);
    expect(messages).toEqual([msg]);
  });

  it('backs off exponentially, reconnects, and flags the reconnect', () => {
    const h = run();
    const opened: boolean[] = [];
    h.actor.on('opened', (e) => opened.push(e.reconnect));
    h.last().handlers.onOpen();

    h.last().handlers.onClose('network');
    expect(h.status()).toBe('reconnecting');
    expect(h.actor.getSnapshot().context.attempt).toBe(1);
    expect(h.sockets).toHaveLength(1);

    h.clock.increment(99);
    expect(h.sockets).toHaveLength(1); // not yet: first delay is baseMs = 100
    h.clock.increment(1);
    expect(h.sockets).toHaveLength(2);

    // The second attempt fails too -> longer delay (200ms).
    h.last().handlers.onClose('network');
    expect(h.actor.getSnapshot().context.attempt).toBe(2);
    h.clock.increment(199);
    expect(h.sockets).toHaveLength(2);
    h.clock.increment(1);
    expect(h.sockets).toHaveLength(3);

    h.last().handlers.onOpen();
    expect(h.status()).toBe('connected');
    expect(h.actor.getSnapshot().context.attempt).toBe(0);
    expect(opened).toEqual([false, true]);
  });

  it('closes the previous socket when it retries', () => {
    const h = run();
    h.last().handlers.onClose('server');
    const first = h.last();
    h.clock.increment(100);
    expect(first.closed).toBe(true);
  });

  it('gives up after maxAttempts and recovers on RETRY_NOW', () => {
    const h = run();
    h.last().handlers.onClose('network'); // attempt 1
    h.clock.increment(100);
    h.last().handlers.onClose('network'); // attempt 2
    h.clock.increment(200);
    h.last().handlers.onClose('network'); // attempt 3 -> exhausted
    expect(h.status()).toBe('failed');
    h.clock.increment(60_000);
    expect(h.sockets).toHaveLength(3); // no more automatic tries

    h.actor.send({ type: 'RETRY_NOW' });
    expect(h.status()).toBe('connecting');
    expect(h.sockets).toHaveLength(4);
    expect(h.actor.getSnapshot().context.attempt).toBe(0);
  });

  it('treats a socket that never opens as a failed attempt', () => {
    const h = run();
    h.clock.increment(5000);
    expect(h.status()).toBe('reconnecting');
    expect(h.actor.getSnapshot().context.lastError).toBe('network');
    h.clock.increment(100);
    expect(h.sockets).toHaveLength(2);
  });

  it('DISCONNECT closes the socket and stays idle', () => {
    const h = run();
    h.last().handlers.onOpen();
    const socket = h.last();
    h.actor.send({ type: 'DISCONNECT' });
    expect(h.status()).toBe('idle');
    expect(socket.closed).toBe(true);
    h.clock.increment(60_000);
    expect(h.sockets).toHaveLength(1);
  });

  it('closes the socket when the actor is stopped (scope unmount)', () => {
    const h = run();
    h.last().handlers.onOpen();
    const socket = h.last();
    h.actor.stop();
    expect(socket.closed).toBe(true);
  });

  it('emits why a socket closed', () => {
    const h = run();
    const reasons: CloseReason[] = [];
    h.actor.on('closed', (e) => reasons.push(e.reason));
    h.last().handlers.onOpen();
    h.last().handlers.onClose('server');
    expect(reasons).toEqual(['server']);
  });
});
