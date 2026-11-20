import Box from "@mui/material/Box";
import Typography from "@mui/material/Typography";
import { useLingui } from "@lingui/react/macro";
import type { Event, EventMessage } from "@/api/types";
import { EventCard } from "@/components/events/EventCards";
import CloseIcon from "@mui/icons-material/Close";
import IconButton from "@mui/material/IconButton";
import { useConfirm } from "@/components/ConfirmDialog";
import { useToast } from "@/components/Toast";
import { useEventMessages, useEventParticipants, useRemoveEventMessage, useUpcomingEvents } from "@/queries/events";
import { useCurrentUserId, useUser } from "@/queries/me";
import { useCommunityScope } from "@/scopes/CommunityScope";
import { freeText } from "@/theme/freeText";
import { colors, fontSizes } from "@/theme/tokens";
import { formatLongStamp } from "@/utils/format";
import { isMod } from "@/utils/membership";

const MORE_EVENTS = 3;

// The About tab: the description, announcements for participants, and what else is coming up.
export function EventAbout({ event }: { event: Event }) {
  const { t } = useLingui();
  const { community, status } = useCommunityScope();
  const meId = useCurrentUserId();
  const participants = useEventParticipants(event.id).data;
  const isParticipant = !!participants?.some(
    ({ participant, user }) => user.id === meId && participant.status === "active",
  );
  const canSeeAnnouncements = isParticipant || isMod(status);
  const messages = useEventMessages(canSeeAnnouncements ? event : undefined).data ?? [];
  const more = (useUpcomingEvents(community.id).data ?? [])
    .filter((other) => other.id !== event.id)
    .slice(0, MORE_EVENTS);

  return (
    <Box sx={{ display: "flex", flexDirection: "column", gap: "30px", pt: "24px" }}>
      {event.description && (
        <Section title={t({ id: "description", message: "Description" })}>
          <Typography sx={{ color: colors.onSurfaceVariant, ...freeText }}>
            {event.description}
          </Typography>
        </Section>
      )}
      {canSeeAnnouncements && (
        <Section title={t({ id: "announcements", message: "Announcements" })}>
          {messages.length === 0 ? (
            <Typography sx={{ color: colors.onSurfaceVariant }}>
              {t({ id: "noAnnouncementsSentYet", message: "No announcements sent yet" })}
            </Typography>
          ) : (
            <Box sx={{ display: "flex", flexDirection: "column", gap: "14px" }}>
              {messages.map((message) => (
                <Announcement
                  key={message.id}
                  event={event}
                  message={message}
                  canRemove={isMod(status) || event.creatorId === meId}
                />
              ))}
            </Box>
          )}
        </Section>
      )}
      {more.length > 0 && (
        <Section title={t({ id: "moreUpcomingEvents", message: "More Upcoming Events" })}>
          <Box sx={{ display: "flex", flexDirection: "column", gap: "10px" }}>
            {more.map((other) => (
              <EventCard key={other.id} event={other} />
            ))}
          </Box>
        </Section>
      )}
    </Box>
  );
}

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <Box component="section">
      <Typography component="h3" sx={{ fontSize: fontSizes.lg, fontWeight: 700, mb: "8px" }}>
        {title}
      </Typography>
      {children}
    </Box>
  );
}

function Announcement({ event, message, canRemove }: { event: Event; message: EventMessage; canRemove: boolean }) {
  const { t } = useLingui();
  const toast = useToast();
  const author = useUser(message.creatorId).data;
  const remove = useRemoveEventMessage();
  const { confirm, dialog } = useConfirm();
  const onRemove = async () => {
    const yes = await confirm({
      title: t({ id: "deleteEventAnnouncement", message: "Delete Event Announcement" }),
      mainText: t({
        id: "confirmDeleteEventAnnouncement",
        message: "Are you sure you want to delete this event announcement? This action cannot be undone.",
      }),
      confirmText: t({ id: "delete", message: "Delete" }),
      cancelText: t({ id: "cancel", message: "Cancel" }),
      destructive: true,
    });
    if (yes) {
      await remove
        .mutateAsync({ event, messageId: message.id })
        .catch(() => toast.error(t`Something went wrong. Please try again.`));
    }
  };
  return (
    <Box sx={{ display: "flex", justifyContent: "space-between", gap: "10px" }}>
      <Box>
      <Typography sx={{ fontWeight: 700 }}>
        {author?.displayName}
        {message.createdAt && (
          <Typography component="span" sx={{ ml: "8px", fontWeight: 400, color: colors.onSurfaceVariant }}>
            {formatLongStamp(new Date(message.createdAt))}
          </Typography>
        )}
      </Typography>
      <Typography sx={freeText}>{message.message}</Typography>
      </Box>
      {canRemove && (
        <IconButton size="small" aria-label={t({ id: "removeAnnouncement", message: "Delete announcement" })} onClick={onRemove}>
          <CloseIcon fontSize="small" />
        </IconButton>
      )}
      {dialog}
    </Box>
  );
}
