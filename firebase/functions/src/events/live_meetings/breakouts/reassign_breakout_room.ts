import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { OnCallMethod } from '../../../on_call_function';
import { firestore, firestoreUtils } from '../../../utils/infra/firestore_utils';
import {
  Event, EventType, Membership, BreakoutRoom, BreakoutRoomSession, LiveMeeting,
  LiveMeetingEvent, LiveMeetingEventType, membershipIsMod, breakoutsWaitingRoomId, reassignNewRoomId,
} from '../../../types';

interface ReassignBreakoutRoomRequest {
  eventPath: string;
  userId: string;
  newRoomNumber: string;
  breakoutRoomSessionId: string;
}

export class ReassignBreakoutRoom extends OnCallMethod<ReassignBreakoutRoomRequest> {
  constructor() {
    super('ReassignBreakoutRoom', (json) => json as ReassignBreakoutRoomRequest);
  }

  private async _verifyCallerIsAuthorized(event: Event, context: functions.https.CallableContext): Promise<void> {
    const membershipSnap = await firestore
      .doc(`memberships/${context.auth?.uid}/community-membership/${(event as any).communityId}`)
      .get();
    const membership = firestoreUtils.fromFirestoreJson(membershipSnap.data() ?? {}) as unknown as Membership;
    const isAuthorized = (event as any).creatorId === context.auth?.uid || membershipIsMod((membership as any).status);
    if (!isAuthorized) throw new functions.https.HttpsError('failed-precondition', 'unauthorized');
  }

  async action(request: ReassignBreakoutRoomRequest, context: functions.https.CallableContext): Promise<Record<string, unknown> | null> {
    const event: Event = await firestoreUtils.getFirestoreObject({
      path: request.eventPath,
      constructor: (map) => map as unknown as Event,
    });

    await this._verifyCallerIsAuthorized(event, context);

    const liveMeetingPath = `${request.eventPath}/live-meetings/${(event as any).id}`;
    const collectionPath = `${liveMeetingPath}/breakout-room-sessions/${request.breakoutRoomSessionId}/breakout-rooms`;
    const breakoutSessionRef = firestore.doc(`${liveMeetingPath}/breakout-room-sessions/${request.breakoutRoomSessionId}`);
    const breakoutsCollection = breakoutSessionRef.collection('breakout-rooms');

    const assignedBreakoutRoomQuery = await breakoutsCollection
      .where('participantIds', 'array-contains', request.userId)
      .limit(5)
      .get();
    const assignedBreakoutRoomRefs = assignedBreakoutRoomQuery.docs.map((d) => d.ref);

    let newRoomId: string | null = null;
    if ([breakoutsWaitingRoomId, reassignNewRoomId].includes(request.newRoomNumber)) {
      newRoomId = request.newRoomNumber;
    } else {
      const newRoomQuery = await breakoutsCollection
        .where('roomName', '==', request.newRoomNumber)
        .limit(1)
        .get();
      if (newRoomQuery.empty) {
        throw new functions.https.HttpsError('not-found', `Breakout Room ${request.newRoomNumber} not found.`);
      }
      newRoomId = newRoomQuery.docs[0].id;
    }

    return firestore.runTransaction(async (transaction) => {
      const assignedBreakoutRoomDocs = (
        await Promise.all(assignedBreakoutRoomRefs.map((ref) => transaction.get(ref)))
      ).filter((d) => d.exists);

      const breakoutSessionDetailsDoc = await transaction.get(breakoutSessionRef);
      const breakoutSessionDetails = firestoreUtils.fromFirestoreJson(breakoutSessionDetailsDoc.data() ?? {}) as unknown as BreakoutRoomSession;

      let reassignedBreakoutRoom: BreakoutRoom | null = null;

      if (newRoomId && newRoomId !== reassignNewRoomId) {
        const newRoomDoc = await transaction.get(firestore.doc(`${collectionPath}/${newRoomId}`));
        const breakoutRoom = firestoreUtils.fromFirestoreJson(newRoomDoc.data() ?? {}) as unknown as BreakoutRoom;
        const participantIds = [...((breakoutRoom as any).participantIds ?? []), request.userId];
        reassignedBreakoutRoom = { ...(breakoutRoom as any), participantIds } as unknown as BreakoutRoom;
        console.log(`adding participantId: ${newRoomDoc.ref.path}`);
        transaction.update(newRoomDoc.ref, { participantIds });
      }

      const filteredDocs = assignedBreakoutRoomDocs.filter((doc) => doc.id !== newRoomId);
      for (const breakoutRoomDoc of filteredDocs) {
        const breakoutRoom = firestoreUtils.fromFirestoreJson(breakoutRoomDoc.data() ?? {}) as unknown as BreakoutRoom;
        const participantIds = ((breakoutRoom as any).participantIds ?? []).filter((id: string) => id !== request.userId);
        console.log(`removing participantId: ${breakoutRoomDoc.ref.path}`);
        transaction.update(breakoutRoomDoc.ref, { participantIds });
      }

      const maxRoomNumber = (breakoutSessionDetails as any).maxRoomNumber ?? 0;

      if (request.newRoomNumber === reassignNewRoomId) {
        const newDoc = breakoutsCollection.doc();
        const roomId = newDoc.id;

        let firstAgendaItemId: string | undefined;
        if ((event as any).eventType === EventType.hosted) {
          const liveMeeting = await firestoreUtils.getFirestoreObject({
            path: liveMeetingPath,
            constructor: (map) => map as unknown as LiveMeeting,
          });
          const parentAgendaItemId = ((liveMeeting as any).events ?? [])
            .filter((e: any) => e.event === LiveMeetingEventType.agendaItemStarted)
            .slice(-1)[0]?.agendaItem;
          firstAgendaItemId = parentAgendaItemId ?? (event as any).agendaItems?.[0]?.id;
        } else {
          firstAgendaItemId = (event as any).agendaItems?.[0]?.id;
        }

        reassignedBreakoutRoom = {
          creatorId: context.auth!.uid,
          roomId,
          roomName: `${maxRoomNumber + 1}`,
          orderingPriority: maxRoomNumber,
          participantIds: [request.userId],
        } as unknown as BreakoutRoom;

        transaction.set(newDoc, firestoreUtils.toFirestoreJson(reassignedBreakoutRoom as unknown as Record<string, unknown>));

        const liveMeetingDocRef = newDoc.collection('live-meetings').doc(roomId);
        transaction.set(
          liveMeetingDocRef,
          firestoreUtils.toFirestoreJson({
            events: [
              {
                event: LiveMeetingEventType.agendaItemStarted,
                agendaItem: firstAgendaItemId,
                hostless: true,
                timestamp: new Date(),
              } as LiveMeetingEvent,
            ],
          } as Record<string, unknown>),
          { merge: true }
        );

        transaction.update(breakoutSessionRef, { maxRoomNumber: maxRoomNumber + 1 });
      }

      if (!reassignedBreakoutRoom) return null;
      return {
        ...(reassignedBreakoutRoom as unknown as Record<string, unknown>),
        createdDate: new Date().toISOString(),
      };
    });
  }
}
