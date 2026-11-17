import { describe, expect, it } from "vitest";
import {
  agendaProblem,
  blankDraft,
  draftOf,
  duplicateOf,
  formatStepTime,
  isEdited,
  itemOf,
  newItem,
} from "@/utils/agenda";

describe("draftOf / itemOf", () => {
  it("round-trips each type through the fields it uses", () => {
    const text = { id: "1", type: "text" as const, title: "Hi", content: "Body", timeInSeconds: 60 };
    expect(itemOf(text, draftOf(text))).toEqual(text);
    const poll = { id: "2", type: "poll" as const, content: "Pick", pollAnswers: ["a", "b"], timeInSeconds: 30 };
    expect(itemOf(poll, draftOf(poll))).toEqual(poll);
    const video = { id: "3", type: "video" as const, title: "V", videoType: "youtube" as const, videoUrl: "https://y.co/x", timeInSeconds: 90 };
    expect(itemOf(video, draftOf(video))).toEqual(video);
  });

  it("drops fields a type does not use when the type changes", () => {
    const text = { id: "1", type: "text" as const, title: "Hi", content: "Body", timeInSeconds: 60 };
    const item = itemOf(text, blankDraft("wordCloud", 60));
    expect(item).toEqual({ id: "1", type: "wordCloud", content: "", timeInSeconds: 60 });
  });

  it("notices an edit", () => {
    const item = newItem("1");
    expect(isEdited(item, draftOf(item))).toBe(false);
    expect(isEdited(item, { ...draftOf(item), title: "x" })).toBe(true);
  });
});

describe("agendaProblem", () => {
  const draft = (patch: Partial<ReturnType<typeof draftOf>>) => ({ ...blankDraft("text", 300), ...patch });

  it("asks for what each type needs", () => {
    expect(agendaProblem(draft({}))).toBe("title");
    expect(agendaProblem(draft({ title: "T" }))).toBe("message");
    expect(agendaProblem(draft({ title: "T", content: "C" }))).toBeUndefined();
    expect(agendaProblem(blankDraft("video", 60))).toBe("title");
    expect(agendaProblem({ ...blankDraft("video", 60), title: "T" })).toBe("videoUrl");
    expect(agendaProblem({ ...blankDraft("image", 60), title: "T" })).toBe("imageUrl");
    expect(agendaProblem(blankDraft("poll", 60))).toBe("question");
    expect(agendaProblem({ ...blankDraft("poll", 60), content: "Q" })).toBe("answers");
    expect(agendaProblem(blankDraft("wordCloud", 60))).toBe("prompt");
    expect(agendaProblem(blankDraft("userSuggestions", 60))).toBe("headline");
  });

  it("wants a plain video link to be an MP4, but not a YouTube or Vimeo one", () => {
    const video = { ...blankDraft("video", 60), title: "T", videoUrl: "https://x.co/a.mov" };
    expect(agendaProblem(video)).toBe("videoNotMp4");
    expect(agendaProblem({ ...video, videoUrl: "https://x.co/a.MP4" })).toBeUndefined();
    expect(agendaProblem({ ...video, videoType: "youtube" })).toBeUndefined();
  });

  it("rejects repeated poll answers", () => {
    const poll = { ...blankDraft("poll", 60), content: "Q", answers: ["a", "a"] };
    expect(agendaProblem(poll)).toBe("duplicateAnswers");
  });
});

describe("small helpers", () => {
  it("formats a step's length", () => {
    expect(formatStepTime(300)).toBe("5:00");
    expect(formatStepTime(65)).toBe("1:05");
  });
  it("duplicates with a new id", () => {
    expect(duplicateOf({ id: "1", type: "text", title: "T" }, "2")).toEqual({ id: "2", type: "text", title: "T" });
  });
});
