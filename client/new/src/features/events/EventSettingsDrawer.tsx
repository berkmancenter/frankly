import CloseIcon from "@mui/icons-material/Close";
import Box from "@mui/material/Box";
import Drawer from "@mui/material/Drawer";
import IconButton from "@mui/material/IconButton";
import Switch from "@mui/material/Switch";
import TextField from "@mui/material/TextField";
import Typography from "@mui/material/Typography";
import CircleIcon from "@mui/icons-material/Circle";
import { useLingui } from "@lingui/react/macro";
import { useState } from "react";
import {
  ALL_EVENT_SETTING_FLAGS,
  type Event,
  type AnyEventSettingFlag,
  type EventSettingFlag,
  type EventSettings,
} from "@/api/types";
import { ActionButton } from "@/components/ActionButton";
import { useConfirm } from "@/components/ConfirmDialog";
import { useToast } from "@/components/Toast";
import { useUpdateEventSettings } from "@/queries/events";
import { enableDevEventSettings } from "@/utils/appInfo";
import { useCommunityScope } from "@/scopes/CommunityScope";

const MAX_GRACE_MINUTES = 120;

interface Props {
  event: Event;
  open: boolean;
  onClose: () => void;
}

export function EventSettingsDrawer(props: Props) {
  // Remounted on every open, so each edit starts from the saved settings.
  return props.open ? <Editor {...props} /> : null;
}

