import * as functions from 'firebase-functions';
import { OnCallMethod } from '../../on_call_function';
import { firestore, firestoreUtils } from '../../utils/infra/firestore_utils';
import { firebaseAuthUtils } from '../../utils/infra/firebase_auth_utils';
import { LiveMeetingUtils } from './live_meeting_utils';
import { Event, Participant, ParticipantStatus } from '../../types';
import { firstAndLastInitial } from '../../utils/utils';

interface GetMeetingJoinInfoRequest {
  eventPath: string;
}

export class GetMeetingJoinInfo extends OnCallMethod<GetMeetingJoinInfoRequest> {
  private liveMeetingUtils: LiveMeetingUtils;

  constructor(liveMeetingUtils?: LiveMeetingUtils) {
    super('GetMeetingJoinInfo', (jsonMap) => jsonMap as GetMeetingJoinInfoRequest);
    this.liveMeetingUtils = liveMeetingUtils ?? new LiveMeetingUtils();
  }

  async action(request: GetMeetingJoinInfoRequest, context: functions.https.CallableContext): Promise<Record<string, unknown>> {
    const result = await firestore.runTransaction(async (transaction) => {
      const event: Event = await firestoreUtils.getFirestoreObject({
        transaction,
        path: request.eventPath,
        constructor: (map) => map as unknown as Event,
      });

      const participant: Participant = await firestoreUtils.getFirestoreObject({
        transaction,
        path: `${request.eventPath}/event-participants/${context.auth?.uid}`,
        constructor: (map) => map as unknown as Participant,
      });

      if (participant.status !== ParticipantStatus.active) {
        throw new functions.https.HttpsError('failed-precondition', 'unauthorized');
      }

      const userSnap = await firestore.doc(`publicUser/${context.auth?.uid}`).get();
      let displayName: string | null = userSnap.data()?.displayName ?? null;

      if (!displayName || displayName.trim().length === 0) {
        const users = await firebaseAuthUtils.getUsers([context.auth!.uid]);
        displayName = firstAndLastInitial(users[0]?.displayName) ?? `User-${context.auth!.uid.substring(0, 4)}`;
      }

      return this.liveMeetingUtils.getMeetingJoinInfo({
        transaction,
        event,
        communityId: event.communityId!,
        liveMeetingCollectionPath: `${request.eventPath}/live-meetings`,
        meetingId: event.id!,
        userId: context.auth!.uid,
      });
    });

    const pending = result.pendingRecording;
    if (pending) {
      await this.liveMeetingUtils.agoraUtils.recordRoom({
        roomId: pending.roomId,
        sessionId: pending.sessionId,
        eventId: pending.eventId,
        communityId: pending.communityId,
        roomType: pending.roomType,
        chatPath: pending.chatPath,
        participantIds: pending.participantIds,
      });
    }

    return result.response as unknown as Record<string, unknown>;
  }
}
