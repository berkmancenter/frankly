import * as functions from 'firebase-functions';
import { OnCallMethod } from '../../../on_call_function';
import { firestore, firestoreUtils } from '../../../utils/infra/firestore_utils';
import { Event, Membership, LiveMeeting, BreakoutRoom, BreakoutRoomSession, BreakoutRoomStatus, membershipIsMod, ParticipantStatus, Participant } from '../../../types';
import { LiveMeetingUtils } from '../live_meeting_utils';

interface GetBreakoutRoomJoinInfoRequest {
  eventPath: string;
  eventId: string;
  breakoutRoomId: string;
}

export class GetBreakoutRoomJoinInfo extends OnCallMethod<GetBreakoutRoomJoinInfoRequest> {
  private liveMeetingUtils: LiveMeetingUtils;

  constructor(liveMeetingUtils?: LiveMeetingUtils) {
    super('GetBreakoutRoomJoinInfo', (jsonMap) => jsonMap as GetBreakoutRoomJoinInfoRequest);
    this.liveMeetingUtils = liveMeetingUtils ?? new LiveMeetingUtils();
  }

  async action(request: GetBreakoutRoomJoinInfoRequest, context: functions.https.CallableContext): Promise<Record<string, unknown>> {
    const event: Event = await firestoreUtils.getFirestoreObject({
      path: request.eventPath,
      constructor: (map) => map as unknown as Event,
    });

    const participant: Participant = await firestoreUtils.getFirestoreObject({
      path: `${request.eventPath}/event-participants/${context.auth?.uid}`,
      constructor: (map) => map as unknown as Participant,
    });
    if ((participant as any).status !== ParticipantStatus.active) {
      throw new functions.https.HttpsError('failed-precondition', 'unauthorized');
    }

    const liveMeetingPath = `${request.eventPath}/live-meetings/${request.eventId}`;
    const liveMeeting: LiveMeeting = await firestoreUtils.getFirestoreObject({
      path: liveMeetingPath,
      constructor: (map) => map as unknown as LiveMeeting,
    });

    const membershipSnap = await firestore
      .doc(`memberships/${context.auth?.uid}/community-membership/${(event as any).communityId}`)
      .get();
    const membership = firestoreUtils.fromFirestoreJson(membershipSnap.data() ?? {}) as unknown as Membership;
    const isModOrCreator = (event as any).creatorId === context.auth?.uid || membershipIsMod((membership as any).status);

    const currentBreakoutSession = (liveMeeting as any).currentBreakoutSession as BreakoutRoomSession | undefined;
    const breakoutRoomDoc = await firestore
      .doc(
        `${liveMeetingPath}/breakout-room-sessions/${currentBreakoutSession?.breakoutRoomSessionId}/breakout-rooms/${request.breakoutRoomId}`
      )
      .get();

    const breakoutRoom = firestoreUtils.fromFirestoreJson(breakoutRoomDoc.data() ?? {}) as unknown as BreakoutRoom;
    const isParticipantInBreakoutRoom = (breakoutRoom as any).participantIds?.includes(context.auth?.uid);

    if (!isParticipantInBreakoutRoom && !isModOrCreator) {
      throw new functions.https.HttpsError('failed-precondition', 'unauthorized');
    }

    if (!currentBreakoutSession) {
      throw new functions.https.HttpsError('failed-precondition', 'no active breakout session');
    }

    const breakoutRoomPath = `${liveMeetingPath}/breakout-room-sessions/${currentBreakoutSession.breakoutRoomSessionId}/breakout-rooms/${request.breakoutRoomId}`;

    const joinInfo = await this.liveMeetingUtils.getBreakoutRoomJoinInfo({
      communityId: (event as any).communityId,
      eventId: request.eventId,
      breakoutSessionId: currentBreakoutSession.breakoutRoomSessionId ?? '',
      breakoutRoomPath,
      meetingId: (breakoutRoom as any).roomId,
      userId: context.auth!.uid,
      record: (breakoutRoom as any).record,
      existingRecordingSessionId: (breakoutRoom as any).recordingSessionId,
      participantIds: (breakoutRoom as any).participantIds ?? [],
    });

    return joinInfo as unknown as Record<string, unknown>;
  }
}
