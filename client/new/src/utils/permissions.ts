import type { Community, MembershipStatus } from "@/api/types";
import {
  isAdmin,
  isFacilitator,
  isMember,
  isMod,
  isNotBanned,
} from "./membership";

/**
 * Pure functions of (community, membership for now), so the rules are unit-testable and a scope just
 * memoizes the result.
 * TODO: Add the other permissions here as the pages that need them move.
 */
export interface CommunityPermissions {
  canViewCommunityLinks: boolean;
  canCreateEvent: boolean;
  canCreateTemplate: boolean;
  canEditCommunity: boolean;
}

export function computeCommunityPermissions(
  community: Pick<Community, "settings">,
  status: MembershipStatus = "nonmember",
  hasTemplates: boolean,
): CommunityPermissions {
  const { settings } = community;

  const canCreateTemplate = settings.allowUnofficialTemplates
    ? isMember(status)
    : isMod(status);

  const canCreateEvent = (() => {
    if (!hasTemplates && !canCreateTemplate) return false;
    if (settings.dontAllowMembersToCreateMeetings) return isFacilitator(status);
    if (settings.requireApprovalToJoin) return isMember(status);
    return isNotBanned(status);
  })();

  return {
    canViewCommunityLinks: isMember(status),
    canCreateEvent,
    canCreateTemplate,
    canEditCommunity: isAdmin(status),
  };
}
