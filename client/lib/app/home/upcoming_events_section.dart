// import 'dart:math';

import 'package:flutter/material.dart';
import 'package:junto/app/self/my_discussions_page_provider.dart';
import 'package:junto/common_widgets/discussion_button.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:provider/provider.dart';

class UpcomingEventsSection extends StatefulWidget {
  const UpcomingEventsSection._();

  static Widget create() {
    return ChangeNotifierProvider(
      create: (_) => MyDiscussionsPageProvider(),
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
    context.read<MyDiscussionsPageProvider>().initialize();
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
        child: JuntoText(
          'My Upcoming Events',
          style: AppTextStyle.headline3.copyWith(fontSize: 22),
        ),
      );

  Widget _buildUpcomingEvents() {
    return JuntoStreamBuilder<List<Discussion>>(
      entryFrom: 'HomePage._buildUpcomingEvents',
      stream: Provider.of<MyDiscussionsPageProvider>(context).upcomingDiscussions,
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
            for (final discussion in events.take(eventsToShow)) ...[
              DiscussionButton(key: Key('discussion-${discussion.id}'), discussion: discussion),
              SizedBox(height: 20),
            ],
          ],
        );
      },
    );
  }
}
