import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/live_meeting_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/confirm_text_input_dialogue.dart';
import 'package:junto/services/logging_service.dart';
import 'package:junto/services/services.dart';
import 'package:junto/utils/stream_utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion_proposal.dart';

void useKickProposalListeners(BuildContext context) {
  final liveMeetingProvider = LiveMeetingProvider.watch(context);

  final stream = useBehaviorSubjectWrapper(() {
    return firestoreLiveMeetingService
        .getProposals(liveMeetingPath: liveMeetingProvider.activeLiveMeetingPath)
        .map((proposals) =>
            proposals.where((proposal) => proposal.type == DiscussionProposalType.kick));
  }, [liveMeetingProvider.activeLiveMeetingPath]);
  _listenForClosedKickProposals(stream, context, liveMeetingProvider);
  _listenForOpenKickProposals(stream, context, liveMeetingProvider);
}

void _listenForClosedKickProposals(
  Stream<Iterable<DiscussionProposal>> proposalsStream,
  BuildContext context,
  LiveMeetingProvider liveMeetingProvider,
) {
  useStreamListener<WithPreviousData<Iterable<DiscussionProposal>>>(
    stream: proposalsStream.withPrevious(),
    keys: [],
    function: (values) {
      final previous = values.previous;
      final current = values.current;

      if (previous == null || current == null) return;

      final prevOpen =
          previous.where((proposal) => proposal.status == DiscussionProposalStatus.open);
      final prevOpenSet = {for (var proposal in prevOpen) proposal.id};
      Iterable<DiscussionProposal?> nowClosed =
          current.where((proposal) => proposal.status != DiscussionProposalStatus.open);
      final newlyClosed =
          nowClosed.firstWhereOrNull((proposal) => prevOpenSet.contains(proposal!.id));
      if (newlyClosed != null) {
        if (newlyClosed.status == DiscussionProposalStatus.accepted) {
          showRegularToast(
            context,
            'The reported user was removed from the event.',
            toastType: ToastType.success,
          );
        } else if (newlyClosed.status == DiscussionProposalStatus.rejected) {
          showRegularToast(
            context,
            'Consensus not reached, the reported user will remain in the event.',
            toastType: ToastType.failed,
          );
        }
      }
    },
  );
}

void _listenForOpenKickProposals(Stream<Iterable<DiscussionProposal>> proposalsStream,
    BuildContext context, LiveMeetingProvider liveMeetingProvider) {
  final hasVotedOn = useRef(<String>{});
  final hasBeenShown = useRef(<String>{});
  useStreamListener<Iterable<DiscussionProposal>>(
    stream: proposalsStream,
    keys: [],
    function: (Iterable<DiscussionProposal?> values) async {
      final openProposal = values
          .where(
            (proposal) =>
                proposal!.status == DiscussionProposalStatus.open &&
                !proposal.votes!.any((vote) => vote.voterUserId == userService.currentUserId) &&
                !hasVotedOn.value.contains(proposal.id),
          )
          .firstOrNull;
      final alreadyShownProposal = hasBeenShown.value.contains(openProposal?.id);
      if (openProposal != null && !alreadyShownProposal) {
        hasBeenShown.value.add(openProposal.id!);
        final reason = await _kickProposalConfirmation(openProposal, context);
        final targetUserId = openProposal.targetUserId;
        if (targetUserId == null) {
          loggingService.log(
            '_listenForOpenKickProposals: targetUserId is null',
            logType: LogType.error,
          );
          return;
        }
        hasVotedOn.value.add(openProposal.id!);
        if (reason != null) {
          await cloudFunctionsService.voteToKick(VoteToKickRequest(
            targetUserId: targetUserId,
            discussionPath: liveMeetingProvider.discussionPath,
            liveMeetingPath: liveMeetingProvider.activeLiveMeetingPath,
            reason: reason,
            inFavor: true,
          ));
        } else {
          await cloudFunctionsService.voteToKick(VoteToKickRequest(
            targetUserId: targetUserId,
            discussionPath: liveMeetingProvider.discussionPath,
            liveMeetingPath: liveMeetingProvider.activeLiveMeetingPath,
            inFavor: false,
          ));
        }
      }
    },
  );
}

Future<String?> _kickProposalConfirmation(
    DiscussionProposal proposalToShow, BuildContext context) async {
  final targetUserFuture = firestoreUserService.getPublicUser(userId: proposalToShow.targetUserId!);
  final initiatingUserFuture =
      firestoreUserService.getPublicUser(userId: proposalToShow.initiatingUserId!);
  final targetUser = await targetUserFuture;
  final initiatingUser = await initiatingUserFuture;
  return ConfirmTextInputDialogue(
    title: 'Kick out ${targetUser.displayName}?',
    subText: '${initiatingUser.displayName} started a vote to kick'
        ' ${targetUser.displayName} out of the event. Do you want to'
        ' kick them out? They will not be allowed back in.',
    textLabel: 'Enter reason',
    textHint: 'e.g. They are trying to sabotage the event',
    cancelText: 'No, let them stay',
    confirmText: 'Yes, kick them out',
  ).show(context: context);
}
