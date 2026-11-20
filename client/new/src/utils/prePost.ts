import type { Event, PrePostCard, PrePostLink } from "@/api/types";
import { webUrl } from "./webUrl";

export const emptyCard = (): PrePostCard => ({ headline: "", message: "", links: [] });

// Whether a card has anything worth showing.
export function cardHasData(card: PrePostCard | undefined): boolean {
  if (!card) return false;
  return !!card.headline.trim() || !!card.message.trim() || card.links.some((link) => !!link.url?.trim());
}

// The link with the participant's details added as query parameters, or undefined when it is not a web link.
export function finalLink(
  link: PrePostLink,
  who: { userId: string | undefined; eventId: Event["id"]; email: string | undefined },
): string | undefined {
  const base = webUrl(link.url ?? "");
  if (!base) return undefined;
  const url = new URL(base);
  const values = { userId: who.userId, eventId: who.eventId, email: who.email };
  for (const { type, queryParam } of link.attributes) {
    url.searchParams.append(queryParam.trim() || type, values[type] ?? "");
  }
  return url.href;
}
