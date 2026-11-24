import type { Event, Participant } from "@/api/types";

type Entry = { participant: Participant };

export const isActive = ({ participant }: Entry) => participant.status === "active";

// A hosted event is live once anyone is in the room; hostless and livestream events only keep a head count.
export function isMeetingLive(event: Pick<Event, "eventType">, participants: Entry[]): boolean {
  return event.eventType === "hosted" && participants.some((p) => isActive(p) && p.participant.isPresent);
}

// The people to list: the active ones (only those in the room while live), host first, then you, then the rest.
export function listedParticipants<T extends Entry & { user: { id: string } }>(
  participants: T[],
  { creatorId, userId, live }: { creatorId: string; userId: string | undefined; live: boolean },
): T[] {
  const shown = participants.filter((p) => isActive(p) && (!live || p.participant.isPresent));
  const rank = (p: T) => (p.user.id === creatorId ? 0 : p.user.id === userId ? 1 : 2);
  return [...shown].sort((a, b) => rank(a) - rank(b));
}
