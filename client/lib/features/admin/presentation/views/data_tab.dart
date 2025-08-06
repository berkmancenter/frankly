import 'package:client/core/localization/localization_helper.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/empty_page_content.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/config/environment.dart';

import 'package:client/core/utils/firestore_utils.dart';
import 'package:client/services.dart';
import 'package:client/core/utils/platform_utils.dart';
import 'package:data_models/events/event.dart';
import 'package:universal_html/html.dart' as html;

class DataTab extends StatefulWidget {
  const DataTab({Key? key}) : super(key: key);

  @override
  State<DataTab> createState() => _DataTabState();
}

class _DataTabState extends State<DataTab> {
  late BehaviorSubjectWrapper<List<Event>> _allEvents;
  late UserService _userService;
  int _currentStartIndex = 0;

  @override
  void initState() {
    super.initState();

    _allEvents = firestoreEventService.communityEvents(
      communityId: CommunityProvider.read(context).communityId,
    );
    _userService = UserService();

    _currentStartIndex = 0;
  }

  @override
  void dispose() {
    _allEvents.dispose();
    super.dispose();
  }

  Future<void> downloadRegistrantList(Event event, Iterable<Participant> participants) async {
    final communityProvider = CommunityProvider.read(context);

    final List<String> userIds = participants.map((p) => p.id).toList();
    final members = await _userService.getMemberDetails(
      membersList: userIds,
      communityId: communityProvider.communityId,
      eventPath: event.fullPath,
    );

    EventProvider provider = EventProvider.fromEvent(
      event,
      communityProvider: communityProvider,
    );

    provider.initialize();
    await provider.generateRegistrationDataCsvFile(
      eventId: event.id,
      registrationData: members,
    );  }

  void pressedHandler({
    required BuildContext context,
    required Event event,
    required Iterable<Participant> participants,
    required bool eventInPast,
    required bool registrantListSelected,
    required bool recordingSelected,
  }) async {
    // If the event is in the past, download the recording
    if (recordingSelected) {
      await alertOnError(
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
      );
      // return;
    }

    // If the selected data includes 'registrantList', download the registration data
    if (registrantListSelected) {
      await alertOnError(
        context,
        () async {
          await downloadRegistrantList(event, participants);
        },
      );
    }
  }

