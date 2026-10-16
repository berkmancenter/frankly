import { onDocumentUpdated } from 'firebase-functions/v2/firestore';
import * as admin from 'firebase-admin';

import { agoraStorageBucketName } from './config';
import {
  VTT_FLUSH_WAIT_MS,
  listSessionFiles,
  listUntilMp4,
  mp4sOf,
  vttsOf,
  registerMp4s,
  registerVtts,
  mergeTranscript,
} from './session_artifacts';

const sleep = (ms: number): Promise<void> => new Promise((resolve) => setTimeout(resolve, ms));

interface RecordingSession {
  status?: string;
  gcsPrefix?: string;
  agoraResourceId?: string;
  agoraSid?: string;
  agoraRttAgentId?: string;
  uidToDisplayName?: Record<string, string>;
}

// On stop, register MP4/VTT artifacts and merge the transcript.
export const produceSessions = onDocumentUpdated(
  { document: 'recording-sessions/{sessionId}', timeoutSeconds: 300 },
  async (event) => {
    const before = event.data?.before.data() as RecordingSession | undefined;
    const after = event.data?.after.data() as RecordingSession | undefined;
    if (!before || !after) return;

    if (before.status === after.status) return;
    if (after.status !== 'stopped') return;

    const sessionId = event.params.sessionId;
    const gcsPrefix = after.gcsPrefix;
    if (!gcsPrefix) {
      console.warn(`Session ${sessionId} has no gcsPrefix, skipping post-processing`);
      return;
    }

    const firestore = admin.firestore();
    const bucket = admin.storage().bucket(agoraStorageBucketName.value());
    const ref = event.data!.after.ref;
    const listFiles = () => listSessionFiles(bucket, gcsPrefix);

    let allFiles;
    try {
      allFiles = await listFiles();
    } catch (err) {
      console.error(`Error listing files for session ${sessionId}:`, err);
      return;
    }

    // --- Register MP4 ---
    // MP4 upload can lag the stop. Retry only if recording ran.
    let waitedMs = 0;
    let finalMp4Files = mp4sOf(allFiles);
    try {
      const hadRecording = after.agoraResourceId != null || after.agoraSid != null;
      if (hadRecording && mp4sOf(allFiles).length === 0) {
        const result = await listUntilMp4({ listFiles, initialFiles: allFiles });
        allFiles = result.files;
        waitedMs = result.waitedMs;
      }

      finalMp4Files = mp4sOf(allFiles);
      if (finalMp4Files.length === 0) {
        console.warn(
          `No MP4 found under ${gcsPrefix}/ for session ${sessionId} after waiting ${waitedMs}ms`
        );
      } else {
        await registerMp4s(ref, finalMp4Files);
        console.log(
          `Registered ${finalMp4Files.length} MP4(s) for session ${sessionId} after ${waitedMs}ms: ${finalMp4Files
            .map((f) => f.name)
            .join(', ')}`
        );
      }
    } catch (err) {
      console.error(`Error registering MP4 for session ${sessionId}:`, err);
    }

    // --- Register VTT transcript files ---
    let finalVttFiles = vttsOf(allFiles);
    try {
      let vttFiles = vttsOf(allFiles);

      // Wait for STT flush; MP4 wait counts toward it.
      const hasSTT = after.agoraRttAgentId != null;
      if (vttFiles.length === 0 && hasSTT) {
        const remainingMs = Math.max(0, VTT_FLUSH_WAIT_MS - waitedMs);
        if (remainingMs > 0) {
          console.log(
            `No VTT files yet for STT-enabled session ${sessionId}, waiting ${remainingMs}ms for agent flush...`
          );
          await sleep(remainingMs);
        }
        allFiles = await listFiles();
        vttFiles = vttsOf(allFiles);
      }

      finalVttFiles = vttFiles;
      if (vttFiles.length === 0) {
        console.log(`No VTT files found under ${gcsPrefix}/ for session ${sessionId}`);
      } else {
        await registerVtts(ref, vttFiles);
        console.log(
          `Registered ${vttFiles.length} VTT file(s) for session ${sessionId}: ${vttFiles
            .map((f) => f.name)
            .join(', ')}`
        );
      }
    } catch (err) {
      console.error(`Error registering VTT for session ${sessionId}:`, err);
    }

    // --- Merge VTT fragments into one CSV transcript ---
    try {
      if (finalVttFiles.length > 0) {
        const outPath = await mergeTranscript({
          bucket,
          firestore,
          ref,
          session: after,
          vttFiles: finalVttFiles,
          mp4Files: finalMp4Files,
        });
        console.log(`Registered merged transcript for session ${sessionId}: ${outPath}`);
      }
    } catch (err) {
      console.error(`Error merging transcript for session ${sessionId}:`, err);
    }
  }
);
