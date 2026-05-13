import * as functions from 'firebase-functions';
import { OnCallMethod } from '../on_call_function';
import { firestore, firestoreUtils } from '../utils/infra/firestore_utils';
import { notificationsUtils } from '../utils/notifications_utils';
import { subscriptionPlanUtil } from '../utils/subscription_plan_util';
import { generateEventEndedContent } from '../utils/email_templates';
import { AgoraUtils } from './live_meetings/agora_api';
import { Event, Participant, ParticipantStatus, BreakoutRoom, EventEmailType } from '../types';

interface EventEndedRequest {
  eventPath: string;
}

export class EventEnded extends OnCallMethod<EventEndedRequest> {
  private agoraUtils: AgoraUtils;

  constructor() {
    super('eventEnded', (jsonMap) => jsonMap as EventEndedRequest);
    this.agoraUtils = new AgoraUtils();
  }

  async action(request: EventEndedRequest, context: functions.https.CallableContext): Promise<void> {
    const participant: Participant = await firestoreUtils.getFirestoreObject({
      path: `${request.eventPath}/event-participants/${context.auth?.uid}`,
      constructor: (map) => map as unknown as Participant,
    });

    if (participant.status !== ParticipantStatus.active) {
      throw new functions.https.HttpsError('failed-precondition', 'unauthorized');
    }

    const event: Event = await firestoreUtils.getFirestoreObject({
      path: request.eventPath,
      constructor: (map) => map as unknown as Event,
    });

    // Stop main room recording
    const liveMeetingPath = `${request.eventPath}/live-meetings/${event.id}`;
    try {
      const liveMeeting = await firestoreUtils.getFirestoreObject({
        path: liveMeetingPath,
        constructor: (map) => map as unknown as any,
      });
      if (liveMeeting.recordingSessionId) {
        await this.agoraUtils.stopRoom({ sessionId: liveMeeting.recordingSessionId });
      }
    } catch (e) {
      console.error('Error stopping main room recording:', e);
    }

    // Stop breakout recordings
    try {
      const breakoutSessionDocs = await firestore.collection(`${liveMeetingPath}/breakout-room-sessions`).get();
      for (const sessionDoc of breakoutSessionDocs.docs) {
        const breakoutRoomDocs = await firestore.collection(`${sessionDoc.ref.path}/breakout-rooms`).get();
        for (const roomDoc of breakoutRoomDocs.docs) {
          const breakoutRoom: BreakoutRoom = firestoreUtils.fromFirestoreJson(roomDoc.data()) as unknown as BreakoutRoom;
          if (breakoutRoom.recordingSessionId) {
            try {
              await this.agoraUtils.stopRoom({ sessionId: breakoutRoom.recordingSessionId });
            } catch (e) {
              console.error('Error stopping breakout recording:', e);
            }
          }
        }
      }
    } catch (e) {
      console.error('Error stopping breakout recordings:', e);
    }

    const capabilities = await subscriptionPlanUtil.calculateCapabilities(event.communityId!);
    const hasPrePost = capabilities.hasPrePost ?? false;

    await notificationsUtils.sendEventEndedEmail({
      event,
      communityId: event.communityId!,
      userIds: [context.auth!.uid],
      emailType: EventEmailType.ended,
      generateMessage: (community, user) => ({
        subject: 'Thanks for joining',
        html: generateEventEndedContent({
          header: `Thanks for joining ${event.title}!`,
          community,
          userRecord: user,
          event,
          allowPrePost: hasPrePost,
        }),
      }),
    });
  }
}
