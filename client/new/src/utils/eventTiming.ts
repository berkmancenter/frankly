import { calendarDayDiff } from "./format";

// How long before the start a participant may enter the event.
export const MINUTES_BEFORE_EVENT_TO_JOIN = 15;

export type StartState =
  | { kind: "open" }
  | { kind: "ended" }
  | { kind: "tomorrow" }
  | { kind: "days"; days: number }
  | { kind: "countdown"; ms: number };

// What the "enter" button says about the event's start, judged in calendar days like the event cards.
export function startState(scheduled: Date, now: Date): StartState {
  const days = calendarDayDiff(scheduled, now);
  const ms = scheduled.getTime() - now.getTime();
  if (days > 1) return { kind: "days", days };
  if (days === 1) return { kind: "tomorrow" };
  if (days === 0 && ms / 60_000 > MINUTES_BEFORE_EVENT_TO_JOIN) return { kind: "countdown", ms };
  if (days < 0) return { kind: "ended" };
  return { kind: "open" };
}

// `1h 05m`, `12m 30s`: the time left, for a same-day countdown.
export function formatCountdown(ms: number): string {
  const total = Math.max(0, Math.floor(ms / 1000));
  const hours = Math.floor(total / 3600);
  const minutes = Math.floor((total % 3600) / 60);
  const seconds = total % 60;
  const pad = (n: number) => String(n).padStart(2, "0");
  // Unit suffixes are not words.
  // eslint-disable-next-line lingui/no-unlocalized-strings
  return hours > 0 ? `${hours}h ${pad(minutes)}m` : `${minutes}m ${pad(seconds)}s`;
}

// The template an event has when it was not made from one.
export const DEFAULT_TEMPLATE_ID = "misc";

const DEFAULT_MAX_PARTICIPANTS = 8;
const DEFAULT_MAX_PARTICIPANTS_HOSTLESS = 1000;

// The cap on RSVPs: what the host set, else a default for the event type.
export function effectiveMaxParticipants(event: { maxParticipants?: number; eventType: string }): number {
  return (
    event.maxParticipants ??
    (event.eventType === "hostless" ? DEFAULT_MAX_PARTICIPANTS_HOSTLESS : DEFAULT_MAX_PARTICIPANTS)
  );
}
