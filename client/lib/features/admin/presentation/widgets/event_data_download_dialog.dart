import 'dart:async';
import 'dart:convert';

import 'package:client/core/localization/localization_helper.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/utils/toast_utils.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/event_page/presentation/widgets/event_info.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/styles/styles.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:data_models/user_input/chat_suggestion_data.dart';
import 'package:data_models/user_input/poll_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/config/environment.dart';
import 'package:client/services.dart';
import 'package:data_models/events/event.dart';

class EventDataDownloadDialog extends StatefulWidget {
  const EventDataDownloadDialog({
    Key? key,
    required this.event,
    required this.participants,
    required this.hasRecording,
    required this.recordingParts,
    required this.recordingNotifier,
    required this.eventInPast,
  }) : super(key: key);

  final Event event;
  final Iterable<Participant> participants;
  final bool hasRecording;
  final Map<String, int?> recordingParts;
  final ValueNotifier<int?>? recordingNotifier;
  final bool eventInPast;

  @override
  State<EventDataDownloadDialog> createState() =>
      _EventDataDownloadDialogState();
}

class _EventDataDownloadDialogState extends State<EventDataDownloadDialog> {
  late bool showRecording;
  late bool showRegistrant;

  late bool recordingSelected;
  late bool registrantListSelected;
  bool chatDataSelected = false;
  bool pollsSuggestionsDataSelected = false;

  bool recordingAutoChecked = false;

  late UserService _userService;

  // We already load participants and recordings for all events at the top level.
  // For performance reasons, we only check for other event data once the dialog is opened.
  bool isLoadingChats = true;
  List<ChatSuggestionData> chatData = [];

  bool isLoadingPollsSuggestions = true;
  List<ChatSuggestionData> suggestionData = [];
  List<PollData> pollData = [];

