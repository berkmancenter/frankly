import * as functions from 'firebase-functions';
import { OnCallMethod } from '../../on_call_function';
import { firestore, firestoreUtils } from '../../utils/infra/firestore_utils';
import { notificationsUtils } from '../../utils/notifications_utils';
import { makeNewEventMessageBody } from '../../utils/email_templates';
import { orElseUnauthorized } from '../../utils/utils';
import { TemplateUtils } from '../../utils/template_utils';
import { Event, EventMessage } from '../../types';

interface SendEventMessageRequest {
  communityId: string;
  templateId: string;
  eventId: string;
  eventMessage: EventMessage;
}

export class SendEventMessage extends OnCallMethod<SendEventMessageRequest> {
  constructor() {
    super('sendEventMessage', (jsonMap) => jsonMap as unknown as SendEventMessageRequest);
  }

  async action(request: SendEventMessageRequest, context: functions.https.CallableContext): Promise<void> {
    orElseUnauthorized(context.auth?.uid != null);

    const msgData: Record<string, unknown> = {
      ...(firestoreUtils.toFirestoreJson(request.eventMessage as unknown as Record<string, unknown>)),
      createdAt: new Date(request.eventMessage.createdAtMillis ?? Date.now()),
    };

    await firestore
      .collection(`community/${request.communityId}/templates/${request.templateId}/events/${request.eventId}/event-messages`)
      .add(msgData);

    const [templateDoc, eventDoc] = await Promise.all([
      firestore.doc(`community/${request.communityId}/templates/${request.templateId}`).get(),
      firestore.doc(`community/${request.communityId}/templates/${request.templateId}/events/${request.eventId}`).get(),
    ]);

    const template = TemplateUtils.templateFromSnapshot(templateDoc);
    const event: Event = {
      ...(firestoreUtils.fromFirestoreJson(eventDoc.data() ?? {}) as unknown as Event),
      id: eventDoc.id,
    };

    await notificationsUtils.sendEmailToEventParticipants({
      communityId: request.communityId,
      template,
      event,
      generateMessage: ({ community, user, unsubscribeUrl }) => ({
        subject: `New Message in Event ${event.title}`,
        html: makeNewEventMessageBody({
          community,
          template,
          event,
          eventMessage: request.eventMessage,
          unsubscribeUrl,
        }),
      }),
    });
  }
}
