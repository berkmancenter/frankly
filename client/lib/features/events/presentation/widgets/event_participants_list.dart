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
    final participantCount = EventProvider.watch(context).participantCount;
    final maxNumberOfParticipantsToShow =
        responsiveLayoutService.isMobile(context) ? 4 : 6;
    final numberOfParticipantsToShow =
        min(maxNumberOfParticipantsToShow, participantCount);

    return CustomStreamBuilder<List<Participant>>(
      entryFrom: 'event_participants_list.build_participants',
      stream: EventProvider.watch(context).eventParticipantsStream,
      showLoading: false,
      builder: (context, participants) {
        final activeParticipants = (participants ?? [])
            .where((e) => e.status == ParticipantStatus.active);
        return ParticipantsList(
          key: Key('${activeParticipants.length}'),
          event: event,
          participantIds: activeParticipants.map((e) => e.id).toList(),
          numberOfIconsToShow: numberOfParticipantsToShow,
        );
      },
    );
  }
}
