// Session artifact helpers shared by produceSessions and repairSessionArtifacts.

import * as crypto from 'crypto';
import type { Bucket, File } from '@google-cloud/storage';
import type { DocumentReference, Firestore } from 'firebase-admin/firestore';

import {
  splitLocaleAndDefault,
  findDuplicateCandidates,
  isContentDuplicate,
  buildMergeOrder,
  mergeCsvContents,
  parseVtt,
  cuesToCsv,
} from './transcript_merge';

// 65s total.
export const MP4_RETRY_DELAYS_MS = [5000, 10000, 20000, 30000];
export const VTT_FLUSH_WAIT_MS = 15000;

const defaultSleep = (ms: number): Promise<void> =>
  new Promise((resolve) => setTimeout(resolve, ms));

// Agora STT strips non-alphanumerics from prefix segments.
export function sanitizePrefix(gcsPrefix: string): string {
  return gcsPrefix
    .split('/')
    .map((s) => s.replace(/[^a-zA-Z0-9]/g, ''))
    .join('/');
}

// Raw plus sanitized prefix.
export async function listSessionFiles(bucket: Bucket, gcsPrefix: string): Promise<File[]> {
  const [files] = await bucket.getFiles({ prefix: `${gcsPrefix}/` });
  const sanitizedPrefix = sanitizePrefix(gcsPrefix);
  if (sanitizedPrefix === gcsPrefix) return files;
  const [extraFiles] = await bucket.getFiles({ prefix: `${sanitizedPrefix}/` });
  return [...files, ...extraFiles];
}

export const mp4sOf = (files: File[]): File[] => files.filter((f) => f.name.endsWith('.mp4'));
export const vttsOf = (files: File[]): File[] => files.filter((f) => f.name.endsWith('.vtt'));

export interface ListUntilMp4Options {
  listFiles: () => Promise<File[]>;
  initialFiles: File[];
  delaysMs?: number[];
  sleep?: (ms: number) => Promise<void>;
}

// Re-list with backoff until an MP4 appears.
export async function listUntilMp4({
  listFiles,
  initialFiles,
  delaysMs = MP4_RETRY_DELAYS_MS,
  sleep = defaultSleep,
}: ListUntilMp4Options): Promise<{ files: File[]; waitedMs: number }> {
  let files = initialFiles;
  let waitedMs = 0;
  for (const delay of delaysMs) {
    if (mp4sOf(files).length > 0) break;
    await sleep(delay);
    waitedMs += delay;
    files = await listFiles();
  }
  return { files, waitedMs };
}

export async function registerMp4s(ref: DocumentReference, mp4Files: File[]): Promise<void> {
  if (mp4Files.length === 0) return;
  const updates: Record<string, string> = {};
  mp4Files.forEach((f, i) => {
    updates[`artifactPaths.complete_mp4_${i}`] = f.name;
  });
  await ref.update(updates);
}

export async function registerVtts(ref: DocumentReference, vttFiles: File[]): Promise<void> {
  if (vttFiles.length === 0) return;
  const updates: Record<string, string> = {};
  vttFiles.forEach((f, i) => {
    updates[`artifactPaths.transcript_vtt_${i}`] = f.name;
  });
  await ref.update(updates);
}

async function resolveUidMap(
  firestore: Firestore,
  rawUidMap: Record<string, string> | undefined
): Promise<Record<string, string>> {
  const uidEntries = Object.entries(rawUidMap || {});
  const resolvedNames = await Promise.all(
    uidEntries.map(async ([, userId]) => {
      try {
        const userDoc = await firestore.doc(`publicUser/${userId}`).get();
        return userDoc.exists ? (userDoc.data()?.displayName as string | undefined) ?? null : null;
      } catch {
        return null;
      }
    })
  );
  const uidMap: Record<string, string> = {};
  uidEntries.forEach(([agoraUid, userId], i) => {
    uidMap[agoraUid] = resolvedNames[i] || userId;
  });
  return uidMap;
}

export interface MergeTranscriptOptions {
  bucket: Bucket;
  firestore: Firestore;
  ref: DocumentReference;
  session: { gcsPrefix?: string; uidToDisplayName?: Record<string, string> };
  vttFiles: File[];
  mp4Files: File[];
}

// Merge VTTs to one CSV, register as complete_trx_0.
export async function mergeTranscript({
  bucket,
  firestore,
  ref,
  session,
  vttFiles,
  mp4Files,
}: MergeTranscriptOptions): Promise<string> {
  const entries = vttFiles.map((f) => ({ key: f.name, path: f.name }));
  const { localeEntries, defaultEntries } = splitLocaleAndDefault(entries);
  const candidates = findDuplicateCandidates(localeEntries, defaultEntries);

  const keysToDrop = new Set<string>();
  for (const { localeEntry, defaultEntry } of candidates) {
    const [localeBuf] = await bucket.file(localeEntry.path).download();
    const [defaultBuf] = await bucket.file(defaultEntry.path).download();
    const localeHash = crypto.createHash('sha256').update(localeBuf).digest('hex');
    const defaultHash = crypto.createHash('sha256').update(defaultBuf).digest('hex');
    if (isContentDuplicate(localeHash, localeBuf.length, defaultHash, defaultBuf.length)) {
      keysToDrop.add(localeEntry.key);
    }
  }

  const mergeOrder = buildMergeOrder(entries, keysToDrop);
  const uidMap = await resolveUidMap(firestore, session.uidToDisplayName);

  const csvFragments = await Promise.all(
    mergeOrder.map(async (entry) => {
      const [buf] = await bucket.file(entry.path).download();
      return cuesToCsv(parseVtt(buf.toString('utf-8')), uidMap);
    })
  );
  const mergedCsv = mergeCsvContents(csvFragments);

  const mp4Name = mp4Files[0]?.name;
  const outPath = mp4Name
    ? mp4Name.replace(/\.mp4$/i, '.csv')
    : `${session.gcsPrefix}/transcript_0.csv`;

  await bucket.file(outPath).save(mergedCsv, { contentType: 'text/csv' });
  await ref.update({ 'artifactPaths.complete_trx_0': outPath });
  return outPath;
}
