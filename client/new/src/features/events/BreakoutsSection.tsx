import ArrowDownIcon from "@mui/icons-material/ArrowDownward";
import ArrowUpIcon from "@mui/icons-material/ArrowUpward";
import CheckIcon from "@mui/icons-material/Check";
import DeleteIcon from "@mui/icons-material/DeleteOutlined";
import EditIcon from "@mui/icons-material/Edit";
import ExpandLessIcon from "@mui/icons-material/ExpandLess";
import ExpandMoreIcon from "@mui/icons-material/ExpandMore";
import Box from "@mui/material/Box";
import IconButton from "@mui/material/IconButton";
import MenuItem from "@mui/material/MenuItem";
import Slider from "@mui/material/Slider";
import TextField from "@mui/material/TextField";
import Typography from "@mui/material/Typography";
import { useLingui } from "@lingui/react/macro";
import { useState } from "react";
import type {
  BreakoutAssignmentMethod,
  Event,
  SurveyQuestion,
} from "@/api/types";
import { ActionButton } from "@/components/ActionButton";
import { AddMoreButton } from "@/components/AddMoreButton";
import { useConfirm } from "@/components/ConfirmDialog";
import { useToast } from "@/components/Toast";
import {
  useSaveSurveyQuestions,
  useUpdateBreakoutSettings,
} from "@/queries/events";
import { useCommunityScope } from "@/scopes/CommunityScope";
import { wrapAnywhere } from "@/theme/freeText";
import { colors } from "@/theme/tokens";
import {
  freeTextAvailable,
  MAX_SURVEY_QUESTIONS,
  newQuestion,
  questionComplete,
  withAnswerTitle,
  withTitle,
  withType,
} from "@/utils/surveyQuestions";

const QUESTION_MAX = 140;

// The questions people answer when they sign up, which smart matching uses to put people in rooms together.
// Communities that allow additional registration fields can make one of them free text.
function MatchingQuestions({ event }: { event: Event }) {
  const { t } = useLingui();
  const toast = useToast();
  const { community } = useCommunityScope();
  const save = useSaveSurveyQuestions();
  const [unsaved, setUnsaved] = useState<SurveyQuestion | undefined>();
  const allowFreeText = community.allowAdditionalRegistrationField;

  const saved = event.surveyQuestions ?? [];
  const yes = t({ id: "yes", message: "Yes" });
  const no = t({ id: "no", message: "No" });
  const all = unsaved ? [...saved, unsaved] : saved;

  const persist = async (questions: SurveyQuestion[], message: string) => {
    try {
      await save.mutateAsync({ event, questions });
      toast.success(message);
      return true;
    } catch {
      toast.error(t`Something went wrong. Please try again.`);
      return false;
    }
  };

  const add = () => {
    const last = all[all.length - 1];
    if (last && !questionComplete(last)) {
      toast.error(
        t({
          id: "pleaseCompletePreviousQuestionAndBothAnswers",
          message: "Please complete previous question and both answers",
        }),
      );
      return;
    }
    setUnsaved(newQuestion(yes, no));
  };

  const move = (index: number, direction: -1 | 1) => {
    const next = [...saved];
    const target = index + direction;
    if (target < 0 || target >= next.length) return;
    [next[index], next[target]] = [next[target]!, next[index]!];
    void persist(
      next,
      t({ id: "breakoutUpdated", message: "Breakout Updated!" }),
    );
  };

  return (
    <Box
      sx={{ display: "flex", flexDirection: "column", gap: "10px", pt: "20px" }}
    >
      <Typography
        component="h4"
        sx={{ fontSize: 16, fontWeight: 700, color: "primary.main" }}
      >
        {t({ id: "matchingQuestions", message: "Matching questions" })}
      </Typography>
      {allowFreeText && (
        <Typography sx={{ color: colors.onSurfaceVariant }}>
          {t({
            id: "onlyOneFreeTextQuestionNotice",
            message:
              "You can add one free text question. All other questions must be multiple choice.",
          })}
        </Typography>
      )}
      <Box
        component="ol"
        sx={{
          listStyle: "none",
          m: 0,
          p: 0,
          display: "flex",
          flexDirection: "column",
          gap: "14px",
        }}
      >
        {all.map((question, index) => (
          <QuestionCard
            key={question.id}
            question={question}
            number={index + 1}
            isUnsaved={question === unsaved}
            showTypePicker={allowFreeText}
            freeTextAllowed={freeTextAvailable(all, question.id)}
            canMoveUp={question !== unsaved && index > 0}
            canMoveDown={question !== unsaved && index < saved.length - 1}
            yes={yes}
            no={no}
            onMove={(direction) => move(index, direction)}
            onSave={async (next) => {
              const questions =
                question === unsaved
                  ? [...saved, next]
                  : saved.map((q) => (q.id === next.id ? next : q));
              const ok = await persist(
                questions,
                t({ id: "questionSaved", message: "Question saved!" }),
              );
              if (ok && question === unsaved) setUnsaved(undefined);
            }}
            onDelete={async () => {
              if (question === unsaved) return setUnsaved(undefined);
              await persist(
                saved.filter((q) => q.id !== question.id),
                t({ id: "questionDeleted", message: "Question deleted!" }),
              );
            }}
          />
        ))}
      </Box>
      {all.length < MAX_SURVEY_QUESTIONS && (
        <AddMoreButton
          label={t({ id: "addQuestion", message: "Add a question" })}
          onPress={add}
        />
      )}
    </Box>
  );
}

