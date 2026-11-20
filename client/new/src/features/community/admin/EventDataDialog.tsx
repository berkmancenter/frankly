import Box from "@mui/material/Box";
import Checkbox from "@mui/material/Checkbox";
import FormControlLabel from "@mui/material/FormControlLabel";
import Typography from "@mui/material/Typography";
import { useLingui } from "@lingui/react/macro";
import { useEffect, useState } from "react";
import { useApi } from "@/api/ApiProvider";
import type { Event } from "@/api/types";
import { ActionButton } from "@/components/ActionButton";
import { AppDialog } from "@/components/AppDialog";
import { useToast } from "@/components/Toast";
import {
  useChatData,
  useSuggestionsAndPolls,
  type EventRecordings,
} from "@/queries/eventData";
import { colors } from "@/theme/tokens";
import { downloadText } from "@/utils/csv";
import {
  chatCsv,
  chatFileName,
  pollsSuggestionsCsv,
  pollsSuggestionsFileName,
  registrationCsv,
  registrationFileName,
} from "@/utils/events/eventDataCsv";
import type { FileStatus } from "@/utils/events/recordingStatus";
import { openLinks } from "@/utils/openLinks";

interface Props {
  event: Event;
  /** How many people are registered. */
  registered: number;
  /** Whether the event has already started or is over. */
  inPast: boolean;
  hasRecording: boolean;
  hasTranscript: boolean;
  recordings: EventRecordings;
  onClose: () => void;
}

const isReady = (status: FileStatus) => status.kind === "ready";

