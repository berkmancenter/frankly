import type { RecordingSession } from "@/api/types";

// How far along a kind of file is for an event: video recordings and transcripts both use this.
export type FileStatus =
  | { kind: "checking" }
  | { kind: "preparing" }
  | { kind: "recording" }
  | { kind: "failed" }
  | { kind: "none" }
  | { kind: "ready"; parts: number };

const sum = (sessions: readonly RecordingSession[], count: (session: RecordingSession) => number) =>
  sessions.reduce((total, session) => total + count(session), 0);

// `sessions` is undefined until the first answer arrives.
export function videoStatus(sessions: readonly RecordingSession[] | undefined): FileStatus {
  if (!sessions) return { kind: "checking" };
  if (sessions.some((session) => session.status === "starting" || session.status === "recording")) {
    return { kind: "recording" };
  }
  const parts = sum(sessions, (session) => session.videoParts);
  return parts > 0 ? { kind: "ready", parts } : { kind: "preparing" };
}

// `noTranscript` holds the sessions the server said will never have one.
export function transcriptStatus(
  sessions: readonly RecordingSession[] | undefined,
  noTranscript: ReadonlySet<string>,
): FileStatus {
  if (!sessions) return { kind: "checking" };
  const parts = sum(sessions, (session) => session.transcriptParts);
  if (parts > 0) return { kind: "ready", parts };
  const settled =
    sessions.length > 0 &&
    sessions.every(
      (session) =>
        session.status === "failed" ||
        (session.status === "stopped" && (!session.hasTranscriber || noTranscript.has(session.id))),
    );
  return settled ? { kind: "none" } : { kind: "preparing" };
}

// Files can appear a little after a recording stops, so a repair is not asked for before then.
export const REPAIR_DELAY_MS = 90_000;
export const REPAIR_COOLDOWN_MS = 30_000;

export interface RepairPlan {
  /** Sessions to repair right now. */
  now: RecordingSession[];
  /** Sessions to repair once `waitMs` has passed. */
  later: { session: RecordingSession; waitMs: number }[];
}

/**
 * Which stopped recordings should be asked about again. `lastAt` is when each was last repaired or
 * scheduled; `all` also covers recordings that already have files, for late arrivals.
 */
export function planRepairs(
  sessions: readonly RecordingSession[],
  nowMs: number,
  lastAt: ReadonlyMap<string, number>,
  all = false,
): RepairPlan {
  const plan: RepairPlan = { now: [], later: [] };
  for (const session of sessions) {
    const last = lastAt.get(session.id);
    if (last !== undefined && nowMs < last + REPAIR_COOLDOWN_MS) continue;
    if (session.status !== "stopped") continue;
    const missingVideo = session.hasRecorder && session.videoParts === 0;
    const missingTranscript = session.hasTranscriber && session.transcriptParts === 0;
    if (!all && !missingVideo && !missingTranscript) continue;
    const sinceStop = session.stoppedAt ? nowMs - Date.parse(session.stoppedAt) : 0;
    const waitMs = REPAIR_DELAY_MS - sinceStop;
    if (waitMs <= 0) plan.now.push(session);
    else plan.later.push({ session, waitMs });
  }
  return plan;
}
