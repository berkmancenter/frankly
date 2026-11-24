import ArrowBackRoundedIcon from "@mui/icons-material/ArrowBackRounded";
import ArrowForwardRoundedIcon from "@mui/icons-material/ArrowForwardRounded";
import ChairOutlinedIcon from "@mui/icons-material/ChairOutlined";
import DeckOutlinedIcon from "@mui/icons-material/DeckOutlined";
import FileDownloadOutlinedIcon from "@mui/icons-material/FileDownloadOutlined";
import GroupOutlinedIcon from "@mui/icons-material/GroupOutlined";
import LanguageOutlinedIcon from "@mui/icons-material/LanguageOutlined";
import LiveTvOutlinedIcon from "@mui/icons-material/LiveTvOutlined";
import LockOutlinedIcon from "@mui/icons-material/LockOutlined";
import Box from "@mui/material/Box";
import ButtonBase from "@mui/material/ButtonBase";
import Divider from "@mui/material/Divider";
import IconButton from "@mui/material/IconButton";
import Typography from "@mui/material/Typography";
import { useLingui } from "@lingui/react/macro";
import { useState, type ReactNode } from "react";
import { Link } from "react-router";
import type { Event } from "@/api/types";
import { paths } from "@/app/paths";
import { ActionButton } from "@/components/ActionButton";
import { EmptyPageContent } from "@/components/EmptyPageContent";
import { Img } from "@/components/Img";
import { ErrorState, LoadingState } from "@/components/States";
import { useEventRecordings } from "@/queries/eventData";
import { useAllEvents, useEventParticipants } from "@/queries/events";
import { useCommunityScope } from "@/scopes/CommunityScope";
import { colors, fontSizes } from "@/theme/tokens";
import { useClock } from "@/utils/clock";
import { formatStamp } from "@/utils/events/eventDataCsv";
import { timeZoneAbbreviation } from "@/utils/format";
import { useIsMobile } from "@/utils/useResponsive";
import { EventDataDialog } from "./EventDataDialog";

const PAGE_SIZE = 5;

// The Event Data tab: every event of the community, five at a time, each with what can be downloaded.
export function DataTab() {
  const { t } = useLingui();
  const { community } = useCommunityScope();
  const events = useAllEvents(community.id);
  const [offset, setOffset] = useState(0);

  if (events.isPending) return <LoadingState height={300} />;
  if (events.isError) {
    return (
      <ErrorState
        message={t({
          id: "errorLoadingEvents",
          message: "Something went wrong loading events. Please refresh.",
        })}
      />
    );
  }
  const all = events.data;
  if (all.length === 0)
    return <EmptyPageContent type="events" showContainer={false} />;

  const first = Math.min(
    offset,
    Math.floor((all.length - 1) / PAGE_SIZE) * PAGE_SIZE,
  );
  const end = Math.min(first + PAGE_SIZE, all.length);
  const [start, total] = [first + 1, all.length];
  return (
    <Box sx={{ pt: "12px" }}>
      <Box
        sx={{
          bgcolor: colors.surfaceContainerLowest,
          borderRadius: "16px",
          p: "16px",
        }}
      >
        {all.slice(first, end).map((event) => (
          <EventRow key={event.id} event={event} />
        ))}
      </Box>
      <Box
        sx={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          p: "16px",
        }}
      >
        <Typography sx={{ fontWeight: 700 }}>
          {`${all.length} ${t({ id: "events", message: "Events" })}`}
        </Typography>
        <Box sx={{ display: "flex", alignItems: "center" }}>
          <IconButton
            aria-label={t({ id: "previousPage", message: "Previous page" })}
            disabled={first === 0}
            onClick={() => setOffset(first - PAGE_SIZE)}
          >
            <ArrowBackRoundedIcon />
          </IconButton>
          <Typography sx={{ fontWeight: 700 }}>
            {t({
              id: "adminEventPagination",
              message: `${start} - ${end} of ${total}`,
            })}
          </Typography>
          <IconButton
            aria-label={t({ id: "nextPage", message: "Next page" })}
            disabled={first + PAGE_SIZE >= all.length}
            onClick={() => setOffset(first + PAGE_SIZE)}
          >
            <ArrowForwardRoundedIcon />
          </IconButton>
        </Box>
      </Box>
    </Box>
  );
}

