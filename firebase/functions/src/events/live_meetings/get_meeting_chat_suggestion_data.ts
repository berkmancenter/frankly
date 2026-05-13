import * as functions from 'firebase-functions';
import { OnCallMethod } from '../../on_call_function';
import { firestore, firestoreUtils } from '../../utils/infra/firestore_utils';
import { firebaseAuthUtils } from '../../utils/infra/firebase_auth_utils';
import { orElseUnauthorized } from '../../utils/utils';
import { Event, Membership } from '../../types';

interface GetMeetingChatsSuggestionsDataRequest {
  eventPath: string;
}

export class GetMeetingChatSuggestionData extends OnCallMethod<GetMeetingChatsSuggestionsDataRequest> {
  constructor() {
    super(
      'GetMeetingChatSuggestionData',
      (jsonMap) => jsonMap as GetMeetingChatsSuggestionsDataRequest
    );
  }

  async action(
    request: GetMeetingChatsSuggestionsDataRequest,
    context: functions.https.CallableContext
  ): Promise<Record<string, unknown>> {
    const eventPath = request.eventPath;
    const match = /\/?community\/([^/]+)\/templates\/([^/]+)\/events\/([^/]+)/.exec(eventPath);
    if (!match) throw new functions.https.HttpsError('invalid-argument', 'Path malformed.');

    const communityId = match[1];
    const eventId = match[3];

    const event: Event = await firestoreUtils.getFirestoreObject({
      path: eventPath,
      constructor: (map) => map as unknown as Event,
    });

    const membershipSnap = await firestore
      .doc(`memberships/${context.auth?.uid}/community-membership/${communityId}`)
      .get();
    const membership = firestoreUtils.fromFirestoreJson(membershipSnap.data() ?? {}) as unknown as Membership;

    orElseUnauthorized((membership as any).isAdmin || (event as any).creatorId === context.auth?.uid);

    const liveMeetingPath = `${request.eventPath}/live-meetings/${eventId}`;
    const sessionDocs = await firestore.collection(`${liveMeetingPath}/breakout-room-sessions`).get();
    const roomDocQueries = await Promise.all(
      sessionDocs.docs.map((session) => firestore.collection(`${session.ref.path}/breakout-rooms`).get())
    );
    const roomDocs = roomDocQueries.flatMap((q) => q.docs);
    const breakoutMeetingLinks = roomDocs.map((roomDoc) => `${roomDoc.ref.path}/live-meetings/${roomDoc.id}`);
    const meetingPaths = [request.eventPath, ...breakoutMeetingLinks];

    const [chatDataListResults, suggestionDataListResults] = await Promise.all([
      Promise.all(meetingPaths.map((path) => this._getChatsFromPath(path))),
      Promise.all(meetingPaths.map((path) => this._getSuggestionsFromPath(path))),
    ]);

    const agendaItemSuggestions = await this._getAgendaItemSuggestions(event, [
      liveMeetingPath,
      ...breakoutMeetingLinks,
    ]);

    return {
      chatsSuggestionsList: [
        ...chatDataListResults.flat(),
        ...suggestionDataListResults.flat(),
        ...agendaItemSuggestions,
      ],
    };
  }

  private async _getChatsFromPath(path: string): Promise<Record<string, unknown>[]> {
    const roomId = path.split('/').pop()!;
    const chatsData = await firestore
      .collection(`${path}/chats/community_chat/messages`)
      .orderBy('createdDate')
      .get();

    const chatSuggestions: Record<string, unknown>[] = [];
    for (const document of chatsData.docs) {
      const doc = firestoreUtils.fromFirestoreJson(document.data()) as Record<string, unknown>;
      const memberInfo = await firebaseAuthUtils.getUser(doc['creatorId'] as string);
      const memberDoc = await firestore.doc(`publicUser/${doc['creatorId']}`).get();
      const memberName = (memberDoc.data() ?? {})['displayName'] as string ?? '';

      chatSuggestions.push({
        id: document.id,
        creatorId: doc['creatorId'],
        creatorEmail: (memberInfo as any)?.email,
        creatorName: memberName,
        createdDate: doc['createdDate'],
        message: doc['message'],
        emotionType: doc['emotionType'],
        type: 'chat',
        roomId,
        deleted: doc['messageStatus'] === 'removed',
      });
    }
    return chatSuggestions;
  }

  private async _getSuggestionsFromPath(path: string): Promise<Record<string, unknown>[]> {
    const roomId = path.split('/').pop()!;
    const userSuggestionsData = await firestore
      .collection(`${path}/user-suggestions`)
      .orderBy('createdDate')
      .get();

    const results: Record<string, unknown>[] = [];
    for (const document of userSuggestionsData.docs) {
      const doc = firestoreUtils.fromFirestoreJson(document.data()) as Record<string, unknown>;
      const memberInfo = await firebaseAuthUtils.getUser(doc['creatorId'] as string);
      const memberDoc = await firestore.doc(`publicUser/${doc['creatorId']}`).get();
      const memberName = (memberDoc.data() ?? {})['displayName'] as string ?? '';

      results.push({
        id: document.id,
        creatorId: doc['creatorId'],
        creatorEmail: (memberInfo as any)?.email,
        creatorName: memberName,
        createdDate: doc['createdDate'],
        message: doc['content'],
        type: 'suggestion',
        upvotes: ((doc['upvotedUserIds'] as unknown[]) ?? []).length,
        downvotes: ((doc['downvotedUserIds'] as unknown[]) ?? []).length,
        roomId,
      });
    }
    return results;
  }

  private async _getAgendaItemSuggestions(event: Event, roomPaths: string[]): Promise<Record<string, unknown>[]> {
    const suggestionAgendaItems = ((event as any).agendaItems ?? [])
      .filter((a: any) => a.type === 'userSuggestions')
      .map((a: any) => a.id as string);

    const collections: string[] = roomPaths.flatMap((path) =>
      suggestionAgendaItems.map(
        (id: string) => `${path}/participant-agenda-item-details/${id}/participant-details`
      )
    );

    const results = await Promise.all(collections.map((c) => this._getParticipantAgendaItemDetails(c)));
    return results.flat();
  }

  private async _getParticipantAgendaItemDetails(collection: string): Promise<Record<string, unknown>[]> {
    const documents = await firestore.collection(collection).get();
    const results = await Promise.all(
      documents.docs.map((doc) => {
        const details = firestoreUtils.fromFirestoreJson(doc.data()) as Record<string, unknown>;
        return this._getSuggestionsFromParticipantAgendaItem(doc.id, details);
      })
    );
    return results.flat();
  }

  private async _getSuggestionsFromParticipantAgendaItem(
    docId: string,
    details: Record<string, unknown>
  ): Promise<Record<string, unknown>[]> {
    const userId = details['userId'] as string | undefined;
    if (!userId) return [];

    const memberInfo = await firebaseAuthUtils.getUser(userId);
    const memberDoc = await firestore.doc(`publicUser/${userId}`).get();
    const memberName = (memberDoc.data() ?? {})['displayName'] as string ?? '';

    const suggestions = (details['suggestions'] as unknown[]) ?? [];
    return suggestions.map((suggestion: any) => ({
      id: docId,
      creatorId: userId,
      creatorEmail: (memberInfo as any)?.email,
      creatorName: memberName,
      createdDate: suggestion['createdDate'],
      message: suggestion['suggestion'],
      type: 'suggestion',
      upvotes: (suggestion['likedByIds'] ?? []).length,
      downvotes: (suggestion['dislikedByIds'] ?? []).length,
      roomId: details['meetingId'],
      agendaItemId: details['agendaItemId'],
    }));
  }
}
