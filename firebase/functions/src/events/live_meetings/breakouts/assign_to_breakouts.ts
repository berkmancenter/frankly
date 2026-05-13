import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as crypto from 'crypto';
import { firestore, firestoreUtils } from '../../../utils/infra/firestore_utils';
import { AgoraUtils } from '../agora_api';
import {
  Event, EventType, BreakoutRoom, BreakoutRoomSession, BreakoutRoomStatus,
  BreakoutAssignmentMethod, LiveMeeting, LiveMeetingEvent, LiveMeetingEventType,
  MembershipStatus, Participant, ParticipantStatus, breakoutsWaitingRoomId,
} from '../../../types';

export class AssignToBreakouts {
  private _startTime?: number;

  profile(log: string): void {
    this._startTime = this._startTime ?? Date.now();
    console.log(`${Date.now() - this._startTime}ms: ${log}`);
  }

  private async _assignBreakoutsBasedOnTargetSize({
    targetParticipantsPerRoom,
    presentParticipants,
    creatorId,
    breakoutRoomsCollectionPath,
    alwaysRecord,
  }: {
    targetParticipantsPerRoom: number;
    presentParticipants: Participant[];
    creatorId: string;
    breakoutRoomsCollectionPath: string;
    alwaysRecord: boolean;
  }): Promise<BreakoutRoom[]> {
    const presentParticipantIds = presentParticipants.map((p) => (p as any).id as string);

    const participantMembershipLookup: Record<string, MembershipStatus> = {};
    for (const p of presentParticipants) {
      if ((p as any).membershipStatus != null) {
        participantMembershipLookup[(p as any).id] = (p as any).membershipStatus;
      }
    }

    const statusOrder = Object.values(MembershipStatus);
    const memberBuckets: Record<string, string[]> = {};
    for (const status of statusOrder) memberBuckets[status] = [];
    for (const id of presentParticipantIds) {
      const status = participantMembershipLookup[id] ?? MembershipStatus.nonmember;
      (memberBuckets[status] ?? (memberBuckets[status] = [])).push(id);
    }
    const groupedIds = statusOrder.flatMap((s) => memberBuckets[s] ?? []);

    const numRooms = targetParticipantsPerRoom === 0
      ? 1
      : Math.max(1, Math.round(presentParticipantIds.length / targetParticipantsPerRoom));

    const roomParticipants: string[][] = Array.from({ length: numRooms }, () => []);
    for (let i = 0; i < groupedIds.length; i++) {
      roomParticipants[i % numRooms].push(groupedIds[i]);
    }

    return roomParticipants.map((participants, i) => ({
      roomId: firestore.collection(breakoutRoomsCollectionPath).doc().id,
      creatorId,
      roomName: `${i + 1}`,
      orderingPriority: i,
      participantIds: participants,
      originalParticipantIdsAssignment: participants,
      record: alwaysRecord,
    } as unknown as BreakoutRoom));
  }

  static calculateAdjustedTargetParticipants(numParticipants: number, targetParticipantsPerRoom: number): number {
    if (targetParticipantsPerRoom < 4) return targetParticipantsPerRoom;
    const numRoomsDouble = numParticipants / targetParticipantsPerRoom;
    const higherTarget = numParticipants / Math.floor(numRoomsDouble);
    const lowerTarget = numParticipants / Math.ceil(numRoomsDouble);
    const higherDiff = Math.abs(higherTarget - targetParticipantsPerRoom);
    const lowerDiff = Math.abs(lowerTarget - targetParticipantsPerRoom);
    const adjusted = higherDiff < lowerDiff ? Math.floor(higherTarget) : Math.floor(lowerTarget);
    if (adjusted !== targetParticipantsPerRoom) {
      console.log(`Adjusting target participants to ${adjusted} to create better room distribution`);
    }
    return adjusted;
  }

  private _partitionArray<T>(arr: T[], size: number): T[][] {
    const result: T[][] = [];
    for (let i = 0; i < arr.length; i += size) result.push(arr.slice(i, i + size));
    return result;
  }

  private async _assignBreakoutsForSmartMatch({
    targetParticipantsPerRoom,
    presentParticipants,
    creatorId,
    breakoutRoomsCollectionPath,
  }: {
    targetParticipantsPerRoom: number;
    presentParticipants: Participant[];
    creatorId: string;
    breakoutRoomsCollectionPath: string;
  }): Promise<BreakoutRoom[]> {
    // Fallback: simple target-per-room assignment (frankly_matching Dart library has no TS equivalent)
    return this._assignBreakoutsBasedOnTargetSize({
      targetParticipantsPerRoom,
      presentParticipants,
      creatorId,
      breakoutRoomsCollectionPath,
      alwaysRecord: false,
    });
  }

