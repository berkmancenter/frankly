import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { OnCallMethod } from '../../on_call_function';
import { firestore, firestoreUtils } from '../../utils/infra/firestore_utils';
import { orElseUnauthorized, orElseNotFound } from '../../utils/utils';
import { AgoraUtils } from './agora_api';
import {
  Event, Participant, ParticipantStatus, MembershipStatus,
  EventProposal, EventProposalType, EventProposalStatus, EventProposalVote,
} from '../../types';

interface VoteToKickRequest {
  eventPath: string;
  liveMeetingPath: string;
  targetUserId: string;
  inFavor: boolean;
  reason?: string;
}

export class VoteToKick extends OnCallMethod<VoteToKickRequest> {
  private agoraUtils: AgoraUtils;

  constructor(agoraUtils?: AgoraUtils) {
    super('VoteToKick', (json) => json as VoteToKickRequest);
    this.agoraUtils = agoraUtils ?? new AgoraUtils();
  }

  async action(request: VoteToKickRequest, context: functions.https.CallableContext): Promise<void> {
    orElseUnauthorized(
      request.liveMeetingPath.startsWith(request.eventPath),
      { logMessage: "Event and live meeting path don't match" }
    );

    const liveMeetingId = request.liveMeetingPath.split('/').pop()!;

    const participantSnap = await firestore
      .doc(`${request.eventPath}/event-participants/${request.targetUserId}`)
      .get();
    orElseNotFound(participantSnap.exists);
    const participant = firestoreUtils.fromFirestoreJson(participantSnap.data() ?? {}) as unknown as Participant;
    orElseUnauthorized(
      (participant as any).status === ParticipantStatus.active,
      { logMessage: `User does not have active status: ${(participant as any).status}` }
    );
    const modStatuses = [MembershipStatus.moderator, MembershipStatus.owner, MembershipStatus.admin];
    orElseUnauthorized(!modStatuses.includes((participant as any).membershipStatus));

    const proposalsCollection = firestore.collection(`${request.liveMeetingPath}/proposals`);
    const existingProposalSnapshot = await proposalsCollection
      .where('type', '==', EventProposalType.kick)
      .where('targetUserId', '==', request.targetUserId)
      .limit(1)
      .get();

    const participantsSnapshot = await firestore
      .collection(`${request.eventPath}/event-participants`)
      .where('currentBreakoutRoomId', '==', liveMeetingId)
      .get();
    const participants = participantsSnapshot.docs.map((d) =>
      firestoreUtils.fromFirestoreJson(d.data()) as unknown as Participant
    );
    const votingParticipants = participants.filter((p) => (p as any).id !== request.targetUserId);

    const shouldKick = await firestore.runTransaction(async (transaction) => {
      let shouldKickUser = false;

      if (!existingProposalSnapshot.empty) {
        const ref = existingProposalSnapshot.docs[0].ref;
        const txSnap = await transaction.get(ref);
        const txProposal = firestoreUtils.fromFirestoreJson(txSnap.data() ?? {}) as unknown as EventProposal;

        const votes = (txProposal.votes ?? []).filter((v) => v.voterUserId !== context.auth?.uid);
        votes.push({ voterUserId: context.auth?.uid, inFavor: request.inFavor, reason: request.reason } as EventProposalVote);

        const inFavorCount = votes.filter((v) => v.inFavor === true).length;

        if (inFavorCount > 1 && inFavorCount >= votingParticipants.length) {
          shouldKickUser = true;
          transaction.update(participantSnap.ref, { status: ParticipantStatus.banned });
          transaction.update(ref, {
            ...firestoreUtils.toFirestoreJson({ votes, status: EventProposalStatus.accepted, closedAt: new Date() } as Record<string, unknown>),
          });
        } else {
          transaction.update(ref, { votes: firestoreUtils.toFirestoreJson({ votes } as Record<string, unknown>)['votes'] });
        }
      } else {
        const newProposal = {
          type: EventProposalType.kick,
          targetUserId: request.targetUserId,
          status: EventProposalStatus.open,
          votes: [{ voterUserId: context.auth?.uid, inFavor: request.inFavor, reason: request.reason } as EventProposalVote],
        };
        transaction.set(proposalsCollection.doc(), firestoreUtils.toFirestoreJson(newProposal as unknown as Record<string, unknown>));
      }

      return shouldKickUser;
    });

    if (shouldKick) {
      const breakoutRoomId = request.liveMeetingPath.split('/').pop()!;
      await this.agoraUtils.kickParticipant({ roomId: breakoutRoomId, userId: request.targetUserId });
    }
  }
}
