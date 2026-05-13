import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { OnCallMethod } from '../../../on_call_function';
import { firestore, firestoreUtils } from '../../../utils/infra/firestore_utils';
import { Participant, ParticipantStatus, LiveMeeting, BreakoutRoom, BreakoutRoomSession, BreakoutRoomStatus, breakoutsWaitingRoomId } from '../../../types';

interface GetBreakoutRoomAssignmentRequest {
  eventPath: string;
  eventId: string;
}

interface GetBreakoutRoomAssignmentResponse {
  breakoutRoomId?: string;
}

export class GetBreakoutRoomAssignment extends OnCallMethod<GetBreakoutRoomAssignmentRequest> {
  constructor() {
    super('GetBreakoutRoomAssignment', (jsonMap) => jsonMap as GetBreakoutRoomAssignmentRequest);
  }

  async action(
    request: GetBreakoutRoomAssignmentRequest,
    context: functions.https.CallableContext
  ): Promise<GetBreakoutRoomAssignmentResponse> {
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

    const breakoutSession = (liveMeeting as any).currentBreakoutSession as BreakoutRoomSession | undefined;

    if (!breakoutSession || breakoutSession.breakoutRoomStatus !== BreakoutRoomStatus.active) {
      throw new Error('Breakout rooms not active');
    }

    const breakoutRoomsPath = `${liveMeetingPath}/breakout-room-sessions/${breakoutSession.breakoutRoomSessionId}/breakout-rooms`;
    const breakoutRoomsCollection = firestore.collection(breakoutRoomsPath);

    const currentBreakoutRoomQuery = await breakoutRoomsCollection
      .where('participantIds', 'array-contains', context.auth?.uid)
      .get();

    if (!currentBreakoutRoomQuery.empty) {
      const room = firestoreUtils.fromFirestoreJson(currentBreakoutRoomQuery.docs[0].data()) as unknown as BreakoutRoom;
      return { breakoutRoomId: (room as any).roomId };
    }

    const allBreakoutRoomDocs = await breakoutRoomsCollection.get();
    const allBreakoutRooms = allBreakoutRoomDocs.docs.map((doc) =>
      firestoreUtils.fromFirestoreJson(doc.data()) as unknown as BreakoutRoom
    );

    const assignment = await firestore.runTransaction(async (transaction) => {
      let assignedRoomIndex = allBreakoutRooms.findIndex((br) => (br as any).roomId === breakoutsWaitingRoomId);
      if (assignedRoomIndex < 0 && allBreakoutRooms.length > 0) {
        const minCount = Math.min(...allBreakoutRooms.map((b) => ((b as any).participantIds ?? []).length));
        assignedRoomIndex = allBreakoutRooms.findIndex((b) => ((b as any).participantIds ?? []).length === minCount);
      }

      if (assignedRoomIndex < 0) {
        console.log('error, no breakout rooms found.');
        return null;
      }

      const roomDoc = breakoutRoomsCollection.doc((allBreakoutRooms[assignedRoomIndex] as any).roomId);
      const assignedRoomSnap = await transaction.get(roomDoc);
      const assignedRoom = firestoreUtils.fromFirestoreJson(assignedRoomSnap.data() ?? {}) as unknown as BreakoutRoom;
      const participantIds = [...((assignedRoom as any).participantIds ?? []), context.auth!.uid];

      transaction.update(roomDoc, { participantIds });
      return (assignedRoom as any).roomId as string;
    });

    return { breakoutRoomId: assignment ?? undefined };
  }
}