  Future<void> downloadAllRecordings(Event event) async {
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
      setState(() => widget.recordingParts[event.id] = urls.length);
      widget.recordingNotifier?.value = urls.length;
    });
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
    List<BreakoutRoom> breakoutRooms = await getBreakoutRoomData(event: event);

    await provider.generateRegistrationDataCsvFile(
      eventId: event.id,
      registrationData: members,
      breakoutRooms: breakoutRooms,
    );
  }

  Future<void> downloadChatData(Event event) async {
    // Get CommunityProvider from context before async operations.
    final communityProvider = CommunityProvider.read(context);

    // If empty, fall back to retrying the cloud fetch.
    if (chatData.isEmpty) {
      try {
        final chatSuggestionRequest = GetMeetingChatsSuggestionsDataRequest(
          eventPath: widget.event.fullPath,
        );
        final chatSuggestionResponse = await cloudFunctions.callFunction(
          'GetMeetingChatSuggestionData',
          chatSuggestionRequest.toJson(),
        );
        final chatSuggestionResult =
            GetMeetingChatsSuggestionsDataResponse.fromJson(
          chatSuggestionResponse,
        );

        chatData = chatSuggestionResult.chatsSuggestionsList
                ?.where((e) => e.type == ChatSuggestionType.chat)
                .toList() ??
            [];
      } catch (e) {
        // If there's an error loading data, assume no data available
        chatData = [];
      }
    }

    final breakoutRooms = await getBreakoutRoomData(event: event);
    EventProvider provider = EventProvider.fromEvent(
      event,
      communityProvider: communityProvider,
    );
    provider.initialize();

    // Reconstruct the response format for the CSV generator
    final response = GetMeetingChatsSuggestionsDataResponse(
      chatsSuggestionsList: chatData,
    );

    await provider.generateChatDataCsv(
      response: response,
      eventId: event.id,
      breakoutRooms: breakoutRooms,
    );
  }

  Future<void> downloadPollsSuggestionsData(Event event) async {
    final communityProvider = CommunityProvider.read(context);

    suggestionData = suggestionData;
    pollData = pollData;

    // If empty, fall back to retrying the cloud fetch.
    if (suggestionData.isEmpty || pollData.isEmpty) {
      try {
        final chatSuggestionRequest = GetMeetingChatsSuggestionsDataRequest(
          eventPath: widget.event.fullPath,
        );
        final chatSuggestionResponse = await cloudFunctions.callFunction(
          'GetMeetingChatSuggestionData',
          chatSuggestionRequest.toJson(),
        );
        final chatSuggestionResult =
            GetMeetingChatsSuggestionsDataResponse.fromJson(
          chatSuggestionResponse,
        );

        suggestionData = chatSuggestionResult.chatsSuggestionsList
                ?.where((e) => e.type == ChatSuggestionType.suggestion)
                .toList() ??
            [];

        final pollRequest =
            GetMeetingPollDataRequest(eventPath: widget.event.fullPath);
        final pollResponse = await cloudFunctions.callFunction(
          'GetMeetingPollData',
          pollRequest.toJson(),
        );
        final pollResult = GetMeetingPollDataResponse.fromJson(pollResponse);
        pollData = pollResult.polls ?? [];
      } catch (e) {
        // If there's an error loading data, assume no data available
        suggestionData = [];
        pollData = [];
      }
    }

    if (suggestionData.isEmpty && pollData.isEmpty) {
      if (mounted) {
        showRegularToast(
          context,
          'No polls or suggestions data',
          toastType: ToastType.neutral,
        );
      }
      return;
    }

    final breakoutRooms = await getBreakoutRoomData(event: event);
    EventProvider provider = EventProvider.fromEvent(
      event,
      communityProvider: communityProvider,
    );
    provider.initialize();
    await provider.generatePollsSuggestionsDataCsv(
      suggestionData: suggestionData,
      pollData: pollData,
      eventId: event.id,
      breakoutRooms: breakoutRooms,
    );
  }

  String _recordingAnnotation(BuildContext context, int? parts) {
    if (parts == null) return ' ${context.l10n.recordingStatusChecking}';
    if (parts == 0) return ' ${context.l10n.recordingStatusPreparing}';
    if (parts == -1) return ' ${context.l10n.recordingStatusFailed}';
    return ' ${context.l10n.recordingStatusParts(parts)}';
  }

  Future<void> _handleDownload() async {
    try {
      if (showRecording && recordingSelected) {
        await downloadAllRecordings(widget.event);
      }
      if (showRegistrant && registrantListSelected) {
        await downloadRegistrantList(widget.event, widget.participants);
      }
      if (chatDataSelected) {
        await downloadChatData(widget.event);
      }
      if (pollsSuggestionsDataSelected) {
        await downloadPollsSuggestionsData(widget.event);
      }
    } catch (e) {
      if (mounted) {
        showRegularToast(
          context,
          'Error: ${e.toString()}',
          toastType: ToastType.failed,
        );
      }
    }
    if (mounted) Navigator.of(context).pop();
  }

  bool _isDownloadEnabled(int? recordingParts) {
    final recordingReady = showRecording && (recordingParts ?? 0) > 0;
    return (showRecording && recordingSelected && recordingReady) ||
        (showRegistrant && registrantListSelected) ||
        chatDataSelected ||
        pollsSuggestionsDataSelected;
  }

  @override
  void initState() {
    super.initState();
    final recordingParts = widget.recordingNotifier?.value ?? 0;
    showRecording = widget.eventInPast && widget.hasRecording;
    showRegistrant = widget.participants.isNotEmpty;
    recordingSelected = showRecording && recordingParts > 0;
    recordingAutoChecked = recordingSelected;
    registrantListSelected = showRegistrant;

    _userService = UserService();

    // Load chat and polls/suggestions data to check availability
    _loadEventData();
  }

  Future<void> _loadEventData() async {
    try {
      // Load chat and suggestions data
      final chatSuggestionRequest = GetMeetingChatsSuggestionsDataRequest(
        eventPath: widget.event.fullPath,
      );
      final chatSuggestionResponse = await cloudFunctions.callFunction(
        'GetMeetingChatSuggestionData',
        chatSuggestionRequest.toJson(),
      );
      final chatSuggestionResult =
          GetMeetingChatsSuggestionsDataResponse.fromJson(
        chatSuggestionResponse,
      );

      chatData = chatSuggestionResult.chatsSuggestionsList
              ?.where((e) => e.type == ChatSuggestionType.chat)
              .toList() ??
          [];

      suggestionData = chatSuggestionResult.chatsSuggestionsList
              ?.where((e) => e.type == ChatSuggestionType.suggestion)
              .toList() ??
          [];

      if (mounted) {
        setState(() {
          isLoadingChats = false;
        });
      }

      // Load polls data
      final pollRequest =
          GetMeetingPollDataRequest(eventPath: widget.event.fullPath);
      final pollResponse = await cloudFunctions.callFunction(
        'GetMeetingPollData',
        pollRequest.toJson(),
      );
      final pollResult = GetMeetingPollDataResponse.fromJson(pollResponse);
      pollData = pollResult.polls ?? [];

      if (mounted) {
        setState(() {
          isLoadingPollsSuggestions = false;
        });
      }
    } catch (e) {
      // If there's an error loading data, assume no data available
      if (mounted) {
        setState(() {
          isLoadingChats = false;
          isLoadingPollsSuggestions = false;
          chatData = [];
          suggestionData = [];
          pollData = [];
        });
      }
    }
  }

  Widget _buildDialogContent(int? recordingParts) {
    final chatsLength = chatData.length;
    final pollsSuggestionsLength = suggestionData.length + pollData.length;

    return AlertDialog(
      title: Text(context.l10n.selectData),
      backgroundColor: context.theme.colorScheme.surfaceContainerHighest,
      contentPadding: EdgeInsets.zero,
      actionsPadding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      content: Material(
        color: context.theme.colorScheme.surfaceContainer,
        child: SingleChildScrollView(
          child: ListBody(
            children: [
              if (showRecording)
                CheckboxListTile(
                  value: recordingSelected,
                  enabled: recordingParts != null && recordingParts != 0,
                  onChanged: (value) => setState(
                    () => recordingSelected = value ?? false,
                  ),
                  title: Text(
                    '${context.l10n.recording}${_recordingAnnotation(context, recordingParts)}',
                  ),
                ),
              if (showRegistrant)
                CheckboxListTile(
                  value: registrantListSelected,
                  onChanged: (value) => setState(
                    () => registrantListSelected = value ?? false,
                  ),
                  title: Text(context.l10n.registrationDataDownload),
                ),
              CheckboxListTile(
                value: chatDataSelected,
                onChanged: (value) => setState(
                  () => chatDataSelected = value ?? false,
                ),
                // TODO: L10n
                title: Text(
                  'Chat Data ${isLoadingChats ? '(Loading...)' : '(${chatsLength < 0 ? '$chatsLength items)' : 'none'})'}',
                ),
              ),
              CheckboxListTile(
                value: pollsSuggestionsDataSelected,
                onChanged: (value) => setState(
                  () => pollsSuggestionsDataSelected = value ?? false,
                ),
                // TODO: L10n
                title: Text(
                  'Polls & Suggestions Data ${isLoadingPollsSuggestions ? '(Loading...)' : '(${pollsSuggestionsLength < 0 ? '$pollsSuggestionsLength items)' : 'none'})'}',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed:
              _isDownloadEnabled(recordingParts) ? _handleDownload : null,
          child: Text(context.l10n.download),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (showRecording) {
      final notifier = widget.recordingNotifier ??
          ValueNotifier(widget.recordingParts[widget.event.id]);
      return ValueListenableBuilder<int?>(
        valueListenable: notifier,
        builder: (context, recordingParts, _) {
          // Auto-check recording when it becomes ready
          if ((recordingParts ?? 0) > 0 && !recordingAutoChecked) {
            recordingAutoChecked = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => recordingSelected = true);
              }
            });
          }
          return _buildDialogContent(recordingParts);
        },
      );
    }
    return _buildDialogContent(null);
  }
}
