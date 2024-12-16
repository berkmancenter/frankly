import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:csv/csv.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/confirm_dialog.dart';
import 'package:junto/junto_app.dart';
import 'package:junto/services/firestore/firestore_utils.dart';
import 'package:junto/services/services.dart';
import 'package:junto/utils/extensions.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/chat_suggestion_data.dart';
import 'package:junto_models/firestore/member_details.dart';
import 'package:junto_models/firestore/topic.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:universal_html/html.dart';

class DiscussionProvider with ChangeNotifier {
  final JuntoProvider juntoProvider;
  final String topicId;
  final String discussionId;

  DiscussionProvider({
    required this.juntoProvider,
    required this.topicId,
    required this.discussionId,
  });

  factory DiscussionProvider.fromDocumentPath(
    String documentPath, {
    required JuntoProvider juntoProvider,
  }) {
    final discussionMatch =
        RegExp('/?junto/([^/]+)/topics/([^/]+)/discussions/([^/]+)').matchAsPrefix(documentPath);
    final topicId = discussionMatch!.group(2)!;
    final discussionId = discussionMatch.group(3)!;

    return DiscussionProvider(
      juntoProvider: juntoProvider,
      topicId: topicId,
      discussionId: discussionId,
    );
  }

  factory DiscussionProvider.fromDiscussion(
    Discussion discussion, {
    required JuntoProvider juntoProvider,
  }) {
    return DiscussionProvider(
      juntoProvider: juntoProvider,
      topicId: discussion.topicId,
      discussionId: discussion.id,
    );
  }

  late BehaviorSubjectWrapper<List<Discussion>> _upcomingDiscussions;

  late BehaviorSubject<List<Topic>> _topicsStream;
  late BehaviorSubjectWrapper<Discussion> _discussionStream;
  BehaviorSubjectWrapper<Participant>? _selfParticipantStream;
  BehaviorSubjectWrapper<List<Participant>>? _discussionParticipantsStream;

  late StreamSubscription _topicStreamSubscription;
  late BehaviorSubject<Topic?> _topicStream;

  late StreamSubscription _discussionStreamSubscription;
  StreamSubscription? _selfParticipantStreamSubscription;
  StreamSubscription? _discussionParticipantsStreamSubscription;
  late StreamSubscription _userServiceChangesSubscription;

  Future<PrivateLiveStreamInfo?>? _privateLiveStreamInfo;

  late Future<bool> _hasParticipantAttendedPrerequisiteFuture;

  bool _hasAttendedPrerequisite = false;

  BreakoutRoomDefinition get defaultBreakoutRoomDefinition => BreakoutRoomDefinition(
        creatorId: userService.currentUserId,
        targetParticipants: 8,
        breakoutQuestions: [
          if (juntoProvider.isMeetingOfAmerica)
            BreakoutQuestion(
              id: uuid.v4(),
              answerOptionId: '',
              title: 'Which of the following best describes you?',
              answers: [
                BreakoutAnswer(
                  id: uuid.v4(),
                  options: [BreakoutAnswerOption(id: uuid.v4(), title: 'White')],
                ),
                BreakoutAnswer(
                  id: uuid.v4(),
                  options: [
                    BreakoutAnswerOption(id: uuid.v4(), title: 'Hispanic or Latino'),
                    BreakoutAnswerOption(id: uuid.v4(), title: 'Black/African-American'),
                    BreakoutAnswerOption(id: uuid.v4(), title: 'Asian or Pacific Islander'),
                    BreakoutAnswerOption(id: uuid.v4(), title: 'Native American'),
                    BreakoutAnswerOption(id: uuid.v4(), title: 'Other'),
                  ],
                ),
              ],
            ),
        ],
        assignmentMethod: BreakoutAssignmentMethod.targetPerRoom,
      );

  String get juntoId => juntoProvider.juntoId;

  Stream<List<Discussion>> get upcomingDiscussionsStream => _upcomingDiscussions.stream;

  List<Discussion> get upcomingDiscussions =>
      _upcomingDiscussions.stream.value.where((d) => d.id != discussionId).take(2).toList();

