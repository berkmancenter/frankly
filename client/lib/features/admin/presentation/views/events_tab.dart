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
    required bool showDetails,
  }) {
    final timeFormat = DateFormat('MMM d yyyy, h:mma');
    final timezone = getTimezoneAbbreviation(event.scheduledTime!);
    final time = timeFormat.format(event.scheduledTime ?? clockService.now());

    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProxiedImage(
          event.image,
          width: 80,
          height: 80,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                event.title ?? 'NO TITLE',
                style: context.theme.textTheme.titleLarge,
              ),
              Text(
                '$time $timezone',
                style: context.theme.textTheme.bodyMedium,
              ),
              SizedBox(height: 20,),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 100),
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
                                '${EventProvider.fromEvent(
                                  event,
                                  communityProvider:
                                      CommunityProvider.read(context),
                                ).eventParticipants.length} participants',
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
                                event.isPublic == true ? 'Public' : 'Private',
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
                      child: SizedBox.shrink(),),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );

    // Flex(
    //   direction: responsiveLayoutService.isMobile(context)
    //       ? Axis.vertical
    //       : Axis.horizontal,
    //   children: [
    // SizedBox(height: 8),
    // _buildRowEntry(
    //   width: 170,
    //   child: _buildRecordingSection(event),
    //   ),
    // ],
    // );
  }

  Widget _buildEventsList({
    required List<Event> events,
    required bool showDetails,
  }) {
    return CustomListView(
      children: [
        for (int i = 0; i < events.length; i++)
          _buildEventRow(
            index: i,
            event: events[i],
            showDetails: showDetails,
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

        return Column(
          children: [
            SizedBox(
              height: 32,
            ),
            CustomListView(
              children: [
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
            ),
          ],
        );
      },
    );
  }
}
