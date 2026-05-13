import { OnCallMethod } from '../../../on_call_function';
import { firestore, firestoreUtils } from '../../../utils/infra/firestore_utils';
import {
  Event, EventStatus, BreakoutRoomStatus,
} from '../../../types';
import { AssignToBreakouts } from './assign_to_breakouts';

interface CheckAssignToBreakoutsRequest {
  eventPath: string;
  breakoutSessionId: string;
}

const CLOCK_SKEW_BUFFER_MS = 100;

export class CheckAssignToBreakouts extends OnCallMethod<CheckAssignToBreakoutsRequest> {
  constructor() {
    super(
      'CheckAssignToBreakouts',
      (jsonMap) => jsonMap as CheckAssignToBreakoutsRequest,
      { runWithOptions: { timeoutSeconds: 240, memory: '4GB', minInstances: 0 } }
    );
  }

  async action(request: CheckAssignToBreakoutsRequest, context: import('firebase-functions').https.CallableContext): Promise<void> {
    await this.checkAssignToBreakouts(request, context.auth!.uid);
  }

  async checkAssignToBreakouts(request: CheckAssignToBreakoutsRequest, userId: string): Promise<void> {
    const event: Event = await firestoreUtils.getFirestoreObject({
      path: request.eventPath,
      constructor: (map) => map as unknown as Event,
    });

    if ((event as any).status === EventStatus.canceled) {
      console.log('Event is cancelled, returning.');
      return;
    }

    const liveMeetingPath = `${(event as any).fullPath}/live-meetings/${(event as any).id}`;
    const liveMeeting = await firestoreUtils.getFirestoreObject({
      path: liveMeetingPath,
      constructor: (map) => map as unknown as any,
    });

    const breakoutSession = liveMeeting.currentBreakoutSession;
    if (!breakoutSession) {
      console.log('Breakout session not found in live meeting.');
      return;
    }

    const scheduledStartTime = breakoutSession.scheduledTime
      ? new Date(new Date(breakoutSession.scheduledTime).getTime() - CLOCK_SKEW_BUFFER_MS)
      : null;

    if (!scheduledStartTime) {
      console.log('Scheduled start time is null.');
      return;
    }

    const now = new Date();
    if (now < scheduledStartTime) {
      console.log(`It is currently (${now}) still before scheduled start time (${scheduledStartTime}) so returning.`);
      return;
    }

    if (breakoutSession.breakoutRoomSessionId !== request.breakoutSessionId) {
      console.log(`Current breakout session (${breakoutSession.breakoutRoomSessionId}) does not match requested session ID (${request.breakoutSessionId}).`);
      return;
    }

    if (breakoutSession.breakoutRoomStatus === BreakoutRoomStatus.active) {
      console.log('Breakouts have already been assigned so returning.');
      return;
    }

    await new AssignToBreakouts().assignToBreakouts({
      breakoutSessionId: breakoutSession.breakoutRoomSessionId,
      assignmentMethod: breakoutSession.assignmentMethod,
      targetParticipantsPerRoom: breakoutSession.targetParticipantsPerRoom,
      includeWaitingRoom: breakoutSession.hasWaitingRoom,
      event,
      creatorId: userId,
    });
  }
}