  async writeDocumentsToCollection({
    breakoutRoomsCollectionPath,
    rooms,
    firstAgendaItemId,
  }: {
    breakoutRoomsCollectionPath: string;
    rooms: BreakoutRoom[];
    firstAgendaItemId?: string;
  }): Promise<void> {
    const chunks = this._partitionArray(rooms, 249);
    await Promise.all(
      chunks.map(async (sublist) => {
        const batch = firestore.batch();
        for (const room of sublist) {
          const roomRef = firestore.collection(breakoutRoomsCollectionPath).doc((room as any).roomId);
          batch.set(roomRef, firestoreUtils.toFirestoreJson(room as unknown as Record<string, unknown>));
          if (firstAgendaItemId != null) {
            const liveMeetingDoc = roomRef.collection('live-meetings').doc((room as any).roomId);
            const liveMeetingData: Partial<LiveMeeting> = {
              events: [
                {
                  event: LiveMeetingEventType.agendaItemStarted,
                  agendaItem: firstAgendaItemId,
                  hostless: true,
                  timestamp: new Date(),
                } as LiveMeetingEvent,
              ],
            };
            batch.set(liveMeetingDoc, firestoreUtils.toFirestoreJson(liveMeetingData as unknown as Record<string, unknown>));
          }
        }
        await batch.commit();
      })
    );
  }

  async getParticipantSnapshots({ participantsPath }: { participantsPath: string }): Promise<admin.firestore.QueryDocumentSnapshot[]> {
    const characterFilters = '247ADHLPTXaekmptw'.split('');
    const queries: Promise<admin.firestore.QuerySnapshot>[] = [];

    for (let i = 0; i <= characterFilters.length; i++) {
      const previous = i - 1 >= 0 ? characterFilters[i - 1] : null;
      const next = i < characterFilters.length ? characterFilters[i] : null;

      let query: admin.firestore.Query = firestore.collection(participantsPath);
      if (previous != null) query = query.where('id', '>=', previous);
      if (next != null) query = query.where('id', '<', next);

      queries.push(
        query.select(
          'id', 'status', 'isPresent', 'availableForBreakoutSessionId',
          'breakoutRoomSurveyQuestions', 'joinParameters.participant_id',
          'joinParameters.match_id', 'joinParameters.eventId', 'joinParameters.am'
        ).get()
      );
    }

    const allSnapshots = await Promise.all(queries);
    const allDocs = allSnapshots.flatMap((q) => q.docs);

    const seenIds = new Set<string>();
    return allDocs.filter((d) => {
      if (seenIds.has(d.id)) return false;
      seenIds.add(d.id);
      return true;
    });
  }

  private async _markProcessingAssignmentsIfAvailable({
    liveMeetingPath,
    breakoutSessionId,
    assignmentMethod,
    targetParticipantsPerRoom,
    includeWaitingRoom,
    processingId,
  }: {
    liveMeetingPath: string;
    breakoutSessionId: string;
    assignmentMethod: BreakoutAssignmentMethod;
    targetParticipantsPerRoom: number;
    includeWaitingRoom: boolean;
    processingId: string;
  }): Promise<boolean> {
    const processingTimeoutMs = 45_000;
    return firestore.runTransaction(async (transaction) => {
      const ref = firestore.doc(liveMeetingPath);
      const doc = await transaction.get(ref);
      const liveMeeting = firestoreUtils.fromFirestoreJson(doc.data() ?? {}) as unknown as LiveMeeting;
      const currentBreakoutSession = (liveMeeting as any).currentBreakoutSession as BreakoutRoomSession | undefined;

      const isNewSession = (currentBreakoutSession as any)?.breakoutRoomSessionId !== breakoutSessionId;
      const isPendingOrInactive = [BreakoutRoomStatus.pending, BreakoutRoomStatus.inactive].includes(
        (currentBreakoutSession as any)?.breakoutRoomStatus
      );
      const statusUpdateTime = (currentBreakoutSession as any)?.statusUpdatedTime ?? new Date();
      const isProcessingCanceled =
        (currentBreakoutSession as any)?.breakoutRoomStatus === BreakoutRoomStatus.processingAssignments &&
        ((currentBreakoutSession as any)?.processingId == null ||
          Date.now() - new Date(statusUpdateTime).getTime() > processingTimeoutMs);

      if (isNewSession || isPendingOrInactive || isProcessingCanceled) {
        transaction.update(ref, {
          'currentBreakoutSession': firestoreUtils.toFirestoreJson({
            processingId,
            breakoutRoomStatus: BreakoutRoomStatus.processingAssignments,
            assignmentMethod,
            hasWaitingRoom: includeWaitingRoom,
            breakoutRoomSessionId: breakoutSessionId,
            targetParticipantsPerRoom,
          } as unknown as Record<string, unknown>),
        });
        return true;
      }
      return false;
    });
  }

