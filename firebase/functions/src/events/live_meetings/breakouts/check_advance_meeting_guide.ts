import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { OnCallMethod } from '../../../on_call_function';
import { firestore, firestoreUtils } from '../../../utils/infra/firestore_utils';
import { isNullOrEmpty } from '../../../utils/utils';
import {
  Event, Participant, ParticipantStatus, ParticipantAgendaItemDetails,
  LiveMeeting, LiveMeetingEvent, LiveMeetingEventType, startMeetingAgendaItemId,
} from '../../../types';

interface CheckAdvanceMeetingGuideRequest {
  eventPath: string;
  breakoutRoomId?: string;
  breakoutSessionId?: string;
  userReadyAgendaId?: string;
  presentIds: string[];
}

export class CheckAdvanceMeetingGuide extends OnCallMethod<CheckAdvanceMeetingGuideRequest> {
  constructor() {
    super(
      'CheckAdvanceMeetingGuide',
      (jsonMap) => jsonMap as CheckAdvanceMeetingGuideRequest
    );
  }

  private async _markReady({
    userId,
    liveMeetingPath,
    agendaItemId,
    meetingId,
  }: {
    userId: string;
    liveMeetingPath: string;
    agendaItemId?: string;
    meetingId: string;
  }): Promise<void> {
    const documentId = `${liveMeetingPath}/participant-agenda-item-details/${agendaItemId}/participant-details/${userId}`;
    const docData = firestoreUtils.toFirestoreJson({
      userId,
      agendaItemId,
      meetingId,
      readyToAdvance: true,
    } as Record<string, unknown>);
    await firestore.doc(documentId).set(docData, { merge: true });
  }

  async action(request: CheckAdvanceMeetingGuideRequest, context: functions.https.CallableContext): Promise<void> {
    const event: Event = await firestoreUtils.getFirestoreObject({
      path: request.eventPath,
      constructor: (map) => map as unknown as Event,
    });

    const isBreakout = !isNullOrEmpty(request.breakoutRoomId ?? '');
    const liveMeetingPath = `${request.eventPath}/live-meetings/${(event as any).id}`;
    const breakoutLiveMeetingPath =
      `${liveMeetingPath}/breakout-room-sessions/${request.breakoutSessionId}/breakout-rooms/${request.breakoutRoomId}/live-meetings/${request.breakoutRoomId}`;

    const activeLiveMeetingPath = isBreakout ? breakoutLiveMeetingPath : liveMeetingPath;

    await this._checkAdvanceMeetingGuide({
      liveMeetingPath: activeLiveMeetingPath,
      parentLiveMeetingPath: isBreakout ? liveMeetingPath : null,
      isBreakout,
      request,
      userId: context.auth!.uid,
    });

    if (isNullOrEmpty(request.userReadyAgendaId ?? '')) {
      console.log('No agenda ID passed in so not marking user ready.');
      return;
    }

    await this._markReady({
      userId: context.auth!.uid,
      agendaItemId: request.userReadyAgendaId,
      liveMeetingPath: activeLiveMeetingPath,
      meetingId: activeLiveMeetingPath.split('/').pop()!,
    });
  }

  private _getCurrentAgendaItemId(event: Event, liveMeeting: LiveMeeting): string {
    const events = ((liveMeeting as any).events ?? []).filter(
      (e: any) => e.event === LiveMeetingEventType.agendaItemStarted
    );
    return events.length > 0 ? events[events.length - 1].agendaItem : startMeetingAgendaItemId;
  }

