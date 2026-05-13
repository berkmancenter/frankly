import { firestore, firestoreUtils } from '../../utils/infra/firestore_utils';
import { AgoraUtils, RecordingSession } from './agora_api';
import { uidToInt } from '../../utils/utils';
import { Event, BreakoutRoom } from '../../types';

export interface PendingRecording {
  roomId: string;
  sessionId: string;
  eventId: string;
  communityId: string;
  roomType: string;
  chatPath: string;
  participantIds: string[];
}

export interface GetMeetingJoinInfoResponse {
  identity: string;
  meetingToken: string;
  meetingId: string;
}

export interface MeetingJoinResult {
  response: GetMeetingJoinInfoResponse;
  pendingRecording?: PendingRecording;
}

const RECORDING_COLLECTION = 'recording-sessions';

export class LiveMeetingUtils {
  agoraUtils: AgoraUtils;

  constructor(agoraUtils?: AgoraUtils) {
    this.agoraUtils = agoraUtils ?? new AgoraUtils();
  }

  private _shouldRecord(event: Event): boolean {
    return (event.eventSettings as any)?.alwaysRecord ?? false;
  }

  async getMeetingJoinInfo({
    transaction,
    communityId,
    liveMeetingCollectionPath,
    meetingId,
    userId,
    event,
  }: {
    transaction: FirebaseFirestore.Transaction;
    communityId: string;
    liveMeetingCollectionPath: string;
    meetingId: string;
    userId: string;
    event: Event;
  }): Promise<MeetingJoinResult> {
    const liveMeetingRef = firestore.doc(`${liveMeetingCollectionPath}/${meetingId}`);
    const liveMeetingSnap = await transaction.get(liveMeetingRef);

    let liveMeeting: Record<string, unknown> = liveMeetingSnap.exists
      ? (firestoreUtils.fromFirestoreJson(liveMeetingSnap.data()!) as Record<string, unknown>)
      : {};

    const fieldsToUpdate: string[] = [];

    if (!liveMeeting.meetingId) {
      fieldsToUpdate.push('meetingId');
      liveMeeting = { ...liveMeeting, meetingId };
    }

    const shouldRecord = this._shouldRecord(event) || (liveMeeting.record as boolean);
    let newSessionId: string | undefined;
    if (shouldRecord && !liveMeeting.recordingSessionId) {
      newSessionId = firestore.collection(RECORDING_COLLECTION).doc().id;
      fieldsToUpdate.push('recordingSessionId');
      liveMeeting = { ...liveMeeting, recordingSessionId: newSessionId };
    }

    if (liveMeetingSnap.exists && fieldsToUpdate.length > 0) {
      const update: Record<string, unknown> = {};
      for (const f of fieldsToUpdate) update[f] = liveMeeting[f];
      transaction.update(liveMeetingRef, firestoreUtils.toFirestoreJson(update));
    } else if (!liveMeetingSnap.exists) {
      transaction.set(liveMeetingRef, firestoreUtils.toFirestoreJson(liveMeeting));
    }

    let pendingRecording: PendingRecording | undefined;
    if (newSessionId) {
      const chatPath = `${liveMeetingCollectionPath}/${meetingId}/chats/community_chat/messages`;
      const participantIds = ((liveMeeting.participants as any[]) ?? [])
        .map((p: any) => p.communityId)
        .filter(Boolean) as string[];
      pendingRecording = {
        roomId: meetingId,
        sessionId: newSessionId,
        eventId: event.id!,
        communityId,
        roomType: 'main',
        chatPath,
        participantIds,
      };
    }

    const token = this.agoraUtils.createToken({ uid: uidToInt(userId), roomId: meetingId });

    return {
      response: { identity: userId, meetingToken: token, meetingId },
      pendingRecording,
    };
  }

  async getBreakoutRoomJoinInfo({
    communityId,
    eventId,
    breakoutSessionId,
    breakoutRoomPath,
    meetingId,
    userId,
    record,
    existingRecordingSessionId,
    participantIds,
  }: {
    communityId: string;
    eventId: string;
    breakoutSessionId: string;
    breakoutRoomPath: string;
    meetingId: string;
    userId: string;
    record: boolean;
    existingRecordingSessionId?: string;
    participantIds: string[];
  }): Promise<GetMeetingJoinInfoResponse> {
    const token = this.agoraUtils.createToken({ uid: uidToInt(userId), roomId: meetingId });

    if (record && !existingRecordingSessionId) {
      await this._startBreakoutRecording({
        communityId, eventId, breakoutSessionId, breakoutRoomPath, meetingId, participantIds,
      });
    } else if (record && existingRecordingSessionId) {
      const sessionSnap = await firestore.collection(RECORDING_COLLECTION).doc(existingRecordingSessionId).get();
      if (sessionSnap.exists) {
        const session = firestoreUtils.fromFirestoreJson(sessionSnap.data()!) as unknown as RecordingSession;
        if (session.status === 'stopped' || session.status === 'failed') {
          await this._startBreakoutRecording({
            communityId, eventId, breakoutSessionId, breakoutRoomPath, meetingId, participantIds,
          });
        }
      }
    }

    return { identity: userId, meetingToken: token, meetingId };
  }

  private async _startBreakoutRecording({
    communityId, eventId, breakoutSessionId, breakoutRoomPath, meetingId, participantIds,
  }: {
    communityId: string; eventId: string; breakoutSessionId: string;
    breakoutRoomPath: string; meetingId: string; participantIds: string[];
  }): Promise<void> {
    const newSessionId = firestore.collection(RECORDING_COLLECTION).doc().id;
    await firestore.doc(breakoutRoomPath).update({ recordingSessionId: newSessionId });
    const chatPath = `${breakoutRoomPath}/chats/community_chat/messages`;
    await this.agoraUtils.recordRoom({
      roomId: meetingId, sessionId: newSessionId, eventId, communityId,
      roomType: 'breakout', breakoutSessionId, chatPath, participantIds,
    });
  }
}
