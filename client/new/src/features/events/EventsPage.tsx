import SearchIcon from "@mui/icons-material/Search";
import Box from "@mui/material/Box";
import ButtonBase from "@mui/material/ButtonBase";
import Typography from "@mui/material/Typography";
import { t } from "@lingui/core/macro";
import { useMemo, useState } from "react";
import { ConstrainedBody } from "@/components/ConstrainedBody";
import { EmptyPageContent } from "@/components/EmptyPageContent";
import { EventCard } from "@/components/events/EventCards";
import { ErrorState, LoadingState } from "@/components/States";
import { useClock } from "@/utils/clock";
import {
  addDays,
  formatMonthShortUpper,
  formatWeekdayShort,
  isSameCalendarDay,
  startOfDay,
} from "@/utils/format";
import { useDragScroll } from "@/utils/useDragScroll";
import { useUpcomingEvents } from "@/queries/events";
import { useCommunityScope } from "@/scopes/CommunityScope";
import { useCreateEventDialog } from "./CreateEventDialog";
import { colors, fontSizes } from "@/theme/tokens";

/** `/space/:displayId/discuss/upcoming`: search, a 90-day date strip, and the flat list of upcoming events. */
export function EventsPage() {
  const { community, permissions } = useCommunityScope();
  const clock = useClock();
  const events = useUpcomingEvents(community.id);
  const createEvent = useCreateEventDialog();
  const [search, setSearch] = useState("");
  const [date, setDate] = useState<Date | null>(null);
  const stripRef = useDragScroll<HTMLDivElement>();

  const today = startOfDay(clock.now());
  const days = useMemo(
    () => Array.from({ length: 91 }, (_, i) => addDays(today, i)),
    [today.getTime()],
  );
  const hasEvent = (day: Date) =>
    (events.data ?? []).some(
      (e) =>
        e.scheduledTime && isSameCalendarDay(new Date(e.scheduledTime), day),
    );

  const filtered = (events.data ?? [])
    .filter(
      (e) =>
        !date ||
        (e.scheduledTime && isSameCalendarDay(new Date(e.scheduledTime), date)),
    )
    .filter(
      (e) =>
        !search || (e.title ?? "").toLowerCase().includes(search.toLowerCase()),
    )
    .slice(0, 100);

  return (
    <Box component="main">
      <Box sx={{ height: 30 }} />
      <ConstrainedBody>
        <Box sx={{ pb: "12px" }}>
          <Box
            sx={{
              maxWidth: 450,
              borderRadius: "10px",
              bgcolor: colors.surfaceContainerLowest,
              pl: "12px",
              pr: "32px",
              display: "flex",
              alignItems: "center",
            }}
          >
            <SearchIcon sx={{ mx: "10px", color: colors.onSurface }} />
            <Box
              component="input"
              aria-label={t`Search events`}
              placeholder={t`Search events`}
              value={search}
              onChange={(e: React.ChangeEvent<HTMLInputElement>) =>
                setSearch(e.target.value)
              }
              sx={{
                flex: 1,
                border: 0,
                outline: 0,
                bgcolor: "transparent",
                fontFamily: "inherit",
                fontSize: 16,
                height: 56,
                color: colors.onSurface,
                "&::placeholder": { color: colors.onSurfaceVariant },
              }}
            />
          </Box>
        </Box>
      </ConstrainedBody>

      <Box
        ref={stripRef}
        sx={{
          display: "flex",
          gap: "18px",
          overflowX: "auto",
          py: "10px",
          px: "max(20px, calc((100% - 1100px) / 2 + 20px))",
          scrollbarWidth: "none",
          "&::-webkit-scrollbar": { display: "none" },
          userSelect: "none",
        }}
      >
        {days.map((day) => {
          const disabled = !hasEvent(day);
          const selected = !!date && isSameCalendarDay(day, date);
          return (
            <ButtonBase
              key={day.getTime()}
              disabled={disabled}
              onClick={() => setDate(selected ? null : day)}
              aria-pressed={selected}
              aria-label={day.toDateString()}
              sx={{
                flex: "0 0 auto",
                minWidth: 68,
                py: "8px",
                px: "12px",
                borderRadius: "8px",
                flexDirection: "column",
                bgcolor: selected
                  ? "primary.main"
                  : disabled
                    ? colors.surfaceContainer
                    : colors.surfaceContainerLowest,
                color: selected
                  ? "primary.contrastText"
                  : colors.onSurfaceVariant,
                "&.Mui-disabled": { opacity: 1 },
              }}
            >
              <Typography component="div" sx={{ fontSize: fontSizes.sm, fontWeight: 500, color: "inherit" }}>
                {formatMonthShortUpper(day)}
              </Typography>
              <Typography component="h2" sx={{ fontSize: fontSizes["4xl"], color: "inherit" }}>
                {day.getDate()}
              </Typography>
              <Typography component="div" sx={{ fontSize: fontSizes.sm, fontWeight: 500, color: "inherit" }}>
                {formatWeekdayShort(day)}
              </Typography>
            </ButtonBase>
          );
        })}
      </Box>

      <Box sx={{ height: 18 }} />
      <ConstrainedBody>
        {events.isPending ? (
          <LoadingState height={100} />
        ) : events.isError ? (
          <ErrorState message={t`Something went wrong loading events.`} />
        ) : filtered.length === 0 ? (
          <Box sx={{ pt: "30px" }}>
            <EmptyPageContent
              type="events"
              showContainer={false}
              onButtonPress={
                permissions.canCreateEvent
                  ? () => createEvent.open()
                  : undefined
              }
            />
          </Box>
        ) : (
          <Box
            sx={{
              pt: "30px",
              maxWidth: 700,
              display: "flex",
              flexDirection: "column",
              gap: "20px",
            }}
          >
            {filtered.map((e) => (
              <EventCard key={e.id} event={e} />
            ))}
          </Box>
        )}
      </ConstrainedBody>
      <Box sx={{ height: 100 }} />
      {createEvent.dialog}
    </Box>
  );
}
