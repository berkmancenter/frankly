import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:client/app/community/events/event_page/widgets/event_picture.dart';
import 'package:client/app/community/home/carousel/time_indicator.dart';
import 'package:client/app/community/community_provider.dart';
import 'package:client/common_widgets/custom_stream_builder.dart';
import 'package:client/common_widgets/participants_list.dart';
import 'package:client/routing/locations.dart';
import 'package:client/services/services.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/utils/height_constained_text.dart';
import 'package:data_models/events/event.dart';

import 'custom_ink_well.dart';

class EventButton extends HookWidget {
  final Event event;

  const EventButton({
    Key? key,
    required this.event,
  }) : super(key: key);

  bool get _isLiveStream => event.isLiveStream;

  Widget _buildTime() {
    final scheduledTime = event.scheduledTime ?? clockService.now();

    return VerticalTimeAndDateIndicator(
      shadow: false,
      time: DateTime.fromMillisecondsSinceEpoch(
        (scheduledTime.millisecondsSinceEpoch),
      ),
    );
  }

  Widget _buildCardContent() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          HeightConstrainedText(
            event.title ?? 'Scheduled event',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.headline4.copyWith(
              color: AppColor.darkBlue,
            ),
          ),
          SizedBox(height: 10.0),
          if (_isLiveStream)
            HeightConstrainedText(
              'Livestream',
              style: AppTextStyle.bodySmall.copyWith(
                color: AppColor.gray3,
              ),
            ),
          SizedBox(height: 10),
          _ParticipantsList(
            event: event,
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    const height = 100.0;
    final localEvent = event;

    return CustomInkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => routerDelegate.beamTo(
        CommunityPageRoutes(
          communityDisplayId:
              CommunityProvider.readOrNull(context)?.displayId ??
                  localEvent.communityId,
        ).eventPage(
          templateId: localEvent.templateId,
          eventId: localEvent.id,
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
            EventOrTemplatePicture(
              height: height,
              event: localEvent,
            ),
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
  final Event event;

  const _ParticipantsList({required this.event});

  Future<List<Participant>> _getParticipantsList() async {
    if (event.useParticipantCountEstimate) return [];

    final participants =
        await firestoreEventService.getEventParticipants(event: event);
    final activeParticipants = participants
        .where((p) => p.status == ParticipantStatus.active)
        .toList();

    return activeParticipants;
  }

  @override
  Widget build(BuildContext context) {
    return CustomStreamBuilder<List<Participant>>(
      entryFrom: '_ParticipantsList.build',
      stream: useMemoized(() => _getParticipantsList()).asStream(),
      showLoading: false,
      builder: (_, snapshot) {
        if (snapshot == null) return SizedBox.shrink();
        final participantCount = event.useParticipantCountEstimate
            ? event.participantCountEstimate ?? 1
            : snapshot.length;

        final maxNumberOfParticipantsToShow =
            responsiveLayoutService.isMobile(context) ? 4 : 6;
        final numberOfParticipantsToShow =
            min(maxNumberOfParticipantsToShow, participantCount);
        return ParticipantsList(
          key: Key('${snapshot.length}'),
          event: event,
          iconSize: 30,
          participantIds: snapshot.map((e) => e.id).toList(),
          numberOfIconsToShow: numberOfParticipantsToShow,
        );
      },
    );
  }
}
