import * as functions from 'firebase-functions';
import { OnCallMethod } from '../../on_call_function';
import { firestore, firestoreUtils } from '../../utils/infra/firestore_utils';
import { Event, Membership } from '../../types';

interface ResetParticipantAgendaItemsRequest {
  liveMeetingPath: string;
}

export class ResetParticipantAgendaItems extends OnCallMethod<ResetParticipantAgendaItemsRequest> {
  constructor() {
    super('ResetParticipantAgendaItems', (json) => json as ResetParticipantAgendaItemsRequest);
  }

  async action(request: ResetParticipantAgendaItemsRequest, context: functions.https.CallableContext): Promise<void> {
    const liveMeetingPath = request.liveMeetingPath;
    const communityIdMatch = /\/?community\/([^/]+)/.exec(liveMeetingPath);
    if (!communityIdMatch) {
      throw new functions.https.HttpsError('invalid-argument', 'LiveMeetingPath malformed.');
    }
    const communityId = communityIdMatch[1];

    const liveMeetingDoc = await firestore.doc(liveMeetingPath).get();
    if (!liveMeetingDoc.exists) {
      throw new functions.https.HttpsError('failed-precondition', 'Incorrect meeting path');
    }

    const eventMatch = /\/?community\/([^/]+)\/templates\/([^/]+)\/events\/([^/]+)/.exec(liveMeetingPath);
    const event: Event = await firestoreUtils.getFirestoreObject({
      path: eventMatch![0],
      constructor: (map) => map as unknown as Event,
    });

    const membershipSnap = await firestore
      .doc(`memberships/${context.auth?.uid}/community-membership/${communityId}`)
      .get();
    const membership = firestoreUtils.fromFirestoreJson(membershipSnap.data() ?? {}) as unknown as Membership;

    if (!(membership as any).isAdmin && (event as any).creatorId !== context.auth?.uid) {
      throw new functions.https.HttpsError('failed-precondition', 'Unauthorized');
    }

    const meetingId = liveMeetingDoc.id;
    const participantDetails = await firestore
      .collectionGroup('participant-details')
      .where('meetingId', '==', meetingId)
      .get();

    const docs = participantDetails.docs;
    const matchingDocs = docs.filter((d) => d.ref.path.startsWith(liveMeetingPath));

    if (docs.length !== matchingDocs.length) {
      console.log(
        `Some docs with meetingId: ${meetingId} do not match the requested live meeting path: ${liveMeetingPath}`
      );
    }

    await Promise.all(matchingDocs.map((d) => d.ref.delete()));
  }
}
