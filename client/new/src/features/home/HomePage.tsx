import Box from "@mui/material/Box";
import Typography from "@mui/material/Typography";
import { Trans, useLingui } from "@lingui/react/macro";
import { useMemo } from "react";
import { StandalonePage } from "@/app/layouts/StandalonePage";
import { EventCard } from "@/components/events/EventCards";
import { CommunitiesCarousel } from "@/components/CommunitiesCarousel";
import { ErrorState, LoadingState } from "@/components/States";
import { SignInCard } from "@/features/auth/SignInCard";
import { useIsRegistered } from "@/features/auth/useAuthSession";
import { CreateCommunityButton } from "@/features/community/CreateCommunity";
import { useMyCommunities } from "@/queries/communities";
import { useMyEvents } from "@/queries/profile";
import { fontSizes } from "@/theme/tokens";
import { appName } from "@/utils/appInfo";
import { useClock } from "@/utils/clock";
import { splitMyEvents } from "@/utils/events/myEvents";
import { useDocumentTitle } from "@/utils/useDocumentTitle";
import { useIsMobile } from "@/utils/useResponsive";

const MAX_UPCOMING = 20;

/**
 * The page at "/". A visitor without an account gets the sign-in form:
 * a signed-in user gets their communities. Signing in needs no explicit
 * navigation: the session changes and this page renders the other branch.
 */
export function HomePage() {
  const { t } = useLingui();
  useDocumentTitle(t({ id: "appNameHome", message: `${appName} - Home` }));
  const registered = useIsRegistered();
  return (
    <StandalonePage>
      {registered ? <MyCommunitiesEvents /> : <SignInCard />}
    </StandalonePage>
  );
}

/** The signed-in home page: the user's communities, then the events they're registered for. */
function MyCommunitiesEvents() {
  const isMobile = useIsMobile();
  return (
    <Box
      sx={{
        maxWidth: isMobile ? 550 : 1100,
        mx: "auto",
        px: isMobile ? "20px" : 0,
        py: "40px",
      }}
    >
      <CommunitiesSection />
      {/* Half the width on desktop, like a sidebar-less column. */}
      <Box sx={{ mt: "30px", width: isMobile ? "100%" : "50%" }}>
        <UpcomingEventsSection />
      </Box>
    </Box>
  );
}

// The communities carousel, or a note that there are none yet.
function CommunitiesSection() {
  const { t } = useLingui();
  const communities = useMyCommunities();
  const isMobile = useIsMobile();

  return (
    <section>
      <Box sx={{ display: "flex", alignItems: "center", mb: "20px" }}>
        <Typography
          component="h1"
          sx={{ fontSize: fontSizes.xl, fontWeight: 700 }}
        >
          <Trans id="myCommunities">My Communities</Trans>
        </Typography>
        <Box sx={{ flex: 1 }} />
        <CreateCommunityButton showLabel={!isMobile} />
      </Box>
      {communities.isPending ? (
        <LoadingState height="40vh" />
      ) : communities.isError ? (
        <ErrorState
          message={t({
            id: "errorLoadingCommunitiesMessage",
            message:
              "Something went wrong loading communities. Please refresh.",
          })}
        />
      ) : communities.data.length === 0 ? (
        <Typography sx={{ textAlign: isMobile ? "center" : "left" }}>
          <Trans id="youHaventJoinedAnyCommunities">
            You haven't joined any communities.
          </Trans>
        </Typography>
      ) : (
        <CommunitiesCarousel communities={communities.data} />
      )}
    </section>
  );
}

// The next events the user is registered for, soonest first, or a note that there are none.
function UpcomingEventsSection() {
  const { t } = useLingui();
  const clock = useClock();
  const events = useMyEvents();
  const upcoming = useMemo(
    () => splitMyEvents(events.data ?? [], clock.now()).upcoming,
    [events.data, clock],
  );

  return (
    <section>
      <Typography
        component="h2"
        sx={{ mb: "20px", fontSize: fontSizes.xl, fontWeight: 700 }}
      >
        <Trans id="myUpcomingEvents">My Upcoming Events</Trans>
      </Typography>
      {events.isPending ? (
        <LoadingState height={100} />
      ) : events.isError ? (
        <ErrorState message={t`Something went wrong loading your events.`} />
      ) : upcoming.length === 0 ? (
        <Typography>
          <Trans id="noUpcomingEventsMessage">
            You haven't registered for any upcoming events.
          </Trans>
        </Typography>
      ) : (
        <Box sx={{ display: "flex", flexDirection: "column", gap: "20px" }}>
          {upcoming.slice(0, MAX_UPCOMING).map((event) => (
            <EventCard key={event.id} event={event} />
          ))}
        </Box>
      )}
    </section>
  );
}
