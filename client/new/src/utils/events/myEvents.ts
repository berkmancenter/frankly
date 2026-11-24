import type { Event } from "@/api/types";

const time = (event: Event) => Date.parse(event.scheduledTime ?? "");

// The user's active, scheduled events split around `now`: upcoming soonest first, past latest first.
export function splitMyEvents(
  events: readonly Event[],
  now: Date,
): { upcoming: Event[]; past: Event[] } {
  const at = now.getTime();
  const scheduled = events.filter(
    (event) => event.status === "active" && event.scheduledTime,
  );
  return {
    upcoming: scheduled
      .filter((event) => time(event) > at)
      .sort((a, b) => time(a) - time(b)),
    past: scheduled
      .filter((event) => time(event) < at)
      .sort((a, b) => time(b) - time(a)),
  };
}
