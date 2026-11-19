import ArrowDownIcon from "@mui/icons-material/ArrowDownward";
import ArrowUpIcon from "@mui/icons-material/ArrowUpward";
import CheckIcon from "@mui/icons-material/Check";
import CloseIcon from "@mui/icons-material/Close";
import CopyIcon from "@mui/icons-material/ContentCopy";
import DeleteIcon from "@mui/icons-material/DeleteOutlined";
import EditIcon from "@mui/icons-material/Edit";
import ExpandLessIcon from "@mui/icons-material/ExpandLess";
import ExpandMoreIcon from "@mui/icons-material/ExpandMore";
import Box from "@mui/material/Box";
import IconButton from "@mui/material/IconButton";
import Link from "@mui/material/Link";
import Typography from "@mui/material/Typography";
import { useLingui } from "@lingui/react/macro";
import { useState } from "react";
import type { AgendaItem } from "@/api/types";
import { useConfirm } from "@/components/ConfirmDialog";
import { Img } from "@/components/Img";
import { useToast } from "@/components/Toast";
import { freeText, wrapAnywhere } from "@/theme/freeText";
import { colors } from "@/theme/tokens";
import {
  agendaProblem,
  blankDraft,
  draftOf,
  formatStepTime,
  isEdited,
  itemOf,
  type AgendaDraft,
  type AgendaProblem,
} from "@/utils/agenda";
import { webUrl } from "@/utils/webUrl";
import { AgendaStepFields, TimeFields, TypePicker } from "./AgendaStepFields";
import { useAgendaTypeLabel } from "./agendaTypes";

export interface StepCardProps {
  item: AgendaItem;
  // A step that has not been saved yet (new, or a duplicate): it opens for editing and can be dropped.
  unsaved: boolean;
  canEdit: boolean;
  startsCollapsed: boolean;
  canMoveUp: boolean;
  canMoveDown: boolean;
  onSave: (item: AgendaItem) => Promise<unknown>;
  onDelete: () => Promise<unknown>;
  onDuplicate: () => void;
  onMove: (direction: -1 | 1) => void;
}

