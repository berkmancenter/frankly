import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/on_call_function.dart';
import 'package:junto_functions/utils/agora_api.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_functions/utils/utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/discussion_proposal.dart';
import 'package:junto_models/firestore/membership.dart';
import 'package:junto_models/utils.dart';

/// Cast a vote for or against kicking a user from a hostless meeting
class VoteToKick extends OnCallMethod<VoteToKickRequest> {
  VoteToKick() : super('VoteToKick', (json) => VoteToKickRequest.fromJson(json));

  @override
  Future<void> action(VoteToKickRequest request, CallableContext context) async {
    orElseUnauthorized(
      (request.liveMeetingPath).startsWith(request.discussionPath),
      logMessage: 'Discussion and live meeting path don\'t match',
    );

    final liveMeetingId = request.liveMeetingPath.split('/').last;

    final participantPath =
        '${request.discussionPath}/discussion-participants/${request.targetUserId}';
    final participantSnapshot = await firestore.document(participantPath).get();
    orElseNotFound(participantSnapshot.exists);
    final participant =
        Participant.fromJson(firestoreUtils.fromFirestoreJson(participantSnapshot.data.toMap()));
    orElseUnauthorized(participant.status == ParticipantStatus.active,
        logMessage: 'User does not have active status: ${participant.status}');
    final modStatuses = [
      MembershipStatus.mod,
      MembershipStatus.owner,
      MembershipStatus.admin,
    ];
    orElseUnauthorized(!modStatuses.contains(participant.membershipStatus));

    final proposalsCollection = firestore.collection('${request.liveMeetingPath}/proposals');

    final existingProposalSnapshot = await proposalsCollection
        .where(
          DiscussionProposal.kFieldType,
          isEqualTo: EnumToString.convertToString(DiscussionProposalType.kick),
        )
        .where(DiscussionProposal.kFieldTargetUserId, isEqualTo: request.targetUserId)
        .limit(1)
        .get();

    final participantsSnapshot = await firestore
        .collection('${request.discussionPath}/discussion-participants')
        .where("currentBreakoutRoomId", isEqualTo: liveMeetingId)
        .get();
    final participants = participantsSnapshot.documents
        .map((d) => Participant.fromJson(firestoreUtils.fromFirestoreJson(d.data.toMap())))
        .toList();
    final votingParticipants = participants.where((p) => p.id != request.targetUserId);

    final shouldKickUser = await firestore.runTransaction((transaction) async {
      bool shouldKickUser = false;
      if (existingProposalSnapshot.documents.isNotEmpty) {
        final reference = existingProposalSnapshot.documents[0].reference;
        final txProposalSnapshot = await transaction.get(reference);
        DiscussionProposal txProposal = DiscussionProposal.fromJson(
            firestoreUtils.fromFirestoreJson(txProposalSnapshot.data.toMap()));
        txProposal.votes?.removeWhere((vote) => vote.voterUserId == context?.authUid);
        txProposal.votes?.add(DiscussionProposalVote(
          voterUserId: context?.authUid,
          inFavor: request.inFavor,
          reason: request.reason,
        ));

        final inFavorCount = txProposal.votes?.where((vote) => vote.inFavor == true).length ?? 0;
        final againstCount = txProposal.votes?.where((vote) => vote.inFavor == false).length ?? 0;
        if (inFavorCount > 1 && inFavorCount >= votingParticipants.length) {
          shouldKickUser = true;
          final bannedParticipant = participant.copyWith(status: ParticipantStatus.banned);
          transaction.update(
              participantSnapshot.reference,
              UpdateData.fromMap(jsonSubset(
                [Participant.kFieldStatus, Participant.kFieldLastUpdatedTime],
                firestoreUtils.toFirestoreJson(bannedParticipant.toJson()),
              )));
          txProposal = txProposal.copyWith(
              status: DiscussionProposalStatus.accepted, closedAt: DateTime.now());
          print('Kicking user ${request.targetUserId} from convo.');
        } else if (inFavorCount + againstCount >= votingParticipants.length) {
          print('Not kicking user ${request.targetUserId} from convo due to no consensus');
          txProposal = txProposal.copyWith(
              status: DiscussionProposalStatus.rejected, closedAt: DateTime.now());
        }

        print('Updating kick proposal to ${txProposal.toJson()}');
        transaction.update(
            reference,
            UpdateData.fromMap(jsonSubset([
              DiscussionProposal.kFieldVotes,
              DiscussionProposal.kFieldStatus,
              DiscussionProposal.kFieldClosedAt,
            ], firestoreUtils.toFirestoreJson(txProposal.toJson()))));
      } else {
        final newDoc = proposalsCollection.document();
        final txProposal = DiscussionProposal(
            id: newDoc.documentID,
            initiatingUserId: context?.authUid,
            targetUserId: request.targetUserId,
            type: DiscussionProposalType.kick,
            status: DiscussionProposalStatus.open,
            createdAt: DateTime.now(),
            votes: [
              DiscussionProposalVote(
                voterUserId: context?.authUid,
                inFavor: request.inFavor,
                reason: request.reason,
              )
            ]);

        print('creating proposal ${txProposal.toJson()}');
        final newData = DocumentData.fromMap(firestoreUtils.toFirestoreJson(txProposal.toJson()));
        transaction.create(newDoc, newData);
      }

      return shouldKickUser;
    });

    if (shouldKickUser) {
      print('Current user location is: ${participant.currentBreakoutRoomId}');
      // Kick participant
      final roomId = participant.currentBreakoutRoomId ?? liveMeetingId;
      await AgoraUtils().kickParticipant(roomId: roomId, userId: request.targetUserId);
    }
  }
}
