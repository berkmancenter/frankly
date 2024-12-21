import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:csv/csv.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:client/app/community/community_provider.dart';
import 'package:client/app/community/utils.dart';
import 'package:client/common_widgets/confirm_dialog.dart';
import 'package:client/environment.dart';
import 'package:client/services/firestore/firestore_utils.dart';
import 'package:client/services/services.dart';
import 'package:client/utils/extensions.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/chat/chat_suggestion_data.dart';
import 'package:data_models/community/member_details.dart';
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
      title: 'Cancel',
      mainText:
          'Are you sure you want to cancel $identifier participation in this event?',
      confirmText: 'Yes, cancel',
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
  }) async {
    List<List<dynamic>> rows = [];

    List<dynamic> firstRow = [];
    firstRow.add('${Environment.appName} ID');
    firstRow.add('Name');
    firstRow.add('Email');
    firstRow.add('Member status');
    firstRow.add('RSVP Time');
    rows.add(firstRow);

    final numberOfQuestions =
        _eventStream.value?.breakoutRoomDefinition?.breakoutQuestions.length ??
            0;

    for (var i = 0; i < numberOfQuestions; i++) {
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

      final event = registrationData[i].memberEvent;

      if (event != null) {
        final questionsData =
            event.participant?.breakoutRoomSurveyQuestions ?? [];
        if (questionsData.isEmpty && numberOfQuestions != 0) {
          for (var q = 0; q < numberOfQuestions; q++) {
            row.add('');
          }
        } else {
          for (var i = 0; i < questionsData.length; i++) {
            final questionsList = questionsData[i]
                .answers
                .map((e) => e.options)
                .flattened
                .toList();

            final answerId = questionsData[i].answerOptionId;
            if (answerId.isNotEmpty) {
              final answer =
                  questionsList.firstWhere((element) => element.id == answerId);
              row.add(answer.title);
            } else {
              row.add('');
            }
          }
        }
      }
      rows.add(row);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final stringToBase64 = utf8.fuse(base64);
    final content = stringToBase64.encode(csv);
    final fileName = 'registration-data-$eventId.csv';

    AnchorElement(
      href: 'data:application/octet-stream;charset=utf-8;base64,$content',
    )
      ..setAttribute('download', fileName)
      ..click();
  }

  Future<void> generateChatAndSugguestionsDataCsv({
    required GetMeetingChatsSuggestionsDataResponse response,
    required String? eventId,
  }) async {
    List<List<dynamic>> rows = [];

    List<dynamic> firstRow = [];
    firstRow.add('Type');
    firstRow.add('#');
    firstRow.add('Created');
    firstRow.add('Name');
    firstRow.add('Email');
    firstRow.add('Message');
    firstRow.add('RoomId');
    firstRow.add('Deleted');
    rows.add(firstRow);

    var chatsData = response.chatsSuggestionsList
            ?.where((e) => e.type == ChatSuggestionType.chat)
            .toList() ??
        [];

    for (int i = 0; i < chatsData.length; i++) {
      List<dynamic> row = [];
      row.add('Chat');
      row.add(i + 1);
      row.add(dateTimeFormat(date: chatsData[i].createdDate!));
      row.add(chatsData[i].creatorName ?? '');
      row.add(chatsData[i].creatorEmail ?? '');
      row.add(chatsData[i].message ?? chatsData[i].emotionType?.stringEmoji);
      row.add(chatsData[i].roomId);
      row.add(chatsData[i].deleted);
      rows.add(row);
    }

    var suggestionsData = response.chatsSuggestionsList
            ?.where((e) => e.type == ChatSuggestionType.suggestion)
            .toList() ??
        [];

    if (suggestionsData.isNotEmpty) {
      firstRow.add('Upvotes');
      firstRow.add('Downvotes');
      firstRow.add('AgendaItemId');
    }

    for (int i = 0; i < suggestionsData.length; i++) {
      List<dynamic> row = [];
      row.add('Suggestion');
      row.add(i + 1);
      row.add(dateTimeFormat(date: suggestionsData[i].createdDate!));
      row.add(suggestionsData[i].creatorName ?? '');
      row.add(suggestionsData[i].creatorEmail ?? '');
      row.add(suggestionsData[i].message ?? '');
      row.add(suggestionsData[i].roomId);
      row.add(suggestionsData[i].deleted ?? false);
      row.add(suggestionsData[i].upvotes ?? '');
      row.add(suggestionsData[i].downvotes ?? '');
      row.add(suggestionsData[i].agendaItemId ?? '');
      rows.add(row);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final stringToBase64 = utf8.fuse(base64);
    final content = stringToBase64.encode(csv);
    final fileName = 'chats-suggestions-data-$eventId.csv';

    AnchorElement(
      href: 'data:application/octet-stream;charset=utf-8;base64,$content',
    )
      ..setAttribute('download', fileName)
      ..click();
  }
}
