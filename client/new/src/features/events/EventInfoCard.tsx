import CalendarIcon from "@mui/icons-material/CalendarMonthOutlined";
import CloseIcon from "@mui/icons-material/Close";
import LockIcon from "@mui/icons-material/LockOutlined";
import EditIcon from "@mui/icons-material/EditOutlined";
import MoreIcon from "@mui/icons-material/MoreHoriz";
import SettingsIcon from "@mui/icons-material/SettingsOutlined";
import PublicIcon from "@mui/icons-material/PublicOutlined";
import SendIcon from "@mui/icons-material/SendOutlined";
import SchoolIcon from "@mui/icons-material/SchoolOutlined";
import Box from "@mui/material/Box";
import Checkbox from "@mui/material/Checkbox";
import FormControlLabel from "@mui/material/FormControlLabel";
import Menu from "@mui/material/Menu";
import MenuItem from "@mui/material/MenuItem";
import Typography from "@mui/material/Typography";
import { useLingui } from "@lingui/react/macro";
import { useState, type ReactNode } from "react";
import type { Event } from "@/api/types";
import { paths } from "@/app/paths";
import { ActionButton } from "@/components/ActionButton";
import { CircleIconButton } from "@/components/CircleIconButton";
import { useConfirm } from "@/components/ConfirmDialog";
import { useCreateEventDialog } from "./CreateEventDialog";
import { EditEventDrawer } from "./EditEventDrawer";
import { EventSettingsDrawer } from "./EventSettingsDrawer";
import { PrePostEventDialog } from "./PrePostEventDialog";
import { useSurveyDialog } from "./SurveyDialog";
import { MessageParticipantsDialog } from "./MessageParticipantsDialog";
import { ParticipantsDialog } from "./ParticipantsDialog";
import { EventPageParticipantsList } from "@/components/events/EventPageParticipantsList";
import { Img } from "@/components/Img";
import { absoluteUrl, ShareSection } from "@/components/ShareSection";
import { useToast } from "@/components/Toast";
import { useGuardSignedIn } from "@/features/auth/SignInDialog";
import {
  EVENT_REFRESH_MS,
  useCalendarLinks,
  useCancelEvent,
  useEventParticipants,
  useJoinEvent,
  useRefreshEventFromTemplate,
  useLeaveEvent,
} from "@/queries/events";
import { usePrePostEnabled } from "@/queries/communities";
import { useCurrentUserId } from "@/queries/me";
import { useTemplateTags } from "@/queries/tags";
import { useHasAttendedTemplate } from "@/queries/templates";
import { useCommunityScope } from "@/scopes/CommunityScope";
import { colors, fontSizes } from "@/theme/tokens";
import { appName } from "@/utils/appInfo";
import { eventPermissions } from "@/utils/eventPermissions";
import { DEFAULT_TEMPLATE_ID } from "@/utils/eventTiming";
import {
  effectiveMaxParticipants,
  formatCountdown,
  MINUTES_BEFORE_EVENT_TO_JOIN,
  startState,
} from "@/utils/eventTiming";
import { formatTimeShort, formatWeekdayShort } from "@/utils/format";
import { isMember } from "@/utils/membership";
import { cardHasData } from "@/utils/prePost";
import { useNow } from "@/utils/useNow";
import { useIsMobile } from "@/utils/useResponsive";

const monthDay = new Intl.DateTimeFormat("en-US", {
  month: "short",
  day: "numeric",
});

// "Tue, Nov 17, 6:00p - 7:00p".
function timeRange(event: Event): string | undefined {
  if (!event.scheduledTime) return undefined;
  const start = new Date(event.scheduledTime);
  const end = new Date(start.getTime() + event.durationInMinutes * 60_000);
  return `${formatWeekdayShort(start)}, ${monthDay.format(start)}, ${formatTimeShort(start)} - ${formatTimeShort(end)}`;
}

