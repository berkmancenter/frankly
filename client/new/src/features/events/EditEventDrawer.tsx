import CloseIcon from "@mui/icons-material/Close";
import EditIcon from "@mui/icons-material/Edit";
import Box from "@mui/material/Box";
import ButtonBase from "@mui/material/ButtonBase";
import Drawer from "@mui/material/Drawer";
import FormControlLabel from "@mui/material/FormControlLabel";
import IconButton from "@mui/material/IconButton";
import MenuItem from "@mui/material/MenuItem";
import Radio from "@mui/material/Radio";
import RadioGroup from "@mui/material/RadioGroup";
import Switch from "@mui/material/Switch";
import TextField from "@mui/material/TextField";
import Typography from "@mui/material/Typography";
import { plural } from "@lingui/core/macro";
import { useLingui } from "@lingui/react/macro";
import { useState } from "react";
import type { Event, EventType, EventUpdate } from "@/api/types";
import { ActionButton } from "@/components/ActionButton";
import { AppDialog } from "@/components/AppDialog";
import { useConfirm } from "@/components/ConfirmDialog";
import { Img } from "@/components/Img";
import { useToast } from "@/components/Toast";
import { Upload } from "@/components/Upload";
import { useUpdateEvent } from "@/queries/events";
import { colors } from "@/theme/tokens";
import { effectiveMaxParticipants } from "@/utils/eventTiming";

export const HOSTED_MIN_PARTICIPANTS = 2;
export const HOSTED_MAX_PARTICIPANTS = 50;

// Lengths offered: every 15 minutes, under four hours.
const DURATIONS = Array.from({ length: 15 }, (_, i) => (i + 1) * 15);