  private async _checkAdvanceMeetingGuide({
    isBreakout,
    userId,
    liveMeetingPath,
    parentLiveMeetingPath,
    request,
  }: {
    isBreakout: boolean;
    userId: string;
    liveMeetingPath: string;
    parentLiveMeetingPath: string | null;
    request: CheckAdvanceMeetingGuideRequest;
  }): Promise<void> {
    const liveMeeting: LiveMeeting = await firestoreUtils.getFirestoreObject({
      path: liveMeetingPath,
      constructor: (map) => map as unknown as LiveMeeting,
    });

    if (!isBreakout) {
      console.log('Only breakouts are currently hostless');
      return;
    }
    if (((liveMeeting as any).events ?? []).some((e: any) => e.event === LiveMeetingEventType.finishMeeting)) {
      console.log('Meeting already finished. Not checking advanced');
      return;
    }

    const event: Event = await firestoreUtils.getFirestoreObject({
      path: request.eventPath,
      constructor: (map) => map as unknown as Event,
    });

    const currentAgendaItemId = this._getCurrentAgendaItemId(event, liveMeeting);
    console.log('current agenda item:', currentAgendaItemId);

    let participantsQuery = firestore.collection(`${request.eventPath}/event-participants`) as admin.firestore.Query;
    if (isBreakout) {
      participantsQuery = participantsQuery.where('currentBreakoutRoomId', '==', request.breakoutRoomId);
    }
    const participantsSnapshot = await participantsQuery.get();
    const registeredParticipants = participantsSnapshot.docs
      .map((doc) => firestoreUtils.fromFirestoreJson(doc.data()) as unknown as Participant)
      .filter((p) => (p as any).status === ParticipantStatus.active);

    const presentParticipantIds = new Set<string>(request.presentIds);

    const agendaItemParticipantDetailsPath =
      `${liveMeetingPath}/participant-agenda-item-details/${currentAgendaItemId}/participant-details`;
    const detailsDocs = await firestore.collection(agendaItemParticipantDetailsPath).get();
    const agendaItemParticipantDetails = detailsDocs.docs.map(
      (doc) => firestoreUtils.fromFirestoreJson(doc.data()) as unknown as ParticipantAgendaItemDetails
    );

    const readyToMoveOnIds = new Set<string>([
      ...agendaItemParticipantDetails
        .filter((a) => (a.readyToAdvance ?? false) && presentParticipantIds.has(a.userId ?? ''))
        .map((p) => p.userId ?? ''),
      ...(request.userReadyAgendaId === currentAgendaItemId && !isNullOrEmpty(userId) ? [userId] : []),
    ]);

    console.log('ready to move on:', readyToMoveOnIds);
    console.log('present:', presentParticipantIds);

    if (readyToMoveOnIds.size >= presentParticipantIds.size / 2) {
      await this._advanceMeetingGuide({
        liveMeetingPath,
        event,
        currentAgendaItemId,
        parentLiveMeetingPath,
      });
    }
  }

  private async _advanceMeetingGuide({
    event,
    liveMeetingPath,
    currentAgendaItemId,
    parentLiveMeetingPath,
  }: {
    event: Event;
    liveMeetingPath: string;
    currentAgendaItemId: string;
    parentLiveMeetingPath: string | null;
  }): Promise<void> {
    await firestore.runTransaction(async (transaction) => {
      const liveMeeting: LiveMeeting = await firestoreUtils.getFirestoreObject({
        path: liveMeetingPath,
        constructor: (map) => map as unknown as LiveMeeting,
      });

      const newCurrentAgendaItemId = this._getCurrentAgendaItemId(event, liveMeeting);
      if (newCurrentAgendaItemId !== currentAgendaItemId) {
        console.log(`${currentAgendaItemId} is no longer the current agenda Item: ${newCurrentAgendaItemId}`);
        return;
      }

      const agendaItems: any[] = (event as any).agendaItems ?? [];
      const agendaItemIndex = agendaItems.findIndex((a) => a.id === currentAgendaItemId);
      let nextAgendaItem = agendaItemIndex + 1 < agendaItems.length ? agendaItems[agendaItemIndex + 1] : null;

      if (currentAgendaItemId === startMeetingAgendaItemId && parentLiveMeetingPath != null) {
        const parentLiveMeeting: LiveMeeting = await firestoreUtils.getFirestoreObject({
          path: parentLiveMeetingPath,
          constructor: (map) => map as unknown as LiveMeeting,
        });
        const parentAgendaItemId = this._getCurrentAgendaItemId(event, parentLiveMeeting);
        const parentAgendaItem = agendaItems.find((item) => item.id === parentAgendaItemId);
        if (parentAgendaItemId !== startMeetingAgendaItemId && parentAgendaItem != null) {
          nextAgendaItem = parentAgendaItem;
        }
      }

      const newEvent: LiveMeetingEvent = {
        agendaItem: nextAgendaItem?.id,
        event: nextAgendaItem == null ? LiveMeetingEventType.finishMeeting : LiveMeetingEventType.agendaItemStarted,
        timestamp: new Date(),
        hostless: true,
      };
      console.log('adding new event:', newEvent);

      const allTimingEvents = ((liveMeeting as any).events ?? []).filter((e: any) =>
        [LiveMeetingEventType.agendaItemStarted, LiveMeetingEventType.finishMeeting].includes(e.event)
      );
      const lastEvent = allTimingEvents.length > 0 ? allTimingEvents[allTimingEvents.length - 1] : null;
      if (lastEvent?.agendaItem === newEvent.agendaItem && lastEvent?.event === newEvent.event) {
        console.log('New live event has already been added. Returning.');
        return;
      }

      const currentEvents = (liveMeeting as any).events ?? [];
      transaction.set(
        firestore.doc(liveMeetingPath),
        firestoreUtils.toFirestoreJson({ events: [...currentEvents, newEvent] } as Record<string, unknown>),
        { merge: true }
      );
    });
  }
}
