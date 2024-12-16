// import 'dart:math';

import 'package:flutter/material.dart';
import 'package:client/app/self/my_events_page_provider.dart';
import 'package:client/common_widgets/event_button.dart';
import 'package:client/common_widgets/custom_stream_builder.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/utils/height_constained_text.dart';
import 'package:data_models/firestore/event.dart';
import 'package:provider/provider.dart';

class UpcomingEventsSection extends StatefulWidget {
  const UpcomingEventsSection._();

  static Widget create() {
    return ChangeNotifierProvider(
      create: (_) => MyEventsPageProvider(),
      child: UpcomingEventsSection._(),
    );
  }

  @override
  State<UpcomingEventsSection> createState() => _UpcomingEventsSectionState();
}

class _UpcomingEventsSectionState extends State<UpcomingEventsSection> {
  final eventsToShow = 20;

  @override
  void initState() {
    context.read<MyEventsPageProvider>().initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTitle(),
        SizedBox(height: 20),
        _buildUpcomingEvents(),
        SizedBox(height: 48),
      ],
    );
  }

  Widget _buildTitle() => Align(
        alignment: Alignment.centerLeft,
        child: HeightConstrainedText(
          'My Upcoming Events',
          style: AppTextStyle.headline3.copyWith(fontSize: 22),
        ),
      );

  Widget _buildUpcomingEvents() {
    return CustomStreamBuilder<List<Event>>(
      entryFrom: 'HomePage._buildUpcomingEvents',
      stream: Provider.of<MyEventsPageProvider>(context).upcomingEvents,
      height: 100,
      builder: (_, events) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (events!.isEmpty)
              Text(
                "You haven't registered for any upcoming events.",
                style: AppTextStyle.body,
              ),
            for (final event in events.take(eventsToShow)) ...[
              EventButton(
                key: Key('event-${event.id}'),
                event: event,
              ),
              SizedBox(height: 20),
            ],
          ],
        );
      },
    );
  }
}
