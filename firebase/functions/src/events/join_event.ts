import * as functions from 'firebase-functions';
import { OnCallMethod } from '../on_call_function';
import { firestore, firestoreUtils } from '../utils/infra/firestore_utils';
import { Event, Community, Participant, ParticipantStatus, EventEmailType } from '../types';
import { getEventFullPath } from '../types';
import { EventEmails } from './notifications/event_emails';

export class JoinEvent extends OnCallMethod<Event> {
  private eventEmailUtils: EventEmails;

  constructor() {
    super('joinEvent', (jsonMap) => jsonMap as unknown as Event);
    this.eventEmailUtils = new EventEmails();
  }

  async action(request: Event, context: functions.https.CallableContext): Promise<void> {
    const eventPath = getEventFullPath(request);
    const participantRef = firestore.doc(`${eventPath}/event-participants/${context.auth?.uid}`);
    const participantSnapshot = await participantRef.get();
    if (!participantSnapshot.exists) return;

    const participant: Participant = {
      ...(firestoreUtils.fromFirestoreJson(participantSnapshot.data() ?? {}) as unknown as Participant),
      id: context.auth?.uid,
    };

    const community: Community = await firestoreUtils.getFirestoreObject({
      path: `community/${request.communityId}`,
      constructor: (map) => map as unknown as Community,
    });

    const suppressEmail = !((request.eventSettings as any)?.reminderEmails ??
      (community as any).eventSettingsMigration?.reminderEmails ?? true);

    if (participant.status === ParticipantStatus.active && !suppressEmail) {
      await this.eventEmailUtils.sendEmailsToUsers({
        eventPath,
        userIds: [context.auth!.uid],
        emailType: EventEmailType.initialSignUp,
      });
    }
  }
}
