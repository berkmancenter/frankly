import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/meeting_agenda_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/topic_provider.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/visible_exception.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/analytics/analytics_entities.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/topic.dart';
import 'package:pedantic/pedantic.dart';

import '../discussion_page/discussion_page_provider.dart';

enum CurrentPage {
  selectTopic,
  selectVisibility,
  selectDate,
  selectTime,
  selectParticipants,
  selectTitle,
  selectHostingType,
  choosePlatform,
}

/// Holds logic for the CreateDiscussionDialog class.
class CreateDiscussionDialogModel with ChangeNotifier {
  final JuntoProvider juntoProvider;
  final DiscussionProvider? discussionProvider;
  final List<CurrentPage>? pages;
  final Topic? initialTopic;
  final Discussion? discussionTemplate;
  final DiscussionType discussionType;

  CreateDiscussionDialogModel({
    required this.juntoProvider,
    this.discussionProvider,
    this.pages,
    this.initialTopic,
    this.discussionType = DiscussionType.hosted,
    this.discussionTemplate,
  });

  Topic? _selectedTopic;
  late Discussion _discussion;

  int _currentPage = 0;

  Discussion get discussion => _discussion;

  DateTime? get scheduledTime => discussion.scheduledTime;

  bool get isEdit => discussionProvider != null;

  Topic? get selectedTopic => _selectedTopic;

  CurrentPage get currentPageInfo => allPages[_currentPage];

  /// The list of pages that this dialog will show. For editing the caller passes in what pages
  /// to show, otherwise we use the default creation flow.
  List<CurrentPage> get allPages =>
      pages ??
      [
        if (initialTopic == null) CurrentPage.selectTopic,
        CurrentPage.selectVisibility,
        CurrentPage.selectDate,
        CurrentPage.selectTime,
      ];

  bool get allowBack => currentPageIndex > 0;

  int get currentPageIndex => _currentPage;

  bool get isFinalPage => currentPageIndex == allPages.length - 1;

  late DiscussionType _discussionTypeWhenEventWasCreated;

  void initialize() {
    if (isEdit) {
      _discussion = discussionProvider!.discussion;
      _discussionTypeWhenEventWasCreated = _discussion.discussionType;
    } else {
      _selectedTopic = initialTopic;

      final now = clockService.now();
      final nowWithoutSeconds =
          now.subtract(Duration(seconds: now.second, milliseconds: now.millisecond));

      _discussion = Discussion(
        id: firestoreDatabase.generateNewDocId(
          collectionPath: firestoreDiscussionService
              .discussionsCollection(
                juntoId: juntoProvider.juntoId,
                topicId: _selectedTopic?.id ?? defaultTopicId,
              )
              .path,
        ),
        // These required fields get overwritten when the discussion is actually created
        collectionPath: '',
        topicId: '',
        status: DiscussionStatus.active,
        juntoId: juntoProvider.juntoId,
        creatorId: userService.currentUserId!,
        scheduledTime: nowWithoutSeconds.add(Duration(minutes: 60 - now.minute)),
        nullableDiscussionType: discussionType,
        isPublic: false,
        title: discussionTemplate?.title,
        description: discussionTemplate?.description,
        image: discussionTemplate?.image,
        minParticipants: discussionTemplate?.minParticipants,
        maxParticipants: discussionTemplate?.maxParticipants,
        agendaItems: discussionTemplate?.agendaItems ?? [],
        preEventCardData: discussionTemplate?.preEventCardData,
        postEventCardData: discussionTemplate?.postEventCardData,
        prerequisiteTopicId: discussionTemplate?.prerequisiteTopicId,
        breakoutRoomDefinition: discussionTemplate?.breakoutRoomDefinition,
        waitingRoomInfo: discussionTemplate?.waitingRoomInfo,
        discussionSettings: _selectedTopic?.discussionSettings ?? juntoProvider.discussionSettings,
      );
    }
  }

  void goBack() {
    _currentPage -= 1;
    notifyListeners();
  }

  void goNext() {
    _currentPage += 1;
    notifyListeners();
  }

  void setTopic(Topic topic) {
    _selectedTopic = topic;
    notifyListeners();
  }

  void updateScheduledTime(DateTime date) {
    _discussion = _discussion.copyWith(scheduledTime: date);
    notifyListeners();
  }

  void updateVisibility({required bool isPublic}) {
    _discussion = _discussion.copyWith(isPublic: isPublic);
    notifyListeners();
  }

  void setDiscussion(Discussion discussion) {
    _discussion = discussion;
    notifyListeners();
  }

  void updateDiscussionType(DiscussionType type) {
    _discussion = _discussion.copyWith(nullableDiscussionType: type);
    notifyListeners();
  }

  Future<Discussion?> submit(BuildContext context) async {
    Future<Discussion?> localSubmit() async {
      if (isEdit) {
        await _updateDiscussion();
        return null;
      } else {
        return await _createDiscussion();
      }
    }

    if (_discussion.isPublic) {
      return await guardJuntoMember<Discussion?>(context, juntoProvider.junto, localSubmit);
    } else {
      return await localSubmit();
    }
  }

