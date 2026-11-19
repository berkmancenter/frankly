/* eslint-disable lingui/no-unlocalized-strings */
import {
  assign,
  fromCallback,
  fromPromise,
  setup,
  type EventObject,
  type SnapshotFrom,
} from "xstate";

/**
 * Media machine — the local camera/microphone.
 *
 *   idle ──START──▶ requesting ──ok──▶ ready ◀─────────────┐
 *                       │  ▲             │ SELECT_*_INPUT   │
 *                       │  └─────────────┘ (re-acquire)     │
 *                       └─error─▶ failed ──RETRY──▶ requesting
 *                                   └─SKIP──▶ unavailable ──START──▶ requesting
 *
 *  - The machine does not know about any SDK. Tracks come from an injected {@link MediaSource}
 *    (production: Agora, `scopes/agoraMediaSource.ts`). A track only has to be enable/disable-able
 *    and closable, and the audio track has to report a volume.
 *  - `ready` invokes three child actors whose lifetimes *are* the lifetime of the tracks:
 *      trackGuard    – closes every track when `ready` is left (device switch, STOP, unmount)
 *      levelMeter    – mic level 0..1 for the talking indicator
 *      deviceWatcher – device list, refreshed when devices change
 *    Because they are invoked actors, camera light off == actor stopped. No effect cleanup to forget.
 *  - With no source (or `simulate`), the machine runs without hardware: no tracks, a synthetic
 *    level and fake devices. Tests, CI browsers and demos without a camera keep working.
 */

export interface DeviceInfo {
  deviceId: string;
  label: string;
}

export type MediaErrorKind =
  | "denied"
  | "notFound"
  | "inUse"
  | "unsupported"
  | "unknown";

export interface MediaErrorInfo {
  kind: MediaErrorKind;
  message: string;
}

/** What the machine needs from a local track. Agora's `IMicrophoneAudioTrack` / `ICameraVideoTrack` satisfy it. */
export interface LocalTrackLike {
  /** Mute/unmute without releasing the device (video: also turns the camera light off). */
  setEnabled(enabled: boolean): Promise<void> | void;
  /** Release the device. */
  close(): void;
}
export interface LocalAudioTrackLike extends LocalTrackLike {
  /** 0..1 */
  getVolumeLevel(): number;
}
export type LocalVideoTrackLike = LocalTrackLike;

export interface AcquiredTracks {
  audio: LocalAudioTrackLike | null;
  video: LocalVideoTrackLike | null;
}

export interface MediaSource {
  /**
   * Create the local tracks. A missing camera should yield `video: null` (audio-only is still a
   * usable meeting); a hard failure (denied, nothing at all) should reject.
   */
  acquire(options: {
    audioId: string | null;
    videoId: string | null;
  }): Promise<AcquiredTracks>;
  listDevices(): Promise<{
    audioInputs: DeviceInfo[];
    videoInputs: DeviceInfo[];
  }>;
  /** Subscribe to plug/unplug. Returns the unsubscribe function. */
  onDevicesChanged(listener: () => void): () => void;
}

export interface MediaInput {
  source?: MediaSource | null;
  /** Never touch hardware. */
  simulate?: boolean;
  /** Initial mute state. Flutter starts hosted calls with mic and camera on. */
  startWith?: { audio: boolean; video: boolean };
  /** Request immediately on creation instead of waiting for `START`. */
  autoStart?: boolean;
  /** Devices picked earlier (the mirror check); used for the first acquisition. */
  audioDeviceId?: string | null;
  videoDeviceId?: string | null;
}

export interface MediaContext {
  source: MediaSource | null;
  simulate: boolean;
  autoStart: boolean;
  audioTrack: LocalAudioTrackLike | null;
  videoTrack: LocalVideoTrackLike | null;
  simulated: boolean;
  hasAudioTrack: boolean;
  hasVideoTrack: boolean;
  audioEnabled: boolean;
  videoEnabled: boolean;
  audioInputs: DeviceInfo[];
  videoInputs: DeviceInfo[];
  selectedAudioId: string | null;
  selectedVideoId: string | null;
  error: MediaErrorInfo | null;
  /** 0..1, raw mic level (use `selectAudioLevel` to account for mute). */
  level: number;
}

export type MediaEvent =
  | { type: "START" }
  | { type: "STOP" }
  | { type: "RETRY" }
  | { type: "SKIP" }
  | { type: "TOGGLE_AUDIO" }
  | { type: "TOGGLE_VIDEO" }
  | { type: "SELECT_AUDIO_INPUT"; deviceId: string }
  | { type: "SELECT_VIDEO_INPUT"; deviceId: string }
  | { type: "LEVEL"; level: number }
  | { type: "DEVICES"; audioInputs: DeviceInfo[]; videoInputs: DeviceInfo[] };