  private async _processAssignments({
    liveMeetingPath,
    event,
    breakoutSessionId,
    creatorId,
    assignmentMethod,
    targetParticipantsPerRoom,
    includeWaitingRoom,
    processingId,
  }: {
    liveMeetingPath: string;
    event: Event;
    breakoutSessionId: string;
    creatorId: string;
    assignmentMethod: BreakoutAssignmentMethod;
    targetParticipantsPerRoom: number;
    includeWaitingRoom: boolean;
    processingId: string;
  }): Promise<void> {
    this.profile('getting participants');
    const participantSnapshots = await this.getParticipantSnapshots({
      participantsPath: `${(event as any).fullPath ?? (event as any).communityId ? `community/${(event as any).communityId}/templates/${(event as any).templateId}/events/${(event as any).id}` : ''}/event-participants`,
    });

    this.profile('constructing participant objects');
    const allParticipants = participantSnapshots.map((doc) =>
      firestoreUtils.fromFirestoreJson(doc.data()) as unknown as Participant
    );

    const assignAllPresent = (event as any).eventType === EventType.hosted;
    const presentParticipants = allParticipants.filter((participant) => {
      const userIsAvailable =
        (!assignAllPresent && (participant as any).availableForBreakoutSessionId === breakoutSessionId) ||
        (assignAllPresent && (participant as any).isPresent);
      return (participant as any).status === ParticipantStatus.active && userIsAvailable;
    });

    this.profile(`present available for breakouts ${presentParticipants.length}`);

    const breakoutRoomsSessionPath = `${liveMeetingPath}/breakout-room-sessions/${breakoutSessionId}`;
    const breakoutRoomsCollectionPath = `${breakoutRoomsSessionPath}/breakout-rooms`;

    const alwaysRecord = (event as any).eventSettings?.alwaysRecord ?? false;

    let breakoutRooms: BreakoutRoom[];
    if (assignmentMethod === BreakoutAssignmentMethod.targetPerRoom) {
      breakoutRooms = await this._assignBreakoutsBasedOnTargetSize({
        targetParticipantsPerRoom,
        presentParticipants,
        creatorId,
        breakoutRoomsCollectionPath,
        alwaysRecord,
      });
    } else if (assignmentMethod === BreakoutAssignmentMethod.smartMatch) {
      breakoutRooms = await this._assignBreakoutsForSmartMatch({
        targetParticipantsPerRoom,
        presentParticipants,
        creatorId,
        breakoutRoomsCollectionPath,
      });
    } else {
      throw new Error(`Unknown assignment method: ${assignmentMethod}`);
    }

    let maxBreakoutRoomNumber = breakoutRooms.length;

    if (includeWaitingRoom) {
      breakoutRooms.unshift({
        roomId: breakoutsWaitingRoomId,
        roomName: 'Waiting Room',
        orderingPriority: -1,
        creatorId,
        participantIds: [],
        record: alwaysRecord,
      } as unknown as BreakoutRoom);
    }

    if (breakoutRooms.length === 0) {
      maxBreakoutRoomNumber = 1;
      breakoutRooms.push({
        roomId: firestore.collection(breakoutRoomsCollectionPath).doc().id,
        roomName: '1',
        orderingPriority: 0,
        creatorId,
        participantIds: [],
        record: alwaysRecord,
      } as unknown as BreakoutRoom);
    }

    this.profile('Verifying processing ID still matches');
    const currentLiveMeeting = await firestoreUtils.getFirestoreObject({
      path: liveMeetingPath,
      constructor: (map) => map as unknown as LiveMeeting,
    });
    const currentBreakoutSession = (currentLiveMeeting as any).currentBreakoutSession;
    if (
      currentBreakoutSession?.breakoutRoomStatus !== BreakoutRoomStatus.processingAssignments ||
      currentBreakoutSession?.processingId !== processingId
    ) {
      this.profile('No longer processing or processingId doesnt match. Returning.');
      return;
    }

    this.profile(`writing rooms ${breakoutRooms.length}`);

    let firstAgendaItemId: string | undefined;
    if ((event as any).eventType === EventType.hosted) {
      const parentAgendaItemId = (currentLiveMeeting as any).events
        ?.filter((e: any) => e.event === LiveMeetingEventType.agendaItemStarted)
        .slice(-1)[0]?.agendaItem;
      firstAgendaItemId = parentAgendaItemId ?? (event as any).agendaItems?.[0]?.id;
    } else {
      firstAgendaItemId = (event as any).agendaItems?.[0]?.id;
    }

    await this.writeDocumentsToCollection({
      breakoutRoomsCollectionPath,
      rooms: breakoutRooms,
      firstAgendaItemId,
    });

    // Start recordings
    if (alwaysRecord || (currentLiveMeeting as any).record) {
      const agoraUtils = new AgoraUtils();
      for (const room of breakoutRooms) {
        if ((room as any).roomId === breakoutsWaitingRoomId) continue;
        const newSessionId = firestore.collection('recording-sessions').doc().id;
        const roomPath = `${breakoutRoomsCollectionPath}/${(room as any).roomId}`;
        await firestore.doc(roomPath).update({ recordingSessionId: newSessionId });
        try {
          await agoraUtils.recordRoom({
            roomId: (room as any).roomId,
            sessionId: newSessionId,
            eventId: (event as any).id,
            communityId: (event as any).communityId,
            roomType: 'breakout',
            breakoutSessionId: breakoutSessionId,
            chatPath: `${roomPath}/chats/community_chat/messages`,
            participantIds: (room as any).participantIds ?? [],
          });
        } catch (e) {
          console.log(`Error starting recording for breakout room ${(room as any).roomId}: ${e}`);
        }
      }
    }

    this.profile('writing session doc');
    const breakoutRoomSession: Partial<BreakoutRoomSession> = {
      breakoutRoomSessionId: breakoutSessionId,
      breakoutRoomStatus: BreakoutRoomStatus.active,
      hasWaitingRoom: includeWaitingRoom,
      targetParticipantsPerRoom,
      maxRoomNumber: maxBreakoutRoomNumber,
      assignmentMethod,
    };

    await firestore.doc(breakoutRoomsSessionPath).set(
      firestoreUtils.toFirestoreJson(breakoutRoomSession as unknown as Record<string, unknown>)
    );

    await firestore.doc(liveMeetingPath).set(
      { currentBreakoutSession: firestoreUtils.toFirestoreJson(breakoutRoomSession as unknown as Record<string, unknown>) },
      { merge: true }
    );
    this.profile('done writing');
  }