interface CardProps {
  question: SurveyQuestion;
  number: number;
  isUnsaved: boolean;
  showTypePicker: boolean;
  freeTextAllowed: boolean;
  canMoveUp: boolean;
  canMoveDown: boolean;
  yes: string;
  no: string;
  onMove: (direction: -1 | 1) => void;
  onSave: (question: SurveyQuestion) => Promise<unknown>;
  onDelete: () => Promise<unknown>;
}

// One question: folded away once it is complete, open for editing while it is not.
function QuestionCard({
  question,
  number,
  isUnsaved,
  showTypePicker,
  freeTextAllowed,
  canMoveUp,
  canMoveDown,
  yes,
  no,
  onMove,
  onSave,
  onDelete,
}: CardProps) {
  const { t } = useLingui();
  const { confirm, dialog } = useConfirm();
  const [draft, setDraft] = useState(question);
  const complete = questionComplete(question);
  const [editing, setEditing] = useState(!complete);
  const [expanded, setExpanded] = useState(!complete);
  const [attempted, setAttempted] = useState(false);
  const toast = useToast();

  const ready = questionComplete(draft);
  const edited = JSON.stringify(draft) !== JSON.stringify(question);
  const heading =
    question.title ||
    t({ id: "questionWithNumber", message: `Question ${number}` });

  const submit = async () => {
    setAttempted(true);
    if (!ready) {
      toast.error(
        t({
          id: "pleaseCompleteAllYourQuestionsAndAnswers",
          message: "Please complete all your questions and answers!",
        }),
      );
      return;
    }
    await onSave(draft);
    setEditing(false);
    setExpanded(false);
    setAttempted(false);
  };

  const remove = async () => {
    const yesDelete = await confirm({
      title: t({ id: "deleteOption", message: "Delete option" }),
      mainText: t({
        id: "confirmDelete",
        message: "Are you sure you want to delete?",
      }),
      confirmText: t({ id: "delete", message: "Delete" }),
      cancelText: t({ id: "cancel", message: "Cancel" }),
      destructive: true,
    });
    if (yesDelete) await onDelete();
  };

  return (
    <Box
      component="li"
      sx={{
        bgcolor: colors.surfaceContainerLowest,
        border: 1,
        borderColor: colors.outlineVariant,
        borderRadius: "10px",
      }}
    >
      <Box
        sx={{
          display: "flex",
          alignItems: "center",
          gap: "6px",
          p: "8px 12px",
        }}
      >
        {!editing && (
          <Box sx={{ display: "flex" }}>
            <IconButton
              size="small"
              disabled={!canMoveUp}
              aria-label={t({ id: "moveUp", message: "Move up" })}
              onClick={() => onMove(-1)}
            >
              <ArrowUpIcon fontSize="small" />
            </IconButton>
            <IconButton
              size="small"
              disabled={!canMoveDown}
              aria-label={t({ id: "moveDown", message: "Move down" })}
              onClick={() => onMove(1)}
            >
              <ArrowDownIcon fontSize="small" />
            </IconButton>
          </Box>
        )}
        <Typography
          sx={{
            flex: 1,
            fontSize: 16,
            fontWeight: 500,
            color: "primary.main",
            ...wrapAnywhere,
          }}
        >
          {heading}
        </Typography>
        {!editing && (
          <IconButton
            aria-label={t({ id: "editItem", message: "Edit Item" })}
            onClick={() => {
              setExpanded(true);
              setEditing(true);
            }}
          >
            <EditIcon />
          </IconButton>
        )}
        <IconButton
          aria-label={
            expanded
              ? t({ id: "collapseStep", message: "Collapse" })
              : t({ id: "expandStep", message: "Expand" })
          }
          aria-expanded={expanded}
          onClick={() => setExpanded(!expanded)}
        >
          {expanded ? <ExpandLessIcon /> : <ExpandMoreIcon />}
        </IconButton>
      </Box>
      {expanded && (
        <Box
          sx={{
            p: "10px 20px 20px",
            display: "flex",
            flexDirection: "column",
            gap: "14px",
          }}
        >
          {showTypePicker && (
            <TextField
              select
              size="small"
              disabled={!editing}
              value={draft.type}
              onChange={(change) =>
                setDraft(
                  withType(
                    draft,
                    change.target.value as SurveyQuestion["type"],
                    yes,
                    no,
                  ),
                )
              }
              slotProps={{
                htmlInput: {
                  "aria-label": t({
                    id: "questionType",
                    message: "Question type",
                  }),
                },
              }}
              sx={{ width: 200 }}
            >
              <MenuItem value="multipleChoice">
                {t({
                  id: "questionTypeMultipleChoice",
                  message: "Multiple choice",
                })}
              </MenuItem>
              <MenuItem value="freeText" disabled={!freeTextAllowed}>
                {t({ id: "questionTypeFreeText", message: "Free text" })}
              </MenuItem>
            </TextField>
          )}
          <TextField
            label={t({
              id: "enterQuestionWithNumber",
              message: `Enter Question ${number}`,
            })}
            value={draft.title}
            disabled={!editing}
            onChange={(change) =>
              setDraft(withTitle(draft, change.target.value))
            }
            error={attempted && !draft.title.trim()}
            slotProps={{ htmlInput: { maxLength: QUESTION_MAX } }}
          />
          {draft.type === "multipleChoice" &&
            draft.options.map((option, index) => (
              <TextField
                key={option.id}
                size="small"
                disabled={!editing}
                value={option.title}
                onChange={(change) =>
                  setDraft(
                    withAnswerTitle(draft, option.id, change.target.value),
                  )
                }
                error={attempted && !option.title.trim()}
                slotProps={{
                  htmlInput: {
                    "aria-label": t({
                      id: "answerNumber",
                      message: `Answer ${index + 1}`,
                    }),
                  },
                }}
              />
            ))}
          <Box
            sx={{ display: "flex", justifyContent: "flex-end", gap: "10px" }}
          >
            <IconButton
              aria-label={t({
                id: "deleteQuestion",
                message: "Delete question",
              })}
              disabled={!editing}
              onClick={isUnsaved ? () => void onDelete() : remove}
            >
              <DeleteIcon />
            </IconButton>
            <IconButton
              aria-label={t({ id: "saveQuestion", message: "Save question" })}
              disabled={!editing || (!edited && !isUnsaved)}
              onClick={submit}
            >
              <CheckIcon />
            </IconButton>
          </Box>
        </Box>
      )}
      {dialog}
    </Box>
  );
}

