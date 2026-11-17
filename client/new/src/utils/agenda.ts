// Step types, form-field names and problem codes in this file are identifiers, not UI text.
/* eslint-disable lingui/no-unlocalized-strings */
import type { AgendaItem, AgendaItemType, VideoType } from "@/api/types";

// Five minutes, what a new agenda step gets.
export const DEFAULT_AGENDA_SECONDS = 300;

export const AGENDA_ITEM_TYPES: readonly AgendaItemType[] = [
  "text",
  "video",
  "image",
  "poll",
  "wordCloud",
  "userSuggestions",
];

// What the edit form holds for one step. Which fields matter depends on the type:
// text uses title and content; video, title and link; image, title and picture; poll, content as the question
// and the answers; word cloud, content as the prompt; suggestions, title as the headline.
export interface AgendaDraft {
  type: AgendaItemType;
  title: string;
  content: string;
  videoType: VideoType;
  videoUrl: string;
  imageUrl: string;
  answers: string[];
  seconds: number;
}

export const draftOf = (item: AgendaItem): AgendaDraft => ({
  type: item.type,
  title: item.title ?? "",
  content: item.content ?? "",
  videoType: item.videoType ?? "url",
  videoUrl: item.videoUrl ?? "",
  imageUrl: item.imageUrl ?? "",
  answers: [...(item.pollAnswers ?? [])],
  seconds: item.timeInSeconds ?? DEFAULT_AGENDA_SECONDS,
});

// Switching type starts that type's fields afresh and keeps the time.
export const blankDraft = (type: AgendaItemType, seconds: number): AgendaDraft => ({
  ...draftOf({ id: "", type }),
  seconds,
});

// The step the draft describes: only the fields its type uses.
export function itemOf(base: AgendaItem, draft: AgendaDraft): AgendaItem {
  const item: AgendaItem = { id: base.id, type: draft.type, timeInSeconds: draft.seconds };
  switch (draft.type) {
    case "text":
      return { ...item, title: draft.title, content: draft.content };
    case "video":
      return { ...item, title: draft.title, videoType: draft.videoType, videoUrl: draft.videoUrl };
    case "image":
      return { ...item, title: draft.title, imageUrl: draft.imageUrl };
    case "poll":
      return { ...item, content: draft.content, pollAnswers: draft.answers };
    case "wordCloud":
      return { ...item, content: draft.content };
    case "userSuggestions":
      return { ...item, title: draft.title };
  }
}

export type AgendaProblem =
  | "title"
  | "message"
  | "videoUrl"
  | "videoNotMp4"
  | "imageUrl"
  | "question"
  | "answers"
  | "duplicateAnswers"
  | "prompt"
  | "headline";

// What is missing before the step can be saved, if anything.
export function agendaProblem(draft: AgendaDraft): AgendaProblem | undefined {
  const blank = (text: string) => !text.trim();
  switch (draft.type) {
    case "text":
      return blank(draft.title) ? "title" : blank(draft.content) ? "message" : undefined;
    case "video":
      if (blank(draft.title)) return "title";
      if (blank(draft.videoUrl)) return "videoUrl";
      return draft.videoType === "url" && !draft.videoUrl.trim().toLowerCase().endsWith("mp4") ? "videoNotMp4" : undefined;
    case "image":
      return blank(draft.title) ? "title" : blank(draft.imageUrl) ? "imageUrl" : undefined;
    case "poll":
      if (blank(draft.content)) return "question";
      if (draft.answers.length === 0) return "answers";
      return new Set(draft.answers).size !== draft.answers.length ? "duplicateAnswers" : undefined;
    case "wordCloud":
      return blank(draft.content) ? "prompt" : undefined;
    case "userSuggestions":
      return blank(draft.title) ? "headline" : undefined;
  }
}

export const isEdited = (item: AgendaItem, draft: AgendaDraft): boolean =>
  JSON.stringify(draftOf(item)) !== JSON.stringify(draft);

// `m:ss`, as the steps show their length.
export function formatStepTime(seconds: number): string {
  const total = Math.max(0, Math.floor(seconds));
  return `${Math.floor(total / 60)}:${String(total % 60).padStart(2, "0")}`;
}

// A copy of a step with a fresh id (the clock's milliseconds, like every new step).
export const duplicateOf = (item: AgendaItem, id: string): AgendaItem => ({ ...item, id });

// A new, empty text step.
export const newItem = (id: string): AgendaItem => ({ id, type: "text", timeInSeconds: DEFAULT_AGENDA_SECONDS });
