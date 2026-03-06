import 'dart:math';

import 'package:flutter/material.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/features/events/presentation/widgets/participants_list.dart';
import 'package:client/services.dart';
import 'package:data_models/events/event.dart';

/// This is a list of participants for a event card that relies on the event provider
class EventPageParticipantsList extends StatelessWidget {
  final Event event;
  final double? iconSize;
  final bool showFullParticipantCount;

  const EventPageParticipantsList(
    this.event, {
    Key? key,
    this.iconSize,
    this.showFullParticipantCount = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final eventProvider = EventProvider.watch(context);

    // When the meeting is live (any participant is present), show only
    // present participants to match the in-meeting counts.
    final isLive = eventProvider.hasPresentParticipants;
    final participantCount = isLive
        ? eventProvider.presentParticipantCount
        : eventProvider.participantCount;
    final maxNumberOfParticipantsToShow =
        responsiveLayoutService.isMobile(context) ? 4 : 6;
    final numberOfParticipantsToShow =
        min(maxNumberOfParticipantsToShow, participantCount);

    return CustomStreamBuilder<List<Participant>>(
      entryFrom: 'event_participants_list.build_participants',
      stream: eventProvider.eventParticipantsStream,
      showLoading: false,
      builder: (context, participants) {
        final activeParticipants = (participants ?? [])
            .where((e) => e.status == ParticipantStatus.active);
        final displayParticipants = isLive
            ? activeParticipants.where((p) => p.isPresent)
            : activeParticipants;
        return ParticipantsList(
          key: Key('${displayParticipants.length}'),
          event: event,
          participantIds: displayParticipants.map((e) => e.id).toList(),
          numberOfIconsToShow: numberOfParticipantsToShow,
          participantCount: participantCount,
        );
      },
    );
  }
}