  Stream<List<Topic>> get topicsStream => _topicsStream;

  Stream<Discussion> get discussionStream => _discussionStream.stream;

  Stream<List<Participant>>? get discussionParticipantsStream =>
      _discussionParticipantsStream?.stream;

  Stream<Participant>? get selfParticipantStream => _selfParticipantStream?.stream;

  Future<PrivateLiveStreamInfo?> get privateLiveStreamInfo => _privateLiveStreamInfo ??=
      firestoreDiscussionService.liveStreamPrivateInfo(discussion: discussion);

  Discussion get discussion {
    final discussionValue = _discussionStream.stream.valueOrNull;
    if (discussionValue == null) {
      throw Exception('Event must be loaded before being accessed.');
    }

    return discussionValue;
  }

  Topic? get topic => _topicStream.valueOrNull;

  Participant? get selfParticipant => _selfParticipantStream?.stream.valueOrNull;

  List<Participant> get discussionParticipants =>
      _discussionParticipantsStream?.stream.valueOrNull
          ?.where((p) => p.status == ParticipantStatus.active)
          .toList() ??
      [];

  bool get isParticipant =>
      _selfParticipantStream?.stream.valueOrNull?.status == ParticipantStatus.active;

  bool get isBanned =>
      _selfParticipantStream?.stream.valueOrNull?.status == ParticipantStatus.banned;

  bool get isLiveStream => discussion.isLiveStream;

  bool get hasAttendedPrerequisite => _hasAttendedPrerequisite;

  final List<Participant> _fakeLiveStreamParticipantsList = [
    for (var i = 0; i < 10; i++) Participant(id: i.toString()),
  ];

  List<Participant> get fakeLiveStreamParticipantsList => _fakeLiveStreamParticipantsList;

  Future<bool> get hasParticipantAttendedPrerequisiteFuture =>
      _hasParticipantAttendedPrerequisiteFuture;

  bool get showSmartMatchingForBreakouts =>
      (_settingsValue((settings) => settings.showSmartMatchingForBreakouts)) ||
      (discussion.breakoutRoomDefinition?.assignmentMethod == BreakoutAssignmentMethod.smartMatch);

  bool get enablePrerequisites => _settingsValue((settings) => settings.enablePrerequisites);

  bool get enableChat => _settingsValue((settings) => settings.chat);

  bool get enableTalkingTimer => _settingsValue((settings) => settings.talkingTimer);

  bool get enableFloatingChat => _settingsValue((settings) => settings.showChatMessagesInRealTime);

  bool get allowPredefineBreakoutsOnHosted =>
      _settingsValue((settings) => settings.allowPredefineBreakoutsOnHosted);

  bool get enableScreenshare => false; //_settingsValue((settings) => settings.allowScreenshare);

  bool get defaultStageView => _settingsValue((settings) => settings.defaultStageView);

  bool get enableBreakoutsByCategory =>
      _settingsValue((settings) => settings.enableBreakoutsByCategory);

  bool get agendaPreview => _settingsValue((settings) => settings.agendaPreview);

  bool _settingsValue(bool? Function(DiscussionSettings) getValue, {defaultValue = false}) {
    bool? getValueIfNotNull(DiscussionSettings? settings) =>
        settings != null ? getValue(settings) : null;

    return getValueIfNotNull(discussion.discussionSettings) ??
        getValueIfNotNull(topic?.discussionSettings) ??
        getValueIfNotNull(juntoProvider.discussionSettings) ??
        defaultValue;
  }

  Future<bool> _checkHasParticipantAttendedPrerequisite() async {
    final discussion = await _discussionStream.first;
    final prerequisiteTopicId = discussion.prerequisiteTopicId;
    if (prerequisiteTopicId != null) {
      _hasAttendedPrerequisite = await firestoreDiscussionService.userHasParticipatedInTopic(
        topicId: prerequisiteTopicId,
      );
    }
    notifyListeners();
    return _hasAttendedPrerequisite;
  }

  bool get useParticipantCountEstimate {
    return discussion.useParticipantCountEstimate;
  }

