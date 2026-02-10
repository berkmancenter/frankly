import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:client/core/utils/date_utils.dart';
import 'package:client/core/utils/provider_utils.dart';
import 'package:collection/collection.dart';
import 'package:csv/csv.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/widgets/confirm_dialog.dart';
import 'package:client/core/utils/firestore_utils.dart';
import 'package:client/services.dart';
import 'package:client/core/utils/extensions.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/user_input/chat_suggestion_data.dart';
import 'package:data_models/user_input/poll_data.dart';
import 'package:data_models/community/member_details.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:data_models/templates/template.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:universal_html/html.dart';

class EventProvider with ChangeNotifier {
  final CommunityProvider communityProvider;
  final String templateId;
  final String eventId;

  EventProvider({
    required this.communityProvider,
    required this.templateId,
    required this.eventId,
  });

  factory EventProvider.fromDocumentPath(
    String documentPath, {
    required CommunityProvider communityProvider,
  }) {
    final eventMatch =
        RegExp('/?community/([^/]+)/templates/([^/]+)/events/([^/]+)')
            .matchAsPrefix(documentPath);
    final templateId = eventMatch!.group(2)!;
    final eventId = eventMatch.group(3)!;

    return EventProvider(
      communityProvider: communityProvider,
      templateId: templateId,
      eventId: eventId,
    );
  }

  factory EventProvider.fromEvent(
    Event event, {
    required CommunityProvider communityProvider,
  }) {
    return EventProvider(
      communityProvider: communityProvider,
      templateId: event.templateId,
      eventId: event.id,
    );
  }

  late BehaviorSubjectWrapper<List<Event>> _upcomingEvents;

  late BehaviorSubject<List<Template>> _templatesStream;
  late BehaviorSubjectWrapper<Event> _eventStream;
  BehaviorSubjectWrapper<Participant>? _selfParticipantStream;
  BehaviorSubjectWrapper<List<Participant>>? _eventParticipantsStream;

  late StreamSubscription _templateStreamSubscription;
  late BehaviorSubject<Template?> _templateStream;

  late StreamSubscription _eventStreamSubscription;
  StreamSubscription? _selfParticipantStreamSubscription;
  StreamSubscription? _eventParticipantsStreamSubscription;
  late StreamSubscription _userServiceChangesSubscription;

  Future<PrivateLiveStreamInfo?>? _privateLiveStreamInfo;

  late Future<bool> _hasParticipantAttendedPrerequisiteFuture;

  bool _hasAttendedPrerequisite = false;

  BreakoutRoomDefinition get defaultBreakoutRoomDefinition =>
      BreakoutRoomDefinition(
        creatorId: userService.currentUserId,
        targetParticipants: 8,
        breakoutQuestions: [],
        assignmentMethod: BreakoutAssignmentMethod.targetPerRoom,
      );

  String get communityId => communityProvider.communityId;

  Stream<List<Event>> get upcomingEventsStream => _upcomingEvents.stream;

  List<Event> get upcomingEvents => _upcomingEvents.stream.value
      .where((d) => d.id != eventId)
      .take(2)
      .toList();

  Stream<List<Template>> get templatesStream => _templatesStream;

  Stream<Event> get eventStream => _eventStream.stream;

  Stream<List<Participant>>? get eventParticipantsStream =>
      _eventParticipantsStream?.stream;

  Stream<Participant>? get selfParticipantStream =>
      _selfParticipantStream?.stream;

  Future<PrivateLiveStreamInfo?> get privateLiveStreamInfo =>
      _privateLiveStreamInfo ??=
          firestoreEventService.liveStreamPrivateInfo(event: event);

  Event get event {
    final eventValue = _eventStream.stream.valueOrNull;
    if (eventValue == null) {
      throw Exception('Event must be loaded before being accessed.');
    }

    return eventValue;
  }

  Template? get template => _templateStream.valueOrNull;

  Participant? get selfParticipant =>
      _selfParticipantStream?.stream.valueOrNull;

  List<Participant> get eventParticipants =>
      _eventParticipantsStream?.stream.valueOrNull
          ?.where((p) => p.status == ParticipantStatus.active)
          .toList() ??
      [];

  bool get isParticipant =>
      _selfParticipantStream?.stream.valueOrNull?.status ==
      ParticipantStatus.active;

  bool get isBanned =>
      _selfParticipantStream?.stream.valueOrNull?.status ==
      ParticipantStatus.banned;