// Choose what to take from an event: its recording, who signed up, what was said and answered, and
// the transcripts. What is not there yet shows how far along it is.
export function EventDataDialog(props: Props) {
  const { event, onClose, recordings } = props;
  const { t } = useLingui();
  const api = useApi();
  const toast = useToast();
  const chat = useChatData(event, true);
  const suggestionsAndPolls = useSuggestionsAndPolls(event, true);

  const showRecording = props.inPast && props.hasRecording;
  const showTranscript = props.inPast && props.hasTranscript;
  const showRegistrants = props.registered > 0;
  const [recording, setRecording] = useState(false);
  const [registrants, setRegistrants] = useState(showRegistrants);
  const [chatSelected, setChatSelected] = useState(false);
  const [pollsSelected, setPollsSelected] = useState(false);
  const [transcript, setTranscript] = useState(false);
  const [busy, setBusy] = useState(false);

  // A recording that becomes ready while the dialog is open is chosen for the person, once.
  const videoReady = isReady(recordings.video);
  const [autoChecked, setAutoChecked] = useState(false);
  useEffect(() => {
    if (videoReady && !autoChecked) {
      setAutoChecked(true);
      setRecording(true);
    }
  }, [videoReady, autoChecked]);

  const chatCount = chat.data?.length ?? 0;
  const pollsCount =
    (suggestionsAndPolls.data?.suggestions.length ?? 0) +
    (suggestionsAndPolls.data?.polls.length ?? 0);

  const recordingParts = (count: number) =>
    t({ id: "recordingStatusParts", message: `(${count} parts)` });
  const annotate = (status: FileStatus): string => {
    switch (status.kind) {
      case "checking":
        return ` ${t({ id: "recordingStatusChecking", message: "(checking...)" })}`;
      case "preparing":
        return ` ${t({ id: "recordingStatusPreparing", message: "(preparing...)" })}`;
      case "recording":
        return ` ${t({ id: "recordingStatusInProgress", message: "(recording...)" })}`;
      case "failed":
        return ` ${t({ id: "recordingStatusFailed", message: "(failed)" })}`;
      case "none":
        return ` (${t({ id: "none", message: "None" }).toLowerCase()})`;
      case "ready":
        return ` ${recordingParts(status.parts)}`;
    }
  };
  const available = (count: number, loading: boolean) =>
    loading
      ? `(${t({ id: "loading", message: "Loading" })}...)`
      : count > 0
        ? `(${count} ${t({ id: "items", message: "Items" })})`
        : `(${t({ id: "none", message: "None" })})`;

  const canDownload =
    (showRecording && recording && videoReady) ||
    (showRegistrants && registrants) ||
    chatSelected ||
    pollsSelected ||
    (showTranscript && transcript && isReady(recordings.transcript));

  const download = async () => {
    setBusy(true);
    try {
      if (showRecording && recording)
        await openLinks(await api.events.recordingUrls(event));
      if (showRegistrants && registrants) {
        const [people, rooms] = await Promise.all([
          api.events.registrants(event),
          api.events.breakoutRooms(event),
        ]);
        downloadText(
          registrationFileName(event.id),
          registrationCsv({
            registrants: people,
            rooms,
            eventId: event.id,
            questionTitles: (event.surveyQuestions ?? []).map(
              (question) => question.title,
            ),
          }),
        );
      }
      if (chatSelected) {
        const messages = chat.data ?? (await api.events.chatMessages(event));
        if (messages.length === 0) {
          toast.show(
            t({
              id: "noChatDataForEvent",
              message: "No chat data for this event.",
            }),
          );
        } else {
          const rooms = await api.events.breakoutRooms(event);
          downloadText(
            chatFileName(event.id),
            chatCsv({ messages, rooms, eventId: event.id }),
          );
        }
      }
      if (pollsSelected) {
        const { suggestions, polls } =
          suggestionsAndPolls.data ??
          (await api.events.suggestionsAndPolls(event));
        if (suggestions.length === 0 && polls.length === 0) {
          toast.show(
            t({
              id: "noPollsOrSuggestionsDataForEvent",
              message: "No polls or suggestions data for this event.",
            }),
          );
        } else {
          const rooms = await api.events.breakoutRooms(event);
          const prompts = new Map(
            event.agendaItems.map(
              (item) => [item.id, item.title ?? item.content ?? ""] as const,
            ),
          );
          downloadText(
            pollsSuggestionsFileName(event.id),
            pollsSuggestionsCsv({
              suggestions,
              polls,
              rooms,
              eventId: event.id,
              prompts,
            }),
          );
        }
      }
      if (showTranscript && transcript)
        await openLinks(await api.events.transcriptUrls(event));
    } catch {
      toast.error(t({ id: "errorOccurred", message: "An error occurred" }));
      setBusy(false);
      return;
    }
    setBusy(false);
    onClose();
    toast.success(t({ id: "downloadComplete", message: "Download complete" }));
  };

  return (
    <AppDialog
      open
      onClose={busy ? () => {} : onClose}
      maxWidth={450}
      padding={24}
      background={colors.surfaceContainerHighest}
      ariaLabel={t({ id: "selectData", message: "Select Data" })}
    >
      <Typography component="h2" sx={{ pb: "24px" }}>
        {t({ id: "selectData", message: "Select Data" })}
      </Typography>
      <Box
        sx={{
          bgcolor: colors.surfaceContainer,
          display: "flex",
          flexDirection: "column",
          py: "8px",
        }}
      >
        {showRecording && (
          <Choice
            checked={recording}
            disabled={!videoReady}
            onChange={setRecording}
            label={`${t({ id: "recording", message: "Recordings" })}${annotate(recordings.video)}`}
          />
        )}
        {showRegistrants && (
          <Choice
            checked={registrants}
            onChange={setRegistrants}
            label={t({
              id: "registrationDataDownload",
              message: "Registrations",
            })}
          />
        )}
        <Choice
          checked={chatSelected}
          onChange={setChatSelected}
          label={`${t({ id: "chatData", message: "Chat Data" })} ${available(chatCount, chat.isPending)}`}
        />
        <Choice
          checked={pollsSelected}
          onChange={setPollsSelected}
          label={`${t({ id: "pollsSuggestionsData", message: "Polls & Suggestions Data" })} ${available(pollsCount, suggestionsAndPolls.isPending)}`}
        />
        {showTranscript && (
          <Choice
            checked={transcript}
            disabled={!isReady(recordings.transcript)}
            onChange={setTranscript}
            label={`${t({ id: "transcriptsCsv", message: "Transcripts (CSV)" })}${annotate(recordings.transcript)}`}
          />
        )}
      </Box>
      <Box
        sx={{
          display: "flex",
          justifyContent: "flex-end",
          gap: "8px",
          pt: "16px",
        }}
      >
        <ActionButton type="text" disabled={busy} onPress={onClose}>
          {t({ id: "cancel", message: "Cancel" })}
        </ActionButton>
        <ActionButton
          type="text"
          disabled={!canDownload || busy}
          onPress={download}
        >
          {t({ id: "download", message: "Download" })}
        </ActionButton>
      </Box>
    </AppDialog>
  );
}

function Choice({
  checked,
  onChange,
  label,
  disabled = false,
}: {
  checked: boolean;
  onChange: (checked: boolean) => void;
  label: string;
  disabled?: boolean;
}) {
  return (
    <FormControlLabel
      sx={{ mx: 0, px: "16px", py: "4px" }}
      disabled={disabled}
      control={
        <Checkbox
          checked={checked}
          onChange={(event) => onChange(event.target.checked)}
        />
      }
      label={label}
    />
  );
}
