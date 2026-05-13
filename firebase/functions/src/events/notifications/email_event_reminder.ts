import { OnRequestMethod } from '../../on_request_method';
import { firestore, firestoreUtils } from '../../utils/infra/firestore_utils';
import { Event, Community, Participant, ParticipantStatus, EventEmailType } from '../../types';

interface EmailEventReminderRequest {
  communityId: string;
  templateId: string;
  eventId: string;
  eventEmailType: EventEmailType;
}

const REMINDER_DURATION_BUFFER_MS = 30 * 60 * 1000; // 30 minutes

export class EmailEventReminder extends OnRequestMethod<EmailEventReminderRequest> {
  static readonly emailReminderOffsetMs: Record<string, number> = {
    [EventEmailType.oneDayReminder]: 24 * 60 * 60 * 1000,
    [EventEmailType.oneHourReminder]: 60 * 60 * 1000,
  };

  constructor() {
    super('EmailEventReminder', (jsonMap) => jsonMap as EmailEventReminderRequest);
  }

  async action(request: EmailEventReminderRequest): Promise<string> {
    await firestore.runTransaction(async (transaction) => {
      const eventPath = `community/${request.communityId}/templates/${request.templateId}/events/${request.eventId}`;
      const event: Event = await firestoreUtils.getFirestoreObject({
        transaction,
        path: eventPath,
        constructor: (map) => map as unknown as Event,
      });

      console.log('Attempting reminder email for event:', event.id);
      const reminderOffsetMs = EmailEventReminder.emailReminderOffsetMs[request.eventEmailType];
      if (reminderOffsetMs === undefined) return;

      const timeUntilEvent = event.scheduledTime
        ? event.scheduledTime.getTime() - Date.now()
        : null;
      if (
        timeUntilEvent === null ||
        timeUntilEvent > reminderOffsetMs + REMINDER_DURATION_BUFFER_MS ||
        timeUntilEvent < reminderOffsetMs - REMINDER_DURATION_BUFFER_MS
      ) {
        console.log('Event is not within notification window of reminder offset:', reminderOffsetMs);
        return;
      }

      const community: Community = await firestoreUtils.getFirestoreObject({
        path: `community/${request.communityId}`,
        constructor: (map) => map as unknown as Community,
      });

      const suppressEmail = !(
        event.eventSettings?.reminderEmails ??
        (community as any).eventSettingsMigration?.reminderEmails ??
        true
      );
      if (suppressEmail) return;

      const participantSnaps = await firestore
        .collection(`${eventPath}/event-participants`)
        .get();
      const participants = participantSnaps.docs
        .map((doc) => ({
          ...(firestoreUtils.fromFirestoreJson(doc.data()) as unknown as Participant),
          id: doc.id,
        }))
        .filter((p) => p.status === ParticipantStatus.active);

      // Lazy import to avoid circular dependency
      const { EventEmails } = await import('./event_emails');
      await new EventEmails().sendEmailsToUsers({
        event,
        eventPath,
        userIds: participants.map((p) => p.id!),
        emailType: request.eventEmailType,
      });
    });

    return '';
  }
}
