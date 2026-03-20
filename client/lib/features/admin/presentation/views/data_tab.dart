import 'dart:async';
import 'dart:convert';
import 'dart:math';

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

  // Recording status per event: null=loading, 0=preparing, N=N parts ready, -1=error.
  final Map<String, int?> _recordingParts = {};
  final Map<String, Timer> _pollingTimers = {};
  final Map<String, int> _retryCount = {};

  // After this many auto-retries (~3 minutes at 5s intervals), stop polling
  // and show the error/manual-retry state instead.
  static const int _maxAutoRetries = 36;
  late StreamSubscription<List<Event>> _eventsSubscription;

  @override
  void initState() {
    super.initState();

    _allEvents = firestoreEventService.communityEvents(
      communityId: CommunityProvider.read(context).communityId,
    );
    _eventsSubscription = _allEvents.stream.listen((events) {
      if (!mounted) return;
      for (final event in events) {
        final isPast = event.scheduledTime?.isBefore(DateTime.now()) ?? false;
        if (isPast && (event.eventSettings?.alwaysRecord ?? false)) {
          _maybeStartRecordingCheck(event);
        }
      }
    });
    _userService = UserService();

    _currentStartIndex = 0;
  }

  @override
  void dispose() {
    for (final timer in _pollingTimers.values) {
      timer.cancel();
    }
    _eventsSubscription.cancel();
    _allEvents.dispose();
    super.dispose();
  }

  Future<void> downloadRegistrantList(
    Event event,
    Iterable<Participant> participants,
  ) async {
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
    );
  }

  Widget _buildDownloadButton(
    Event event,
    Iterable<Participant> participants,
    bool eventInPast,
    bool hasRecording,
  ) {
    // Past event without a recording, or upcoming event with no registrants: hide.
    if ((eventInPast && !hasRecording) ||
        (!eventInPast && participants.isEmpty)) {
      return const SizedBox.shrink();
    }

    // Download registrant list directly. Recordings are handled by the
    // inline _buildRecordingWidget shown alongside this button.
    return ActionButton(
      type: ActionButtonType.text,
      icon: const Icon(Icons.file_download_outlined),
      loadingHeight: 16,
      borderSide: BorderSide(color: Theme.of(context).primaryColor),
      textColor: Theme.of(context).primaryColor,
      onPressed: () => downloadRegistrantList(event, participants),
      text: context.l10n.dataDownload,
    );
  }

  // --- Recording status and download ---

  void _maybeStartRecordingCheck(Event event) {
    if (_recordingParts.containsKey(event.id)) return;
    _recordingParts[event.id] = null; // null = loading
    _fetchRecordingCount(event);
  }

  void _retryRecordingCheck(Event event) {
    setState(() {
      _recordingParts.remove(event.id);
      _retryCount.remove(event.id);
    });
    _maybeStartRecordingCheck(event);
  }

  Future<void> _fetchRecordingCount(Event event) async {
    try {
      final idToken = await userService.firebaseAuth.currentUser?.getIdToken();
      if (idToken == null) {
        if (mounted) _scheduleRetry(event);
        return;
      }
      final response = await http.post(
        Uri.parse('${Environment.functionsUrlPrefix}/downloadRecording'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'eventPath': event.fullPath}),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final count = (body['recordings'] as List?)?.length ?? 0;
        setState(() => _recordingParts[event.id] = count);
        if (count == 0) _scheduleRetry(event);
      } else {
        // Non-200 means a function error, not "recordings not ready".
        // Stop polling and show an error state (-1) to avoid infinite retry.
        setState(() => _recordingParts[event.id] = -1);
      }
    } catch (_) {
      if (mounted) setState(() => _recordingParts[event.id] = -1);
    }
  }

  void _scheduleRetry(Event event) {
    final retries = (_retryCount[event.id] ?? 0) + 1;
    if (retries >= _maxAutoRetries) {
      setState(() => _recordingParts[event.id] = -1);
      return;
    }
    _retryCount[event.id] = retries;
    _pollingTimers[event.id]?.cancel();
    _pollingTimers[event.id] = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() => _recordingParts[event.id] = null);
      _fetchRecordingCount(event);
    });
  }

  Future<void> _downloadAllRecordings(Event event) async {
    final errorMsg = context.l10n.errorOccurred;
    final preparingMsg = context.l10n.recordingPreparing;
    await alertOnError(context, () async {
      final idToken = await userService.firebaseAuth.currentUser?.getIdToken();
      if (idToken == null) throw Exception(errorMsg);
      final response = await http.post(
        Uri.parse('${Environment.functionsUrlPrefix}/downloadRecording'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'eventPath': event.fullPath}),
      );
      if (response.statusCode != 200) {
        throw Exception(errorMsg);
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final rawList = body['recordings'];
      if (rawList is! List || rawList.isEmpty) {
        throw Exception(preparingMsg);
      }
      final urls = rawList
          .whereType<Map<String, dynamic>>()
          .map((r) => r['url'] as String? ?? '')
          .where((url) => url.isNotEmpty)
          .toList();
      for (int i = 0; i < urls.length; i++) {
        final anchor = html.AnchorElement(href: urls[i])..target = '_blank';
        html.document.body!.append(anchor);
        anchor.click();
        anchor.remove();
        if (i < urls.length - 1) {
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }
      setState(() => _recordingParts[event.id] = urls.length);
    });
  }

  Widget _buildRecordingWidget(Event event) {
    final parts = _recordingParts[event.id];

    if (!_recordingParts.containsKey(event.id) || parts == null || parts == 0) {
      return ActionButton(
        type: ActionButtonType.outline,
        loadingHeight: 16,
        onPressed: null,
        text: context.l10n.recordingPreparing,
      );
    }

    if (parts == -1) {
      return ActionButton(
        type: ActionButtonType.outline,
        loadingHeight: 16,
        onPressed: () => _retryRecordingCheck(event),
        text: context.l10n.retryRecording,
      );
    }

    return ActionButton(
      type: ActionButtonType.outline,
      loadingHeight: 16,
      onPressed: () => _downloadAllRecordings(event),
      text: context.l10n.downloadRecordingParts(parts),
    );
  }

  // --- Event list building ---

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

    final l10n = context.l10n;
    final labelLargeStyle = context.theme.textTheme.labelLarge;
    final titleLargeStyle = context.theme.textTheme.titleLarge;
    final bodyMediumStyle = context.theme.textTheme.bodyMedium;

    final participants = await _getEventParticipants(event);

    final eventInPast = event.scheduledTime!.isBefore(DateTime.now());
    final hasRecording = event.eventSettings?.alwaysRecord! ?? false;

    if (!context.mounted) return SizedBox.shrink();

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
              '${participants.length} ${l10n.registered}',
              style: labelLargeStyle,
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
              style: labelLargeStyle,
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
              style: labelLargeStyle,
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
          hoverColor: Colors.transparent,
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
                        style: titleLargeStyle,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        '$time $timezone',
                        style: bodyMediumStyle,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDownloadButton(
                        event,
                        participants,
                        eventInPast,
                        hasRecording,
                      ),
                      if (eventInPast && hasRecording) ...[
                        const SizedBox(height: 8),
                        _buildRecordingWidget(event),
                      ],
                    ],
                  ),
                ),
              ] else ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDownloadButton(
                      event,
                      participants,
                      eventInPast,
                      hasRecording,
                    ),
                    if (eventInPast && hasRecording) ...[
                      const SizedBox(height: 8),
                      _buildRecordingWidget(event),
                    ],
                  ],
                ),
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
                        FutureBuilder<List<Widget>>(
                          future: Future.wait([
                            // Build the event rows
                            for (int i = _currentStartIndex;
                                i < _currentStartIndex + 5 && i < events.length;
                                i++)
                              _buildEventRow(
                                index: i,
                                event: events[i],
                                isMobile: isMobile,
                              ),
                          ]),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Column(children: snapshot.data!);
                            }
                            if (snapshot.hasError) {
                              return Text(
                                context.l10n.errorOccurred,
                                style: context.theme.textTheme.bodyLarge,
                              );
                            }
                            return Center(
                              child: CircularProgressIndicator(),
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
                        '${_currentStartIndex + 1} - ${events.length > 5 ? min(_currentStartIndex + 5, events.length) : events.length} of ${events.length}',
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
