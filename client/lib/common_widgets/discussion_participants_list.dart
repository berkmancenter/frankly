import 'dart:math';

import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/common_widgets/participants_list.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/firestore/discussion.dart';

/// This is a list of participants for a discussion card that relies on the discussion provider
class DiscussionPageParticipantsList extends StatelessWidget {
  final Discussion discussion;
  final double? iconSize;
  final bool showFullParticipantCount;

  const DiscussionPageParticipantsList(
    this.discussion, {
    Key? key,
    this.iconSize,
    this.showFullParticipantCount = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final participantCount = DiscussionProvider.watch(context).participantCount;
    final maxNumberOfParticipantsToShow = responsiveLayoutService.isMobile(context) ? 4 : 6;
    final numberOfParticipantsToShow = min(maxNumberOfParticipantsToShow, participantCount);

    return JuntoStreamBuilder<List<Participant>>(
      entryFrom: 'discussion_participants_list.build_participants',
      stream: DiscussionProvider.watch(context).discussionParticipantsStream,
      showLoading: false,
      builder: (context, participants) {
        final activeParticipants =
            (participants ?? []).where((e) => e.status == ParticipantStatus.active);
        return ParticipantsList(
          key: Key('${activeParticipants.length}'),
          discussion: discussion,
          participantIds: activeParticipants.map((e) => e.id).toList(),
          numberOfIconsToShow: numberOfParticipantsToShow,
        );
      },
    );
  }
}