  bool get isLiveStream => event.isLiveStream;

  bool get hasAttendedPrerequisite => _hasAttendedPrerequisite;

  final List<Participant> _fakeLiveStreamParticipantsList = [
    for (var i = 0; i < 10; i++) Participant(id: i.toString()),
  ];

  List<Participant> get fakeLiveStreamParticipantsList =>
      _fakeLiveStreamParticipantsList;

  Future<bool> get hasParticipantAttendedPrerequisiteFuture =>
      _hasParticipantAttendedPrerequisiteFuture;

  bool get showSmartMatchingForBreakouts =>
      (_settingsValue((settings) => settings.showSmartMatchingForBreakouts)) ||
      (event.breakoutRoomDefinition?.assignmentMethod ==
          BreakoutAssignmentMethod.smartMatch);

  bool get enablePrerequisites =>
      _settingsValue((settings) => settings.enablePrerequisites);

  bool get enableChat => _settingsValue((settings) => settings.chat);

  bool get enableTalkingTimer =>
      _settingsValue((settings) => settings.talkingTimer);

  bool get enableFloatingChat =>
      _settingsValue((settings) => settings.showChatMessagesInRealTime);

  bool get allowPredefineBreakoutsOnHosted =>
      _settingsValue((settings) => settings.allowPredefineBreakoutsOnHosted);

  bool get enableScreenshare =>
      false; //_settingsValue((settings) => settings.allowScreenshare);

  bool get defaultStageView =>
      _settingsValue((settings) => settings.defaultStageView);

  bool get enableBreakoutsByCategory =>
      _settingsValue((settings) => settings.enableBreakoutsByCategory);

  bool get agendaPreview =>
      _settingsValue((settings) => settings.agendaPreview);

  bool _settingsValue(
    bool? Function(EventSettings) getValue, {
    defaultValue = false,
  }) {
    bool? getValueIfNotNull(EventSettings? settings) =>
        settings != null ? getValue(settings) : null;

    return getValueIfNotNull(event.eventSettings) ??
        getValueIfNotNull(template?.eventSettings) ??
        getValueIfNotNull(communityProvider.eventSettings) ??
        defaultValue;
  }

  Future<bool> _checkHasParticipantAttendedPrerequisite() async {
    final event = await _eventStream.first;
    final prerequisiteTemplateId = event.prerequisiteTemplateId;
    if (prerequisiteTemplateId != null) {
      _hasAttendedPrerequisite =
          await firestoreEventService.userHasParticipatedInTemplate(
        templateId: prerequisiteTemplateId,
      );
    }
    notifyListeners();
    return _hasAttendedPrerequisite;
  }

  bool get useParticipantCountEstimate {
    return event.useParticipantCountEstimate;
  }

  int get participantCount => useParticipantCountEstimate
      ? max(1, event.participantCountEstimate ?? 0)
      : eventParticipants.length;

  int get presentParticipantCount => useParticipantCountEstimate
      ? max(1, event.presentParticipantCountEstimate ?? 0)
      : eventParticipants.where((p) => p.isPresent).length;

  void initialize() {
    _upcomingEvents = firestoreEventService.futurePublicEventsForCommunity(
      communityId: communityId,
    );

    _eventStream = firestoreEventService.eventStream(
      communityId: communityId,
      templateId: templateId,
      eventId: eventId,
    );

    _templatesStream = wrapInBehaviorSubject(
      firestoreDatabase.communityTemplatesStream(communityId).map(
            (templates) => templates
              ..sort((a, b) {
                final aPriority = a.orderingPriority;
                final bPriority = b.orderingPriority;

                if (bPriority == null) {
                  return -1;
                } else if (aPriority == null) {
                  return 1;
                }
                return aPriority.compareTo(bPriority);
              }),
          ),
    ).stream;

    _userServiceChangesSubscription =
        userService.currentUserChanges.listen((_) {
      _selfParticipantStream?.dispose();
      if (userService.currentUserId != null) {
        _selfParticipantStream = wrapInBehaviorSubject(
          firestoreEventService.eventParticipantStream(
            communityId: communityId,
            templateId: templateId,
            eventId: eventId,
            userId: userService.currentUserId!,
          ),
        );
      } else {
        _selfParticipantStream = null;
      }

      _selfParticipantStreamSubscription?.cancel();
      _selfParticipantStreamSubscription =
          _selfParticipantStream?.stream.listen((_) => notifyListeners());
      notifyListeners();
    });
    _templateStream = wrapInBehaviorSubject(
      firestoreDatabase.templateStream(
        communityId: communityId,
        templateId: templateId,
      ),
    ).stream;

    _listenToStreams();
    _hasParticipantAttendedPrerequisiteFuture =
        _checkHasParticipantAttendedPrerequisite();
  }