/* -------------------------------------------------------------------------- */

/** Understands both browser `DOMException` names and Agora's `AgoraRTCError.code` strings. */
export function classifyMediaError(error: unknown): MediaErrorInfo {
  const e = error as { name?: string; code?: string; message?: string } | null;
  const key = `${e?.code ?? ""} ${e?.name ?? ""}`;
  const message =
    error instanceof Error ? error.message : String(e?.message ?? error);
  if (/PERMISSION_DENIED|NotAllowedError|SecurityError/.test(key))
    return { kind: "denied", message };
  if (
    /DEVICE_NOT_FOUND|NotFoundError|OverconstrainedError|DevicesNotFoundError/.test(
      key,
    )
  ) {
    return { kind: "notFound", message };
  }
  if (/NOT_READABLE|NotReadableError|AbortError/.test(key))
    return { kind: "inUse", message };
  if (/NOT_SUPPORTED|TypeError/.test(key))
    return { kind: "unsupported", message };
  return { kind: "unknown", message };
}

interface AcquireInput {
  source: MediaSource | null;
  simulate: boolean;
  audioId: string | null;
  videoId: string | null;
}

interface Acquired extends AcquiredTracks {
  simulated: boolean;
}

const neverSettles = () => new Promise<never>(() => {});

const closeAll = (t: AcquiredTracks) => {
  t.audio?.close();
  t.video?.close();
};

const acquire = fromPromise<Acquired, AcquireInput>(
  async ({ input, signal }) => {
    if (input.simulate || !input.source)
      return { audio: null, video: null, simulated: true };
    try {
      const tracks = await input.source.acquire({
        audioId: input.audioId,
        videoId: input.videoId,
      });
      // The request may have been canceled while the browser was prompting (STOP, a device
      // switch, the scope unmounting, React StrictMode's mount/unmount/mount). Tracks nobody
      // will own must not keep the camera light on.
      if (signal.aborted) {
        closeAll(tracks);
        return neverSettles();
      }
      return { ...tracks, simulated: false };
    } catch (error) {
      // A superseded run must not report at all. StrictMode restarts the *same* actor, so a
      // result or an error from the dead run would be taken for the live run's answer.
      if (signal.aborted) return neverSettles();
      throw error;
    }
  },
);

/** Closes every track when the invoking state is exited — the "camera light off" guarantee. */
const trackGuard = fromCallback<
  EventObject,
  { audio: LocalAudioTrackLike | null; video: LocalVideoTrackLike | null }
>(({ input }) => {
  return () => closeAll(input);
});

const levelMeter = fromCallback<
  { type: "LEVEL"; level: number },
  { audio: LocalAudioTrackLike | null; simulated: boolean }
>(({ input, sendBack }) => {
  if (input.simulated) {
    // A lazy random walk: mostly quiet with bursts, enough to animate a meter.
    let level = 0;
    const id = setInterval(() => {
      level = Math.max(
        0,
        Math.min(1, level * 0.6 + (Math.random() < 0.3 ? Math.random() : 0)),
      );
      sendBack({ type: "LEVEL", level });
    }, 120);
    return () => clearInterval(id);
  }
  if (!input.audio) return;
  const track = input.audio;
  const id = setInterval(() => {
    try {
      sendBack({
        type: "LEVEL",
        level: Math.min(1, track.getVolumeLevel() * 1.5),
      });
    } catch {
      /* track closed between ticks */
    }
  }, 100);
  return () => clearInterval(id);
});

const SIMULATED_DEVICES = {
  audioInputs: [{ deviceId: "sim-mic", label: "Simulated microphone" }],
  videoInputs: [{ deviceId: "sim-cam", label: "Simulated camera" }],
};

const deviceWatcher = fromCallback<
  { type: "DEVICES"; audioInputs: DeviceInfo[]; videoInputs: DeviceInfo[] },
  { source: MediaSource | null; simulate: boolean }
>(({ input, sendBack }) => {
  const { source } = input;
  if (input.simulate || !source) {
    sendBack({ type: "DEVICES", ...SIMULATED_DEVICES });
    return;
  }
  let canceled = false;
  const refresh = async () => {
    try {
      const devices = await source.listDevices();
      if (!canceled) sendBack({ type: "DEVICES", ...devices });
    } catch {
      /* device list is best-effort */
    }
  };
  void refresh();
  const off = source.onDevicesChanged(() => void refresh());
  return () => {
    canceled = true;
    off();
  };
});

