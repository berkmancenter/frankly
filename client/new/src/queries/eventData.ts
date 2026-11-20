import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { useApi } from "@/api/ApiProvider";
import type { Event } from "@/api/types";
import {
  planRepairs,
  transcriptStatus,
  videoStatus,
  type FileStatus,
} from "@/utils/events/recordingStatus";
import { qk } from "./keys";

// While files may still arrive, look again this often.
const POLL_MS = 10_000;

export function useChatData(event: Event, enabled: boolean) {
  const api = useApi();
  return useQuery({
    queryKey: qk.eventChat(event.id),
    queryFn: () => api.events.chatMessages(event),
    enabled,
    staleTime: 60_000,
  });
}

export function useSuggestionsAndPolls(event: Event, enabled: boolean) {
  const api = useApi();
  return useQuery({
    queryKey: qk.eventSuggestionsPolls(event.id),
    queryFn: () => api.events.suggestionsAndPolls(event),
    enabled,
    staleTime: 60_000,
  });
}

export interface EventRecordings {
  video: FileStatus;
  transcript: FileStatus;
  /** Ask again now for files a recording is missing; for when someone is about to download. */
  repairNow: () => void;
}

/**
 * How far along an event's recording and transcript are. Looks again until they are ready, and asks
 * the server to repair recordings that stopped without all their files. Does nothing unless `enabled`.
 */
export function useEventRecordings(event: Event, enabled: boolean): EventRecordings {
  const api = useApi();
  const qc = useQueryClient();
  const [noTranscript, setNoTranscript] = useState<ReadonlySet<string>>(new Set());
  const lastAt = useRef(new Map<string, number>());
  const timers = useRef(new Set<ReturnType<typeof setTimeout>>());

  const sessions = useQuery({
    queryKey: qk.recordingSessions(event.id),
    queryFn: () => api.events.recordingSessions(event),
    enabled,
    refetchInterval: (query) => {
      const data = query.state.data;
      if (!data) return POLL_MS;
      const settled = videoStatus(data).kind === "ready" && transcriptStatus(data, noTranscript).kind !== "preparing";
      return settled ? false : POLL_MS;
    },
  });

  const repair = useCallback(
    async (sessionId: string) => {
      try {
        const { noTranscript: none } = await api.events.repairRecording(sessionId);
        if (none) setNoTranscript((current) => new Set(current).add(sessionId));
        // The new files show up in the sessions.
        await qc.invalidateQueries({ queryKey: qk.recordingSessions(event.id) });
      } catch {
        // Not critical: what was registered can still be downloaded.
      }
    },
    [api, event.id, qc],
  );

  const run = useCallback(
    (all: boolean) => {
      if (!sessions.data) return;
      const now = Date.now();
      const plan = planRepairs(sessions.data, now, lastAt.current, all);
      for (const session of plan.now) {
        lastAt.current.set(session.id, now);
        void repair(session.id);
      }
      for (const { session, waitMs } of plan.later) {
        lastAt.current.set(session.id, now + waitMs);
        const timer = setTimeout(() => {
          timers.current.delete(timer);
          void repair(session.id);
        }, waitMs);
        timers.current.add(timer);
      }
    },
    [sessions.data, repair],
  );

  useEffect(() => {
    if (enabled) run(false);
  }, [enabled, run]);
  useEffect(
    () => () => {
      for (const timer of timers.current) clearTimeout(timer);
    },
    [],
  );

  return useMemo(
    () => ({
      video: sessions.isError ? { kind: "failed" } : videoStatus(sessions.data),
      transcript: sessions.isError ? { kind: "failed" } : transcriptStatus(sessions.data, noTranscript),
      repairNow: () => run(true),
    }),
    [sessions.data, sessions.isError, noTranscript, run],
  );
}
