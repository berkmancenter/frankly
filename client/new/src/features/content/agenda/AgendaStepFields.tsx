import DeleteIcon from "@mui/icons-material/DeleteOutlined";
import Box from "@mui/material/Box";
import IconButton from "@mui/material/IconButton";
import MenuItem from "@mui/material/MenuItem";
import TextField from "@mui/material/TextField";
import ToggleButton from "@mui/material/ToggleButton";
import ToggleButtonGroup from "@mui/material/ToggleButtonGroup";
import Typography from "@mui/material/Typography";
import { useLingui } from "@lingui/react/macro";
import { useState } from "react";
import type { AgendaItemType, VideoType } from "@/api/types";
import { AddMoreButton } from "@/components/AddMoreButton";
import { ActionButton } from "@/components/ActionButton";
import { AppDialog } from "@/components/AppDialog";
import { Img } from "@/components/Img";
import { Upload } from "@/components/Upload";
import { colors } from "@/theme/tokens";
import { AGENDA_ITEM_TYPES, type AgendaDraft, type AgendaProblem } from "@/utils/agenda";
import { useAgendaTypeLabel } from "./agendaTypes";

const TITLE_MAX = 50;

interface Props {
  draft: AgendaDraft;
  onChange: (draft: AgendaDraft) => void;
  // The problem to point at once the person tries to save.
  problem: AgendaProblem | undefined;
}

// The step's length, as minutes and seconds.
export function TimeFields({ seconds, onChange }: { seconds: number; onChange: (seconds: number) => void }) {
  const { t } = useLingui();
  const minutes = Math.floor(seconds / 60);
  const rest = seconds % 60;
  const part = (raw: string) => Math.max(0, Math.floor(Number(raw) || 0));
  return (
    <Box sx={{ display: "flex", alignItems: "center", gap: "6px" }}>
      <TextField
        size="small"
        type="number"
        value={minutes}
        onChange={(change) => onChange(part(change.target.value) * 60 + rest)}
        slotProps={{ htmlInput: { min: 0, "aria-label": t({ id: "agendaMinutes", message: "Minutes" }) } }}
        sx={{ width: 80 }}
      />
      <Typography aria-hidden>:</Typography>
      <TextField
        size="small"
        type="number"
        value={rest}
        onChange={(change) => onChange(minutes * 60 + Math.min(59, part(change.target.value)))}
        slotProps={{ htmlInput: { min: 0, max: 59, "aria-label": t({ id: "agendaSeconds", message: "Seconds" }) } }}
        sx={{ width: 80 }}
      />
    </Box>
  );
}

export function TypePicker({ value, onChange }: { value: AgendaItemType; onChange: (type: AgendaItemType) => void }) {
  const { t } = useLingui();
  const label = useAgendaTypeLabel();
  return (
    <TextField
      select
      size="small"
      value={value}
      onChange={(change) => onChange(change.target.value as AgendaItemType)}
      slotProps={{ htmlInput: { "aria-label": t({ id: "agendaItemType", message: "Type of agenda item" }) } }}
      sx={{ minWidth: 190 }}
    >
      {AGENDA_ITEM_TYPES.map((type) => (
        <MenuItem key={type} value={type}>
          {label(type)}
        </MenuItem>
      ))}
    </TextField>
  );
}

