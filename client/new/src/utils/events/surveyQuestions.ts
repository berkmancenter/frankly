import type { SurveyQuestion } from "@/api/types";

// How many matching questions an event can ask.
export const MAX_SURVEY_QUESTIONS = 8;

// The two answers a new multiple-choice question starts with (the words are supplied, so they can be translated).
export function defaultAnswers(yes: string, no: string, id: () => string = () => crypto.randomUUID()): SurveyQuestion["answers"] {
  return [
    { id: id(), options: [{ id: id(), title: yes }] },
    { id: id(), options: [{ id: id(), title: no }] },
  ];
}

const withOptions = (question: Omit<SurveyQuestion, "options">): SurveyQuestion => ({
  ...question,
  options: question.answers.flatMap((answer) => answer.options),
});

export function newQuestion(yes: string, no: string, id: () => string = () => crypto.randomUUID()): SurveyQuestion {
  return withOptions({ id: id(), title: "", type: "multipleChoice", answers: defaultAnswers(yes, no, id) });
}

// A question is ready to save once it is worded, and (unless free text) has two or more answers, all worded.
export function questionComplete(question: SurveyQuestion): boolean {
  if (!question.title.trim()) return false;
  if (question.type === "freeText") return true;
  return question.answers.length >= 2 && question.options.every((option) => option.title.trim());
}

export function withTitle(question: SurveyQuestion, title: string): SurveyQuestion {
  return { ...question, title };
}

export function withAnswerTitle(question: SurveyQuestion, optionId: string, title: string): SurveyQuestion {
  return withOptions({
    ...question,
    answers: question.answers.map((answer) => ({
      ...answer,
      options: answer.options.map((option) => (option.id === optionId ? { ...option, title } : option)),
    })),
  });
}

// Free text has no answers; switching back brings the defaults back unless there are some.
export function withType(
  question: SurveyQuestion,
  type: SurveyQuestion["type"],
  yes: string,
  no: string,
  id: () => string = () => crypto.randomUUID(),
): SurveyQuestion {
  if (type === "freeText") return withOptions({ ...question, type, answers: [] });
  return withOptions({
    ...question,
    type,
    answers: question.answers.length > 0 ? question.answers : defaultAnswers(yes, no, id),
  });
}

// Only one question can be free text.
export const freeTextAvailable = (questions: SurveyQuestion[], questionId: string): boolean =>
  !questions.some((question) => question.id !== questionId && question.type === "freeText");