// The left column: what, when, who is going, and the button that gets you in.
export function EventInfoCard({ event }: { event: Event }) {
  const { t } = useLingui();
  const isMobile = useIsMobile();
  const { community, status, permissions } = useCommunityScope();
  const meId = useCurrentUserId();
  // The card is the page's long-lived reader of the participants, so it keeps them fresh.
  const participants =
    useEventParticipants(event.id, true, EVENT_REFRESH_MS).data ?? [];
  const self = participants.find(({ user }) => user.id === meId)?.participant;
  const isParticipant = self?.status === "active";
  const isBanned = self?.status === "banned";
  const allowed = eventPermissions({
    event,
    userId: meId,
    status,
    settings: community.settings,
    isParticipant,
  });
  const canceled = event.status === "canceled";
  const [showParticipants, setShowParticipants] = useState(false);
  const [messaging, setMessaging] = useState(false);
  const { onCancel: cancelEvent, dialog: cancelDialog } =
    useCancelEventConfirmation(event);

  // An event is tagged through its template; five tags are enough for the card.
  const tags = (useTemplateTags(community.id).data ?? [])
    .filter(({ templateId }) => templateId === event.templateId)
    .slice(0, 5);

  const range = timeRange(event);
  const eventTypeName =
    event.eventType === "hostless"
      ? t({ id: "hostless", message: "Hostless" })
      : event.eventType === "livestream"
        ? t({ id: "livestream", message: "Livestream" })
        : undefined;
  const shareUrl = absoluteUrl(
    paths.community(community.displayId).event(event.templateId, event.id),
  );
  const communityName = community.name;

  return (
    <Box
      component="section"
      sx={{
        border: "1px solid",
        borderColor: colors.outlineVariant,
        borderRadius: "12px",
        bgcolor: colors.surfaceContainerLowest,
        display: "flex",
        flexDirection: "column",
      }}
    >
      <Box
        sx={{
          px: "19px",
          pt: "20px",
          display: "flex",
          flexDirection: "column",
          gap: "10px",
        }}
      >
        <Box
          sx={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "flex-start",
          }}
        >
          <Img
            src={event.image}
            width={isMobile ? 100 : 120}
            height={isMobile ? 100 : 120}
            radius={20}
            alt=""
          />
          {allowed.canEdit && !canceled && <EventActions event={event} />}
        </Box>
        <Typography
          component="h1"
          sx={{
            fontSize: fontSizes["3xl"],
            lineHeight: 1.2,
            fontWeight: 400,
            color: "primary.main",
            textDecoration: canceled ? "line-through" : "none",
            // eslint-disable-next-line lingui/no-unlocalized-strings
            overflowWrap: "anywhere",
          }}
        >
          {event.title}
        </Typography>
        {range && (
          <Typography
            sx={{
              fontSize: fontSizes.md,
              fontWeight: 700,
              color: colors.onSurfaceVariant,
            }}
          >
            {range}
          </Typography>
        )}
        <Box
          sx={{
            display: "flex",
            alignItems: "center",
            gap: "20px",
            flexWrap: "wrap",
          }}
        >
          <Visibility
            event={event}
            canSeePublic={allowed.isHost || permissions.canEditCommunity}
          />
          {eventTypeName && (
            <Typography sx={{ color: colors.onSurfaceVariant }}>
              {eventTypeName}
            </Typography>
          )}
        </Box>
        {tags.length > 0 && (
          <Typography sx={{ color: colors.onSurfaceVariant }}>
            {tags.map(({ tag }) => `#${tag.title}`).join(" ")}
          </Typography>
        )}
        <EventPageParticipantsList
          event={event}
          iconSize={34}
          maxAvatars={isMobile ? 4 : 6}
          onOpen={
            event.eventType === "hosted" || permissions.canEditCommunity
              ? () => setShowParticipants(true)
              : undefined
          }
        />
        <ParticipantsDialog
          event={event}
          open={showParticipants}
          onClose={() => setShowParticipants(false)}
        />
        {canceled ? (
          <Typography sx={{ color: colors.error, fontWeight: 700 }}>
            {t({
              id: "thisEventWasCanceled",
              message: "This event was canceled.",
            })}
          </Typography>
        ) : (
          <JoinSection
            event={event}
            isParticipant={isParticipant}
            isBanned={isBanned}
            canJoin={allowed.canJoin}
          />
        )}
        <Box
          sx={{
            display: "flex",
            flexDirection: "column",
            gap: "10px",
            alignItems: "center",
          }}
        >
          {!canceled && (isParticipant || allowed.isHost) && (
            <AddToCalendar event={event} />
          )}
          {allowed.canCancelParticipation && !canceled && (
            <CancelRsvp event={event} />
          )}
          {allowed.canCancelEvent && !canceled && (
            <>
              <ActionButton
                type="text"
                icon={<CloseIcon fontSize="small" />}
                onPress={cancelEvent}
              >
                {t({ id: "cancelEvent", message: "Cancel Event" })}
              </ActionButton>
              {cancelDialog}
            </>
          )}
          {allowed.canEdit && (
            <>
              <ActionButton
                type="text"
                icon={<SendIcon fontSize="small" />}
                onPress={() => setMessaging(true)}
              >
                {t({
                  id: "messageParticipants",
                  message: "Message Participants",
                })}
              </ActionButton>
              <MessageParticipantsDialog
                event={event}
                open={messaging}
                onClose={() => setMessaging(false)}
              />
            </>
          )}
        </Box>
      </Box>
      <Box sx={{ px: "20px", py: "10px" }}>
        <ShareSection
          url={shareUrl}
          subject={t`Join my event on ${appName}!`}
          body={
            event.title
              ? t`Join me in a conversation about "${event.title}" on ${communityName}!`
              : t`Join an event with me on ${appName}!`
          }
          size={40}
          iconSize={20}
          buttonPadding={4}
        />
      </Box>
    </Box>
  );
}