  int get participantCount => useParticipantCountEstimate
      ? max(1, discussion.participantCountEstimate ?? 0)
      : discussionParticipants.length;

  int get presentParticipantCount => useParticipantCountEstimate
      ? max(1, discussion.presentParticipantCountEstimate ?? 0)
      : discussionParticipants.where((p) => p.isPresent).length;

  void initialize() {
    _upcomingDiscussions = firestoreDiscussionService.futurePublicDiscussionsForJunto(
      juntoId: juntoId,
    );

    _discussionStream = firestoreDiscussionService.discussionStream(
      juntoId: juntoId,
      topicId: topicId,
      discussionId: discussionId,
    );

    _topicsStream =
        wrapInBehaviorSubject(firestoreDatabase.juntoTopicsStream(juntoId).map((topics) => topics
          ..sort((a, b) {
            final aPriority = a.orderingPriority;
            final bPriority = b.orderingPriority;

            if (bPriority == null) {
              return -1;
            } else if (aPriority == null) {
              return 1;
            }
            return aPriority.compareTo(bPriority);
          }))).stream;

    _userServiceChangesSubscription = userService.currentUserChanges.listen((_) {
      _selfParticipantStream?.dispose();
      if (userService.currentUserId != null) {
        _selfParticipantStream =
            wrapInBehaviorSubject(firestoreDiscussionService.discussionParticipantStream(
          juntoId: juntoId,
          topicId: topicId,
          discussionId: discussionId,
          userId: userService.currentUserId!,
        ));
      } else {
        _selfParticipantStream = null;
      }

      _selfParticipantStreamSubscription?.cancel();
      _selfParticipantStreamSubscription =
          _selfParticipantStream?.stream.listen((_) => notifyListeners());
      notifyListeners();
    });
    _topicStream =
        wrapInBehaviorSubject(firestoreDatabase.topicStream(juntoId: juntoId, topicId: topicId))
            .stream;

    _listenToStreams();
    _hasParticipantAttendedPrerequisiteFuture = _checkHasParticipantAttendedPrerequisite();
  }

  void _listenToStreams() {
    _topicStreamSubscription = _topicStream.stream.listen((value) {
      notifyListeners();
    });
    _discussionStreamSubscription = _discussionStream.stream.listen((_) {
      if (!useParticipantCountEstimate && _discussionParticipantsStream == null) {
        _discussionParticipantsStream = firestoreDiscussionService.discussionParticipantsStream(
          juntoId: juntoId,
          topicId: topicId,
          discussionId: discussionId,
        );
        _discussionParticipantsStreamSubscription =
            _discussionParticipantsStream?.stream.listen((_) => notifyListeners());
      }
      notifyListeners();
    });
  }

  Future<void> updateDiscussionSettings(DiscussionSettings newSettings) {
    return firestoreDiscussionService.updateDiscussion(
      discussion: discussion.copyWith(discussionSettings: newSettings),
      keys: [Discussion.kFieldDiscussionSettings],
    );
  }

  @override
  void dispose() {
    _userServiceChangesSubscription.cancel();
    _discussionStreamSubscription.cancel();
    _selfParticipantStreamSubscription?.cancel();
    _discussionParticipantsStreamSubscription?.cancel();
    _topicStreamSubscription.cancel();
    _topicsStream.close();
    _topicStream.close();
    _upcomingDiscussions.dispose();
    _discussionStream.dispose();
    _selfParticipantStream?.dispose();
    _discussionParticipantsStream?.dispose();
    super.dispose();
  }

  static DiscussionProvider watch(BuildContext context) => Provider.of<DiscussionProvider>(context);

  static DiscussionProvider read(BuildContext context) =>
      Provider.of<DiscussionProvider>(context, listen: false);

  static DiscussionProvider? readOrNull(BuildContext context) =>
      providerOrNull(() => Provider.of<DiscussionProvider>(context, listen: false));

  Future<void> refreshDiscussion(Topic topic, Discussion discussion) async {
    await firestoreDiscussionService.updateDiscussion(
      discussion: discussion.copyWith(agendaItems: topic.agendaItems),
      keys: [Discussion.kFieldAgendaItems],
    );
  }

