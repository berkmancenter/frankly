import { useMemo } from "react";
import { Outlet, useMatches, useParams } from "react-router";
import { useDocumentTitle } from "@/utils/useDocumentTitle";
import { AppScaffold, ScaffoldFab } from "@/components/shell/AppScaffold";
import { CommunityBottomNavBar } from "@/components/shell/BottomNavBar";
import { useCreateEventDialog } from "@/features/events/CreateEventDialog";
import { useShowBottomNav } from "@/utils/useResponsive";
import { CommunityScope, useCommunityScope } from "@/scopes/CommunityScope";
import { communityBackground, communityScheme, lightScheme } from "@/theme/m3";
import { createAppTheme } from "@/theme/theme";

/** Per-route options, the port of the arguments `CommunityLocation.buildPages` passes to `CommunityPage`. */
export interface CommunityRouteHandle {
  /** Show the "Create an event" FAB / bottom-nav button on this page. */
  createEventFab?: boolean;
}

export function CommunityLayout() {
  const { displayId } = useParams();
  return (
    <CommunityScope key={displayId} displayId={displayId!}>
      <CommunityFrame />
    </CommunityScope>
  );
}

function CommunityFrame() {
  const { community, permissions } = useCommunityScope();
  const matches = useMatches();
  const handle = (matches[matches.length - 1]?.handle ??
    {}) as CommunityRouteHandle;
  const showBottomNav = useShowBottomNav();
  const createEvent = useCreateEventDialog();
  useDocumentTitle(community.name);

  // Pages inside a community use the community's colors.
  const theme = useMemo(
    () =>
      createAppTheme(
        communityScheme(lightScheme, {
          dark: community.themeDarkColor,
          light: community.themeLightColor,
        }),
      ),
    [community.themeDarkColor, community.themeLightColor],
  );

  const showCreateEvent = !!handle.createEventFab && permissions.canCreateEvent;

  return (
    <AppScaffold
      bgColor={communityBackground(lightScheme, {
        light: community.themeLightColor,
      })}
      childTheme={theme}
      bottomNav={
        showBottomNav ? (
          <CommunityBottomNavBar showCreateEventButton={showCreateEvent} />
        ) : undefined
      }
    >
      {showCreateEvent && !showBottomNav && (
        <ScaffoldFab
          text="Create an event"
          onClick={() => createEvent.open()}
        />
      )}
      {createEvent.dialog}
      <Outlet />
    </AppScaffold>
  );
}
