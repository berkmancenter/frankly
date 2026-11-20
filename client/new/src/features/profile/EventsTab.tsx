import Box from "@mui/material/Box";
import Typography from "@mui/material/Typography";
import { useLingui } from "@lingui/react/macro";
import { useMemo } from "react";
import type { Event } from "@/api/types";
import { ConstrainedBody } from "@/components/ConstrainedBody";
import { EventCard } from "@/components/events/EventCards";
import { ErrorState, LoadingState } from "@/components/States";
import { useMyEvents } from "@/queries/profile";
import { useClock } from "@/utils/clock";
import { splitMyEvents } from "@/utils/events/myEvents";
import { fontSizes } from "@/theme/tokens";

const MAX_SHOWN = 40;

// The "my events" tab: what the user is registered for, upcoming (soonest first) then history (latest first).
export function EventsTab() {
  const { t } = useLingui();
  const clock = useClock();
  const events = useMyEvents();

  const { upcoming, past } = useMemo(
    () => splitMyEvents(events.data ?? [], clock.now()),
    [events.data, clock],
  );

  if (events.isPending) return <LoadingState height={300} />;
  if (events.isError) {
    return (
      <ErrorState message={t`Something went wrong loading your events.`} />
    );
  }

  return (
    <>
      <EventList
        title={t({ id: "upcomingHeader", message: "UPCOMING" })}
        events={upcoming}
      />
      <EventList
        title={t({ id: "historyHeader", message: "HISTORY" })}
        events={past}
      />
    </>
  );
}

function EventList({ title, events }: { title: string; events: Event[] }) {
  const { t } = useLingui();
  return (
    <>
      <ConstrainedBody sx={{ pt: "40px" }}>
        <Typography
          component="h2"
          sx={{ width: "100%", fontSize: fontSizes.md, fontWeight: 700 }}
        >
          {title}
        </Typography>
      </ConstrainedBody>
      <ConstrainedBody sx={{ pt: "30px" }}>
        <Box
          sx={{
            width: "100%",
            display: "flex",
            flexDirection: "column",
            gap: "20px",
          }}
        >
          {events.length === 0 && (
            <Typography>
              {t({ id: "noEventsFound", message: "No events found" })}
            </Typography>
          )}
          {events.slice(0, MAX_SHOWN).map((event) => (
            <EventCard key={event.id} event={event} />
          ))}
        </Box>
      </ConstrainedBody>
    </>
  );
}
