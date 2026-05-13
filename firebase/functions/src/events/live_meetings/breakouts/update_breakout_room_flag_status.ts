import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { OnCallMethod } from '../../../on_call_function';
import { firestore, firestoreUtils } from '../../../utils/infra/firestore_utils';
import { Event, Membership, BreakoutRoom, BreakoutRoomFlagStatus, membershipIsMod } from '../../../types';

interface UpdateBreakoutRoomFlagStatusRequest {
  eventPath: string;
  breakoutSessionId: string;
  roomId: string;
  flagStatus: BreakoutRoomFlagStatus;
}

export class UpdateBreakoutRoomFlagStatus extends OnCallMethod<UpdateBreakoutRoomFlagStatusRequest> {
  constructor() {
    super('UpdateBreakoutRoomFlagStatus', (json) => json as UpdateBreakoutRoomFlagStatusRequest);
  }

  async action(request: UpdateBreakoutRoomFlagStatusRequest, context: functions.https.CallableContext): Promise<string> {
    const event: Event = await firestoreUtils.getFirestoreObject({
      path: request.eventPath,
      constructor: (map) => map as unknown as Event,
    });

    await firestore.runTransaction(async (transaction) => {
      const breakoutRoomDoc = await firestore
        .doc(
          `${(event as any).fullPath}/live-meetings/${(event as any).id}/breakout-room-sessions/${request.breakoutSessionId}/breakout-rooms/${request.roomId}`
        )
        .get();

      const breakoutRoom = firestoreUtils.fromFirestoreJson(breakoutRoomDoc.data() ?? {}) as unknown as BreakoutRoom;

      const membershipSnap = await firestore
        .doc(`memberships/${context.auth?.uid}/community-membership/${(event as any).communityId}`)
        .get();
      const membership = firestoreUtils.fromFirestoreJson(membershipSnap.data() ?? {}) as unknown as Membership;

      const isAuthorizedParticipant =
        ((breakoutRoom as any).participantIds ?? []).includes(context.auth?.uid) &&
        request.flagStatus === BreakoutRoomFlagStatus.needsHelp;
      const isCreator = (event as any).creatorId === context.auth?.uid;
      const isAuthorized = membershipIsMod((membership as any).status) || isCreator || isAuthorizedParticipant;

      if (!isAuthorized) {
        throw new functions.https.HttpsError('failed-precondition', 'unauthorized');
      }

      transaction.update(breakoutRoomDoc.ref, { flagStatus: request.flagStatus });
    });

    return '';
  }
}
