import * as functions from 'firebase-functions';
import { OnCallMethod } from '../../../on_call_function';
import { firestore, firestoreUtils } from '../../../utils/infra/firestore_utils';
import { Event, EventType, EventStatus, BreakoutRoomStatus, BreakoutAssignmentMethod, LiveMeeting, timeUntilWaitingRoomFinished, getEventFullPath } from '../../../types';
import { InitiateBreakouts } from './initiate_breakouts';
import { CheckHostlessGoToBreakoutsServer } from './check_hostless_go_to_breakouts_server';

interface CheckHostlessGoToBreakoutsRequest {
  eventPath: string;
}

export class CheckHostlessGoToBreakouts extends OnCallMethod<CheckHostlessGoToBreakoutsRequest> {
  constructor() {
    super(
      'CheckHostlessGoToBreakouts',
      (jsonMap) => jsonMap as CheckHostlessGoToBreakoutsRequest,
      { runWithOptions: { timeoutSeconds: 240, memory: '4GB', minInstances: 0 } }
    );
  }

  async action(request: CheckHostlessGoToBreakoutsRequest, context: functions.https.CallableContext): Promise<void> {
    await this.checkHostlessGoToBreakouts(request, context.auth!.uid);
  }

  async checkHostlessGoToBreakouts(request: CheckHostlessGoToBreakoutsRequest, userId: string): Promise<void> {
    const event: Event = await firestoreUtils.getFirestoreObject({
      path: request.eventPath,
      constructor: (map) => map as unknown as Event,
    });
    console.log('Retrieved event:', (event as any).id);

    if ((event as any).eventType !== EventType.hostless) {
      console.log('Event is not hostless, returning.');
      return;
    }

    if ((event as any).status === EventStatus.canceled) {
      console.log('Event is cancelled, returning.');
      return;
    }

    const nowWithBuffer = new Date(Date.now() + 100);
    const timeUntilWaitingRoom = timeUntilWaitingRoomFinished(event, nowWithBuffer);

    console.log(`Waiting room finished in ${timeUntilWaitingRoom}ms`);
    if (timeUntilWaitingRoom >= 0) {
      console.log('It is still before scheduled start time so returning.');
      return;
    }

    const liveMeetingPath = `${getEventFullPath(event)}/live-meetings/${(event as any).id}`;
    const liveMeeting: LiveMeeting = await firestoreUtils.getFirestoreObject({
      path: liveMeetingPath,
      constructor: (map) => map as unknown as LiveMeeting,
    });

    if ((liveMeeting as any).currentBreakoutSession?.breakoutRoomStatus === BreakoutRoomStatus.active) {
      console.log('Breakouts have already been assigned so returning.');
      return;
    }

    const defaultTargetParticipants = 8;
    console.log('initializing breakouts');
    await new InitiateBreakouts().initiateBreakouts({
      event,
      request: {
        eventPath: getEventFullPath(event),
        breakoutSessionId: (event as any).id,
        assignmentMethod: (event as any).breakoutRoomDefinition?.assignmentMethod ?? BreakoutAssignmentMethod.targetPerRoom,
        targetParticipantsPerRoom: (event as any).breakoutRoomDefinition?.targetParticipants ?? defaultTargetParticipants,
        includeWaitingRoom: true,
      },
      creatorId: userId,
    });
    console.log('Finished initiating breakouts');
  }

  async enqueueScheduledCheck(event: Event): Promise<void> {
    const timeToGoToBreakoutsMs = timeUntilWaitingRoomFinished(event, new Date());
    const timeToGoToBreakouts = new Date(Date.now() + timeToGoToBreakoutsMs);

    await new CheckHostlessGoToBreakoutsServer().schedule(
      { eventPath: getEventFullPath(event) },
      timeToGoToBreakouts
    );
  }
}