  async assignToBreakouts({
    event,
    breakoutSessionId,
    creatorId,
    assignmentMethod,
    targetParticipantsPerRoom,
    includeWaitingRoom = false,
  }: {
    event: Event;
    breakoutSessionId: string;
    creatorId: string;
    assignmentMethod: BreakoutAssignmentMethod;
    targetParticipantsPerRoom: number;
    includeWaitingRoom?: boolean;
  }): Promise<void> {
    const liveMeetingPath = `${(event as any).fullPath}/live-meetings/${(event as any).id}`;
    const processingId = crypto.randomUUID();

    this.profile(`updating breakout room to assigning with processingID: ${processingId}`);
    const markedProcessing = await this._markProcessingAssignmentsIfAvailable({
      liveMeetingPath,
      targetParticipantsPerRoom,
      breakoutSessionId,
      assignmentMethod,
      includeWaitingRoom,
      processingId,
    });

    if (!markedProcessing) {
      this.profile('Breakout session already processing. Returning.');
      return;
    }

    try {
      await this._processAssignments({
        liveMeetingPath,
        event,
        targetParticipantsPerRoom,
        breakoutSessionId,
        assignmentMethod,
        includeWaitingRoom,
        creatorId,
        processingId,
      });
    } catch (e) {
      await firestore.runTransaction(async (transaction) => {
        const ref = firestore.doc(liveMeetingPath);
        const doc = await transaction.get(ref);
        const liveMeeting = firestoreUtils.fromFirestoreJson(doc.data() ?? {}) as unknown as LiveMeeting;
        const currentBreakoutSession = (liveMeeting as any).currentBreakoutSession;
        if (
          currentBreakoutSession?.breakoutRoomStatus === BreakoutRoomStatus.processingAssignments &&
          currentBreakoutSession?.processingId === processingId
        ) {
          console.log('Updating live meeting doc processingID to null');
          transaction.update(ref, {
            'currentBreakoutSession.processingId': admin.firestore.FieldValue.delete(),
          });
        }
      });
      throw e;
    }
  }
}