function Editor({ event, onClose }: Props) {
  const { t } = useLingui();
  const toast = useToast();
  const update = useUpdateEventSettings();
  const { confirm, dialog } = useConfirm();
  const { community, templates } = useCommunityScope();

  // What this event starts from: its template's settings, else the community's.
  const template = templates.find(
    (candidate) => candidate.id === event.templateId,
  );
  const defaults: EventSettings =
    template?.eventSettings ?? community.eventSettings;
  const saved: EventSettings = event.eventSettings ?? community.eventSettings;
  const [settings, setSettings] = useState<EventSettings>(saved);
  const [grace, setGrace] = useState(
    String(saved.autoEndGracePeriodMinutes ?? 0),
  );

  const value = (flag: EventSettingFlag, fallback = false) =>
    settings[flag] ?? fallback;
  const set = (flag: EventSettingFlag, on: boolean) =>
    setSettings((current) => ({ ...current, [flag]: on }));
  const changedFromDefault = (flag: EventSettingFlag) =>
    (settings[flag] ?? false) !== (defaults[flag] ?? false);
  const same = (a: EventSettings, b: EventSettings) =>
    a.autoEndGracePeriodMinutes === b.autoEndGracePeriodMinutes &&
    ALL_EVENT_SETTING_FLAGS.every((flag) => a[flag] === b[flag]);
  const dirty = !same(settings, saved);

  // Whole minutes, 0-120.
  const correctedGrace = Math.min(
    MAX_GRACE_MINUTES,
    Math.max(0, Math.floor(Number(grace) || 0)),
  );

  const close = async () => {
    if (!dirty) return onClose();
    const discard = await confirm({
      title: t({ id: "unsavedChanges", message: "Unsaved changes" }),
      mainText: t({
        id: "discardSettingsChanges",
        message: "You have unsaved changes to these settings. Discard them?",
      }),
      confirmText: t({ id: "discard", message: "Discard" }),
      cancelText: t({ id: "keepEditing", message: "Keep editing" }),
      destructive: true,
    });
    if (discard) onClose();
  };

  const save = async () => {
    try {
      await update.mutateAsync({
        event,
        settings: {
          ...settings,
          ...(value("autoEndMeeting")
            ? { autoEndGracePeriodMinutes: correctedGrace }
            : {}),
        },
      });
      onClose();
    } catch {
      toast.error(t`Something went wrong. Please try again.`);
    }
  };

  const rows: {
    flag: EventSettingFlag;
    label: string;
    checked: boolean;
    marked: boolean;
  }[] = [
    {
      flag: "chat",
      label: t({ id: "chat", message: "Chat" }),
      checked: value("chat"),
      marked: changedFromDefault("chat"),
    },
    {
      flag: "showChatMessagesInRealTime",
      label: t({ id: "floatingChat", message: "Floating Chat" }),
      // Floating chat only means something while chat is on.
      checked: value("showChatMessagesInRealTime") && value("chat"),
      marked: changedFromDefault("showChatMessagesInRealTime"),
    },
    {
      flag: "alwaysRecord",
      label: t({ id: "record", message: "Recording" }),
      checked: value("alwaysRecord"),
      marked: changedFromDefault("alwaysRecord"),
    },
    {
      flag: "alwaysTranscribe",
      label: t({ id: "transcription", message: "Transcription" }),
      checked: value("alwaysTranscribe"),
      marked: changedFromDefault("alwaysTranscribe"),
    },
    {
      flag: "autoEndMeeting",
      label: t({ id: "autoEndMeeting", message: "Auto-end meeting" }),
      checked: value("autoEndMeeting"),
      marked: changedFromDefault("autoEndMeeting"),
    },
    {
      flag: "talkingTimer",
      label: t({ id: "odometer", message: "Odometer" }),
      checked: value("talkingTimer"),
      marked: changedFromDefault("talkingTimer"),
    },
    {
      flag: "agendaPreview",
      label: t({ id: "previewAgenda", message: "Preview Agenda" }),
      checked: value("agendaPreview", true),
      marked: false,
    },
  ];

  return (
    <Drawer
      anchor="right"
      open
      onClose={close}
      slotProps={{ paper: { sx: { width: "min(376px, 100vw)", p: "30px" } } }}
    >
      <Box
        sx={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          mb: "30px",
        }}
      >
        <Typography component="h2" sx={{ fontSize: 24 }}>
          {t({ id: "eventSettings", message: "Event Settings" })}
        </Typography>
        <IconButton aria-label={t`Close`} onClick={close}>
          <CloseIcon />
        </IconButton>
      </Box>
      <Box sx={{ display: "flex", flexDirection: "column", gap: "6px" }}>
        {rows.map(({ flag, label, checked, marked }) => (
          <Box key={flag}>
            <Box
              sx={{
                display: "flex",
                flexDirection: "row",
                alignItems: "center",
                justifyContent: "space-between",
              }}
            >
              <Box
                sx={{
                  display: "flex",
                  flexDirection: "row",
                  alignItems: "center",
                }}
              >
                {marked && (
                  <CircleIcon
                    fontSize="small"
                    sx={{ fontSize: ".5rem", mr: "4px" }}
                  />
                )}
                <Typography>{label}</Typography>
              </Box>
              <Switch
                checked={checked}
                slotProps={{ input: { "aria-label": label } }}
                onChange={(_change, on) => set(flag, on)}
              />
            </Box>
            {flag === "autoEndMeeting" && value("autoEndMeeting") && (
              <Box
                sx={{
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "space-between",
                  pl: "16px",
                  gap: "10px",
                }}
              >
                <Typography>
                  {t({
                    id: "gracePeriodMinutes",
                    message: "Grace period (0-120 min):",
                  })}
                </Typography>
                <TextField
                  size="small"
                  type="number"
                  value={grace}
                  onChange={(change) => setGrace(change.target.value)}
                  onBlur={() => setGrace(String(correctedGrace))}
                  error={
                    grace !== "" &&
                    String(correctedGrace) !== String(Number(grace))
                  }
                  sx={{ width: 84 }}
                  slotProps={{
                    htmlInput: {
                      min: 0,
                      max: MAX_GRACE_MINUTES,
                      "aria-label": t`Grace period in minutes`,
                    },
                  }}
                />
              </Box>
            )}
          </Box>
        ))}
      </Box>
      <Box
        sx={{
          display: "flex",
          flexDirection: "column",
          gap: "16px",
          mt: "40px",
        }}
      >
        <ActionButton expand onPress={save}>
          {t({ id: "saveSettings", message: "Save Settings" })}
        </ActionButton>
        <ActionButton
          expand
          type="outline"
          disabled={same(settings, defaults)}
          onPress={() => {
            setSettings(defaults);
            setGrace(String(defaults.autoEndGracePeriodMinutes ?? 0));
          }}
        >
          {t({ id: "restoreSettings", message: "Restore Default Settings" })}
        </ActionButton>
      </Box>
      {enableDevEventSettings() && (
        <Box component="section" sx={{ mt: "40px" }}>
          <Typography component="h3" sx={{ fontSize: 24, mb: "20px" }}>
            {t({ id: "devSettings", message: "Developer Settings" })}
          </Typography>
          {ALL_EVENT_SETTING_FLAGS.map((flag: AnyEventSettingFlag) => (
            <Box
              key={flag}
              sx={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}
            >
              <Typography>{flag}</Typography>
              <Switch
                checked={settings[flag] ?? false}
                slotProps={{ input: { "aria-label": flag } }}
                onChange={(_change, on) =>
                  setSettings((current) => ({ ...current, [flag]: on }))
                }
              />
            </Box>
          ))}
        </Box>
      )}
      {dialog}
    </Drawer>
  );
}
