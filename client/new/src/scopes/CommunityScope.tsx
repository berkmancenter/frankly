import { createContext, useContext, useMemo, type ReactNode } from "react";
import type { Community, MembershipStatus, Template } from "@/api/types";
import { ErrorState, LoadingState } from "@/components/States";
import {
  computeCommunityPermissions,
  type CommunityPermissions,
} from "@/utils/permissions";
import { useCommunity } from "@/queries/communities";
import { useMembership } from "@/queries/me";
import { useTemplates } from "@/queries/templates";

export interface CommunityScopeValue {
  community: Community;
  status: MembershipStatus;
  permissions: CommunityPermissions;
  /** Active templates (empty until loaded). */
  templates: Template[];
}

const CommunityScopeContext = createContext<CommunityScopeValue | null>(null);

/**
 * Scoped, parameterized state for "the current community".
 *
 * Nothing is stored here: the community, the user's membership and the templates are all
 * queries keyed by `displayId`; this component just joins them and derives permissions.
 * The parent route keys it by `displayId`, so changing community mounts a fresh scope.
 */
export function CommunityScope({
  displayId,
  children,
}: {
  displayId: string;
  children: ReactNode;
}) {
  const communityQuery = useCommunity(displayId);
  const community = communityQuery.data;
  const membership = useMembership(community?.id);
  const templatesQuery = useTemplates(community?.id);

  const templates = useMemo(
    () => (templatesQuery.data ?? []).filter((t) => t.status === "active"),
    [templatesQuery.data],
  );
  const status: MembershipStatus = membership?.status ?? "nonmember";

  const value = useMemo<CommunityScopeValue | null>(
    () =>
      community
        ? {
            community,
            status,
            templates,
            permissions: computeCommunityPermissions(
              community,
              status,
              templates.length > 0,
            ),
          }
        : null,
    [community, status, templates],
  );

  if (communityQuery.isPending) return <LoadingState height="60vh" />;
  // Not `isError ||`: a failed background refetch keeps the cached community, and unmounting
  // the page for it would discard open dialogs and unsaved input.
  if (!value) {
    return (
      <ErrorState
        height="60vh"
        message="Something went wrong loading the community."
      />
    );
  }
  return (
    <CommunityScopeContext.Provider value={value}>
      {children}
    </CommunityScopeContext.Provider>
  );
}

export function useCommunityScope(): CommunityScopeValue {
  const value = useContext(CommunityScopeContext);
  if (!value)
    throw new Error("useCommunityScope must be used inside <CommunityScope>");
  return value;
}

export const useCommunityScopeOrNull = (): CommunityScopeValue | null =>
  useContext(CommunityScopeContext);