  void _listenToStreams() {
    _templateStreamSubscription = _templateStream.stream.listen((value) {
      notifyListeners();
    });
    _eventStreamSubscription = _eventStream.stream.listen((_) {
      if (!useParticipantCountEstimate && _eventParticipantsStream == null) {
        _eventParticipantsStream =
            firestoreEventService.eventParticipantsStream(
          communityId: communityId,
          templateId: templateId,
          eventId: eventId,
        );
        _eventParticipantsStreamSubscription =
            _eventParticipantsStream?.stream.listen((_) => notifyListeners());
      }
      notifyListeners();
    });
  }

  Future<void> updateEventSettings(EventSettings newSettings) {
    return firestoreEventService.updateEvent(
      event: event.copyWith(eventSettings: newSettings),
      keys: [Event.kFieldEventSettings],
    );
  }

  @override
  void dispose() {
    _userServiceChangesSubscription.cancel();
    _eventStreamSubscription.cancel();
    _selfParticipantStreamSubscription?.cancel();
    _eventParticipantsStreamSubscription?.cancel();
    _templateStreamSubscription.cancel();
    _templatesStream.close();
    _templateStream.close();
    _upcomingEvents.dispose();
    _eventStream.dispose();
    _selfParticipantStream?.dispose();
    _eventParticipantsStream?.dispose();
    super.dispose();
  }

  static EventProvider watch(BuildContext context) =>
      Provider.of<EventProvider>(context);

  static EventProvider read(BuildContext context) =>
      Provider.of<EventProvider>(context, listen: false);

  static EventProvider? readOrNull(BuildContext context) => providerOrNull(
        () => Provider.of<EventProvider>(context, listen: false),
      );

  Future<void> refreshEvent(Template template, Event event) async {
    await firestoreEventService.updateEvent(
      event: event.copyWith(agendaItems: template.agendaItems),
      keys: [Event.kFieldAgendaItems],
    );
  }

  Future<void> cancelParticipation({required String participantId}) async {
    final participantIsUser = userService.currentUserId == participantId;
    final identifier = participantIsUser ? 'your' : 'this user\'s';
    final cancelParticipation = await ConfirmDialog(
      title: appLocalizationService.getLocalization().cancel,
      mainText:
          'Are you sure you want to cancel $identifier participation in this event?',
      confirmText: 'Yes, cancel',
      cancelText: appLocalizationService.getLocalization().no,
    ).show();
    if (cancelParticipation) {
      await firestoreEventService.removeParticipant(
        communityId: event.communityId,
        templateId: event.templateId,
        eventId: event.id,
        participantId: participantId,
      );
    }
  }

