import * as functions from 'firebase-functions';
import { OnCallMethod } from '../../on_call_function';
import { firestore, firestoreUtils } from '../../utils/infra/firestore_utils';
import { firebaseAuthUtils } from '../../utils/infra/firebase_auth_utils';
import { calendarLinkUtil } from '../../utils/calendar_link_util';
import { TemplateUtils } from '../../utils/template_utils';
import { orElseUnauthorized } from '../../utils/utils';
import { Event } from '../../types';

interface GetCommunityCalendarLinkRequest {
  eventPath: string;
}

interface GetCommunityCalendarLinkResponse {
  googleCalendarLink?: string;
  office365CalendarLink?: string;
  outlookCalendarLink?: string;
  icsLink?: string;
}

export class GetCommunityCalendarLink extends OnCallMethod<GetCommunityCalendarLinkRequest> {
  constructor() {
    super('GetCommunityCalendarLink', (jsonMap) => jsonMap as GetCommunityCalendarLinkRequest);
  }

  async action(
    request: GetCommunityCalendarLinkRequest,
    context: functions.https.CallableContext
  ): Promise<GetCommunityCalendarLinkResponse> {
    orElseUnauthorized(context.auth?.uid != null, { logMessage: 'Context auth ID was null' });

    const event: Event = await firestoreUtils.getFirestoreObject({
      path: request.eventPath,
      constructor: (map) => map as unknown as Event,
    });

    const users = await firebaseAuthUtils.getUsers([(event as any).creatorId]);
    if (users.length !== 1) throw new Error('Organizer not found');
    const organizer = users[0];

    const communitySnap = await firestore.doc(`community/${(event as any).communityId}`).get();
    const community = firestoreUtils.fromFirestoreJson(communitySnap.data() ?? {}) as unknown as any;

    const templatePath = `community/${community.id}/templates/${(event as any).templateId}`;
    const templateDoc = await firestore.doc(templatePath).get();
    const template = TemplateUtils.templateFromSnapshot(templateDoc);

    return {
      googleCalendarLink: calendarLinkUtil.getGoogleLink({ community, template, event }),
      office365CalendarLink: calendarLinkUtil.getOffice365Link({ community, template, event }),
      outlookCalendarLink: calendarLinkUtil.getOutlookLink({ community, template, event }),
      icsLink: calendarLinkUtil.getICS({ community, template, event, organizerEmail: (organizer as any)?.email }),
    };
  }
}
