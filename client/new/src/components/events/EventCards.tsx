import Box from "@mui/material/Box";
import ButtonBase from "@mui/material/ButtonBase";
import Typography from "@mui/material/Typography";
import { t } from "@lingui/core/macro";
import { Trans } from "@lingui/react/macro";
import { Link } from "react-router";
import type { Event } from "@/api/types";
import { Img } from "@/components/Img";
import { PrerequisiteBadge } from "@/components/misc";
import { paths } from "@/app/paths";
import { isAdmin } from "@/utils/membership";
import { useIsMobile } from "@/utils/useResponsive";
import { useHasAttendedTemplate } from "@/queries/templates";
import { useMembership } from "@/queries/me";
import { ParticipantsRow } from "./ParticipantsRow";
import { VerticalTimeAndDateIndicator } from "./TimeIndicator";
import { colors, fontSizes } from "@/theme/tokens";

/** Is the user locked out of this event by an unmet prerequisite? Admins never are. */
function usePrerequisiteLock(event: Event): boolean {
  const attended = useHasAttendedTemplate(event.prerequisiteTemplateId);
  const membership = useMembership(event.communityId);
  if (!event.prerequisiteTemplateId) return false;
  if (membership && isAdmin(membership.status)) return false;
  return attended.data !== true;
}

const eventHref = (event: Event) =>
  paths.community(event.communityDisplayId).event(event.templateId, event.id);

/**
 * `EventCard` — the card used on the community home and the events page: outlined white card,
 * date block, 90px picture, title and the participants row. Locked (prerequisite) events are
 * grayed out and not clickable. The event page is Flutter's, so the link hands off to it.
 */
export function EventCard({ event }: { event: Event }) {
  const isMobile = useIsMobile();
  const locked = usePrerequisiteLock(event);
  const start = event.scheduledTime ? new Date(event.scheduledTime) : undefined;

  return (
    <ButtonBase
      component={locked ? "div" : Link}
      {...(locked ? {} : { to: eventHref(event) })}
      aria-disabled={locked}
      sx={{
        display: "block",
        width: "100%",
        textAlign: "left",
        borderRadius: "10px",
        cursor: locked ? "default" : "pointer",
        color: "inherit",
        textDecoration: "none",
      }}
    >
      <Box
        sx={{
          border: "1px solid",
          borderColor: colors.outlineVariant,
          borderRadius: "12px",
          bgcolor: locked ? colors.surfaceContainer : colors.surfaceContainerLowest,
          overflow: "hidden",
          p: "8px",
          display: "flex",
          alignItems: "center",
        }}
      >
        {start ? (
          <VerticalTimeAndDateIndicator
            time={start}
            durationMinutes={event.durationInMinutes}
            disabled={locked}
            padding="8px 16px 8px 8px"
          />
        ) : (
          <Box sx={{ width: 100 }} />
        )}
        <Img src={event.image} width={90} height={90} radius="10px" />
        <Box
          sx={{
            flex: 1,
            minWidth: 0,
            p: "12px",
            ml: "8px",
            display: "flex",
            flexDirection: "column",
          }}
        >
          <Typography
            component="div"
            sx={{
              fontSize: fontSizes.md, fontWeight: 500, color: locked ? "rgba(28,27,27,0.75)" : colors.onSurface,
              display: "-webkit-box",
              WebkitLineClamp: 2,
              WebkitBoxOrient: "vertical",
              overflow: "hidden",
            }}
          >
            {event.title ?? t`Scheduled event`}
          </Typography>
          <Box sx={{ mt: "20px" }}>
            {locked ? (
              <PrerequisiteBadge />
            ) : (
              <>
                {event.eventType === "livestream" && (
                  <Typography
                    sx={{ fontSize: fontSizes.xs, color: "rgba(28,27,27,0.75)" }}
                  >
                    <Trans>Livestream</Trans>
                  </Typography>
                )}
                <ParticipantsRow
                  event={event}
                  iconSize={30}
                  maxAvatars={isMobile ? 3 : 6}
                />
              </>
            )}
          </Box>
        </Box>
      </Box>
    </ButtonBase>
  );
}