// One agenda step: read it, and (for editors) edit, duplicate, delete and move it.
export function AgendaStepCard(props: StepCardProps) {
  const { item, unsaved, canEdit, startsCollapsed, canMoveUp, canMoveDown, onSave, onDelete, onDuplicate, onMove } = props;
  const { t } = useLingui();
  const toast = useToast();
  const { confirm, dialog } = useConfirm();
  const typeLabel = useAgendaTypeLabel();
  const [editing, setEditing] = useState(unsaved);
  const [collapsed, setCollapsed] = useState(startsCollapsed && !unsaved);
  const [draft, setDraft] = useState<AgendaDraft>(() => draftOf(item));
  const [attempted, setAttempted] = useState(false);

  const problem = agendaProblem(draft);
  const edited = isEdited(item, draft);
  const shown = editing ? draft : draftOf(item);
  const heading = headingOf(shown, t);

  const problemMessage = (found: AgendaProblem): string => {
    switch (found) {
      case "title":
        return t({ id: "titleIsRequired", message: "Title is required" });
      case "message":
        return t({ id: "messageIsRequired", message: "Message is required" });
      case "videoUrl":
        return t({ id: "videoUrlIsRequired", message: "Video URL is required" });
      case "videoNotMp4":
        return t({ id: "linkMustBeMp4", message: "Link must be MP4" });
      case "imageUrl":
        return t({ id: "imageUrlIsRequired", message: "Image URL is required" });
      case "question":
        return t({ id: "questionIsRequired", message: "Question is required" });
      case "answers":
        return t({ id: "pleaseAddSomeAnswers", message: "Please add some answers" });
      case "duplicateAnswers":
        return t({ id: "pleaseRemoveDuplicateAnswers", message: "Please remove duplicate answers." });
      case "prompt":
        return t({ id: "wordCloudPromptRequired", message: "Word Cloud prompt is required" });
      case "headline":
        return t({ id: "headlineIsRequired", message: "Headline is required" });
    }
  };

  const save = async () => {
    setAttempted(true);
    if (problem) return toast.error(problemMessage(problem));
    try {
      await onSave(itemOf(item, draft));
      toast.success(t({ id: "agendaItemWasSaved", message: "Agenda item was saved" }));
      setEditing(false);
      setAttempted(false);
    } catch {
      toast.error(t`Something went wrong. Please try again.`);
    }
  };

  const cancel = async () => {
    if (edited) {
      const discard = await confirm({
        mainText: t({ id: "confirmDiscardChanges", message: "Are you sure you want to discard changes?" }),
        cancelText: t({ id: "cancel", message: "Cancel" }),
      });
      if (!discard) return;
    }
    if (unsaved) {
      await onDelete();
      return;
    }
    setDraft(draftOf(item));
    setAttempted(false);
    setEditing(false);
  };

  const remove = async () => {
    const yes = await confirm({
      title: t({ id: "deleteAgendaItemGeneral", message: "Delete Agenda Item" }),
      mainText: t({
        id: "confirmDeleteAgendaItem",
        message: "Are you sure you want to delete this agenda item? This action cannot be undone.",
      }),
      confirmText: t({ id: "delete", message: "Delete" }),
      cancelText: t({ id: "cancel", message: "Cancel" }),
      destructive: true,
    });
    if (!yes) return;
    try {
      await onDelete();
      toast.success(t({ id: "agendaItemWasDeleted", message: "Agenda item was deleted" }));
    } catch {
      toast.error(t`Something went wrong. Please try again.`);
    }
  };

  return (
    <Box
      component="li"
      sx={{ border: 1, borderColor: colors.outlineVariant, borderRadius: "12px", bgcolor: colors.surfaceContainerLowest }}
    >
      <Box sx={{ p: "12px", display: "flex", flexDirection: "column", gap: "16px" }}>
        <Box sx={{ display: "flex", alignItems: "center", gap: "8px" }}>
          {canEdit && !editing && (
            <Box sx={{ display: "flex" }}>
              <IconButton size="small" disabled={!canMoveUp} aria-label={t({ id: "moveUp", message: "Move up" })} onClick={() => onMove(-1)}>
                <ArrowUpIcon fontSize="small" />
              </IconButton>
              <IconButton size="small" disabled={!canMoveDown} aria-label={t({ id: "moveDown", message: "Move down" })} onClick={() => onMove(1)}>
                <ArrowDownIcon fontSize="small" />
              </IconButton>
            </Box>
          )}
          <Typography component="h4" sx={{ flex: 1, fontSize: 16, fontWeight: 500, ...wrapAnywhere }}>
            {heading}
          </Typography>
          {!editing && (
            <Typography sx={{ color: colors.onSurfaceVariant, whiteSpace: "nowrap" }}>
              {formatStepTime(item.timeInSeconds ?? 0)}
            </Typography>
          )}
          {!editing && (
            <IconButton
              aria-label={collapsed ? t({ id: "expandStep", message: "Expand" }) : t({ id: "collapseStep", message: "Collapse" })}
              aria-expanded={!collapsed}
              onClick={() => setCollapsed(!collapsed)}
            >
              {collapsed ? <ExpandMoreIcon /> : <ExpandLessIcon />}
            </IconButton>
          )}
        </Box>
        {editing && (
          <Box sx={{ display: "flex", flexWrap: "wrap", justifyContent: "space-between", gap: "10px" }}>
            <TypePicker value={draft.type} onChange={(type) => setDraft(blankDraft(type, draft.seconds))} />
            <TimeFields seconds={draft.seconds} onChange={(seconds) => setDraft({ ...draft, seconds })} />
          </Box>
        )}
      </Box>
      {!collapsed && (
        <Box sx={{ px: "16px", pb: "16px" }}>
          {editing ? (
            <AgendaStepFields draft={draft} onChange={setDraft} problem={attempted ? problem : undefined} />
          ) : (
            <StepPreview item={item} typeName={typeLabel(item.type)} />
          )}
        </Box>
      )}
      {canEdit && !collapsed && (
        <Box sx={{ borderTop: 1, borderColor: colors.outlineVariant, p: "10px 20px", display: "flex", alignItems: "center", gap: "6px" }}>
          {editing ? (
            <>
              {!unsaved && (
                <IconButton aria-label={t({ id: "deleteAgendaItemGeneral", message: "Delete Agenda Item" })} onClick={remove}>
                  <DeleteIcon />
                </IconButton>
              )}
              <Box sx={{ flex: 1 }} />
              <IconButton aria-label={t({ id: "cancel", message: "Cancel" })} onClick={cancel}>
                <CloseIcon />
              </IconButton>
              <IconButton
                aria-label={t({ id: "saveAgendaItem", message: "Save Agenda Item" })}
                disabled={!edited && !unsaved}
                onClick={save}
              >
                <CheckIcon />
              </IconButton>
            </>
          ) : (
            <>
              <Box sx={{ flex: 1 }} />
              <IconButton aria-label={t({ id: "duplicateItem", message: "Duplicate Item" })} onClick={onDuplicate}>
                <CopyIcon />
              </IconButton>
              <IconButton aria-label={t({ id: "editItem", message: "Edit Item" })} onClick={() => setEditing(true)}>
                <EditIcon />
              </IconButton>
            </>
          )}
        </Box>
      )}
      {dialog}
    </Box>
  );
}

// What a step is called in its header: its own title, or the kind of step when it has none yet.
function headingOf(draft: AgendaDraft, t: ReturnType<typeof useLingui>["t"]): string {
  switch (draft.type) {
    case "text":
      return draft.title || t({ id: "textTitle", message: "Text Title" });
    case "video":
      return draft.title || t({ id: "video", message: "Video" });
    case "image":
      return draft.title || t({ id: "image", message: "Image" });
    case "poll":
      return draft.content || t({ id: "question", message: "Question" });
    case "wordCloud":
      return draft.content || t({ id: "wordCloud", message: "Word Cloud" });
    case "userSuggestions":
      return draft.title || t({ id: "suggestions", message: "Suggestions" });
  }
}

function StepPreview({ item, typeName }: { item: AgendaItem; typeName: string }) {
  const video = item.videoUrl ? webUrl(item.videoUrl) : undefined;
  return (
    <Box sx={{ display: "flex", flexDirection: "column", gap: "8px" }}>
      <Typography variant="body2" sx={{ color: colors.onSurfaceVariant }}>
        {typeName}
      </Typography>
      {item.type === "text" && item.content && (
        <Typography sx={{ color: colors.onSurfaceVariant, ...freeText }}>{item.content}</Typography>
      )}
      {item.type === "image" && item.imageUrl && (
        <Img src={item.imageUrl} width="100%" height={200} radius={8} fit="contain" alt={item.title ?? ""} />
      )}
      {item.type === "video" && video && (
        <Link href={video} target="_blank" rel="noopener noreferrer" sx={wrapAnywhere}>
          {item.videoUrl}
        </Link>
      )}
      {item.type === "poll" && (
        <Box component="ul" sx={{ m: 0, pl: "20px" }}>
          {(item.pollAnswers ?? []).map((answer) => (
            <li key={answer}>{answer}</li>
          ))}
        </Box>
      )}
    </Box>
  );
}
