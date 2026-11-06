import { afterEach, describe, expect, it, vi } from 'vitest';
import { createActor } from 'xstate';
import {
  classifyMediaError,
  mediaMachine,
  selectAudioLevel,
  selectMediaStatus,
  type AcquiredTracks,
  type MediaInput,
  type MediaSource,
} from '../media.machine';

class FakeTrack {
  enabled = true;
  closed = false;
  setEnabled = vi.fn(async (e: boolean) => {
    this.enabled = e;
  });
  close = vi.fn(() => {
    this.closed = true;
  });
  getVolumeLevel = () => 0.5;
}

const tracks = (opts: { audio?: boolean; video?: boolean } = {}) => ({
  audio: opts.audio === false ? null : new FakeTrack(),
  video: opts.video === false ? null : new FakeTrack(),
});

const agoraError = (code: string) => Object.assign(new Error(code), { code });
const flush = async (rounds = 8) => {
  for (let i = 0; i < rounds; i += 1) await Promise.resolve();
};

function source(acquire: MediaSource['acquire']): MediaSource {
  return {
    acquire,
    listDevices: vi.fn(async () => ({
      audioInputs: [{ deviceId: 'mic1', label: 'Built-in mic' }],
      videoInputs: [
        { deviceId: 'cam1', label: 'Built-in camera' },
        { deviceId: 'cam2', label: 'External camera' },
      ],
    })),
    onDevicesChanged: () => () => {},
  };
}

const actors: { stop(): void }[] = [];
afterEach(() => {
  for (const a of actors.splice(0)) a.stop();
});

function start(input: MediaInput) {
  const actor = createActor(mediaMachine, { input });
  actor.start();
  actors.push(actor);
  return actor;
}