const applyEnabled = (
  audio: LocalTrackLike | null,
  video: LocalTrackLike | null,
  a: boolean,
  v: boolean,
) => {
  void audio?.setEnabled(a);
  void video?.setEnabled(v);
};

export const mediaMachine = setup({
  types: {
    context: {} as MediaContext,
    events: {} as MediaEvent,
    input: {} as MediaInput,
  },
  actors: { acquire, trackGuard, levelMeter, deviceWatcher },
  guards: { autoStart: ({ context }) => context.autoStart },
  actions: {
    storeTracks: assign(({ context, event }) => {
      const out = (event as unknown as { output: Acquired }).output;
      applyEnabled(
        out.audio,
        out.video,
        context.audioEnabled,
        context.videoEnabled,
      );
      return {
        audioTrack: out.audio,
        videoTrack: out.video,
        simulated: out.simulated,
        hasAudioTrack: out.simulated || !!out.audio,
        hasVideoTrack: out.simulated || !!out.video,
        error: null,
      };
    }),
    storeError: assign({
      error: ({ event }) =>
        classifyMediaError((event as unknown as { error: unknown }).error),
      audioTrack: null,
      videoTrack: null,
    }),
    toggleAudio: assign(({ context }) => {
      const audioEnabled = !context.audioEnabled;
      void context.audioTrack?.setEnabled(audioEnabled);
      return { audioEnabled, level: audioEnabled ? context.level : 0 };
    }),
    toggleVideo: assign(({ context }) => {
      const videoEnabled = !context.videoEnabled;
      void context.videoTrack?.setEnabled(videoEnabled);
      return { videoEnabled };
    }),
    selectAudio: assign({
      selectedAudioId: ({ event }) =>
        event.type === "SELECT_AUDIO_INPUT" ? event.deviceId : null,
    }),
    selectVideo: assign({
      selectedVideoId: ({ event }) =>
        event.type === "SELECT_VIDEO_INPUT" ? event.deviceId : null,
    }),
    storeLevel: assign({
      level: ({ event }) => (event.type === "LEVEL" ? event.level : 0),
    }),
    storeDevices: assign({
      audioInputs: ({ context, event }) =>
        event.type === "DEVICES" ? event.audioInputs : context.audioInputs,
      videoInputs: ({ context, event }) =>
        event.type === "DEVICES" ? event.videoInputs : context.videoInputs,
    }),
    clearTracks: assign({
      audioTrack: null,
      videoTrack: null,
      level: 0,
      error: null,
    }),
  },
}).createMachine({
  /** @xstate-layout N4IgpgJg5mDOIC5QFtIEsCGBiAygFQHkAFAbQAYBdRUABwHtY0AXNOgO2pAA9EBWAdgA0IAJ6IATAA5JAOgEBGXuIAs-RWTLz+AX23DUETFgAiAUQBqASQDCpnOSpIQ9Ri3aceCXgDZeMld7KUt6Siry8ksJiCPLyAMz8MrG8AJyS4RH8ZEq6+ugYMgBGdHRMWA6cLsysHE6e4hr+aprykvze3nHeaVGIoTLKKUPSKa28yvIpcbkgBphFJWUk8o60DNXudRKN4s2xbR1dPaKIk37yu9m8caFx4nGKM3MFaBAANmC4eACCAEp4FScVTctVAnm6sim1zIkmU3nEvFakROCAaZCSITiZAhoSkT3yMgATmAAI4AVzgLDYUCwEHYYBkaDYADc6ABrBkYADG5LQxMBa1cNQ8iH4-HEMmysKCkk0926vQQ3n4fnF42U2N8QTS+MMBWJ5MpTJpYEJhLohJkNDeGCYADMLcgZNzefzKJV1iCRQgxXEBoo4ZMyOIUoFeIr2ikBrLg1lAuIpPJdfNiRgICIsIQAOJZgAypgA+t8AKrGSwEAXOT3CrYIZQTSVBbowlTieEIxXKa5JVr3WLK8LtHR6WYE1PpzMEHP5gtWMwV91A6ubMGIesS1LdIa7VopBFCFFxHwyOKnyQpFU+ARXZP6sBpjP58ymXOV4E11d17zo-iSLGhDoxX4ZQ4kVBEo3GFJeGxBJAjUYc8j1Il7wnHAX1Maw8CLUtywLSwADkiGLAFF0FDZQW4RAIRkKF-zhBEkTAxFGygmD2lULRb2Qh9cHQzDZ0sec8MI4i32XCjwTSGijzo+FEWkRUBEhCYyEGZR0lPJMR2eGQ7QwNAPggLBflMPBfgATTEoUV0o1Edj2Vp2k6CFFSmP0QwmARunkTo4hSLi9IMyBcAAaUsUhSKrayJO2dEdxaA5nOOaJ5GyZR-DiVRgjlQZJC4sk2AwZl9JtQoPi+P4SNWKLyO9ajaJhej5ORFK0oyrLJG-C5ct0Ec2DoCA4E4Z4PWi70UkVABabxJQ0DRZW6I9Ul4LjilKUbatrVLEkmfgEhSOFv1hPbFU6-wyH4FILsmBp4nrLjXg+DavVresZphRbVD28IOm8MDGg6P9sTSXE8u0sdSQpWAqSgZ6P1skGT3kCYVVPZUOlc9ENRVUJxmByZlC48dojIl7Py6dLVCg+C-0UCaUXCdKroRODf3VBDRyQwLDLhmzPFS9EKb2xzkjUFrECmeR-AOgWLgRBNxHywrioMjAyrAXmYq-LHUa0SYwymZRFVS8YZD29SQL2g69umXqgA */
  id: "media",
  context: ({ input }) => ({
    source: input.source ?? null,
    simulate: input.simulate ?? false,
    autoStart: input.autoStart ?? false,
    audioTrack: null,
    videoTrack: null,
    simulated: false,
    hasAudioTrack: false,
    hasVideoTrack: false,
    audioEnabled: input.startWith?.audio ?? true,
    videoEnabled: input.startWith?.video ?? true,
    audioInputs: [],
    videoInputs: [],
    selectedAudioId: input.audioDeviceId ?? null,
    selectedVideoId: input.videoDeviceId ?? null,
    error: null,
    level: 0,
  }),
  initial: "boot",
  on: {
    // Works from any state; leaving `ready` runs trackGuard's cleanup.
    STOP: { target: ".idle", actions: "clearTracks" },
    DEVICES: { actions: "storeDevices" },
  },
  states: {
    boot: {
      always: [{ guard: "autoStart", target: "requesting" }, "idle"],
    },
    idle: {
      on: { START: "requesting" },
    },
    requesting: {
      invoke: {
        id: "acquire",
        src: "acquire",
        input: ({ context }) => ({
          source: context.source,
          simulate: context.simulate,
          audioId: context.selectedAudioId,
          videoId: context.selectedVideoId,
        }),
        onDone: { target: "ready", actions: "storeTracks" },
        onError: { target: "failed", actions: "storeError" },
      },
    },
    ready: {
      invoke: [
        {
          id: "trackGuard",
          src: "trackGuard",
          input: ({ context }) => ({
            audio: context.audioTrack,
            video: context.videoTrack,
          }),
        },
        {
          id: "levelMeter",
          src: "levelMeter",
          input: ({ context }) => ({
            audio: context.audioTrack,
            simulated: context.simulated,
          }),
        },
        {
          id: "deviceWatcher",
          src: "deviceWatcher",
          input: ({ context }) => ({
            source: context.source,
            simulate: context.simulate || context.simulated,
          }),
        },
      ],
      on: {
        TOGGLE_AUDIO: { actions: "toggleAudio" },
        TOGGLE_VIDEO: { actions: "toggleVideo" },
        LEVEL: { actions: "storeLevel" },
        SELECT_AUDIO_INPUT: { target: "requesting", actions: "selectAudio" },
        SELECT_VIDEO_INPUT: { target: "requesting", actions: "selectVideo" },
      },
    },
    failed: {
      on: {
        RETRY: "requesting",
        SKIP: "unavailable",
      },
    },
    /** The user chose to continue without camera/microphone. */
    unavailable: {
      on: { START: "requesting" },
    },
  },
});

export type MediaSnapshot = SnapshotFrom<typeof mediaMachine>;

export type MediaStatus =
  | "idle"
  | "requesting"
  | "ready"
  | "failed"
  | "unavailable";

export function selectMediaStatus(s: MediaSnapshot): MediaStatus {
  if (s.matches("ready")) return "ready";
  if (s.matches("requesting")) return "requesting";
  if (s.matches("failed")) return "failed";
  if (s.matches("unavailable")) return "unavailable";
  return "idle";
}

/** Mic level that respects mute (a muted mic shows a flat meter). */
export const selectAudioLevel = (s: MediaSnapshot) =>
  s.context.audioEnabled ? s.context.level : 0;
