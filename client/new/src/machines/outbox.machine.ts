import {
  assign,
  fromCallback,
  fromPromise,
  setup,
  type SnapshotFrom,
} from "xstate";
import { backoffDelay, withRetryDefaults, type RetryPolicy } from "./retry";

/**
 * Outbox machine — an ordered, retrying, offline-tolerant queue for fire-and-forget writes
 * (chat messages, reactions, raised hands, poll votes, word-cloud entries, suggestions).
 *
 *   idle ─(gate open ∧ something queued)─▶ sending ─ok──▶ idle        (loop: next item)
 *                                             │  └─transient error─▶ backoff ──▶ idle
 *                                             └─permanent / too many attempts─▶ item.failed ▶ idle
 *
 * Guarantees
 *  - FIFO: items are delivered one at a time, in enqueue order, so chat reads in the order it
 *    was typed. A `failed` item does not block the ones behind it.
 *  - At-least-once delivery with idempotency: `item.id` is the client-generated idempotency key
 *    the API dedupes on, so a retry after an ambiguous failure never duplicates.
 *  - Gated: while the `gate` is closed (e.g. the realtime connection is down) nothing is sent;
 *    when it opens the backlog flushes. The machine does not know *what* the gate is.
 *  - The queue is plain data in context, so the owning scope can persist it to storage and pass
 *    it back as `initialItems` after a reload.
 *
 * When NOT to use the outbox: request/response form submissions that the user is waiting on
 * (create event, save settings...) are TanStack `useMutation`s. The outbox is for interactions
 * the UI should show as "sent" immediately and settle in the background.
 */

export type OutboxItemStatus = "queued" | "sending" | "failed";

export interface OutboxItem<K extends string = string, P = unknown> {
  /** Idempotency key. */
  id: string;
  kind: K;
  payload: P;
  createdAt: number;
  attempts: number;
  status: OutboxItemStatus;
  error?: string;
}

/** A boolean signal the outbox waits on before sending. */
export interface Gate {
  isOpen(): boolean;
  subscribe(listener: (open: boolean) => void): () => void;
}

export interface OutboxInput {
  /** Identifies the queue (also the persistence key). */
  scopeKey: string;
  deliver: (item: OutboxItem, signal: AbortSignal) => Promise<void>;
  gate?: Gate;
  initialItems?: OutboxItem[];
  retry?: Partial<RetryPolicy>;
  /** Attempts per item before it is marked `failed` and left for the user. */
  maxAttempts?: number;
  /** Return false for errors a retry cannot fix (validation, forbidden...). */
  isRetryable?: (error: unknown) => boolean;
}

export interface OutboxContext {
  scopeKey: string;
  deliver: OutboxInput["deliver"];
  gate: Gate | undefined;
  gateOpen: boolean;
  items: OutboxItem[];
  /** Id of the item currently being delivered. */
  sendingId: string | null;
  /** Consecutive failures of the item at the head of the queue (drives the backoff delay). */
  failures: number;
  retry: RetryPolicy;
  maxAttempts: number;
  isRetryable: (error: unknown) => boolean;
}

export type OutboxEvent =
  | {
      type: "ENQUEUE";
      item: Omit<OutboxItem, "attempts" | "status" | "createdAt"> & {
        createdAt?: number;
      };
    }
  | { type: "RETRY"; id: string }
  | { type: "RETRY_ALL" }
  | { type: "DISCARD"; id: string }
  | { type: "GATE"; open: boolean };

const errorMessage = (e: unknown) =>
  e instanceof Error ? e.message : String(e);

const gateWatcher = fromCallback<
  { type: "GATE"; open: boolean },
  { gate: Gate | undefined }
>(({ input, sendBack }) => {
  const { gate } = input;
  if (!gate) return;
  sendBack({ type: "GATE", open: gate.isOpen() });
  return gate.subscribe((open) => sendBack({ type: "GATE", open }));
});

const deliverActor = fromPromise<
  void,
  { item: OutboxItem; deliver: OutboxInput["deliver"] }
>(({ input, signal }) => input.deliver(input.item, signal));

const nextQueued = (items: OutboxItem[]) =>
  items.find((i) => i.status === "queued");