function Visibility({
  event,
  canSeePublic,
}: {
  event: Event;
  canSeePublic: boolean;
}) {
  const { t } = useLingui();
  // Everyone is told when an event is private; only people who run it need to hear that it is public.
  if (event.isPublic && !canSeePublic) return null;
  const Icon = event.isPublic ? PublicIcon : LockIcon;
  const label = event.isPublic
    ? t({ id: "publicVisibility", message: "Public" })
    : t({ id: "privateVisibility", message: "Private" });
  return (
    <Box
      sx={{
        display: "flex",
        alignItems: "center",
        gap: "6px",
        color: colors.onSurfaceVariant,
      }}
    >
      <Icon aria-hidden fontSize="small" />
      <Typography>{label}</Typography>
    </Box>
  );
}

function Warning({
  icon,
  title,
  message,
}: {
  icon: ReactNode;
  title: string;
  message?: string;
}) {
  return (
    <Box
      role="status"
      sx={{ display: "flex", gap: "10px", alignItems: "flex-start", py: "6px" }}
    >
      {icon}
      <Box>
        <Typography sx={{ fontWeight: 700, color: colors.error }}>
          {title}
        </Typography>
        {message && (
          <Typography sx={{ color: colors.onSurfaceVariant }}>
            {message}
          </Typography>
        )}
      </Box>
    </Box>
  );
}

