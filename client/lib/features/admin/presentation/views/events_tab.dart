import 'package:client/core/localization/localization_helper.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/empty_page_content.dart';
import 'package:client/core/widgets/custom_list_view.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/config/environment.dart';

import 'package:client/core/utils/firestore_utils.dart';
import 'package:client/services.dart';
import 'package:client/core/utils/platform_utils.dart';
import 'package:data_models/events/event.dart';
import 'package:universal_html/html.dart' as html;

class EventsTab extends StatefulWidget {
  @override
  _EventsTabState createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  late BehaviorSubjectWrapper<List<Event>> _allEvents;
  int _currentStartIndex = 0;

  @override
  void initState() {
    super.initState();

    _allEvents = firestoreEventService.communityEvents(
      communityId: CommunityProvider.read(context).communityId,
    );

    _currentStartIndex = 0;
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

  Widget _buildRecordingSection(Event event) {
    if (!(event.eventSettings?.alwaysRecord ?? false)) {
      return Text('');
    } else {
      return ActionButton(
        type: ActionButtonType.text,
        icon: Icon(Icons.file_download_outlined),
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
        text: context.l10n.dataDownload,
      );
    }
  }

  Widget _buildEventRow({
    required int index,
    required Event event,
  }) {
    final timeFormat = DateFormat('MMM d yyyy, h:mma');
    final timezone = getTimezoneAbbreviation(event.scheduledTime!);
    final time = timeFormat.format(event.scheduledTime ?? clockService.now());
    final participantsLabel = '${EventProvider.fromEvent(
      event,
      communityProvider: CommunityProvider.read(context),
    ).eventParticipants.length} ${event.scheduledTime!.isBefore(DateTime.now()) ? context.l10n.participants.toLowerCase() : context.l10n.registered.toLowerCase()}';

    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Row(
          // mainAxisSize: MainAxisSize.max,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProxiedImage(
              event.image,
              width: 80,
              height: 80,
            ),
            SizedBox(width: 8),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    event.title ?? 'NO TITLE',
                    style: context.theme.textTheme.titleLarge,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    '$time $timezone',
                    style: context.theme.textTheme.bodyMedium,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 100, maxWidth: 800),
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.group_outlined,
                                  ),
                                  Text(
                                    participantsLabel,
                                    style: context.theme.textTheme.labelLarge,
                                  ),
                                ],
                              ),
                              // SizedBox(width: 48),
                              Row(
                                children: [
                                  Icon(
                                    event.isPublic == true
                                        ? Icons.language_outlined
                                        : Icons.lock_outline,
                                  ),
                                  Text(
                                    event.isPublic == true
                                        ? 'Public'
                                        : 'Private',
                                    style: context.theme.textTheme.labelLarge,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    event.isLiveStream
                                        ? Icons.live_tv_outlined
                                        : event.isHosted
                                            ? Icons.waving_hand_outlined
                                            : Icons.chair_outlined,
                                  ),
                                  Text(
                                    event.isLiveStream
                                        ? 'Live'
                                        : event.isHosted
                                            ? 'Hosted'
                                            : 'Hostless',
                                    style: context.theme.textTheme.labelLarge,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
              
                ],
              ),
     
          ],
        ),
      _buildRecordingSection(event),
        ],
      ),
      Divider(),
    ],);
  }

  @override
  Widget build(BuildContext context) {
    bool showDetails = responsiveLayoutService.isMobile(context);
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

/*         var fakeEvents = List.generate(
          80,
          (i) => events[0].copyWith(
            title: 'Fake Event ${i + 1}',
            scheduledTime: clockService.now().add(Duration(days: i)),
            image: 'https://picsum.photos/200/300?random=$i',
          ),
        );
 */
        return Column(
          children: [
            SizedBox(
              height: 32,
            ),
            Expanded(
              child: Material(
                color: context.theme.colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (int i = _currentStartIndex;
                            i < _currentStartIndex + 5 && i < events.length;
                            i++)
                          _buildEventRow(
                            index: i,
                            event: events[i],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${events.length} ${context.l10n.events}',
                    style: context.theme.textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _currentStartIndex == 0
                            ? null
                            : () {
                                setState(() {
                                  _currentStartIndex -= 5;
                                });
                              },
                        icon: Icon(Icons.arrow_back_rounded),
                      ),
                      Text(
                        '${_currentStartIndex + 1} - ${events.length > 5 ? _currentStartIndex + 5 : events.length} of ${events.length}',
                        style: context.theme.textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: _currentStartIndex + 5 >= events.length
                            ? null
                            : () {
                                setState(() {
                                  _currentStartIndex += 5;
                                });
                              },
                        icon: Icon(Icons.arrow_forward_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
