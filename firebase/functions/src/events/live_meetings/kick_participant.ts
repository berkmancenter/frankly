import * as functions from 'firebase-functions';
import { OnCallMethod } from '../../on_call_function';
import { firestore, firestoreUtils } from '../../utils/infra/firestore_utils';
import { orElseUnauthorized } from '../../utils/utils';
import { AgoraUtils } from './agora_api';
import { Event, Membership, LiveMeeting, membershipIsFacilitator } from '../../types';

interface KickParticipantRequest {
  eventPath: string;
  userToKickId: string;
  breakoutRoomId?: string;
}

export class KickParticipant extends OnCallMethod<KickParticipantRequest> {
  private agoraUtils: AgoraUtils;

  constructor(agoraUtils?: AgoraUtils) {
    super('KickParticipant', (json) => json as KickParticipantRequest);
    this.agoraUtils = agoraUtils ?? new AgoraUtils();
  }

  async action(request: KickParticipantRequest, context: functions.https.CallableContext): Promise<string> {
    const eventPath = request.eventPath;

    await firestore.runTransaction(async (transaction) => {
      const event: Event = await firestoreUtils.getFirestoreObject({
        transaction,
        path: eventPath,
        constructor: (map) => map as unknown as Event,
      });

      const communityMembershipSnap = await firestore
        .doc(`memberships/${context.auth?.uid}/community-membership/${(event as any).communityId}`)
        .get();
      const membership = firestoreUtils.fromFirestoreJson(communityMembershipSnap.data() ?? {}) as unknown as Membership;

      if ((event as any).creatorId !== context.auth?.uid && !membershipIsFacilitator((membership as any).status)) {
        throw new functions.https.HttpsError('failed-precondition', 'unauthorized');
      }

      orElseUnauthorized(
        request.userToKickId !== (event as any).creatorId,
        { logMessage: 'Event creator cannot be kicked from event.' }
      );

      const liveMeeting: LiveMeeting = await firestoreUtils.getFirestoreObject({
        transaction,
        path: `${eventPath}/live-meetings/${(event as any).id}`,
        constructor: (map) => map as unknown as LiveMeeting,
      });

      const roomId = request.breakoutRoomId ?? (liveMeeting as any).meetingId ?? '';
      await this.agoraUtils.kickParticipant({ roomId, userId: request.userToKickId });
    });

    return '';
  }
}
