import CloseIcon from "@mui/icons-material/Close";
import Box from "@mui/material/Box";
import IconButton from "@mui/material/IconButton";
import Typography from "@mui/material/Typography";
import { useLingui } from "@lingui/react/macro";
import type { Event } from "@/api/types";
import { AppDialog } from "@/components/AppDialog";
import { useConfirm } from "@/components/ConfirmDialog";
import { ProfileChip } from "@/components/ProfileChip";
import { ErrorState, LoadingState } from "@/components/States";
import { useToast } from "@/components/Toast";
import { useEventParticipants, useLeaveEvent } from "@/queries/events";
import { useCurrentUserId } from "@/queries/me";
import { useCommunityScope } from "@/scopes/CommunityScope";
import { colors } from "@/theme/tokens";
import { eventPermissions } from "@/utils/events/eventPermissions";
import {
  isActive,
  isMeetingLive,
  listedParticipants,
} from "@/utils/events/participants";
import { useNow } from "@/utils/useNow";

interface Props {
  event: Event;
  open: boolean;
  onClose: () => void;
}

// Everyone registered for the event; the host, moderators and each person themself can remove a name.
export function ParticipantsDialog({ event, open, onClose }: Props) {
  const { t } = useLingui();
  const toast = useToast();
  const now = useNow(60_000);
  const { community, status } = useCommunityScope();
  const meId = useCurrentUserId();
  const participants = useEventParticipants(event.id, open);
  const leave = useLeaveEvent();
  const { confirm, dialog } = useConfirm();

  const all = participants.data ?? [];
  const live = isMeetingLive(event, all);
  const listed = listedParticipants(all, {
    creatorId: event.creatorId,
    userId: meId,
    live,
  });
  const allowed = eventPermissions({
    event,
    userId: meId,
    status,
    settings: community.settings,
    isParticipant: all.some((p) => isActive(p) && p.user.id === meId),
  });

  const estimated = event.eventType !== "hosted";
  const registered = event.registrationCount ?? 0;
  const active = Math.max(
    1,
    event.presentParticipantCountEstimate ||
      event.participantCountEstimate ||
      0,
  );
  const ended =
    !!event.scheduledTime &&
    new Date(event.scheduledTime).getTime() + event.durationInMinutes * 60_000 <
      now.getTime();
  const count = all.filter(isActive).length;
  const regCount = registered;
  const attendedCount = active;
  const activeCount = active;
  const title = !estimated
    ? t({ id: "participantCount", message: `${count} participants` })
    : ended
      ? t({
          id: "registrationCountWithAttended",
          message: `${regCount} registrations (${attendedCount} attended)`,
        })
      : t({
          id: "registrationCountWithActive",
          message: `${regCount} registrations (${activeCount} active)`,
        });

  const remove = async (userId: string) => {
    const self = userId === meId;
    const yes = await confirm({
      title: t({ id: "cancel", message: "Cancel" }),
      mainText: self
        ? t({
            id: "confirmCancelYourParticipation",
            message:
              "Are you sure you want to cancel your participation in this event?",
          })
        : t({
            id: "confirmCancelUserParticipation",
            message:
              "Are you sure you want to cancel this user's participation in this event?",
          }),
      confirmText: t({ id: "yesCancel", message: "Yes, cancel" }),
      cancelText: t({ id: "no", message: "No" }),
    });
    if (yes) {
      await leave
        .mutateAsync({ event, participantId: userId })
        .catch(() => toast.error(t`Something went wrong. Please try again.`));
    }
  };

  return (
    <AppDialog
      open={open}
      onClose={onClose}
      maxWidth={400}
      padding={20}
      ariaLabel={title}
    >
      <Typography
        sx={{
          color: "primary.main",
          textAlign: "center",
          pt: "20px",
          pb: "10px",
        }}
      >
        {title}
      </Typography>
      {participants.isPending ? (
        <LoadingState height={120} />
      ) : participants.isError ? (
        <ErrorState
          height={80}
          message={t({
            id: "participantsLoadError",
            message:
              "Something went wrong loading participants. Please refresh.",
          })}
        />
      ) : listed.length === 0 ? (
        <Typography
          sx={{
            color: colors.onSurfaceVariant,
            textAlign: "center",
            py: "20px",
          }}
        >
          {t({ id: "noOneIsHereYet", message: "No one is here yet." })}
        </Typography>
      ) : (
        <Box component="ul" sx={{ listStyle: "none", m: 0, p: 0 }}>
          {listed.map(({ user }) => (
            <Box
              component="li"
              key={user.id}
              sx={{
                display: "flex",
                justifyContent: "space-between",
                alignItems: "center",
                p: "5px",
              }}
            >
              <ProfileChip userId={user.id} showIsYou />
              {allowed.canRemoveParticipant(user.id) && !event.isLocked && (
                <IconButton
                  size="small"
                  aria-label={t({
                    id: "removeParticipant",
                    message: "Remove participant",
                  })}
                  onClick={() => remove(user.id)}
                >
                  <CloseIcon fontSize="small" />
                </IconButton>
              )}
            </Box>
          ))}
        </Box>
      )}
      {dialog}
    </AppDialog>
  );
}
