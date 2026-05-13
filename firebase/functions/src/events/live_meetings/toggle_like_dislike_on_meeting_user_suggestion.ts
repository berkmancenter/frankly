import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { OnCallMethod } from '../../on_call_function';
import { firestore, firestoreUtils } from '../../utils/infra/firestore_utils';
import { ParticipantAgendaItemDetails } from '../../types';

interface ParticipantAgendaItemDetailsMeta {
  documentPath: string;
  userSuggestionId: string;
  voterId: string;
  likeType: 'like' | 'neutral' | 'dislike';
}

export class ToggleLikeDislikeOnMeetingUserSuggestion extends OnCallMethod<ParticipantAgendaItemDetailsMeta> {
  constructor() {
    super(
      'toggleLikeDislikeOnMeetingUserSuggestion',
      (jsonMap) => jsonMap as ParticipantAgendaItemDetailsMeta
    );
  }

  async action(request: ParticipantAgendaItemDetailsMeta, _context: functions.https.CallableContext): Promise<void> {
    await firestore.runTransaction(async (transaction) => {
      const docRef = firestore.doc(request.documentPath);
      const snap = await transaction.get(docRef);
      if (!snap.exists) {
        console.log(`agendaItemDetailsSnap from path ${request.documentPath} does not exist`);
        return;
      }

      let agendaItemDetails: ParticipantAgendaItemDetails;
      try {
        agendaItemDetails = firestoreUtils.fromFirestoreJson(snap.data() ?? {}) as unknown as ParticipantAgendaItemDetails;
      } catch (e) {
        console.log('Cannot parse participant agenda item details:', snap.data());
        return;
      }

      const suggestions = ((agendaItemDetails as any).suggestions ?? []) as Array<any>;
      const suggestionIndex = suggestions.findIndex((s: any) => s.id === request.userSuggestionId);
      if (suggestionIndex < 0) {
        console.log('userSuggestion is null. Request:', request);
        return;
      }

      const suggestion = { ...(suggestions[suggestionIndex] as any) };
      const likedByIds: string[] = [...(suggestion.likedByIds ?? [])];
      const dislikedByIds: string[] = [...(suggestion.dislikedByIds ?? [])];
      const voterId = request.voterId;

      console.log(`Toggle: ${request.likeType} for user suggestion ${suggestion.id}`);

      if (request.likeType === 'like') {
        if (!likedByIds.includes(voterId)) likedByIds.push(voterId);
        const idx = dislikedByIds.indexOf(voterId);
        if (idx >= 0) dislikedByIds.splice(idx, 1);
      } else if (request.likeType === 'neutral') {
        const li = likedByIds.indexOf(voterId);
        if (li >= 0) likedByIds.splice(li, 1);
        const di = dislikedByIds.indexOf(voterId);
        if (di >= 0) dislikedByIds.splice(di, 1);
      } else if (request.likeType === 'dislike') {
        const li = likedByIds.indexOf(voterId);
        if (li >= 0) likedByIds.splice(li, 1);
        if (!dislikedByIds.includes(voterId)) dislikedByIds.push(voterId);
      }

      suggestion.likedByIds = likedByIds;
      suggestion.dislikedByIds = dislikedByIds;
      suggestions[suggestionIndex] = suggestion;

      const updateData = firestoreUtils.toFirestoreJson({ suggestions } as Record<string, unknown>);
      transaction.update(docRef, updateData);
    });
  }
}