describe('mediaMachine', () => {
  it('acquires tracks on START and applies the initial mute state', async () => {
    const t = tracks();
    const actor = start({ source: source(async () => t as AcquiredTracks), startWith: { audio: true, video: false } });

    expect(selectMediaStatus(actor.getSnapshot())).toBe('idle');
    actor.send({ type: 'START' });
    expect(selectMediaStatus(actor.getSnapshot())).toBe('requesting');
    await flush();

    const snap = actor.getSnapshot();
    expect(selectMediaStatus(snap)).toBe('ready');
    expect(snap.context.audioTrack).toBe(t.audio);
    expect(t.audio!.setEnabled).toHaveBeenCalledWith(true);
    expect(t.video!.setEnabled).toHaveBeenCalledWith(false);
    await flush();
    expect(actor.getSnapshot().context.videoInputs.map((d) => d.label)).toEqual(['Built-in camera', 'External camera']);
  });

  it('toggles audio and video with setEnabled, without closing the tracks', async () => {
    const t = tracks();
    const actor = start({ source: source(async () => t as AcquiredTracks), autoStart: true });
    await flush();

    actor.send({ type: 'TOGGLE_AUDIO' });
    expect(actor.getSnapshot().context.audioEnabled).toBe(false);
    expect(t.audio!.setEnabled).toHaveBeenLastCalledWith(false);
    actor.send({ type: 'TOGGLE_VIDEO' });
    expect(t.video!.setEnabled).toHaveBeenLastCalledWith(false);
    actor.send({ type: 'TOGGLE_VIDEO' });
    expect(t.video!.setEnabled).toHaveBeenLastCalledWith(true);
    expect(t.audio!.closed || t.video!.closed).toBe(false);
  });

  it('reports a muted mic as a flat level', async () => {
    const actor = start({ simulate: true, autoStart: true });
    await flush();
    actor.send({ type: 'LEVEL', level: 0.8 });
    expect(selectAudioLevel(actor.getSnapshot())).toBe(0.8);
    actor.send({ type: 'TOGGLE_AUDIO' });
    expect(selectAudioLevel(actor.getSnapshot())).toBe(0);
  });

  it('fails with a classified error, then recovers on RETRY', async () => {
    const t = tracks();
    const acquire = vi
      .fn<MediaSource['acquire']>()
      .mockRejectedValueOnce(agoraError('PERMISSION_DENIED'))
      .mockResolvedValueOnce(t as AcquiredTracks);
    const actor = start({ source: source(acquire), autoStart: true });
    await flush();

    expect(selectMediaStatus(actor.getSnapshot())).toBe('failed');
    expect(actor.getSnapshot().context.error?.kind).toBe('denied');

    actor.send({ type: 'RETRY' });
    await flush();
    expect(selectMediaStatus(actor.getSnapshot())).toBe('ready');
    expect(actor.getSnapshot().context.error).toBeNull();
  });

  it('is ready without a camera when the source returns audio only', async () => {
    const t = tracks({ video: false });
    const actor = start({ source: source(async () => t as AcquiredTracks), autoStart: true });
    await flush();
    const snap = actor.getSnapshot();
    expect(selectMediaStatus(snap)).toBe('ready');
    expect(snap.context.hasAudioTrack).toBe(true);
    expect(snap.context.hasVideoTrack).toBe(false);
  });

  it('lets the user continue without devices after a failure', async () => {
    const acquire = vi.fn<MediaSource['acquire']>().mockRejectedValue(agoraError('DEVICE_NOT_FOUND'));
    const actor = start({ source: source(acquire), autoStart: true });
    await flush();
    actor.send({ type: 'SKIP' });
    expect(selectMediaStatus(actor.getSnapshot())).toBe('unavailable');
    actor.send({ type: 'START' });
    expect(selectMediaStatus(actor.getSnapshot())).toBe('requesting');
  });

  it('switching device re-acquires with that device id and closes the old tracks', async () => {
    const first = tracks();
    const second = tracks();
    const acquire = vi
      .fn<MediaSource['acquire']>()
      .mockResolvedValueOnce(first as AcquiredTracks)
      .mockResolvedValueOnce(second as AcquiredTracks);
    const actor = start({ source: source(acquire), autoStart: true });
    await flush();

    actor.send({ type: 'SELECT_VIDEO_INPUT', deviceId: 'cam2' });
    expect(first.audio!.closed && first.video!.closed).toBe(true); // old devices released immediately
    await flush();

    expect(acquire).toHaveBeenLastCalledWith({ audioId: null, videoId: 'cam2' });
    expect(actor.getSnapshot().context.videoTrack).toBe(second.video);
    expect(second.video!.closed).toBe(false);
  });

  it('keeps the mute choices across a device switch', async () => {
    const acquire = vi.fn<MediaSource['acquire']>().mockImplementation(async () => tracks() as AcquiredTracks);
    const actor = start({ source: source(acquire), autoStart: true });
    await flush();
    actor.send({ type: 'TOGGLE_AUDIO' });
    actor.send({ type: 'SELECT_AUDIO_INPUT', deviceId: 'mic1' });
    await flush();
    const snap = actor.getSnapshot();
    expect(snap.context.audioEnabled).toBe(false);
    expect((snap.context.audioTrack as unknown as FakeTrack).setEnabled).toHaveBeenLastCalledWith(false);
  });

  it('starts with preferred devices from the mirror check', async () => {
    const acquire = vi.fn<MediaSource['acquire']>().mockResolvedValue(tracks() as AcquiredTracks);
    start({ source: source(acquire), autoStart: true, audioDeviceId: 'mic9', videoDeviceId: 'cam9' });
    await flush();
    expect(acquire).toHaveBeenCalledWith({ audioId: 'mic9', videoId: 'cam9' });
  });

  it('releases the hardware on STOP and when the actor is stopped', async () => {
    const a = tracks();
    const actorA = start({ source: source(async () => a as AcquiredTracks), autoStart: true });
    await flush();
    actorA.send({ type: 'STOP' });
    expect(selectMediaStatus(actorA.getSnapshot())).toBe('idle');
    expect(a.audio!.closed && a.video!.closed).toBe(true);

    const b = tracks();
    const actorB = start({ source: source(async () => b as AcquiredTracks), autoStart: true });
    await flush();
    actorB.stop(); // what unmounting the MediaScope does
    expect(b.audio!.closed && b.video!.closed).toBe(true);
  });

  it('releases tracks that arrive after their request was canceled', async () => {
    const late = tracks();
    let resolveRequest!: (t: AcquiredTracks) => void;
    const acquire = vi.fn<MediaSource['acquire']>(() => new Promise<AcquiredTracks>((r) => (resolveRequest = r)));
    const actor = start({ source: source(acquire), autoStart: true });
    await flush();
    expect(selectMediaStatus(actor.getSnapshot())).toBe('requesting');

    actor.send({ type: 'STOP' }); // user backs out while the browser permission prompt is open
    resolveRequest(late as AcquiredTracks); // ...and then clicks "Allow"
    await flush();

    expect(selectMediaStatus(actor.getSnapshot())).toBe('idle');
    expect(late.audio!.closed && late.video!.closed).toBe(true);
    expect(actor.getSnapshot().context.audioTrack).toBeNull();
  });

  it('runs without hardware in simulate mode', async () => {
    const acquire = vi.fn<MediaSource['acquire']>();
    const actor = start({ source: source(acquire), simulate: true, autoStart: true });
    await flush();
    const snap = actor.getSnapshot();
    expect(selectMediaStatus(snap)).toBe('ready');
    expect(snap.context.simulated).toBe(true);
    expect(snap.context.audioTrack).toBeNull();
    expect(acquire).not.toHaveBeenCalled();
    expect(snap.context.audioInputs).toHaveLength(1);
  });

  it('classifies Agora error codes and browser error names', () => {
    expect(classifyMediaError(agoraError('PERMISSION_DENIED')).kind).toBe('denied');
    expect(classifyMediaError(agoraError('DEVICE_NOT_FOUND')).kind).toBe('notFound');
    expect(classifyMediaError(agoraError('NOT_READABLE')).kind).toBe('inUse');
    expect(classifyMediaError(Object.assign(new Error('x'), { name: 'NotAllowedError' })).kind).toBe('denied');
    expect(classifyMediaError(new Error('?')).kind).toBe('unknown');
  });
});