// The fields of one agenda step, by type.
export function AgendaStepFields({ draft, onChange, problem }: Props) {
  const { t } = useLingui();
  const [uploading, setUploading] = useState(false);
  const set = (patch: Partial<AgendaDraft>) => onChange({ ...draft, ...patch });
  const titleField = (label: string) => (
    <TextField
      label={label}
      value={draft.title}
      onChange={(change) => set({ title: change.target.value })}
      error={problem === "title" || problem === "headline"}
      slotProps={{ htmlInput: { maxLength: TITLE_MAX } }}
    />
  );

  switch (draft.type) {
    case "text":
      return (
        <Box sx={{ display: "flex", flexDirection: "column", gap: "16px" }}>
          {titleField(t({ id: "enterTextTitle", message: "Title" }))}
          <TextField
            label={t({ id: "content", message: "Content" })}
            helperText={t({
              id: "keepItShortHint",
              message: "Keep it short! You don’t want people to spend time reading.",
            })}
            value={draft.content}
            onChange={(change) => set({ content: change.target.value })}
            error={problem === "message"}
            multiline
            minRows={3}
          />
        </Box>
      );
    case "video":
      return (
        <Box sx={{ display: "flex", flexDirection: "column", gap: "16px" }}>
          {titleField(t({ id: "enterVideoTitle", message: "Enter Video title" }))}
          <ToggleButtonGroup
            exclusive
            size="small"
            value={draft.videoType}
            onChange={(_change, next: VideoType | null) => next && set({ videoType: next })}
            aria-label={t({ id: "videoSource", message: "Video source" })}
          >
            <ToggleButton value="youtube">{t({ id: "videoTabYoutube", message: "YOUTUBE" })}</ToggleButton>
            <ToggleButton value="vimeo">{t({ id: "videoTabVimeo", message: "VIMEO" })}</ToggleButton>
            <ToggleButton value="url">{t({ id: "videoTabUrl", message: "URL" })}</ToggleButton>
          </ToggleButtonGroup>
          <TextField
            label={
              draft.videoType === "youtube"
                ? t({ id: "youtubeUrl", message: "YouTube URL" })
                : draft.videoType === "vimeo"
                  ? t({ id: "vimeoUrl", message: "Vimeo URL" })
                  : t({ id: "videoUrl", message: "Video URL" })
            }
            value={draft.videoUrl}
            onChange={(change) => set({ videoUrl: change.target.value })}
            error={problem === "videoUrl" || problem === "videoNotMp4"}
            helperText={problem === "videoNotMp4" ? t({ id: "linkMustBeMp4", message: "Link must be MP4" }) : undefined}
          />
        </Box>
      );
    case "image":
      return (
        <Box sx={{ display: "flex", flexDirection: "column", gap: "16px" }}>
          {titleField(t({ id: "enterImageTitle", message: "Enter Image title" }))}
          <TextField
            label={t({ id: "imageUrl", message: "Image URL" })}
            value={draft.imageUrl}
            onChange={(change) => set({ imageUrl: change.target.value })}
            error={problem === "imageUrl"}
            helperText={!draft.imageUrl ? t({ id: "imageUrlNotSet", message: "(Image URL is not set.)" }) : undefined}
          />
          {draft.imageUrl && <Img src={draft.imageUrl} width="100%" height={160} radius={8} fit="contain" alt="" />}
          <Box>
            <ActionButton type="outline" onPress={() => setUploading(true)}>
              {draft.imageUrl
                ? t({ id: "uploadNewImage", message: "Upload New Image" })
                : t({ id: "uploadImage", message: "Upload Image" })}
            </ActionButton>
          </Box>
          <AppDialog open={uploading} onClose={() => setUploading(false)} maxWidth={500} padding={30} ariaLabel={t`Upload image`}>
            <Box sx={{ pt: "20px" }}>
              <Upload
                onUploaded={({ url }) => {
                  set({ imageUrl: url });
                  setUploading(false);
                }}
              />
            </Box>
          </AppDialog>
        </Box>
      );
    case "poll":
      return (
        <Box sx={{ display: "flex", flexDirection: "column", gap: "12px" }}>
          <TextField
            label={t({ id: "pollQuestion", message: "Poll Question" })}
            placeholder={t({ id: "questionGoesHere", message: "Question goes here" })}
            value={draft.content}
            onChange={(change) => set({ content: change.target.value })}
            error={problem === "question"}
            multiline
          />
          {draft.answers.map((answer, index) => (
            <Box key={index} sx={{ display: "flex", alignItems: "center", gap: "6px" }}>
              <TextField
                fullWidth
                size="small"
                placeholder={t({ id: "addOption", message: "Add option" })}
                value={answer}
                onChange={(change) =>
                  set({ answers: draft.answers.map((existing, i) => (i === index ? change.target.value : existing)) })
                }
                error={problem === "duplicateAnswers" && draft.answers.filter((other) => other === answer).length > 1}
                slotProps={{ htmlInput: { "aria-label": t({ id: "pollOptionNumber", message: `Option ${index + 1}` }) } }}
              />
              <IconButton
                aria-label={t({ id: "deleteOption", message: "Delete option" })}
                onClick={() => set({ answers: draft.answers.filter((_, i) => i !== index) })}
              >
                <DeleteIcon />
              </IconButton>
            </Box>
          ))}
          {problem === "answers" && (
            <Typography color="error">{t({ id: "pleaseAddSomeAnswers", message: "Please add some answers" })}</Typography>
          )}
          {problem === "duplicateAnswers" && (
            <Typography color="error">
              {t({ id: "pleaseRemoveDuplicateAnswers", message: "Please remove duplicate answers." })}
            </Typography>
          )}
          <AddMoreButton label={t({ id: "addOption", message: "Add option" })} onPress={() => set({ answers: [...draft.answers, ""] })} />
        </Box>
      );
    case "wordCloud":
      return (
        <Box sx={{ display: "flex", flexDirection: "column", gap: "12px" }}>
          <TextField
            label={t({ id: "wordCloudLabelText", message: "Word Cloud Prompt" })}
            placeholder={t({ id: "enterWordCloudPrompt", message: "Enter Word Cloud prompt" })}
            value={draft.content}
            onChange={(change) => set({ content: change.target.value })}
            error={problem === "prompt"}
            multiline
          />
          <Typography sx={{ color: colors.onSurfaceVariant }}>
            {t({
              id: "wordCloudDescription",
              message: "Participants will be asked to respond with a list of words or short phrases.",
            })}
          </Typography>
        </Box>
      );
    case "userSuggestions":
      return (
        <Box sx={{ display: "flex", flexDirection: "column", gap: "12px" }}>
          {titleField(t({ id: "headline", message: "Headline" }))}
          <Typography sx={{ color: colors.onSurfaceVariant }}>
            {t({
              id: "agendaSuggestionsDescription",
              message: "Let participants suggest agenda items and then upvote or downvote.",
            })}
          </Typography>
        </Box>
      );
  }
}
