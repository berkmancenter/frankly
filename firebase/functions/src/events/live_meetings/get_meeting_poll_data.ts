import * as functions from 'firebase-functions';
import { OnCallMethod } from '../../on_call_function';
import { firestore, firestoreUtils } from '../../utils/infra/firestore_utils';
import { firebaseAuthUtils } from '../../utils/infra/firebase_auth_utils';
import { orElseUnauthorized } from '../../utils/utils';
import { Event, Membership, Participant, ParticipantStatus, AgendaItemType } from '../../types';

interface GetMeetingPollDataRequest {
  eventPath: string;
}

interface PollData {
  userId?: string;
  userName?: string;
  userEmail?: string;
  agendaItemId?: string;
  pollQuestion?: string;
  pollResponse?: unknown;
  roomId?: string;
  answeredDate?: Date;
}

export class GetMeetingPollData extends OnCallMethod<GetMeetingPollDataRequest> {
  constructor() {
    super('GetMeetingPollData', (jsonMap) => jsonMap as GetMeetingPollDataRequest);
  }

  async action(request: GetMeetingPollDataRequest, context: functions.https.CallableContext): Promise<Record<string, unknown>> {
    const match = /\/?community\/([^/]+)\/templates\/([^/]+)\/events\/([^/]+)/.exec(request.eventPath);
    if (!match) throw new functions.https.HttpsError('invalid-argument', 'Path malformed.');
    const communityId = match[1];
    const eventId = match[3];

    const event: Event = await firestoreUtils.getFirestoreObject({
      path: request.eventPath,
      constructor: (map) => map as unknown as Event,
    });

    const membershipSnap = await firestore.doc(`memberships/${context.auth?.uid}/community-membership/${communityId}`).get();
    const membership: Membership = firestoreUtils.fromFirestoreJson(membershipSnap.data() ?? {}) as unknown as Membership;
    orElseUnauthorized((membership as any).isAdmin || event.creatorId === context.auth?.uid);

    const liveMeetingPath = `${request.eventPath}/live-meetings/${eventId}`;
    const breakoutRoomSessions = `${liveMeetingPath}/breakout-room-sessions`;
    const sessionDocs = await firestore.collection(breakoutRoomSessions).get();

    const roomDocQueries = await Promise.all(
      sessionDocs.docs.map((session) => firestore.collection(`${session.ref.path}/breakout-rooms`).get())
    );
    const roomDocs = roomDocQueries.flatMap((q) => q.docs);
    const breakoutMeetingLinks = roomDocs.map((roomDoc) => `${roomDoc.ref.path}/live-meetings/${roomDoc.id}`);
    const meetingPaths = [liveMeetingPath, ...breakoutMeetingLinks];

    const pollDataListResults = await Promise.all(meetingPaths.map((path) => this._getPollsFromPath(path, event)));
    const allPolls = pollDataListResults.flat();

    return { polls: allPolls };
  }

  private async _getPollsFromPath(path: string, event: Event): Promise<PollData[]> {
    const roomId = path.split('/').pop()!;
    const pollAgendaItems = (event.agendaItems ?? []).filter((a: any) => a.type === AgendaItemType?.poll || a.type === 'poll');
    const pollDataList: PollData[] = [];

    for (const agendaItem of pollAgendaItems) {
      const participantDetailsPath = `${path}/participant-agenda-item-details/${agendaItem.id}/participant-details`;
      const docs = await firestore.collection(participantDetailsPath).get();
      for (const doc of docs.docs) {
        const details = firestoreUtils.fromFirestoreJson(doc.data()) as unknown as any;
        if (details.pollResponse != null) {
          const memberInfo = await firebaseAuthUtils.getUser(details.userId);
          const memberDoc = await firestore.doc(`publicUser/${details.userId}`).get();
          const memberName = memberDoc.data()?.displayName ?? '';
          pollDataList.push({
            userId: details.userId,
            userName: memberName,
            userEmail: memberInfo?.email,
            agendaItemId: agendaItem.id,
            pollQuestion: agendaItem.content,
            pollResponse: details.pollResponse,
            roomId,
            answeredDate: doc.updateTime?.toDate(),
          });
        }
      }
    }

    return pollDataList;
  }
}
