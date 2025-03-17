import 'package:client/core/utils/error_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:client/features/admin/presentation/views/members_tab.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/empty_page_content.dart';
import 'package:client/core/widgets/custom_list_view.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/config/environment.dart';
import 'package:client/core/routing/locations.dart';

import 'package:client/core/utils/firestore_utils.dart';
import 'package:client/services.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/core/utils/platform_utils.dart';
import 'package:data_models/events/event.dart';
import 'package:universal_html/html.dart' as html;

class EventsTab extends StatefulWidget {
  @override
  _EventsTabState createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  late BehaviorSubjectWrapper<List<Event>> _allEvents;

  var _numToShow = 10;

  @override
  void initState() {
    super.initState();

    _allEvents = firestoreEventService.communityEvents(
      communityId: CommunityProvider.read(context).communityId,
    );
  }

  @override
  void dispose() {
    _allEvents.dispose();
    super.dispose();
  }

  Widget _buildRowEntry({double? width, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      width: width,
      child: child,
    );
  }

  Widget _buildEventHeaders({required bool showDetails}) {
    return Row(
      children: [
        _buildRowEntry(
          width: 200,
          child: Text(
            'Date',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        _buildRowEntry(
          width: 320,
          child: Text(
            'Title',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        if (showDetails)
          _buildRowEntry(
            width: 70,
            child: Text(
              'Visibility',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        if (showDetails)
          _buildRowEntry(
            width: 80,
            child: Text(
              'Live?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        if (showDetails)
          _buildRowEntry(
            width: 100,
            child: Text(
              'Num Participants',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        _buildRowEntry(
          width: 170,
          child: Text(
            'Recordings',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingSection(Event event) {
    if (!(event.eventSettings?.alwaysRecord ?? false)) {
      return Text('');
    } else {
      return ActionButton(
        type: ActionButtonType.outline,
        loadingHeight: 16,
        borderSide: BorderSide(color: Theme.of(context).primaryColor),
        textColor: Theme.of(context).primaryColor,
        onPressed: () => alertOnError(
          context,
          () async {
            final idToken =
                await userService.firebaseAuth.currentUser?.getIdToken();

            var downloadTriggerUrl =
                '${Environment.functionsUrlPrefix}/downloadRecording';

            final response = await http.post(
              Uri.parse(downloadTriggerUrl),
              headers: {'Authorization': 'Bearer $idToken'},
              body: {
                'eventPath': event.fullPath,
              },
            );

            final content = response.bodyBytes;

            final blob = html.Blob([content]);

            final blobUrl = html.Url.createObjectUrlFromBlob(blob);

            final anchor = html.AnchorElement(href: blobUrl)
              ..setAttribute('download', 'recording.zip');
            anchor.click();

            html.Url.revokeObjectUrl(blobUrl);
          },
        ),
        sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.right,
        text: 'Download',
      );
    }
  }

  Widget _buildEventRow({
    required int index,
    required Event event,
    required bool showDetails,
  }) {
    final timeFormat = DateFormat('MMM d yyyy, h:mma');
    final timezone = getTimezoneAbbreviation(event.scheduledTime!);
    final time = timeFormat.format(event.scheduledTime ?? clockService.now());

    return Container(
      color: index.isEven ? blueBackground : Colors.white70,
      child: Row(
        children: [
          _buildRowEntry(
            width: 200,
            child: GestureDetector(
              onTap: () => routerDelegate.beamTo(
                CommunityPageRoutes(
                  communityDisplayId: CommunityProvider.read(context).displayId,
                ).eventPage(
                  templateId: event.templateId,
                  eventId: event.id,
                ),
              ),
              child: HeightConstrainedText(
                '$time $timezone',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          _buildRowEntry(
            width: 320,
            child: HeightConstrainedText(event.title ?? event.id),
          ),
          if (showDetails)
            _buildRowEntry(
              width: 70,
              child: HeightConstrainedText(
                event.isPublic == true ? 'Public' : 'Private',
              ),
            ),
          _buildRowEntry(
            width: 170,
            child: _buildRecordingSection(event),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList({
    required List<Event> events,
    required bool showDetails,
  }) {
    return CustomListView(
      children: [
        for (int i = 0; i < events.length; i++)
          FittedBox(
            fit: BoxFit.fitWidth,
            child: _buildEventRow(
              index: i,
              event: events[i],
              showDetails: showDetails,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool showDetails = !responsiveLayoutService.isMobile(context);
    return CustomStreamBuilder<List<Event>>(
      stream: _allEvents.stream,
      entryFrom: '_EventsTabState.build',
      builder: (_, events) {
        if (events == null || events.isEmpty) {
          return EmptyPageContent(
            type: EmptyPageType.events,
            showContainer: false,
          );
        }

        return CustomListView(
          children: [
            FittedBox(
              fit: BoxFit.fitWidth,
              child: _buildEventHeaders(showDetails: showDetails),
            ),
            _buildEventsList(
              events: events.take(_numToShow).toList(),
              showDetails: showDetails,
            ),
            if (_numToShow < events.length)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                alignment: Alignment.center,
                child: ActionButton(
                  onPressed: () => setState(() => _numToShow += 10),
                  text: 'View more',
                ),
              ),
          ],
        );
      },
    );
  }
}