  Future<void> cancelParticipation({required String participantId}) async {
    final participantIsUser = userService.currentUserId == participantId;
    final identifier = participantIsUser ? 'your' : 'this user\'s';
    final cancelParticipation = await ConfirmDialog(
      title: 'Cancel',
      mainText: 'Are you sure you want to cancel $identifier participation in this event?',
      confirmText: 'Yes, cancel',
    ).show();
    if (cancelParticipation) {
      await firestoreDiscussionService.removeParticipant(
        juntoId: discussion.juntoId,
        topicId: discussion.topicId,
        discussionId: discussion.id,
        participantId: participantId,
      );
    }
  }

  Future<void> generateRegistrationDataCsvFile({
    required List<MemberDetails> registrationData,
    required String? discussionId,
  }) async {
    List<List<dynamic>> rows = [];

    List<dynamic> firstRow = [];
    firstRow.add('Frankly ID');
    firstRow.add('Name');
    firstRow.add('Email');
    firstRow.add('Member status');
    firstRow.add('RSVP Time');
    rows.add(firstRow);

    final numberOfQuestions =
        _discussionStream.value?.breakoutRoomDefinition?.breakoutQuestions.length ?? 0;

    if (juntoProvider.isAmericaTalks) {
      firstRow.add('America Talks Opt In');
      firstRow.add('Zip Code');
      firstRow.add('gup');
      firstRow.add('source');
    }
    for (var i = 0; i < numberOfQuestions; i++) {
      firstRow.add('Answer ${i + 1}');
    }

    for (var i = 0; i < registrationData.length; i++) {
      List<dynamic> row = [];
      row.add(registrationData[i].id);
      row.add(registrationData[i].displayName ?? '');
      row.add(registrationData[i].email ?? '');
      row.add(EnumToString.convertToString(registrationData[i].membership?.status));
      row.add(registrationData[i].memberDiscussion?.participant?.createdDate?.toUtc());

      if (juntoProvider.isAmericaTalks) {
        row.add(registrationData[i].memberDiscussion?.participant?.optInToAmericaTalks);
        row.add(registrationData[i].memberDiscussion?.participant?.zipCode);
        final joinParameters =
            registrationData[i].memberDiscussion?.participant?.joinParameters ?? {};
        row.add(joinParameters['gup']);
        row.add(joinParameters['source']);
      }

      final discussion = registrationData[i].memberDiscussion;

      if (discussion != null) {
        final questionsData = discussion.participant?.breakoutRoomSurveyQuestions ?? [];
        if (questionsData.isEmpty && numberOfQuestions != 0) {
          for (var q = 0; q < numberOfQuestions; q++) {
            row.add('');
          }
        } else {
          for (var i = 0; i < questionsData.length; i++) {
            final questionsList = questionsData[i].answers.map((e) => e.options).flattened.toList();

            final answerId = questionsData[i].answerOptionId;
            if (answerId.isNotEmpty) {
              final answer = questionsList.firstWhere((element) => element.id == answerId);
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
    final fileName = 'registration-data-$discussionId.csv';

    AnchorElement(href: 'data:application/octet-stream;charset=utf-8;base64,$content')
      ..setAttribute('download', fileName)
      ..click();
  }

  Future<void> generateChatAndSugguestionsDataCsv({
    required GetMeetingChatsSuggestionsDataResponse response,
    required String? discussionId,
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

    var chatsData =
        response.chatsSuggestionsList?.where((e) => e.type == ChatSuggestionType.chat).toList() ??
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
    final fileName = 'chats-suggestions-data-$discussionId.csv';

    AnchorElement(href: 'data:application/octet-stream;charset=utf-8;base64,$content')
      ..setAttribute('download', fileName)
      ..click();
  }

  Future<void> optInForAmericaTalks() async {
    await firestoreDiscussionService.optInToAmericaTalks(
      juntoId: juntoId,
      topicId: topicId,
      discussionId: discussionId,
      participantId: userService.currentUserId!,
    );
  }
}
