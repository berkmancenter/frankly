import 'package:client/core/widgets/constrained_body.dart';
import 'package:flutter/material.dart';
import 'package:client/features/user/data/providers/my_events_page_provider.dart';
import 'package:client/features/events/presentation/widgets/event_button.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/events/event.dart';
import 'package:provider/provider.dart';
import 'package:client/core/localization/localization_helper.dart';

class EventsTab extends StatefulWidget {
  const EventsTab._();

  static Widget create() {
    return ChangeNotifierProvider(
      create: (_) => MyEventsPageProvider(),
      child: EventsTab._(),
    );
  }

  @override
  _EventsTabState createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  @override
  void initState() {
    context.read<MyEventsPageProvider>().initialize();

    super.initState();
  }

  Widget _buildEventsList(Stream<List<Event>> eventStream) {
    return CustomStreamBuilder<List<Event>>(
      entryFrom: '_EventsTabState._buildEventsList',
      stream: eventStream,
      height: 100,
      builder: (_, events) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 30),
            if (events!.isEmpty)
              Text(context.l10n.noEventsFound, style: AppTextStyle.body),
            for (final event in events.take(40)) ...[
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

  List<Widget> _buildUpcomingEvents() {
    return [
      SizedBox(height: 40),
      ConstrainedBody(
        child: Align(
          alignment: Alignment.centerLeft,
          child: HeightConstrainedText(
            'UPCOMING',
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      ),
      ConstrainedBody(
        child: _buildEventsList(
          Provider.of<MyEventsPageProvider>(context).upcomingEvents,
        ),
      ),
    ];
  }

  List<Widget> _buildPastEvents() {
    return [
      SizedBox(height: 40),
      ConstrainedBody(
        child: Align(
          alignment: Alignment.centerLeft,
          child: HeightConstrainedText(
            'HISTORY',
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      ),
      ConstrainedBody(
        child: _buildEventsList(
          Provider.of<MyEventsPageProvider>(context).previousEvents,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ..._buildUpcomingEvents(),
        ..._buildPastEvents(),
      ],
    );
  }
}