  Widget _buildDowloadButton(
    Event event,
    Iterable<Participant> participants,
    bool eventInPast,
  ) {
    Future<void> openAlert() {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          bool recordingSelected = true;
          bool registrantListSelected = true;
          return AlertDialog(
            title: const Text('Select Data to Download'),
            surfaceTintColor: context.theme.colorScheme.surface,
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      CheckboxListTile(
                        title: Text('Registrant List'),
                        checkColor: Colors.white,
                        fillColor:
                            WidgetStatePropertyAll(context.theme.primaryColor),
                        value: registrantListSelected,
                        onChanged: (value) {
                          setState(() {
                            registrantListSelected = !registrantListSelected;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: Text('Recording'),
                        checkColor: Colors.white,
                        fillColor:
                            WidgetStatePropertyAll(context.theme.primaryColor),
                        value: recordingSelected,
                        onChanged: (value) {
                          setState(() {
                            recordingSelected = value!;
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            actions: <Widget>[
              ActionButton(
                type: ActionButtonType.text,
                text: context.l10n.cancel,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ActionButton(
                type: ActionButtonType.filled,
                text: context.l10n.dataDownload,
                onPressed: () => pressedHandler(
                    context: context,
                    event: event,
                    participants: participants,
                    eventInPast: eventInPast,
                    registrantListSelected: registrantListSelected,
                    recordingSelected: recordingSelected,),
              ),
            ],
          );
        },
      );
    }

    // If the event is in the past and not set to always record, or in future and there are no registrants, do not show the download button
    if (eventInPast && !(event.eventSettings?.alwaysRecord ?? false) ||
        (!eventInPast && participants.isEmpty)) {
      return Text('');
    }

    return ActionButton(
      type: ActionButtonType.text,
      icon: Icon(Icons.file_download_outlined),
      loadingHeight: 16,
      borderSide: BorderSide(color: Theme.of(context).primaryColor),
      textColor: Theme.of(context).primaryColor,
      onPressed: () => !eventInPast ? downloadRegistrantList(event, participants) : openAlert(),
      text: eventInPast
          ? context.l10n.dataDownload
          : context.l10n.registrationDataDownload,
    );
  }

  Future<Iterable<Participant>> _getEventParticipants(Event event) async {
    final participantsWrapper = firestoreEventService.eventParticipantsStream(
      communityId: event.communityId,
      templateId: event.templateId,
      eventId: event.id,
    );
    final participants = await participantsWrapper.stream
        .map((s) => s.where((p) => p.status == ParticipantStatus.active))
        .first;
    await participantsWrapper.dispose();
    return participants;
  }

  Future<Widget> _buildEventRow({
    required int index,
    required Event event,
    required bool isMobile,
  }) async {
    final timeFormat = DateFormat('MMM d yyyy, h:mma');
    final timezone = getTimezoneAbbreviation(event.scheduledTime!);
    final time = timeFormat.format(event.scheduledTime ?? clockService.now());
    final eventInPast = event.scheduledTime!.isBefore(DateTime.now());
    final participants = await _getEventParticipants(event);

    if (!context.mounted) return SizedBox.shrink();

    // Determine to show participants or those registered based on the event time
    final participantsLabel =
        '${participants.length} ${eventInPast ? (participants.length == 1 ? context.l10n.participant : context.l10n.participants) : context.l10n.registered}';
    // This widget builds a row for each event, displaying its details;
    // it is used in differerent parts of the layout depending on the device type.
    // It includes the event's participants, public/private status, and type.
    final detailsWidget = Row(
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
              event.isPublic == true ? 'Public' : 'Private',
              style: context.theme.textTheme.labelLarge,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              event.isLiveStream
                  ? Icons.live_tv_outlined
                  : event.isHosted
                      ? Icons.chair_outlined
                      : Icons.deck_outlined,
            ),
            SizedBox(width: 4),
            Text(
              event.isLiveStream
                  ? 'Livestream'
                  : event.isHosted
                      ? 'Hosted'
                      : 'Hostless',
              style: context.theme.textTheme.labelLarge,
            ),
          ],
        ),
      ],
    );

    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        InkWell(
          onTap: () {
            routerDelegate.beamTo(
              CommunityPageRoutes(
                communityDisplayId:
                    CommunityProvider.readOrNull(context)?.displayId ??
                        event.communityId,
              ).eventPage(
                templateId: event.templateId,
                eventId: event.id,
              ),
            );
          },
          child: Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                      if (!isMobile) ...[
                        ConstrainedBox(
                          constraints:
                              BoxConstraints(maxHeight: 100, maxWidth: 400),
                          child: detailsWidget,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              if (isMobile) ...[
                SizedBox(
                  height: 10,
                ),
                detailsWidget,
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: _buildDowloadButton(event, participants, eventInPast),
                ),
              ] else ...[
                _buildDowloadButton(event, participants, eventInPast),
              ],
            ],
          ),
        ),
        Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = responsiveLayoutService.isMobile(context);
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
                          FutureBuilder<Widget>(
                            future: _buildEventRow(
                              index: i,
                              event: events[i],
                              isMobile: isMobile,
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return snapshot.data!;
                              }
                              if (snapshot.hasError) {
                                return Text(
                                  context.l10n.errorOccurred,
                                  style: context.theme.textTheme.bodyLarge,
                                );
                              }
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: const [
                                  CircularProgressIndicator(),
                                ],
                              );
                            },
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
      errorBuilder: (context) => SizedBox(
        height: 100,
        child: Text(
          context.l10n.errorLoadingEvents,
          style: context.theme.textTheme.bodyLarge,
        ),
      ),
    );
  }
}