function Detail({ icon, children }: { icon: ReactNode; children: ReactNode }) {
  return (
    <Box sx={{ display: "flex", alignItems: "center", gap: "4px" }}>
      {icon}
      <Typography sx={{ fontWeight: 500 }}>{children}</Typography>
    </Box>
  );
}

function EventRow({ event }: { event: Event }) {
  const { t } = useLingui();
  const isMobile = useIsMobile();
  const clock = useClock();
  const [open, setOpen] = useState(false);
  const participants = useEventParticipants(event.id);
  const registered = (participants.data ?? []).filter(
    ({ participant }) => participant.status === "active",
  ).length;

  const start = event.scheduledTime ? new Date(event.scheduledTime) : undefined;
  const inPast = !!start && start.getTime() < clock.now().getTime();
  const hasRecording = event.eventSettings?.alwaysRecord ?? false;
  const hasTranscript = event.eventSettings?.alwaysTranscribe ?? false;
  const recordings = useEventRecordings(
    event,
    inPast && (hasRecording || hasTranscript),
  );

  const details = (
    <Box
      sx={{
        display: "flex",
        justifyContent: "space-between",
        gap: "16px",
        maxWidth: isMobile ? undefined : 400,
      }}
    >
      <Detail icon={<GroupOutlinedIcon />}>
        {`${registered} ${t({ id: "registered", message: "Registered" })}`}
      </Detail>
      <Detail
        icon={event.isPublic ? <LanguageOutlinedIcon /> : <LockOutlinedIcon />}
      >
        {event.isPublic
          ? t({ id: "publicVisibility", message: "Public" })
          : t({ id: "privateVisibility", message: "Private" })}
      </Detail>
      <Detail
        icon={
          event.eventType === "livestream" ? (
            <LiveTvOutlinedIcon />
          ) : event.eventType === "hosted" ? (
            <ChairOutlinedIcon />
          ) : (
            <DeckOutlinedIcon />
          )
        }
      >
        {event.eventType === "livestream"
          ? t({ id: "livestream", message: "Livestream" })
          : event.eventType === "hosted"
            ? t({ id: "hosted", message: "Hosted" })
            : t({ id: "hostless", message: "Hostless" })}
      </Detail>
    </Box>
  );

  // Nothing to take from an event that has not happened and has nobody signed up.
  const showDownload = !participants.isPending && (inPast || registered > 0);
  const download = showDownload && (
    <ActionButton
      type="text"
      icon={<FileDownloadOutlinedIcon />}
      onPress={() => {
        recordings.repairNow();
        setOpen(true);
      }}
    >
      {t({ id: "dataDownload", message: "Data Download" })}
    </ActionButton>
  );

  return (
    <Box>
      <Box
        sx={{
          display: "flex",
          flexDirection: isMobile ? "column" : "row",
          justifyContent: "space-between",
          alignItems: isMobile ? "stretch" : "flex-start",
          gap: "10px",
          pt: "10px",
        }}
      >
        <ButtonBase
          component={Link}
          to={paths
            .community(event.communityDisplayId)
            .event(event.templateId, event.id)}
          sx={{
            display: "flex",
            justifyContent: "flex-start",
            alignItems: "flex-start",
            gap: "8px",
            textAlign: "left",
            color: "inherit",
          }}
        >
          <Img src={event.image} width={80} height={80} />
          <Box>
            <Typography sx={{ fontSize: fontSizes.xl }}>
              {event.title ?? t({ id: "noTitle", message: "NO TITLE" })}
            </Typography>
            {start && (
              <Typography sx={{ py: "10px" }}>
                {`${formatStamp(event.scheduledTime)} ${timeZoneAbbreviation(start)}`}
              </Typography>
            )}
            {!isMobile && details}
          </Box>
        </ButtonBase>
        {isMobile && details}
        <Box
          sx={{
            display: "flex",
            justifyContent: isMobile ? "center" : "flex-end",
          }}
        >
          {download}
        </Box>
      </Box>
      <Divider sx={{ mt: "10px" }} />
      {open && (
        <EventDataDialog
          event={event}
          registered={registered}
          inPast={inPast}
          hasRecording={hasRecording}
          hasTranscript={hasTranscript}
          recordings={recordings}
          onClose={() => setOpen(false)}
        />
      )}
    </Box>
  );
}