  Future<Discussion?> _createDiscussion() async {
    final agendaItemsCandidates = [
      _discussion.agendaItems,
      _selectedTopic?.agendaItems ?? [],
      defaultAgendaItems(juntoProvider.juntoId).map((item) => item.copyWith()).toList(),
    ];
    final agendaItems = agendaItemsCandidates.firstWhere((items) => items.isNotEmpty).toList();

    if (_discussion.isPublic == true && discussionType == DiscussionType.hosted) {
      final confirmed = await verifyAvailableForDiscussion(discussion);
      if (!confirmed) return null;
    }

    List<AgendaItem> templateAgendaItems = _discussion.agendaItems;
    if (templateAgendaItems.isEmpty) {
      templateAgendaItems = _selectedTopic?.agendaItems ?? [];
    }

    _discussion = _discussion.copyWith(
      juntoId: juntoProvider.juntoId,
      topicId: selectedTopic?.id ?? defaultTopicId,
      title: _discussion.title ?? selectedTopic?.title ?? 'My Custom Event',
      description: _discussion.description ?? selectedTopic?.description ?? '',
      image: _discussion.image ?? selectedTopic?.image ?? generateRandomImageUrl(),
      minParticipants: _discussion.minParticipants ?? Discussion.defaultMinParticipants,
      maxParticipants: _discussion.maxParticipants ??
          (discussionType == DiscussionType.hosted
              ? Discussion.defaultMaxParticipants
              : Discussion.defaultMaxParticipantsInHostlessEvent),
      isLocked: false,
      agendaItems: agendaItems,
      preEventCardData: _discussion.preEventCardData ?? selectedTopic?.preEventCardData,
      postEventCardData: _discussion.postEventCardData ?? selectedTopic?.postEventCardData,
      prerequisiteTopicId: _discussion.prerequisiteTopicId ?? selectedTopic?.prerequisiteTopicId,
      discussionSettings: _selectedTopic?.discussionSettings ?? juntoProvider.discussionSettings,
    );

    PrivateLiveStreamInfo? privateLiveStreamInfo;

    if (_discussion.discussionType == DiscussionType.livestream) {
      privateLiveStreamInfo = await _processLiveStreamInfoForDiscussion();
    }

    _discussion = await firestoreDiscussionService.createDiscussionIfNotExists(
      discussion: _discussion,
      privateLiveStreamInfo: privateLiveStreamInfo,
    );
    unawaited(cloudFunctionsService.createDiscussion(_discussion));

    analytics.logEvent(AnalyticsCreateEventEvent(
      juntoId: juntoProvider.junto.id,
      discussionId: _discussion.id,
      guideId: _discussion.topicId,
    ));

    final time = _discussion.scheduledTime;
    if (time != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final scheduledDay = DateTime(time.year, time.month, time.day);
      analytics.logEvent(AnalyticsScheduleEventEvent(
        juntoId: juntoProvider.junto.id,
        discussionId: _discussion.id,
        daysFromNow: today.difference(scheduledDay).inDays,
        guideId: _discussion.topicId,
      ));
    }

    final analyticsEvent = _discussion.discussionType == DiscussionType.livestream
        ? 'create_discussion'
        : 'create_live_stream';
    unawaited(swallowErrors(() => firebaseAnalytics.logEvent(
          name: analyticsEvent,
          parameters: {'public': _discussion.isPublic.toString()},
        )));

    return _discussion;
  }

  Future<void> _updateDiscussion() async {
    final maxParticipants = _discussion.maxParticipants;
    final participantCount = discussionProvider?.participantCount;

    if (_discussion.discussionType != DiscussionType.livestream &&
        maxParticipants != null &&
        participantCount != null &&
        maxParticipants < participantCount) {
      throw VisibleException(
        'Cannot lower the number of participants below the current number registered.',
      );
    }

    if (_discussion.scheduledTime == null) {
      throw VisibleException('You must select a time.');
    }

    if (_discussionTypeWhenEventWasCreated != _discussion.discussionType) {
      _discussion = _discussion.copyWith(
        maxParticipants: _discussion.discussionType == DiscussionType.hosted
            ? Discussion.defaultMaxParticipants
            : Discussion.defaultMaxParticipantsInHostlessEvent,
      );

      if (_discussion.isPublic == true && _discussion.discussionType == DiscussionType.hosted) {
        final confirmed = await verifyAvailableForDiscussion(discussion);
        if (!confirmed) return;
      } else if (_discussion.discussionType == DiscussionType.livestream &&
          _discussion.liveStreamInfo == null) {
        PrivateLiveStreamInfo privateLiveStreamInfo = await _processLiveStreamInfoForDiscussion();
        await firestoreDiscussionService.addLiveStreamDiscussionDetails(
          discussion: _discussion,
          privateLiveStreamInfo: privateLiveStreamInfo,
        );
      }
    }

    await firestoreDiscussionService.updateDiscussion(
      discussion: _discussion,
      keys: [
        Discussion.kFieldDiscussionType,
        Discussion.kFieldScheduledTime,
        Discussion.kFieldIsPublic,
        Discussion.kFieldTitle,
        Discussion.kFieldMinParticipants,
        Discussion.kFieldMaxParticipants,
        Discussion.kFieldLiveStreamInfo,
      ],
    );

    analytics.logEvent(AnalyticsEditEventEvent(
      juntoId: juntoProvider.junto.id,
      discussionId: _discussion.id,
      guideId: _discussion.topicId,
    ));
  }

  Future<PrivateLiveStreamInfo> _processLiveStreamInfoForDiscussion() async {
    final liveStreamResponse =
        await cloudFunctionsService.createLiveStream(juntoId: juntoProvider.juntoId);

    _discussion = _discussion.copyWith(
        liveStreamInfo: LiveStreamInfo(
      muxId: liveStreamResponse.muxId,
      muxPlaybackId: liveStreamResponse.muxPlaybackId,
    ));

    return PrivateLiveStreamInfo(
      streamServerUrl: liveStreamResponse.streamServerUrl,
      streamKey: liveStreamResponse.streamKey,
    );
  }
}
