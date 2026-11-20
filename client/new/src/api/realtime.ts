import type {
  ChatMessage,
  EmotionType,
  EventMessage,
  LiveMeetingState,
  PresenceEntry,
} from './types';

/**
 * Wire protocol for the realtime channel (WebSocket/SSE in the real backend).
 *
 * Rule of thumb for the architecture: **writes go over HTTP** (so they are request/response,
 * idempotent and retryable by the outbox) and **reads are pushed over the socket** and folded
 * into the TanStack Query cache by the realtime scope. The socket never carries commands.
 */
export type ServerMessage =
  | { type: 'presence.snapshot'; participants: PresenceEntry[] }
  | { type: 'presence.joined'; entry: PresenceEntry }
  | { type: 'presence.left'; userId: string }
  | { type: 'presence.speaking'; userId: string; speaking: boolean }
  | { type: 'chat.created'; message: ChatMessage }
  | { type: 'chat.removed'; messageId: string }
  | { type: 'reaction.created'; userId: string; emotion: EmotionType; id: string }
  | { type: 'meeting.updated'; meeting: LiveMeetingState }
  | { type: 'event.message'; message: EventMessage };

export type CloseReason = 'network' | 'server' | 'client';

export interface TransportHandlers {
  onOpen(): void;
  onMessage(message: ServerMessage): void;
  onClose(reason: CloseReason): void;
}

export interface TransportHandle {
  close(): void;
}

/**
 * Minimal socket abstraction. The connection machine owns exactly one handle at a time;
 * closing the handle (machine exit / actor stop) must be idempotent and silent.
 */
export interface RealtimeTransport {
  connect(channel: string, handlers: TransportHandlers): TransportHandle;
}
