import type { Bucket, File } from '@google-cloud/storage';
import type { DocumentReference, Firestore } from 'firebase-admin/firestore';

import {
  MP4_RETRY_DELAYS_MS,
  sanitizePrefix,
  listSessionFiles,
  listUntilMp4,
  registerMp4s,
  registerVtts,
  mergeTranscript,
} from './session_artifacts';

const file = (name: string): File => ({ name }) as unknown as File;

function fakeRef(): DocumentReference & { updates: Record<string, unknown>[] } {
  const updates: Record<string, unknown>[] = [];
  return {
    updates,
    update: async (u: Record<string, unknown>) => {
      updates.push(u);
    },
  } as unknown as DocumentReference & { updates: Record<string, unknown>[] };
}

function fakeBucket(
  contents: Record<string, string> = {},
  listings: Record<string, File[]> = {}
): Bucket & { saved: Record<string, string> } {
  const saved: Record<string, string> = {};
  return {
    saved,
    getFiles: async ({ prefix }: { prefix: string }) => [listings[prefix] || []],
    file: (path: string) => ({
      download: async () => [Buffer.from(contents[path] || '')],
      save: async (data: string) => {
        saved[path] = data;
      },
    }),
  } as unknown as Bucket & { saved: Record<string, string> };
}

const fakeFirestore = (names: Record<string, string> = {}): Firestore =>
  ({
    doc: (path: string) => ({
      get: async () => {
        const id = path.split('/')[1];
        return { exists: id in names, data: () => ({ displayName: names[id] }) };
      },
    }),
  }) as unknown as Firestore;

test('sanitizePrefix strips non-alphanumerics per segment', () => {
  expect(sanitizePrefix('a-b/c_d/e')).toBe('ab/cd/e');
});

test('listSessionFiles merges raw and sanitized prefixes', async () => {
  const bucket = fakeBucket({}, { 'a-b/': [file('a-b/x.mp4')], 'ab/': [file('ab/x.vtt')] });
  const files = await listSessionFiles(bucket, 'a-b');
  expect(files.map((f) => f.name)).toEqual(['a-b/x.mp4', 'ab/x.vtt']);
});

test('listSessionFiles lists once when prefix is already clean', async () => {
  let calls = 0;
  const bucket = {
    getFiles: async () => {
      calls++;
      return [[]];
    },
  } as unknown as Bucket;
  await listSessionFiles(bucket, 'abc');
  expect(calls).toBe(1);
});

test('listUntilMp4 does not wait when MP4 already present', async () => {
  const sleeps: number[] = [];
  const result = await listUntilMp4({
    initialFiles: [file('p/a.mp4')],
    listFiles: async () => {
      throw new Error('should not relist');
    },
    sleep: async (ms: number) => {
      sleeps.push(ms);
    },
  });
  expect(sleeps).toEqual([]);
  expect(result.waitedMs).toBe(0);
});

test('listUntilMp4 stops as soon as MP4 appears', async () => {
  const sleeps: number[] = [];
  const listings = [[], [file('p/a.mp4')]];
  const result = await listUntilMp4({
    initialFiles: [],
    listFiles: async () => listings.shift() ?? [],
    sleep: async (ms: number) => {
      sleeps.push(ms);
    },
  });
  expect(sleeps).toEqual(MP4_RETRY_DELAYS_MS.slice(0, 2));
  expect(result.waitedMs).toBe(15000);
  expect(result.files[0].name).toBe('p/a.mp4');
});

test('listUntilMp4 gives up after all delays', async () => {
  const sleeps: number[] = [];
  const result = await listUntilMp4({
    initialFiles: [file('p/a.vtt')],
    listFiles: async () => [file('p/a.vtt')],
    sleep: async (ms: number) => {
      sleeps.push(ms);
    },
  });
  expect(sleeps).toEqual(MP4_RETRY_DELAYS_MS);
  expect(result.waitedMs).toBe(65000);
  expect(result.files.length).toBe(1);
});

test('registerMp4s and registerVtts write indexed keys, skip empty', async () => {
  const ref = fakeRef();
  await registerMp4s(ref, []);
  await registerVtts(ref, []);
  expect(ref.updates.length).toBe(0);

  await registerMp4s(ref, [file('a.mp4'), file('b.mp4')]);
  await registerVtts(ref, [file('a.vtt')]);
  expect(ref.updates).toEqual([
    { 'artifactPaths.complete_mp4_0': 'a.mp4', 'artifactPaths.complete_mp4_1': 'b.mp4' },
    { 'artifactPaths.transcript_vtt_0': 'a.vtt' },
  ]);
});

const vtt = (start: string, text: string) => `WEBVTT\n\n${start} --> 00:00:02.000\n${text}\n`;

test('mergeTranscript orders fragments, drops locale dupes, maps speakers', async () => {
  const bsid = 'aBreakoutSessionId20';
  const early = `p/evt-${bsid}_r_s_20260101000000000.vtt`;
  const late = `p/evt-${bsid}_r_s_20260101000100000.vtt`;
  const dupe = `p/evt-en-US_${bsid}_r_s_20260101000000000.vtt`;
  const bucket = fakeBucket({
    [early]: vtt('00:00:00.000', '<v 1>hello'),
    [late]: vtt('00:01:00.000', '<v 2>bye'),
    [dupe]: vtt('00:00:00.000', '<v 1>hello'),
  });
  const ref = fakeRef();

  const outPath = await mergeTranscript({
    bucket,
    firestore: fakeFirestore({ u1: 'Ann' }),
    ref,
    session: { gcsPrefix: 'p', uidToDisplayName: { '1': 'u1', '2': 'u2' } },
    vttFiles: [file(late), file(dupe), file(early)],
    mp4Files: [file('p/rec.mp4')],
  });

  expect(outPath).toBe('p/rec.csv');
  expect(ref.updates).toEqual([{ 'artifactPaths.complete_trx_0': 'p/rec.csv' }]);
  expect(bucket.saved['p/rec.csv']).toBe(
    'Start,End,Speaker,Speaker ID,Text\n' +
      '00:00:00.000,00:00:02.000,"Ann","1","hello"\n' +
      '00:01:00.000,00:00:02.000,"u2","2","bye"\n'
  );
});

test('mergeTranscript falls back to gcsPrefix path without MP4', async () => {
  const bucket = fakeBucket({ 'p/a.vtt': vtt('00:00:00.000', 'hi') });
  const outPath = await mergeTranscript({
    bucket,
    firestore: fakeFirestore(),
    ref: fakeRef(),
    session: { gcsPrefix: 'p' },
    vttFiles: [file('p/a.vtt')],
    mp4Files: [],
  });
  expect(outPath).toBe('p/transcript_0.csv');
});
