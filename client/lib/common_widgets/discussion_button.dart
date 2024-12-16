import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/discussion_picture.dart';
import 'package:junto/app/junto/home/carousel/time_indicator.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/common_widgets/participants_list.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/firestore/discussion.dart';

import 'junto_ink_well.dart';

class DiscussionButton extends HookWidget {
  final Discussion discussion;

  const DiscussionButton({
    Key? key,
    required this.discussion,
  }) : super(key: key);

  bool get _isLiveStream => discussion.isLiveStream;

  Widget _buildTime() {
    final scheduledTime = discussion.scheduledTime ?? clockService.now();

    return VerticalTimeAndDateIndicator(
      shadow: false,
      time: DateTime.fromMillisecondsSinceEpoch((scheduledTime.millisecondsSinceEpoch)),
    );
  }

  Widget _buildCardContent() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          JuntoText(
            discussion.title ?? 'Scheduled event',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.headline4.copyWith(
              color: AppColor.darkBlue,
            ),
          ),
          SizedBox(height: 10.0),
          if (_isLiveStream)
            JuntoText(
              'Livestream',
              style: AppTextStyle.bodySmall.copyWith(
                color: AppColor.gray3,
              ),
            ),
          SizedBox(height: 10),
          _ParticipantsList(
            discussion: discussion,
          )
        ],
      );

  @override
  Widget build(BuildContext context) {
    const height = 100.0;
    final localDiscussion = discussion;

    return JuntoInkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => routerDelegate.beamTo(
        JuntoPageRoutes(
          juntoDisplayId: JuntoProvider.readOrNull(context)?.displayId ?? localDiscussion.juntoId,
        ).discussionPage(
          topicId: localDiscussion.topicId,
          discussionId: localDiscussion.id,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColor.black.withOpacity(0.5),
              blurRadius: 4,
              offset: Offset(1, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(width: 8),
            _buildTime(),
            DiscussionOrTopicPicture(height: height, discussion: localDiscussion),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildCardContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParticipantsList extends HookWidget {
  final Discussion discussion;

  const _ParticipantsList({required this.discussion});

  Future<List<Participant>> _getParticipantsList() async {
    if (discussion.useParticipantCountEstimate) return [];

    final participants =
        await firestoreDiscussionService.getDiscussionParticipants(discussion: discussion);
    final activeParticipants =
        participants.where((p) => p.status == ParticipantStatus.active).toList();

    return activeParticipants;
  }

  @override
  Widget build(BuildContext context) {
    return JuntoStreamBuilder<List<Participant>>(
      entryFrom: '_ParticipantsList.build',
      stream: useMemoized(() => _getParticipantsList()).asStream(),
      showLoading: false,
      builder: (_, snapshot) {
        if (snapshot == null) return SizedBox.shrink();
        final participantCount = discussion.useParticipantCountEstimate
            ? discussion.participantCountEstimate ?? 1
            : snapshot.length;

        final maxNumberOfParticipantsToShow = responsiveLayoutService.isMobile(context) ? 4 : 6;
        final numberOfParticipantsToShow = min(maxNumberOfParticipantsToShow, participantCount);
        return ParticipantsList(
          key: Key('${snapshot.length}'),
          discussion: discussion,
          iconSize: 30,
          participantIds: snapshot.map((e) => e.id).toList(),
          numberOfIconsToShow: numberOfParticipantsToShow,
        );
      },
    );
  }
}