// Stored method names.
const BY_SIZE: BreakoutAssignmentMethod = "targetPerRoom";
const SMART_MATCH: BreakoutAssignmentMethod = "smartMatch";
const MIN_TARGET_SIZE = 2;
const MAX_TARGET_SIZE = 20;
const DEFAULT_TARGET_SIZE = 8;

// Above the agenda: how people are split into breakout rooms. By size, rooms are filled to a target number of people;
// with smart match, the sign-up questions are used to put different people together. A livestream has no breakouts
// unless the host asks for them.
export function BreakoutsSection({ event }: { event: Event }) {
  const { t } = useLingui();
  const toast = useToast();
  const save = useSaveSurveyQuestions();
  const update = useUpdateBreakoutSettings();

  if (event.eventType === "livestream" && !event.breakout) {
    return (
      <AddMoreButton
        label={t({
          id: "defineBreakoutsOptional",
          message: "Define Breakouts (Optional)",
        })}
        onPress={() =>
          save
            .mutateAsync({ event, questions: [] })
            .catch(() =>
              toast.error(t`Something went wrong. Please try again.`),
            )
        }
      />
    );
  }

  // With no definition yet, the defaults are shown; the first change stores them.
  const method = event.breakout?.assignmentMethod ?? BY_SIZE;
  const targetSize = event.breakout?.targetParticipants ?? DEFAULT_TARGET_SIZE;

  const change = async (patch: {
    assignmentMethod?: BreakoutAssignmentMethod;
    targetParticipants?: number;
  }) => {
    try {
      await update.mutateAsync({ event, patch });
      toast.success(t({ id: "breakoutUpdated", message: "Breakout Updated!" }));
    } catch {
      toast.error(t`Something went wrong. Please try again.`);
    }
  };

  return (
    <Box
      component="section"
      sx={{
        bgcolor: colors.surfaceContainer,
        borderRadius: "20px",
        p: "20px",
        display: "flex",
        flexDirection: "column",
        gap: "10px",
      }}
    >
      <Typography
        component="h3"
        sx={{ fontSize: 22, color: colors.onSurfaceVariant }}
      >
        {t({ id: "addBreakouts", message: "Add breakouts" })}
      </Typography>
      <Box sx={{ display: "flex", gap: "10px", flexWrap: "wrap" }}>
        <ActionButton
          type={method === BY_SIZE ? "filled" : "outline"}
          onPress={() =>
            method === BY_SIZE
              ? undefined
              : change({ assignmentMethod: BY_SIZE })
          }
        >
          {t({ id: "bySize", message: "By Size" })}
        </ActionButton>
        <ActionButton
          type={method === SMART_MATCH ? "filled" : "outline"}
          onPress={() =>
            method === SMART_MATCH
              ? undefined
              : change({ assignmentMethod: SMART_MATCH })
          }
        >
          {t({ id: "smartMatch", message: "Smart Match" })}
        </ActionButton>
      </Box>
      <TargetSize
        value={targetSize}
        onCommit={(size) => change({ targetParticipants: size })}
      />
      {method === SMART_MATCH && <MatchingQuestions event={event} />}
    </Box>
  );
}

