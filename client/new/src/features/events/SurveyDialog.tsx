import Box from "@mui/material/Box";
import TextField from "@mui/material/TextField";
import Typography from "@mui/material/Typography";
import { useLingui } from "@lingui/react/macro";
import { useCallback, useRef, useState } from "react";
import type { Event, SurveyAnswer } from "@/api/types";
import { ActionButton } from "@/components/ActionButton";
import { AppDialog } from "@/components/AppDialog";

const FREE_TEXT_LIMIT = 270;

// The questions the host asks while people sign up; the answers are all-or-nothing.
export function SurveyDialog({
  event,
  onAnswer,
  onCancel,
}: {
  event: Event;
  onAnswer: (answers: SurveyAnswer[]) => void;
  onCancel: () => void;
}) {
  const { t } = useLingui();
  const questions = event.surveyQuestions ?? [];
  const [answers, setAnswers] = useState<Record<string, SurveyAnswer>>({});

  const done = questions.every((question) => {
    const answer = answers[question.id];
    return question.type === "freeText" ? !!answer?.freeText?.trim() : !!answer?.answerOptionId;
  });

  return (
    <AppDialog open onClose={onCancel} maxWidth={700} padding={30} ariaLabel={t({ id: "finishRsvp", message: "Finish RSVP" })}>
      <Box sx={{ display: "flex", flexDirection: "column", gap: "20px", pt: "30px" }}>
        <Typography component="h2" sx={{ fontSize: 32 }}>
          {t({ id: "finishRsvp", message: "Finish RSVP" })}
        </Typography>
        <Typography>
          {t({
            id: "pleaseAnswerQuestions",
            message: "Please answer a few questions so we can match you with the right group.",
          })}
        </Typography>
        {questions.map((question) => (
          <Box key={question.id} role="group" aria-label={question.title} sx={{ display: "flex", flexDirection: "column", gap: "8px" }}>
            <Typography sx={{ fontSize: 18, fontWeight: 500 }}>{question.title}</Typography>
            {question.type === "freeText" ? (
              <TextField
                multiline
                minRows={3}
                slotProps={{ htmlInput: { maxLength: FREE_TEXT_LIMIT, "aria-label": question.title } }}
                value={answers[question.id]?.freeText ?? ""}
                onChange={(change) =>
                  setAnswers({ ...answers, [question.id]: { questionId: question.id, freeText: change.target.value } })
                }
              />
            ) : (
              <Box sx={{ display: "flex", flexWrap: "wrap", gap: "10px" }}>
                {question.options.map((option) => {
                  const selected = answers[question.id]?.answerOptionId === option.id;
                  return (
                    <ActionButton
                      key={option.id}
                      type={selected ? "filled" : "outline"}
                      radius={30}
                      maxTextWidth={220}
                      onPress={() =>
                        setAnswers({ ...answers, [question.id]: { questionId: question.id, answerOptionId: option.id } })
                      }
                      ariaLabel={option.title}
                    >
                      {option.title}
                    </ActionButton>
                  );
                })}
              </Box>
            )}
          </Box>
        ))}
        <Box sx={{ display: "flex", justifyContent: "flex-end" }}>
          <ActionButton onPress={done ? () => onAnswer(Object.values(answers)) : undefined}>
            {t({ id: "finish", message: "Finish" })}
          </ActionButton>
        </Box>
      </Box>
    </AppDialog>
  );
}

// Asks the sign-up questions on demand: `ask()` resolves with the answers, or undefined if the person backs out.
export function useSurveyDialog(event: Event) {
  const [open, setOpen] = useState(false);
  const resolver = useRef<((answers: SurveyAnswer[] | undefined) => void) | null>(null);

  const ask = useCallback(
    () =>
      new Promise<SurveyAnswer[] | undefined>((resolve) => {
        resolver.current?.(undefined);
        resolver.current = resolve;
        setOpen(true);
      }),
    [],
  );
  const finish = (answers: SurveyAnswer[] | undefined) => {
    resolver.current?.(answers);
    resolver.current = null;
    setOpen(false);
  };

  const dialog = open ? <SurveyDialog event={event} onAnswer={finish} onCancel={() => finish(undefined)} /> : null;
  return { ask, dialog };
}