// The primary button: RSVP, enter, or the reason there is none.
function JoinSection({
  event,
  isParticipant,
  isBanned,
  canJoin,
}: {
  event: Event;
  isParticipant: boolean;
  isBanned: boolean;
  canJoin: boolean;
}) {
  const { t } = useLingui();
  const toast = useToast();
  const now = useNow();
  const { community, status, permissions } = useCommunityScope();
  const participants = useEventParticipants(event.id).data;
  const join = useJoinEvent();
  const { guard, dialog } = useGuardSignedIn();
  const attended = useHasAttendedTemplate(event.prerequisiteTemplateId);
  const [followCommunity, setFollowCommunity] = useState(true);
  const communityName = community.name;

  const start = event.scheduledTime ? new Date(event.scheduledTime) : now;
  const activeCount = (participants ?? []).filter(
    ({ participant }) => participant.status === "active",
  ).length;
  const headcount =
    event.eventType === "hosted"
      ? activeCount
      : Math.max(1, event.participantCountEstimate ?? 0);
  const isFull =
    event.eventType === "hosted" &&
    headcount >= effectiveMaxParticipants(event);
  const needsPrerequisite =
    !!event.prerequisiteTemplateId &&
    attended.data !== true &&
    !isParticipant &&
    !permissions.canEditCommunity;
  const canFollow =
    !isMember(status) && !community.settings.requireApprovalToJoin;

  const minutesToStart = (start.getTime() - now.getTime()) / 60_000;
  const nearlyStarted =
    canJoin && !isFull && minutesToStart <= MINUTES_BEFORE_EVENT_TO_JOIN;
  const showEnter = isParticipant || nearlyStarted;

  const fail = (error: unknown) =>
    toast.error(
      error instanceof Error
        ? error.message
        : t`Something went wrong. Please try again.`,
    );
  const prePostEnabled = usePrePostEnabled(
    event.communityId,
    cardHasData(event.preEventCard),
  );
  const [showPreEvent, setShowPreEvent] = useState(false);
  const { ask: askSurvey, dialog: surveyDialog } = useSurveyDialog(event);
  const rsvp = async () => {
    try {
      // Questions come first; backing out of them leaves the person not signed up.
      const survey = event.surveyQuestions?.length
        ? await askSurvey()
        : undefined;
      if (event.surveyQuestions?.length && !survey) return;
      await join.mutateAsync({
        event,
        joinCommunity: canFollow && followCommunity,
        survey,
      });
      // The host's message for new sign-ups appears once, right after they sign up.
      if (prePostEnabled.data && cardHasData(event.preEventCard))
        setShowPreEvent(true);
    } catch (error) {
      fail(error);
    }
  };
  const preEventDialog =
    showPreEvent && event.preEventCard ? (
      <PrePostEventDialog
        event={event}
        card={event.preEventCard}
        onClose={() => setShowPreEvent(false)}
      />
    ) : null;

  if (needsPrerequisite) {
    return (
      <Warning
        icon={<SchoolIcon sx={{ color: colors.error }} />}
        title={t({ id: "prereqRequired", message: "Prerequisite required" })}
      />
    );
  }
  if (isBanned) {
    return (
      <Warning
        icon={<LockIcon sx={{ color: colors.error }} />}
        title={t({ id: "prereqRequired", message: "Prerequisite required" })}
        message={t({
          id: "removedFromEvent",
          message: "You were removed from this event and cannot rejoin.",
        })}
      />
    );
  }
  if (event.isLocked) {
    return (
      <Warning
        icon={<LockIcon sx={{ color: colors.error }} />}
        title={t({ id: "locked", message: "Locked" })}
        message={t({ id: "eventIsLocked", message: "This event is locked" })}
      />
    );
  }

  if (showEnter) {
    const state = startState(start, now);
    const open = state.kind === "open";
    const label =
      state.kind === "days"
        ? t`Starts in ${state.days} Days`
        : state.kind === "tomorrow"
          ? t({ id: "startsTomorrow", message: "Starts Tomorrow" })
          : state.kind === "countdown"
            ? t`Starts in ${formatCountdown(state.ms)}`
            : state.kind === "ended"
              ? t({ id: "eventEnded", message: "Event Ended" })
              : t({ id: "enterEvent", message: "Enter Event" });
    const onPress = () =>
      guard(async () => {
        if (!isParticipant) await rsvp();
        if (state.kind === "ended") return;
        toast.show(
          open
            ? t({
                id: "liveEventsNotHereYet",
                message:
                  "Live events can't be joined from this version of the app yet.",
              })
            : t({
                id: "eventHasNotStartedYet",
                message: "The event has not started yet. We'll see you soon!",
              }),
        );
      });
    return (
      <>
        <ActionButton
          height={64}
          expand
          type={open ? "filled" : "outline"}
          onPress={onPress}
        >
          {label}
        </ActionButton>
        {dialog}
        {preEventDialog}
        {surveyDialog}
      </>
    );
  }
  if (isFull) {
    return (
      <ActionButton
        height={64}
        expand
        text={t({ id: "eventFull", message: "FULL" })}
      />
    );
  }
  if (!canJoin) return null;
  return (
    <>
      <ActionButton height={64} expand onPress={() => guard(rsvp)}>
        {t({ id: "rsvp", message: "RSVP" })}
      </ActionButton>
      {canFollow && (
        <FormControlLabel
          control={
            <Checkbox
              checked={followCommunity}
              onChange={(_event, checked) => setFollowCommunity(checked)}
            />
          }
          label={t({
            id: "followCommunityAccess",
            message: `Follow ${communityName} for access to all events and resources.`,
          })}
        />
      )}
      {dialog}
      {preEventDialog}
      {surveyDialog}
    </>
  );
}