const pad = (n: number) => String(n).padStart(2, "0");
const dateInput = (d: Date) =>
  `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
const timeInput = (d: Date) => `${pad(d.getHours())}:${pad(d.getMinutes())}`;

function durationLabel(minutes: number): string {
  const hours = Math.floor(minutes / 60);
  const rest = minutes % 60;
  const hourText =
    hours > 0 ? plural(hours, { one: "# hour", other: "# hours" }) : "";
  const minuteText =
    rest > 0 ? plural(rest, { one: "# minute", other: "# minutes" }) : "";
  return [hourText, minuteText].filter(Boolean).join(" ");
}

const clampParticipants = (n: number) =>
  Math.min(HOSTED_MAX_PARTICIPANTS, Math.max(HOSTED_MIN_PARTICIPANTS, n));

interface Props {
  event: Event;
  open: boolean;
  onClose: () => void;
  // Cancelling the event is offered here too, since this is where hosts manage it.
  onCancelEvent?: () => void;
}

export function EditEventDrawer(props: Props) {
  // Remounted on every open, so each edit starts from the saved event.
  return props.open ? <Editor {...props} /> : null;
}

function Editor({ event, onClose, onCancelEvent }: Props) {
  const { t } = useLingui();
  const toast = useToast();
  const update = useUpdateEvent();
  const { confirm, dialog } = useConfirm();

  const start = event.scheduledTime ? new Date(event.scheduledTime) : undefined;
  const [eventType, setEventType] = useState<EventType>(event.eventType);
  const [image, setImage] = useState(event.image ?? "");
  const [title, setTitle] = useState(event.title ?? "");
  const [description, setDescription] = useState(event.description ?? "");
  const [isPublic, setIsPublic] = useState(event.isPublic);
  const [date, setDate] = useState(start ? dateInput(start) : "");
  const [time, setTime] = useState(start ? timeInput(start) : "");
  const [duration, setDuration] = useState(event.durationInMinutes);
  const [maxParticipants, setMaxParticipants] = useState(
    clampParticipants(effectiveMaxParticipants(event)),
  );
  const [uploading, setUploading] = useState(false);
  const [touched, setTouched] = useState(false);

  const scheduled = date && time ? new Date(`${date}T${time}`) : undefined;
  const validSchedule = !!scheduled && !Number.isNaN(scheduled.getTime());

  // Only what changed is written.
  const patch: EventUpdate = {
    ...(eventType !== event.eventType ? { eventType } : {}),
    ...(title.trim() !== (event.title ?? "") ? { title: title.trim() } : {}),
    ...(description.trim() !== (event.description ?? "")
      ? { description: description.trim() }
      : {}),
    ...(image !== (event.image ?? "") ? { image } : {}),
    ...(isPublic !== event.isPublic ? { isPublic } : {}),
    ...(validSchedule && scheduled.getTime() !== (start?.getTime() ?? NaN)
      ? { scheduledTime: scheduled.toISOString() }
      : {}),
    ...(duration !== event.durationInMinutes
      ? { durationInMinutes: duration }
      : {}),
    ...(eventType === "hosted" &&
    maxParticipants !== clampParticipants(effectiveMaxParticipants(event))
      ? { maxParticipants }
      : {}),
  };
  const dirty = Object.keys(patch).length > 0;

  const close = async () => {
    if (!dirty) return onClose();
    const discard = await confirm({
      title: t({ id: "unsavedChanges", message: "Unsaved changes" }),
      mainText: t({
        id: "discardEventChanges",
        message: "You have unsaved changes to this event. Discard them?",
      }),
      confirmText: t({ id: "discard", message: "Discard" }),
      cancelText: t({ id: "keepEditing", message: "Keep editing" }),
      destructive: true,
    });
    if (discard) onClose();
  };

  const save = async () => {
    setTouched(true);
    if (!title.trim() || !validSchedule) return;
    try {
      await update.mutateAsync({ event, patch });
      onClose();
    } catch {
      toast.error(t`Something went wrong. Please try again.`);
    }
  };

  const typeLabels: Record<EventType, string> = {
    hosted: t({ id: "hosted", message: "Hosted" }),
    hostless: t({ id: "hostless", message: "Hostless" }),
    livestream: t({ id: "livestream", message: "Livestream" }),
  };
  const typeChoices: EventType[] = ["hosted", "hostless", "livestream"];
  const heading = t({ id: "editEvent", message: "Edit event" });

  return (
    <Drawer
      anchor="right"
      open
      onClose={close}
      slotProps={{
        paper: { sx: { width: "min(420px, 100vw)", p: "30px 20px 20px" } },
      }}
    >
      <Box
        sx={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          px: "10px",
          mb: "20px",
        }}
      >
        <Typography component="h2" sx={{ fontSize: 24 }}>
          {heading}
        </Typography>
        <IconButton
          aria-label={t({ id: "closeEdit", message: "Close edit" })}
          onClick={close}
        >
          <CloseIcon />
        </IconButton>
      </Box>
      <Box
        sx={{
          display: "flex",
          flexDirection: "column",
          gap: "20px",
          overflowY: "auto",
          pt: "6px",
        }}
      >
        {(
          <RadioGroup
            value={eventType}
            onChange={(change) =>
              setEventType(change.target.value as EventType)
            }
          >
            {typeChoices.map((type) => (
              <FormControlLabel
                key={type}
                value={type}
                control={<Radio />}
                label={typeLabels[type]}
              />
            ))}
          </RadioGroup>
        )}
        <Box
          sx={{
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
          }}
        >
          <Typography sx={{ color: colors.onSurfaceVariant }}>
            {t({ id: "image", message: "Image" })}
          </Typography>
          <ButtonBase
            aria-label={t`Change picture`}
            onClick={() => setUploading(true)}
            sx={{ position: "relative", borderRadius: "6px" }}
          >
            <Img src={image} width={40} height={40} radius={6} alt="" />
            <EditIcon
              aria-hidden
              sx={{
                position: "absolute",
                right: -6,
                bottom: -6,
                fontSize: 16,
                bgcolor: "background.paper",
                borderRadius: "50%",
              }}
            />
          </ButtonBase>
        </Box>
        <TextField
          label={t({ id: "title", message: "Title" })}
          value={title}
          onChange={(change) => setTitle(change.target.value)}
          multiline
          maxRows={2}
          slotProps={{ htmlInput: { maxLength: 60 } }}
          error={touched && !title.trim()}
          helperText={
            touched && !title.trim()
              ? t({
                  id: "titleCannotBeEmpty",
                  message: "Title cannot be empty",
                })
              : undefined
          }
        />
        <TextField
          label={t({ id: "description", message: "Description" })}
          value={description}
          onChange={(change) => setDescription(change.target.value)}
          multiline
          minRows={3}
        />
        <FormControlLabel
          control={
            <Switch
              checked={isPublic}
              onChange={(_change, checked) => setIsPublic(checked)}
            />
          }
          sx={{ mx: 0 }}
          label={t({ id: "publicVisibility", message: "Public" })}
        />
        <TextField
          type="date"
          label={t({ id: "date", message: "Date" })}
          value={date}
          onChange={(change) => setDate(change.target.value)}
          slotProps={{ inputLabel: { shrink: true } }}
          error={touched && !validSchedule}
        />
        <TextField
          type="time"
          label={t({ id: "time", message: "Time" })}
          value={time}
          onChange={(change) => setTime(change.target.value)}
          slotProps={{ inputLabel: { shrink: true } }}
          error={touched && !validSchedule}
        />
        <TextField
          select
          label={t({ id: "length", message: "Length" })}
          value={DURATIONS.includes(duration) ? duration : ""}
          onChange={(change) => setDuration(Number(change.target.value))}
        >
          {DURATIONS.map((minutes) => (
            <MenuItem key={minutes} value={minutes}>
              {durationLabel(minutes)}
            </MenuItem>
          ))}
        </TextField>
        {eventType === "hosted" && (
          <TextField
            type="number"
            label={t({ id: "maximum", message: "Maximum" })}
            value={maxParticipants}
            onChange={(change) =>
              setMaxParticipants(
                clampParticipants(Math.round(Number(change.target.value)) || 0),
              )
            }
            slotProps={{
              htmlInput: {
                min: HOSTED_MIN_PARTICIPANTS,
                max: HOSTED_MAX_PARTICIPANTS,
              },
            }}
            helperText={plural(maxParticipants, {
              one: "# person",
              other: "# people",
            })}
          />
        )}
        <ActionButton expand onPress={save}>
          {t({ id: "saveEvent", message: "Save Event" })}
        </ActionButton>
        {onCancelEvent && (
          <ActionButton
            expand
            type="outline"
            color={colors.error}
            textColor={colors.error}
            onPress={() => {
              onClose();
              onCancelEvent();
            }}
          >
            {t({ id: "cancelEvent", message: "Cancel Event" })}
          </ActionButton>
        )}
      </Box>
      <AppDialog
        open={uploading}
        onClose={() => setUploading(false)}
        maxWidth={500}
        padding={30}
        ariaLabel={t`Upload image`}
      >
        <Box sx={{ pt: "20px" }}>
          <Upload
            onUploaded={({ url }) => {
              setImage(url);
              setUploading(false);
            }}
          />
        </Box>
      </AppDialog>
      {dialog}
    </Drawer>
  );
}
