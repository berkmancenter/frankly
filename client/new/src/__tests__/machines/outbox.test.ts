import { afterEach, describe, expect, it } from 'vitest';
import { createActor, SimulatedClock } from 'xstate';
import {
  outboxMachine,
  selectOutboxFailedCount,
  selectOutboxItems,
  selectOutboxPendingCount,
  type Gate,
  type OutboxItem,
} from '@/machines/outbox.machine';

/** Let queued microtasks (resolved promises -> actor events) run. */
const flush = async (rounds = 5) => {
  for (let i = 0; i < rounds; i += 1) await Promise.resolve();
};

function createGate(initial: boolean) {
  let open = initial;
  const listeners = new Set<(open: boolean) => void>();
  const gate: Gate = {
    isOpen: () => open,
    subscribe(l) {
      listeners.add(l);
      return () => listeners.delete(l);
    },
  };
  return {
    gate,
    set(next: boolean) {
      open = next;
      for (const l of [...listeners]) l(next);
    },
  };
}

interface Delivery {
  item: OutboxItem;
  resolve(): void;
  reject(error: unknown): void;
  signal: AbortSignal;
}

/** A deliver() whose promises the test settles by hand. */
function manualDeliver() {
  const deliveries: Delivery[] = [];
  const deliver = (item: OutboxItem, signal: AbortSignal) =>
    new Promise<void>((resolve, reject) => {
      deliveries.push({ item, resolve, reject, signal });
    });
  return { deliver, deliveries };
}

const actors: { stop(): void }[] = [];
afterEach(() => {
  for (const a of actors.splice(0)) a.stop();
});

function start(
  options: {
    gate?: Gate;
    initialItems?: OutboxItem[];
    isRetryable?: (e: unknown) => boolean;
    maxAttempts?: number;
  } = {},
) {
  const clock = new SimulatedClock();
  const { deliver, deliveries } = manualDeliver();
  const actor = createActor(outboxMachine, {
    clock,
    input: {
      scopeKey: 'test',
      deliver,
      retry: { baseMs: 100, maxMs: 1000, jitter: false },
      ...options,
    },
  });
  actor.start();
  actors.push(actor);
  const enqueue = (id: string, kind = 'chat', payload: unknown = id) =>
    actor.send({ type: 'ENQUEUE', item: { id, kind, payload } });
  const items = () => selectOutboxItems(actor.getSnapshot());
  return { actor, clock, deliveries, enqueue, items };
}

