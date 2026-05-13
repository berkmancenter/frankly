import * as functions from 'firebase-functions';
import * as https from 'https';
import * as http from 'http';
import { firestore, firestoreUtils } from '../../utils/infra/firestore_utils';
import { uidToInt } from '../../utils/utils';
// agora-token is a CommonJS module
// eslint-disable-next-line @typescript-eslint/no-var-requires
const agoraToken = require('agora-token');

const getAgoraAppId = () => functions.config().agora?.app_id as string;
const getAgoraAppCertificate = () => functions.config().agora?.app_certificate as string;
const getAgoraRestKey = () => functions.config().agora?.rest_key as string;
const getAgoraRestSecret = () => functions.config().agora?.rest_secret as string;
const getAgoraStorageBucketName = () => functions.config().agora?.storage_bucket_name as string;
const getAgoraStorageAccessKey = () => functions.config().agora?.storage_access_key as string;
const getAgoraStorageSecretKey = () => functions.config().agora?.storage_secret_key as string;

const RECORDING_UID = 456;
const RECORDING_COLLECTION = 'recording-sessions';

export interface RecordingSession {
  sessionId?: string;
  communityId?: string;
  eventId?: string;
  roomId?: string;
  roomType?: string;
  status?: string;
  gcsPrefix?: string;
  chatPath?: string;
  participantIds?: string[];
  breakoutSessionId?: string;
  agoraResourceId?: string;
  agoraSid?: string;
  errorMessage?: string;
}

function makeRequest(options: http.RequestOptions, body?: string): Promise<{ statusCode: number; body: string }> {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => resolve({ statusCode: res.statusCode ?? 0, body: data }));
    });
    req.on('error', reject);
    if (body) req.write(body);
    req.end();
  });
}

function getAuthHeaders(): Record<string, string> {
  const plain = `${getAgoraRestKey()}:${getAgoraRestSecret()}`;
  return {
    Authorization: `Basic ${Buffer.from(plain).toString('base64')}`,
    'Content-Type': 'application/json',
  };
}

export class AgoraUtils {
  createToken({ uid, roomId }: { uid: number; roomId: string }): string {
    return agoraToken.RtcTokenBuilder.buildTokenWithUid(
      getAgoraAppId(),
      getAgoraAppCertificate(),
      roomId,
      uid,
      1, // Publisher
      60 * 10,
    );
  }

  async recordRoom({
    roomId,
    sessionId,
    eventId,
    communityId,
    roomType,
    breakoutSessionId,
    chatPath,
    participantIds = [],
  }: {
    roomId: string;
    sessionId: string;
    eventId: string;
    communityId: string;
    roomType: string;
    breakoutSessionId?: string;
    chatPath?: string;
    participantIds?: string[];
  }): Promise<void> {
    const sessionRef = firestore.collection(RECORDING_COLLECTION).doc(sessionId);
    const gcsPrefix = `${eventId}/${breakoutSessionId ?? 'main'}/${roomId}/${sessionId}`;

    await sessionRef.set(firestoreUtils.toFirestoreJson({
      sessionId,
      communityId,
      eventId,
      roomId,
      roomType,
      status: 'starting',
      gcsPrefix,
      chatPath,
      participantIds,
      breakoutSessionId,
    } as unknown as Record<string, unknown>));

    console.log(`recording_start: sessionId=${sessionId} roomId=${roomId} eventId=${eventId} roomType=${roomType}`);

    let resourceId: string;
    try {
      resourceId = await this._acquireResourceId(roomId);
      console.log(`recording_acquired: sessionId=${sessionId} resourceId=${resourceId}`);
    } catch (e) {
      console.error('Agora acquire failed:', e);
      await sessionRef.update({ status: 'failed', errorMessage: String(e) });
      return;
    }

    await sessionRef.update({ agoraResourceId: resourceId });

    try {
      const sid = await this._startRecording({
        roomId,
        resourceId,
        fileNamePrefixSegments: [eventId, breakoutSessionId ?? 'main', roomId, sessionId],
      });
      console.log(`recording_started: sessionId=${sessionId} sid=${sid}`);
      await sessionRef.update({ agoraSid: sid, status: 'recording' });
    } catch (e) {
      console.error('Agora start failed:', e);
      await sessionRef.update({ status: 'failed', errorMessage: String(e) });
    }
  }

