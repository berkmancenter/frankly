import type { CommunitySettings, Event, MembershipStatus } from "@/api/types";
import { isFacilitator, isMember, isMod, isNotBanned } from "./membership";

interface Input {
  event: Pick<Event, "creatorId" | "isLocked">;
  userId: string | undefined;
  status: MembershipStatus;
  settings: Pick<CommunitySettings, "requireApprovalToJoin" | "allowUnofficialTemplates">;
  isParticipant: boolean;
}

// What the signed-in user may do with one event.
export function eventPermissions({ event, userId, status, settings, isParticipant }: Input) {
  const isHost = !!userId && event.creatorId === userId;
  return {
    isHost,
    canJoin: event.isLocked
      ? false
      : settings.requireApprovalToJoin
        ? isMember(status)
        : isNotBanned(status),
    // Hosts edit their own events; when only official templates are allowed they also need to be facilitators.
    canEdit: settings.allowUnofficialTemplates
      ? isHost || isMod(status)
      : (isHost && isFacilitator(status)) || isMod(status),
    canRefreshTemplate: isMod(status),
    canCancelEvent: isHost || isMod(status),
    canCancelParticipation: !isHost && isParticipant,
    // The host cannot be removed; the host and moderators may remove anyone else, and anyone may remove themself.
    canRemoveParticipant: (participantId: string) =>
      participantId !== event.creatorId && (isHost || participantId === userId || isMod(status)),
  };
}
