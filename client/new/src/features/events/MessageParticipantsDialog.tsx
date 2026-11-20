import Box from "@mui/material/Box";
import TextField from "@mui/material/TextField";
import Typography from "@mui/material/Typography";
import { useLingui } from "@lingui/react/macro";
import { useState } from "react";
import type { Event } from "@/api/types";
import { ActionButton } from "@/components/ActionButton";
import { AppDialog } from "@/components/AppDialog";
import { useToast } from "@/components/Toast";
import { useSendEventMessage } from "@/queries/events";

// Writes an announcement to everyone registered for the event.
export function MessageParticipantsDialog({
  event,
  open,
  onClose,
}: {
  event: Event;
  open: boolean;
  onClose: () => void;
}) {
  const { t } = useLingui();
  const toast = useToast();
  const send = useSendEventMessage();
  const [message, setMessage] = useState("");
  const [touched, setTouched] = useState(false);
  const empty = !message.trim();

  const submit = async () => {
    setTouched(true);
    if (empty) return;
    try {
      await send.mutateAsync({ event, message: message.trim() });
      setMessage("");
      setTouched(false);
      onClose();
    } catch {
      toast.error(t`Something went wrong. Please try again.`);
    }
  };

  const title = t({ id: "messageParticipants", message: "Message Participants" });
  return (
    <AppDialog open={open} onClose={onClose} maxWidth={500} padding={30} ariaLabel={title}>
      <Box sx={{ display: "flex", flexDirection: "column", gap: "20px", pt: "20px" }}>
        <Typography component="h2" sx={{ fontSize: 22, textAlign: "center" }}>
          {title}
        </Typography>
        <TextField
          multiline
          minRows={4}
          autoFocus
          value={message}
          onChange={(change) => setMessage(change.target.value)}
          label={t({ id: "message", message: "Message" })}
          error={touched && empty}
          helperText={touched && empty ? t({ id: "messageCannotBeEmpty", message: "Message cannot be empty" }) : undefined}
        />
        <ActionButton expand onPress={submit}>
          {t({ id: "send", message: "Send" })}
        </ActionButton>
      </Box>
    </AppDialog>
  );
}