  async stopRoom({ sessionId }: { sessionId: string }): Promise<void> {
    const sessionRef = firestore.collection(RECORDING_COLLECTION).doc(sessionId);
    const snapshot = await sessionRef.get();
    if (!snapshot.exists) {
      console.log('Session not found, skipping stop:', sessionId);
      return;
    }

    const session = firestoreUtils.fromFirestoreJson(snapshot.data()!) as unknown as RecordingSession;
    if (session.status === 'stopped' || session.status === 'failed') {
      console.log('Session already in terminal state:', sessionId);
      return;
    }

    if (session.agoraResourceId && session.agoraSid) {
      try {
        const headers = getAuthHeaders();
        const path = `/v1/apps/${getAgoraAppId()}/cloud_recording/resourceid/${session.agoraResourceId}/sid/${session.agoraSid}/mode/mix/stop`;
        const result = await makeRequest({
          method: 'POST',
          hostname: 'api.agora.io',
          path,
          headers: { ...headers, 'Content-Length': '0' },
        }, JSON.stringify({ cname: session.roomId, uid: RECORDING_UID.toString(), clientRequest: {} }));
        console.log(`Stop response (${result.statusCode}):`, result.body);
      } catch (e) {
        console.error('Error calling Agora stop:', e);
      }
    }

    await sessionRef.update({ status: 'stopped', stoppedAt: new Date() });
  }

  async kickParticipant({ roomId, userId }: { roomId: string; userId: string }): Promise<void> {
    const headers = getAuthHeaders();
    const body = JSON.stringify({
      appid: getAgoraAppId(),
      cname: roomId,
      uid: uidToInt(userId),
      time: 1440,
      privileges: ['join_channel'],
    });

    const result = await makeRequest({
      method: 'POST',
      hostname: 'api.agora.io',
      path: '/dev/v1/kicking-rule',
      headers: { ...headers, 'Content-Length': Buffer.byteLength(body).toString() },
    }, body);

    console.log('Kick result:', result.body);
    if (result.statusCode < 200 || result.statusCode > 299) {
      throw new functions.https.HttpsError('internal', 'Error kicking user');
    }
  }

  private async _acquireResourceId(roomId: string): Promise<string> {
    const body = JSON.stringify({ cname: roomId, uid: RECORDING_UID.toString(), clientRequest: {} });
    const headers = getAuthHeaders();
    const result = await makeRequest({
      method: 'POST',
      hostname: 'api.agora.io',
      path: `/v1/apps/${getAgoraAppId()}/cloud_recording/acquire`,
      headers: { ...headers, 'Content-Length': Buffer.byteLength(body).toString() },
    }, body);

    console.log(`Acquire response (${result.statusCode}):`, result.body);
    if (result.statusCode < 200 || result.statusCode > 299) {
      throw new functions.https.HttpsError('internal', `Acquire failed: ${result.body}`);
    }
    return JSON.parse(result.body).resourceId as string;
  }

  private async _startRecording({
    roomId,
    resourceId,
    fileNamePrefixSegments,
  }: {
    roomId: string;
    resourceId: string;
    fileNamePrefixSegments: string[];
  }): Promise<string> {
    const token = this.createToken({ uid: RECORDING_UID, roomId });
    const request = {
      cname: roomId,
      uid: RECORDING_UID.toString(),
      clientRequest: {
        token,
        recordingConfig: {
          maxIdleTime: 300,
          transcodingConfig: {
            height: 360, width: 640, bitrate: 500, fps: 15,
            mixedVideoLayout: 1, backgroundColor: '#000000',
          },
        },
        recordingFileConfig: { avFileType: ['hls', 'mp4'] },
        storageConfig: {
          vendor: 6, region: 0,
          bucket: getAgoraStorageBucketName(),
          accessKey: getAgoraStorageAccessKey(),
          secretKey: getAgoraStorageSecretKey(),
          fileNamePrefix: fileNamePrefixSegments,
        },
      },
    };

    const body = JSON.stringify(request);
    const headers = getAuthHeaders();
    const result = await makeRequest({
      method: 'POST',
      hostname: 'api.agora.io',
      path: `/v1/apps/${getAgoraAppId()}/cloud_recording/resourceid/${resourceId}/mode/mix/start`,
      headers: { ...headers, 'Content-Length': Buffer.byteLength(body).toString() },
    }, body);

    console.log(`Start response (${result.statusCode}):`, result.body);
    if (result.statusCode < 200 || result.statusCode > 299) {
      throw new functions.https.HttpsError('internal', `Start failed: ${result.body}`);
    }
    return JSON.parse(result.body).sid as string;
  }
}
