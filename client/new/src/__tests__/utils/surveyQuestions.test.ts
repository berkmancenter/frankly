import { describe, expect, it } from "vitest";
import {
  freeTextAvailable,
  newQuestion,
  questionComplete,
  withAnswerTitle,
  withTitle,
  withType,
} from "@/utils/events/surveyQuestions";

let counter = 0;
const id = () => `id${++counter}`;

describe("surveyQuestions", () => {
  it("starts a question with two answers, and is complete once everything is worded", () => {
    const question = newQuestion("Yes", "No", id);
    expect(question.options.map((option) => option.title)).toEqual([
      "Yes",
      "No",
    ]);
    expect(questionComplete(question)).toBe(false);
    expect(questionComplete(withTitle(question, "Ready?"))).toBe(true);
  });

  it("is incomplete while an answer is blank", () => {
    const question = withTitle(newQuestion("Yes", "No", id), "Ready?");
    const blank = withAnswerTitle(question, question.options[0]!.id, " ");
    expect(questionComplete(blank)).toBe(false);
  });

  it("drops the answers for free text, and brings the defaults back for multiple choice", () => {
    const question = withTitle(newQuestion("Yes", "No", id), "Why?");
    const free = withType(question, "freeText", "Yes", "No", id);
    expect(free.answers).toEqual([]);
    expect(questionComplete(free)).toBe(true);
    const back = withType(free, "multipleChoice", "Yes", "No", id);
    expect(back.options.map((option) => option.title)).toEqual(["Yes", "No"]);
  });

  it("allows one free-text question", () => {
    const a = withType(newQuestion("Y", "N", id), "freeText", "Y", "N", id);
    const b = newQuestion("Y", "N", id);
    expect(freeTextAvailable([a, b], b.id)).toBe(false);
    expect(freeTextAvailable([a, b], a.id)).toBe(true);
  });
});