  Future<void> generateRegistrationDataCsvFile({
    required List<MemberDetails> registrationData,
    required String? eventId,
    List<BreakoutRoom>? breakoutRooms,
  }) async {
    List<List<dynamic>> rows = [];

    List<dynamic> firstRow = [];
    firstRow.add('User ID');
    firstRow.add('Name');
    firstRow.add('Email');
    firstRow.add('Member Status');
    firstRow.add('RSVP Time');
    firstRow.add('Join Time');
    firstRow.add('Room Assigned');
    rows.add(firstRow);

    final numberOfQuestions =
        _eventStream.value?.breakoutRoomDefinition?.breakoutQuestions.length ??
            0;

    // Question format: "Question 1, Answer 1, Question 2, Answer 2". This allows the question text to be visible within participants' answers.
    for (var i = 0; i < numberOfQuestions; i++) {
      firstRow.add('Question ${i + 1}');
      firstRow.add('Answer ${i + 1}');
    }

    for (var i = 0; i < registrationData.length; i++) {
      List<dynamic> row = [];
      row.add(registrationData[i].id);
      row.add(registrationData[i].displayName ?? '');
      row.add(registrationData[i].email ?? '');
      row.add(
        EnumToString.convertToString(registrationData[i].membership?.status),
      );
      row.add(
        registrationData[i].memberEvent?.participant?.createdDate?.toUtc(),
      );

      // Added Join Time field from Participant.mostRecentPresentTime
      row.add(
        registrationData[i]
            .memberEvent
            ?.participant
            ?.mostRecentPresentTime
            ?.toUtc(),
      );

      // Added Room Assigned field from Participant.currentBreakoutRoomId
      // Convert room ID to room name for better readability
      String roomAssigned = '';
      final currentRoomId =
          registrationData[i].memberEvent?.participant?.currentBreakoutRoomId;
      if (currentRoomId != null && currentRoomId.isNotEmpty) {
        if (currentRoomId == 'waiting-room') {
          // Special case: breakout room waiting room
          roomAssigned = 'Waiting room';
        } else if (breakoutRooms != null) {
          // Find room name from breakout rooms data
          final room = breakoutRooms
              .firstWhereOrNull((room) => room.roomId == currentRoomId);
          if (room != null) {
            roomAssigned = room.roomName;
          } else {
            roomAssigned =
                currentRoomId; // Fallback to room ID if room not found
          }
        } else {
          roomAssigned =
              currentRoomId; // Fallback to room ID if no room data available
        }
      } else {
        // If currentRoomId is null or empty, user is likely in main waiting room
        roomAssigned = 'Waiting room';
      }
      row.add(roomAssigned);

      final event = registrationData[i].memberEvent;

      if (event != null) {
        final questionsData =
            event.participant?.breakoutRoomSurveyQuestions ?? [];
        // Get breakout questions from event definition to get question titles
        final eventQuestions =
            _eventStream.value?.breakoutRoomDefinition?.breakoutQuestions ?? [];

        // Process each question defined in the event
        for (var q = 0; q < numberOfQuestions; q++) {
          // Add question title from event definition
          if (q < eventQuestions.length) {
            row.add(eventQuestions[q].title);
          } else {
            row.add('');
          }

          // Find corresponding answer from participant data
          String answerText = '';
          if (q < questionsData.length) {
            final questionsList = questionsData[q]
                .answers
                .map((e) => e.options)
                .flattened
                .toList();

            final answerId = questionsData[q].answerOptionId;
            if (answerId.isNotEmpty) {
              try {
                final answer = questionsList
                    .firstWhere((element) => element.id == answerId);
                answerText = answer.title;
              } catch (e) {
                // Answer not found, leave empty
                answerText = '';
              }
            }
          }
          row.add(answerText);
        }
      }
      rows.add(row);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final stringToBase64 = utf8.fuse(base64);
    final content = stringToBase64.encode(csv);
    // Keep original filename format with eventId to distinguish different event exports
    final fileName = 'registration-data-$eventId.csv';

    AnchorElement(
      href: 'data:application/octet-stream;charset=utf-8;base64,$content',
    )
      ..setAttribute('download', fileName)
      ..click();
  }

  Future<void> generateChatDataCsv({
    required GetMeetingChatsSuggestionsDataResponse response,
    required String? eventId,
    List<BreakoutRoom>? breakoutRooms,
  }) async {
    List<List<dynamic>> rows = [];

    List<dynamic> firstRow = [];
    firstRow.add('Time');
    firstRow.add('User ID');
    firstRow.add('Message');
    firstRow.add('Room');
    firstRow.add('Deleted');
    rows.add(firstRow);

    var chatsData = response.chatsSuggestionsList
            ?.where((e) => e.type == ChatSuggestionType.chat)
            .toList() ??
        [];

    for (int i = 0; i < chatsData.length; i++) {
      List<dynamic> row = [];
      // Changed "Created" to "Time"
      row.add(dateTimeFormat(date: chatsData[i].createdDate!));
      // Added "User ID" field
      row.add(chatsData[i].creatorId ?? '');
      row.add(chatsData[i].message ?? chatsData[i].emotionType?.stringEmoji);

      // Convert room ID to room name for better readability
      String roomName = '';
      final roomId = chatsData[i].roomId;
      if (roomId != null && roomId.isNotEmpty) {
        if (roomId == 'waiting-room') {
          roomName = 'Waiting room';
        } else if (roomId == eventId) {
          // If roomId matches eventId, user is in main room
          roomName = 'Main room';
        } else if (breakoutRooms != null && breakoutRooms.isNotEmpty) {
          // Try to find room by roomId
          final room =
              breakoutRooms.firstWhereOrNull((room) => room.roomId == roomId);
          if (room != null) {
            roomName =
                room.roomName; // This will be "1", "2", etc. for breakout rooms
          } else {
            // If roomId is not found in breakout rooms, it might be a main room ID
            // Check if it's the main event room (same as eventId)
            roomName = 'Main room';
          }
        } else {
          // If no breakout rooms data available, assume it's main room
          roomName = 'Main room';
        }
      } else {
        // If roomId is null or empty, user is in main room
        roomName = 'Main room';
      }
      row.add(roomName);

      row.add(chatsData[i].deleted);
      rows.add(row);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final stringToBase64 = utf8.fuse(base64);
    final content = stringToBase64.encode(csv);
    final fileName = 'chat-data-$eventId.csv';

    AnchorElement(
      href: 'data:application/octet-stream;charset=utf-8;base64,$content',
    )
      ..setAttribute('download', fileName)
      ..click();
  }

  Future<void> generatePollsSuggestionsDataCsv({
    required List<ChatSuggestionData> suggestionData,
    required List<PollData> pollData,
    required String? eventId,
    List<BreakoutRoom>? breakoutRooms,
  }) async {
    List<List<dynamic>> rows = [];

    List<dynamic> firstRow = [];
    firstRow.add('Type');
    firstRow.add('Time');
    firstRow.add('User ID');
    firstRow.add('Prompt');
    firstRow.add('Response');
    firstRow.add('Room');
    firstRow.add('Upvotes');
    firstRow.add('Downvotes');
    firstRow.add('Deleted');
    rows.add(firstRow);

    // Get agenda items from event to map agendaItemId to prompt text
    final event = _eventStream.value;
    final agendaItems = event?.agendaItems ?? [];

    // Process suggestion data
    for (int i = 0; i < suggestionData.length; i++) {
      List<dynamic> row = [];
      final suggestionItem = agendaItems.firstWhereOrNull(
        (item) => item.id == suggestionData[i].agendaItemId,
      );

      final promptText = suggestionItem?.title ?? suggestionItem?.content ?? '';
      // Add Type field
      row.add('Suggestion');
      // Changed "Created" to "Time"
      row.add(dateTimeFormat(date: suggestionData[i].createdDate!));
      // Added "User ID" field instead of Name, Email
      row.add(suggestionData[i].creatorId ?? '');
      // Add Prompt field
      row.add(promptText);
      // Add Response field
      row.add(suggestionData[i].message ?? '');

      // Convert room ID to room name for better readability
      String roomName = _getRoomName(
        roomId: suggestionData[i].roomId,
        eventId: eventId,
        breakoutRooms: breakoutRooms,
      );
      row.add(roomName);

      row.add(suggestionData[i].upvotes ?? '');
      row.add(suggestionData[i].downvotes ?? '');
      row.add(suggestionData[i].deleted ?? false);
      rows.add(row);
    }

    // Process poll data
    for (int i = 0; i < pollData.length; i++) {
      List<dynamic> row = [];

      final poll = pollData[i];

      // Add Type field
      row.add('Poll');
      // Add Time field
      row.add(dateTimeFormat(date: poll.answeredDate!));
      // Add User ID field
      row.add(poll.userId ?? '');
      // Add Prompt field (poll question)
      row.add(poll.pollQuestion ?? '');
      // Add Response field
      row.add(poll.pollResponse ?? '');

      String roomName = _getRoomName(
        roomId: poll.roomId,
        eventId: eventId,
        breakoutRooms: breakoutRooms,
      );
      row.add(roomName);

      // Add blank spaces for the upvote/downvote/deleted fields which
      // don't apply to the poll data rows.
      row.add('');
      row.add('');
      row.add(false);
      rows.add(row);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final stringToBase64 = utf8.fuse(base64);
    final content = stringToBase64.encode(csv);
    final fileName = 'polls-suggestions-data-$eventId.csv';

    AnchorElement(
      href: 'data:application/octet-stream;charset=utf-8;base64,$content',
    )
      ..setAttribute('download', fileName)
      ..click();
  }

  String _getRoomName({
    required String? roomId,
    required String? eventId,
    List<BreakoutRoom>? breakoutRooms,
  }) {
    if (roomId == null || roomId.isEmpty) {
      return 'Main room';
    }

    if (roomId == 'waiting-room') {
      return 'Waiting room';
    }

    if (roomId == eventId) {
      return 'Main room';
    }

    if (breakoutRooms != null && breakoutRooms.isNotEmpty) {
      final room =
          breakoutRooms.firstWhereOrNull((room) => room.roomId == roomId);
      if (room != null) {
        return room.roomName;
      }
    }

    return 'Main room';
  }
}