export const outboxMachine = setup({
  types: {
    context: {} as OutboxContext,
    events: {} as OutboxEvent,
    input: {} as OutboxInput,
  },
  actors: { gateWatcher, deliver: deliverActor },
  delays: {
    retryDelay: ({ context }) => backoffDelay(context.failures, context.retry),
  },
  guards: {
    canSend: ({ context }) => context.gateOpen && !!nextQueued(context.items),
    isSending: ({ context }, params: { id: string }) =>
      context.sendingId === params.id,
    giveUp: ({ context, event }) => {
      const err = (event as { error?: unknown }).error;
      const item = context.items.find((i) => i.id === context.sendingId);
      return (
        !context.isRetryable(err) ||
        (item?.attempts ?? 0) + 1 >= context.maxAttempts
      );
    },
  },
  actions: {
    enqueue: assign({
      items: ({ context, event }) => {
        if (event.type !== "ENQUEUE") return context.items;
        // Enqueueing the same idempotency key twice is a no-op.
        if (context.items.some((i) => i.id === event.item.id))
          return context.items;
        return [
          ...context.items,
          {
            createdAt: Date.now(), // elapsed/ordering metadata, not business time
            ...event.item,
            attempts: 0,
            status: "queued" as const,
          },
        ];
      },
    }),
    markSending: assign(({ context }) => {
      const head = nextQueued(context.items);
      if (!head) return {};
      return {
        sendingId: head.id,
        items: context.items.map((i) =>
          i.id === head.id ? { ...i, status: "sending" as const } : i,
        ),
      };
    }),
    markDelivered: assign({
      items: ({ context }) =>
        context.items.filter((i) => i.id !== context.sendingId),
      sendingId: null,
      failures: 0,
    }),
    recordFailure: assign(({ context, event }) => ({
      sendingId: null,
      failures: context.failures + 1,
      items: context.items.map((i) =>
        i.id === context.sendingId
          ? {
              ...i,
              status: "queued" as const,
              attempts: i.attempts + 1,
              error: errorMessage((event as { error?: unknown }).error),
            }
          : i,
      ),
    })),
    markFailed: assign(({ context, event }) => ({
      sendingId: null,
      failures: 0,
      items: context.items.map((i) =>
        i.id === context.sendingId
          ? {
              ...i,
              status: "failed" as const,
              attempts: i.attempts + 1,
              error: errorMessage((event as { error?: unknown }).error),
            }
          : i,
      ),
    })),
    setGate: assign({
      gateOpen: ({ context, event }) =>
        event.type === "GATE" ? event.open : context.gateOpen,
    }),
    retryItem: assign({
      items: ({ context, event }) =>
        event.type !== "RETRY"
          ? context.items
          : context.items.map((i) =>
              i.id === event.id && i.status === "failed"
                ? {
                    ...i,
                    status: "queued" as const,
                    attempts: 0,
                    error: undefined,
                  }
                : i,
            ),
    }),
    retryAll: assign({
      items: ({ context }) =>
        context.items.map((i) =>
          i.status === "failed"
            ? { ...i, status: "queued" as const, attempts: 0, error: undefined }
            : i,
        ),
    }),
    discard: assign({
      items: ({ context, event }) =>
        event.type !== "DISCARD"
          ? context.items
          : context.items.filter((i) => i.id !== event.id),
    }),
  },
}).createMachine({
  id: "outbox",
  context: ({ input }) => ({
    scopeKey: input.scopeKey,
    deliver: input.deliver,
    gate: input.gate,
    gateOpen: input.gate ? input.gate.isOpen() : true,
    // A reload may have interrupted a send; whether it landed is unknown, so re-send it.
    // The server dedupes on the idempotency key.
    items: (input.initialItems ?? []).map((i) =>
      i.status === "sending" ? { ...i, status: "queued" as const } : i,
    ),
    sendingId: null,
    failures: 0,
    retry: withRetryDefaults({
      baseMs: 400,
      maxMs: 10_000,
      maxAttempts: 99,
      ...input.retry,
    }),
    maxAttempts: input.maxAttempts ?? 5,
    isRetryable: input.isRetryable ?? (() => true),
  }),
  invoke: {
    id: "gate",
    src: "gateWatcher",
    input: ({ context }) => ({ gate: context.gate }),
  },
  on: {
    ENQUEUE: { actions: "enqueue" },
    GATE: { actions: "setGate" },
    RETRY: { actions: "retryItem" },
    RETRY_ALL: { actions: "retryAll" },
    DISCARD: { actions: "discard" },
  },
  initial: "idle",
  states: {
    idle: {
      always: { guard: "canSend", target: "sending" },
    },
    sending: {
      entry: "markSending",
      invoke: {
        id: "deliver",
        src: "deliver",
        input: ({ context }) => ({
          item: context.items.find((i) => i.id === context.sendingId)!,
          deliver: context.deliver,
        }),
        onDone: { target: "idle", actions: "markDelivered" },
        onError: [
          { guard: "giveUp", target: "idle", actions: "markFailed" },
          { target: "backoff", actions: "recordFailure" },
        ],
      },
      on: {
        // Discarding the in-flight item aborts it (leaving `sending` stops the promise actor).
        DISCARD: [
          {
            guard: {
              type: "isSending",
              params: ({ event }) => ({ id: event.id }),
            },
            target: "idle",
            actions: ["discard", assign({ sendingId: null })],
          },
          { actions: "discard" },
        ],
      },
    },
    backoff: {
      after: { retryDelay: "idle" },
    },
  },
});

export type OutboxSnapshot = SnapshotFrom<typeof outboxMachine>;

export const selectOutboxItems = (s: OutboxSnapshot) => s.context.items;
export const selectOutboxPendingCount = (s: OutboxSnapshot) =>
  s.context.items.filter((i) => i.status !== "failed").length;
export const selectOutboxFailedCount = (s: OutboxSnapshot) =>
  s.context.items.filter((i) => i.status === "failed").length;