function CancelRsvp({ event }: { event: Event }) {
  const { t } = useLingui();
  const toast = useToast();
  const leave = useLeaveEvent();
  const { confirm, dialog } = useConfirm();
  const onPress = async () => {
    const yes = await confirm({
      title: t({ id: "cancel", message: "Cancel" }),
      mainText: t({
        id: "confirmCancelYourParticipation",
        message:
          "Are you sure you want to cancel your participation in this event?",
      }),
      confirmText: t({ id: "yesCancel", message: "Yes, cancel" }),
      cancelText: t({ id: "no", message: "No" }),
    });
    if (yes) {
      await leave
        .mutateAsync({ event })
        .catch(() => toast.error(t`Something went wrong. Please try again.`));
    }
  };
  return (
    <>
      <ActionButton
        type="outline"
        icon={<CloseIcon fontSize="small" />}
        onPress={onPress}
      >
        {t({ id: "cancel", message: "Cancel" })}
      </ActionButton>
      {dialog}
    </>
  );
}

export function useCancelEventConfirmation(event: Event) {
  const { t } = useLingui();
  const toast = useToast();
  const cancel = useCancelEvent();
  const { confirm, dialog } = useConfirm();

  const onCancel = async () => {
    const yes = await confirm({
      title: t({ id: "cancelEvent", message: "Cancel Event" }),
      mainText: t({
        id: "cancelEventConfirmation",
        message:
          "Are you sure you want to cancel this event? This action cannot be undone.",
      }),
      confirmText: t({ id: "cancelEvent", message: "Cancel Event" }),
      cancelText: t({ id: "keepEvent", message: "Keep Event" }),
      destructive: true,
    });
    if (yes) {
      await cancel.mutateAsync({ event }).catch(() => {
        toast.error(t`Something went wrong. Please try again.`);
      });
    }
  };

  return { onCancel, dialog };
}

