import { describe, expect, it } from "vitest";
import type { RecordingSession } from "@/api/types";
import {
  REPAIR_COOLDOWN_MS,
  REPAIR_DELAY_MS,
  planRepairs,
  transcriptStatus,
  videoStatus,
} from "@/utils/events/recordingStatus";

const session = (over: Partial<RecordingSession> = {}): RecordingSession => ({
  id: "s1",
  status: "stopped",
  hasRecorder: true,
  hasTranscriber: true,
  videoParts: 0,
  transcriptParts: 0,
  ...over,
});
const none = new Set<string>();

describe("videoStatus", () => {
  it("is checking until the sessions are known", () => {
    expect(videoStatus(undefined)).toEqual({ kind: "checking" });
  });

  it("is preparing before there is a session or a file", () => {
    expect(videoStatus([])).toEqual({ kind: "preparing" });
    expect(videoStatus([session()])).toEqual({ kind: "preparing" });
  });

  it("is recording while any session still records", () => {
    expect(videoStatus([session({ status: "recording" }), session({ id: "s2", videoParts: 1 })])).toEqual({ kind: "recording" });
    expect(videoStatus([session({ status: "starting" })])).toEqual({ kind: "recording" });
  });

  it("counts the files across sessions", () => {
    expect(videoStatus([session({ videoParts: 2 }), session({ id: "s2", videoParts: 1 })])).toEqual({ kind: "ready", parts: 3 });
  });
});

describe("transcriptStatus", () => {
  it("is checking until the sessions are known", () => {
    expect(transcriptStatus(undefined, none)).toEqual({ kind: "checking" });
  });

  it("counts the files across sessions", () => {
    expect(transcriptStatus([session({ transcriptParts: 1 }), session({ id: "s2", transcriptParts: 2 })], none)).toEqual({
      kind: "ready",
      parts: 3,
    });
  });

  it("is preparing while a transcript may still arrive", () => {
    expect(transcriptStatus([], none)).toEqual({ kind: "preparing" });
    expect(transcriptStatus([session()], none)).toEqual({ kind: "preparing" });
    expect(transcriptStatus([session({ status: "recording" })], none)).toEqual({ kind: "preparing" });
  });

  it("is none once no session can produce one", () => {
    expect(transcriptStatus([session({ hasTranscriber: false })], none)).toEqual({ kind: "none" });
    expect(transcriptStatus([session({ status: "failed" })], none)).toEqual({ kind: "none" });
    expect(transcriptStatus([session()], new Set(["s1"]))).toEqual({ kind: "none" });
  });

  it("stays preparing while one session might still deliver", () => {
    expect(transcriptStatus([session({ hasTranscriber: false }), session({ id: "s2" })], none)).toEqual({ kind: "preparing" });
  });
});

describe("planRepairs", () => {
  const now = Date.parse("2030-01-01T12:00:00.000Z");
  const stoppedAgo = (ms: number) => new Date(now - ms).toISOString();

  it("repairs a stopped recording missing files once the delay has passed", () => {
    const plan = planRepairs([session({ stoppedAt: stoppedAgo(REPAIR_DELAY_MS + 1) })], now, new Map());
    expect(plan.now.map((s) => s.id)).toEqual(["s1"]);
    expect(plan.later).toEqual([]);
  });

  it("schedules it for when the delay has passed", () => {
    const plan = planRepairs([session({ stoppedAt: stoppedAgo(30_000) })], now, new Map());
    expect(plan.now).toEqual([]);
    expect(plan.later).toEqual([{ session: expect.objectContaining({ id: "s1" }), waitMs: REPAIR_DELAY_MS - 30_000 }]);
  });

  it("does not ask again within the cooldown", () => {
    const stopped = session({ stoppedAt: stoppedAgo(REPAIR_DELAY_MS * 2) });
    expect(planRepairs([stopped], now, new Map([["s1", now - REPAIR_COOLDOWN_MS + 1]])).now).toEqual([]);
    expect(planRepairs([stopped], now, new Map([["s1", now - REPAIR_COOLDOWN_MS]])).now).toHaveLength(1);
  });

  it("leaves running recordings and complete ones alone", () => {
    const old = stoppedAgo(REPAIR_DELAY_MS * 2);
    const plan = planRepairs(
      [
        session({ id: "running", status: "recording" }),
        session({ id: "done", stoppedAt: old, videoParts: 1, transcriptParts: 1 }),
        session({ id: "no-recorder", stoppedAt: old, hasRecorder: false, hasTranscriber: false }),
      ],
      now,
      new Map(),
    );
    expect(plan.now).toEqual([]);
    expect(plan.later).toEqual([]);
  });

  it("can look at complete recordings too, for files that arrive late", () => {
    const done = session({ stoppedAt: stoppedAgo(REPAIR_DELAY_MS * 2), videoParts: 1, transcriptParts: 1 });
    expect(planRepairs([done], now, new Map(), true).now).toHaveLength(1);
  });

  it("treats a recording with no stop time as just stopped", () => {
    const plan = planRepairs([session()], now, new Map());
    expect(plan.later[0]!.waitMs).toBe(REPAIR_DELAY_MS);
  });
});
