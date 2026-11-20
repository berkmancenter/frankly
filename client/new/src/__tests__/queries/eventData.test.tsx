// @vitest-environment jsdom
import { waitFor } from "@testing-library/react";
import { describe, expect, it, vi } from "vitest";
import type { RecordingSession } from "@/api/types";
import { event } from "@/__tests__/support/fixtures";
import { renderQueryHook } from "@/__tests__/support/hookHarness";
import { useEventRecordings } from "@/queries/eventData";

const long = "2020-01-01T00:00:00.000Z";
const session = (over: Partial<RecordingSession> = {}): RecordingSession => ({
  id: "s1",
  status: "stopped",
  stoppedAt: long,
  hasRecorder: true,
  hasTranscriber: true,
  videoParts: 0,
  transcriptParts: 0,
  ...over,
});

const hook = (enabled: boolean, api: object) =>
  renderQueryHook(() => useEventRecordings(event(), enabled), { api: { events: api } });

describe("useEventRecordings", () => {
  it("asks for nothing while disabled", async () => {
    const recordingSessions = vi.fn(async () => []);
    const { result } = hook(false, { recordingSessions });
    expect(result.current.video).toEqual({ kind: "checking" });
    expect(recordingSessions).not.toHaveBeenCalled();
  });

  it("reports how far the files are", async () => {
    const { result } = hook(true, {
      recordingSessions: async () => [session({ videoParts: 2, transcriptParts: 1 })],
      repairRecording: async () => ({ noTranscript: false }),
    });
    await waitFor(() => expect(result.current.video).toEqual({ kind: "ready", parts: 2 }));
    expect(result.current.transcript).toEqual({ kind: "ready", parts: 1 });
  });

  it("asks the server to repair a stopped recording that is missing files", async () => {
    const repairRecording = vi.fn<(sessionId: string) => Promise<{ noTranscript: boolean }>>(async () => ({ noTranscript: false }));
    hook(true, { recordingSessions: async () => [session()], repairRecording });
    await waitFor(() => expect(repairRecording).toHaveBeenCalledWith("s1"));
  });

  it("learns from the server that a transcript will never come", async () => {
    const { result } = hook(true, {
      recordingSessions: async () => [session({ videoParts: 1 })],
      repairRecording: async () => ({ noTranscript: true }),
    });
    await waitFor(() => expect(result.current.transcript).toEqual({ kind: "none" }));
  });

  it("does not repair a recording that has all its files", async () => {
    const repairRecording = vi.fn<(sessionId: string) => Promise<{ noTranscript: boolean }>>(async () => ({ noTranscript: false }));
    const { result } = hook(true, {
      recordingSessions: async () => [session({ videoParts: 1, transcriptParts: 1 })],
      repairRecording,
    });
    await waitFor(() => expect(result.current.video.kind).toBe("ready"));
    expect(repairRecording).not.toHaveBeenCalled();
  });

  it("looks again on request, even at recordings that have files", async () => {
    const repairRecording = vi.fn<(sessionId: string) => Promise<{ noTranscript: boolean }>>(async () => ({ noTranscript: false }));
    const { result } = hook(true, {
      recordingSessions: async () => [session({ videoParts: 1, transcriptParts: 1 })],
      repairRecording,
    });
    await waitFor(() => expect(result.current.video.kind).toBe("ready"));
    result.current.repairNow();
    await waitFor(() => expect(repairRecording).toHaveBeenCalledWith("s1"));
  });

  it("carries on when a repair fails", async () => {
    const { result } = hook(true, {
      recordingSessions: async () => [session({ videoParts: 1 })],
      repairRecording: async () => {
        throw new Error("offline");
      },
    });
    await waitFor(() => expect(result.current.video).toEqual({ kind: "ready", parts: 1 }));
  });

  it("says failed when the sessions cannot be read", async () => {
    const { result } = hook(true, {
      recordingSessions: async () => {
        throw new Error("denied");
      },
    });
    await waitFor(() => expect(result.current.video).toEqual({ kind: "failed" }));
    expect(result.current.transcript).toEqual({ kind: "failed" });
  });
});