describe('outboxMachine', () => {
  it('delivers items one at a time, in order', async () => {
    const h = start();
    h.enqueue('a');
    h.enqueue('b');
    h.enqueue('c');
    await flush();

    expect(h.deliveries.map((d) => d.item.id)).toEqual(['a']); // b and c wait their turn
    expect(h.items().map((i) => i.status)).toEqual(['sending', 'queued', 'queued']);

    h.deliveries[0]!.resolve();
    await flush();
    expect(h.deliveries.map((d) => d.item.id)).toEqual(['a', 'b']);

    h.deliveries[1]!.resolve();
    await flush();
    h.deliveries[2]!.resolve();
    await flush();
    expect(h.deliveries.map((d) => d.item.id)).toEqual(['a', 'b', 'c']);
    expect(h.items()).toEqual([]);
  });

  it('holds everything while the gate is closed and flushes when it opens', async () => {
    const g = createGate(false);
    const h = start({ gate: g.gate });
    h.enqueue('a');
    h.enqueue('b');
    await flush();
    expect(h.deliveries).toHaveLength(0);
    expect(selectOutboxPendingCount(h.actor.getSnapshot())).toBe(2);

    g.set(true);
    await flush();
    expect(h.deliveries.map((d) => d.item.id)).toEqual(['a']);
    h.deliveries[0]!.resolve();
    await flush();
    expect(h.deliveries.map((d) => d.item.id)).toEqual(['a', 'b']);
  });

  it('stops sending new items when the gate closes mid-queue', async () => {
    const g = createGate(true);
    const h = start({ gate: g.gate });
    h.enqueue('a');
    h.enqueue('b');
    await flush();
    g.set(false);
    h.deliveries[0]!.resolve(); // the in-flight request is allowed to finish
    await flush();
    expect(h.deliveries).toHaveLength(1);
    expect(h.items().map((i) => i.id)).toEqual(['b']);

    g.set(true);
    await flush();
    expect(h.deliveries.map((d) => d.item.id)).toEqual(['a', 'b']);
  });

  it('retries a transient failure with backoff and keeps the order', async () => {
    const h = start();
    h.enqueue('a');
    h.enqueue('b');
    await flush();

    h.deliveries[0]!.reject(new Error('boom'));
    await flush();
    expect(h.items()[0]).toMatchObject({ id: 'a', status: 'queued', attempts: 1, error: 'boom' });
    expect(h.deliveries).toHaveLength(1); // waiting out the backoff, b must not jump the queue

    h.clock.increment(99);
    await flush();
    expect(h.deliveries).toHaveLength(1);
    h.clock.increment(1);
    await flush();
    expect(h.deliveries.map((d) => d.item.id)).toEqual(['a', 'a']);

    h.deliveries[1]!.resolve();
    await flush();
    expect(h.deliveries.map((d) => d.item.id)).toEqual(['a', 'a', 'b']);
  });

  it('marks an item failed after maxAttempts without blocking the queue', async () => {
    const h = start({ maxAttempts: 2 });
    h.enqueue('a');
    h.enqueue('b');
    await flush();

    h.deliveries[0]!.reject(new Error('1'));
    await flush();
    h.clock.increment(100);
    await flush();
    h.deliveries[1]!.reject(new Error('2'));
    await flush();

    expect(h.items().map((i) => [i.id, i.status])).toEqual([
      ['a', 'failed'],
      ['b', 'sending'],
    ]);
    expect(selectOutboxFailedCount(h.actor.getSnapshot())).toBe(1);
  });

  it('does not retry errors that are not retryable', async () => {
    const h = start({ isRetryable: () => false });
    h.enqueue('a');
    await flush();
    h.deliveries[0]!.reject(new Error('forbidden'));
    await flush();
    expect(h.items()[0]).toMatchObject({ status: 'failed', attempts: 1, error: 'forbidden' });
    h.clock.increment(60_000);
    await flush();
    expect(h.deliveries).toHaveLength(1);
  });

  it('RETRY re-queues a failed item', async () => {
    const h = start({ isRetryable: () => false });
    h.enqueue('a');
    await flush();
    h.deliveries[0]!.reject(new Error('nope'));
    await flush();
    expect(h.items()[0]!.status).toBe('failed');

    h.actor.send({ type: 'RETRY', id: 'a' });
    await flush();
    expect(h.deliveries).toHaveLength(2);
    h.deliveries[1]!.resolve();
    await flush();
    expect(h.items()).toEqual([]);
  });

  it('ignores a second ENQUEUE with the same idempotency key', async () => {
    const h = start();
    h.enqueue('a');
    h.enqueue('a');
    await flush();
    expect(h.items()).toHaveLength(1);
  });

  it('re-sends an item that was in flight when the page reloaded', async () => {
    const stale: OutboxItem = {
      id: 'x',
      kind: 'chat',
      payload: 'hi',
      createdAt: 1,
      attempts: 0,
      status: 'sending',
    };
    const h = start({ initialItems: [stale] });
    await flush();
    expect(h.deliveries.map((d) => d.item.id)).toEqual(['x']);
  });

  it('discarding the in-flight item aborts it and does not drop the next one', async () => {
    const h = start();
    h.enqueue('a');
    h.enqueue('b');
    await flush();
    const first = h.deliveries[0]!;

    h.actor.send({ type: 'DISCARD', id: 'a' });
    await flush();
    expect(first.signal.aborted).toBe(true);
    first.resolve(); // a late success for the discarded item must be harmless
    await flush();

    expect(h.deliveries.map((d) => d.item.id)).toEqual(['a', 'b']);
    expect(h.items().map((i) => i.id)).toEqual(['b']);
  });

  it('can discard a queued item that has not been sent yet', async () => {
    const g = createGate(false);
    const h = start({ gate: g.gate });
    h.enqueue('a');
    h.enqueue('b');
    h.actor.send({ type: 'DISCARD', id: 'a' });
    g.set(true);
    await flush();
    expect(h.deliveries.map((d) => d.item.id)).toEqual(['b']);
  });
});