// The host's controls: settings, edit, and a menu of the rarer actions.
function EventActions({ event }: { event: Event }) {
  const { t } = useLingui();
  const toast = useToast();
  const meId = useCurrentUserId();
  const { community, status, permissions, templates } = useCommunityScope();
  const refresh = useRefreshEventFromTemplate();
  const createEvent = useCreateEventDialog();
  const { confirm, dialog } = useConfirm();
  const { onCancel: cancelEvent, dialog: cancelDialog } =
    useCancelEventConfirmation(event);
  const [anchor, setAnchor] = useState<HTMLElement | null>(null);
  const [editing, setEditing] = useState(false);
  const [configuring, setConfiguring] = useState(false);
  const allowed = eventPermissions({
    event,
    userId: meId,
    status,
    settings: community.settings,
    isParticipant: false,
  });
  const hasTemplate = event.templateId !== DEFAULT_TEMPLATE_ID;
  const failed = () => toast.error(t`Something went wrong. Please try again.`);

  const onCancel = () => {
    setAnchor(null);
    return cancelEvent();
  };

  const onRefresh = async () => {
    setAnchor(null);
    const yes = await confirm({
      title: t({
        id: "confirmRefreshTemplate",
        message: "Are you sure you want to refresh the template?",
      }),
      mainText: t({
        id: "resetEventToTemplateWarning",
        message:
          "Your event will be reset to the original template. The list of attendees will not be affected.",
      }),
      confirmText: t({ id: "yesRefresh", message: "Yes, refresh" }),
      cancelText: t({ id: "cancel", message: "Cancel" }),
    });
    if (yes) await refresh.mutateAsync({ event }).catch(failed);
  };

  const onDuplicate = () => {
    setAnchor(null);
    const template = templates.find(
      (candidate) => candidate.id === event.templateId,
    );
    if (!template) return;
    createEvent.open({
      template,
      isPublic: event.isPublic,
      eventType: event.eventType,
      durationInMinutes: event.durationInMinutes,
    });
  };

  const canDuplicate =
    permissions.canCreateEvent &&
    templates.some((candidate) => candidate.id === event.templateId);

  return (
    <Box sx={{ display: "flex", gap: "5px" }}>
      <CircleIconButton
        icon={<SettingsIcon />}
        tooltip={t({ id: "eventSettings", message: "Event Settings" })}
        color={colors.surfaceContainer}
        iconColor={colors.onSurface}
        size={40}
        onClick={() => setConfiguring(true)}
      />
      <CircleIconButton
        icon={<EditIcon />}
        tooltip={t({ id: "editEvent", message: "Edit event" })}
        color={colors.surfaceContainer}
        iconColor={colors.onSurface}
        size={40}
        onClick={() => setEditing(true)}
      />
      <CircleIconButton
        icon={<MoreIcon />}
        tooltip={t({ id: "showOptions", message: "Show Options" })}
        color={colors.surfaceContainer}
        iconColor={colors.onSurface}
        size={40}
        onClick={(click) => setAnchor(click.currentTarget)}
      />
      <Menu anchorEl={anchor} open={!!anchor} onClose={() => setAnchor(null)}>
        {hasTemplate && allowed.canRefreshTemplate && (
          <MenuItem onClick={onRefresh}>
            {t({ id: "refreshTemplate", message: "Refresh Template" })}
          </MenuItem>
        )}
        {canDuplicate && (
          <MenuItem onClick={onDuplicate}>
            {t({ id: "duplicateEvent", message: "Duplicate Event" })}
          </MenuItem>
        )}
        {allowed.canCancelEvent && (
          <MenuItem onClick={onCancel}>
            {t({ id: "cancelEvent", message: "Cancel Event" })}
          </MenuItem>
        )}
      </Menu>
      <EditEventDrawer
        event={event}
        open={editing}
        onClose={() => setEditing(false)}
        onCancelEvent={allowed.canCancelEvent ? onCancel : undefined}
      />
      <EventSettingsDrawer
        event={event}
        open={configuring}
        onClose={() => setConfiguring(false)}
      />
      {createEvent.dialog}
      {dialog}
      {cancelDialog}
    </Box>
  );
}

function AddToCalendar({ event }: { event: Event }) {
  const { t } = useLingui();
  const [anchor, setAnchor] = useState<HTMLElement | null>(null);
  const links = useCalendarLinks(event, !!anchor).data;

  const open = (url: string) => {
    setAnchor(null);
    if (url) window.open(url, "_blank", "noopener,noreferrer");
  };
  const download = (text: string) => {
    setAnchor(null);
    if (!text) return;
    const url = URL.createObjectURL(
      new Blob([text], { type: "text/calendar" }),
    );
    // eslint-disable-next-line lingui/no-unlocalized-strings
    const link = document.createElement("a");
    link.href = url;
    // The downloaded file's name, not UI text.
    // eslint-disable-next-line lingui/no-unlocalized-strings
    link.download = "invite.ics";
    link.click();
    URL.revokeObjectURL(url);
  };

  return (
    <>
      <ActionButton
        type="text"
        icon={<CalendarIcon fontSize="small" />}
        onPress={(click) => setAnchor(click.currentTarget)}
      >
        {t({ id: "addToCalendar", message: "Add to calendar" })}
      </ActionButton>
      <Menu anchorEl={anchor} open={!!anchor} onClose={() => setAnchor(null)}>
        <MenuItem disabled={!links} onClick={() => open(links?.google ?? "")}>
          {t({ id: "googleCalendar", message: "Google Calendar" })}
        </MenuItem>
        <MenuItem disabled={!links} onClick={() => open(links?.outlook ?? "")}>
          {t({ id: "outlookCalendar", message: "Outlook Calendar" })}
        </MenuItem>
        <MenuItem
          disabled={!links}
          onClick={() => open(links?.office365 ?? "")}
        >
          {t({ id: "office365Calendar", message: "Office 365 Calendar" })}
        </MenuItem>
        <MenuItem disabled={!links} onClick={() => download(links?.ics ?? "")}>
          {t({ id: "iCalCalendar", message: "iCal Calendar" })}
        </MenuItem>
      </Menu>
    </>
  );
}