// How many people a room aims for.
function TargetSize({
  value,
  onCommit,
}: {
  value: number;
  onCommit: (size: number) => unknown;
}) {
  const { t } = useLingui();
  const [shown, setShown] = useState(value);
  const label = t({ id: "targetSizeQuestion", message: "Target Size?" });
  const marks = Array.from(
    { length: MAX_TARGET_SIZE - MIN_TARGET_SIZE + 1 },
    (_, i) => {
      const value = i + MIN_TARGET_SIZE;
      return {
        value,
        label:
          value === MIN_TARGET_SIZE || value === MAX_TARGET_SIZE
            ? String(value)
            : undefined,
      };
    },
  );
  return (
    <Box sx={{ pt: "10px" }}>
      <Typography
        component="h4"
        sx={{ fontSize: 16, fontWeight: 700, mb: "8px" }}
      >
        {t({ id: "targetSize", message: "Target size" })}
      </Typography>
      <Box
        sx={{
          bgcolor: colors.surfaceContainerLowest,
          borderRadius: "10px",
          p: "15px",
        }}
      >
        <Typography sx={{ color: colors.onSurfaceVariant }}>{label}</Typography>
        <Slider
          aria-label={label}
          value={shown}
          min={MIN_TARGET_SIZE}
          max={MAX_TARGET_SIZE}
          step={1}
          marks={marks}
          // eslint-disable-next-line lingui/no-unlocalized-strings
          valueLabelDisplay="on"
          onChange={(_change, next) => setShown(next as number)}
          onChangeCommitted={(_change, next) => {
            if (next !== value) void onCommit(next as number);
          }}
        />
      </Box>
    </Box>
  );
}
