import 'package:client/core/utils/image_utils.dart';
import 'package:client/features/community/utils/guard_utils.dart';
import 'package:flutter/material.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/providers/meeting_agenda_provider.dart';
import 'package:client/features/events/features/event_page/data/providers/template_provider.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/utils/visible_exception.dart';
import 'package:client/services.dart';
import 'package:data_models/analytics/analytics_entities.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/templates/template.dart';
import 'package:pedantic/pedantic.dart';

import '../../../event_page/data/providers/event_page_provider.dart';

enum CurrentPage {
  selectTemplate,
  selectVisibility,
  selectDate,
  selectTime,
  selectParticipants,
  selectTitle,
  selectHostingType,
  choosePlatform,
}

/// Holds logic for the CreateEventDialog class.
class CreateEventDialogModel with ChangeNotifier {
  final CommunityProvider communityProvider;
  final EventProvider? eventProvider;
  final List<CurrentPage>? pages;
  final Template? initialTemplate;
  final Event? eventTemplate;
  final EventType eventType;

  CreateEventDialogModel({
    required this.communityProvider,
    this.eventProvider,
    this.pages,
    this.initialTemplate,
    this.eventType = EventType.hosted,
    this.eventTemplate,
  });

  Template? _selectedTemplate;
  late Event _event;

  int _currentPage = 0;

  Event get event => _event;

  DateTime? get scheduledTime => event.scheduledTime;

  bool get isEdit => eventProvider != null;

  Template? get selectedTemplate => _selectedTemplate;

  CurrentPage get currentPageInfo => allPages[_currentPage];

  /// The list of pages that this dialog will show. For editing the caller passes in what pages
  /// to show, otherwise we use the default creation flow.
  List<CurrentPage> get allPages =>
      pages ??
      [
        if (initialTemplate == null) CurrentPage.selectTemplate,
        CurrentPage.selectVisibility,
        CurrentPage.selectDate,
        CurrentPage.selectTime,
      ];

  bool get allowBack => currentPageIndex > 0;

  int get currentPageIndex => _currentPage;

  bool get isFinalPage => currentPageIndex == allPages.length - 1;

  late EventType _eventTypeWhenEventWasCreated;

  void initialize() {
    if (isEdit) {
      _event = eventProvider!.event;
      _eventTypeWhenEventWasCreated = _event.eventType;
    } else {
      _selectedTemplate = initialTemplate;

      final now = clockService.now();
      final nowWithoutSeconds = now.subtract(
        Duration(seconds: now.second, milliseconds: now.millisecond),
      );

      _event = Event(
        id: firestoreDatabase.generateNewDocId(
          collectionPath: firestoreEventService
              .eventsCollection(
                communityId: communityProvider.communityId,
                templateId: _selectedTemplate?.id ?? defaultTemplateId,
              )
              .path,
        ),
        // These required fields get overwritten when the event is actually created
        collectionPath: '',
        templateId: '',
        status: EventStatus.active,
        communityId: communityProvider.communityId,
        creatorId: userService.currentUserId!,
        scheduledTime:
            nowWithoutSeconds.add(Duration(minutes: 60 - now.minute)),
        nullableEventType: eventType,
        isPublic: false,
        title: eventTemplate?.title,
        description: eventTemplate?.description,
        image: eventTemplate?.image,
        minParticipants: eventTemplate?.minParticipants,
        maxParticipants: eventTemplate?.maxParticipants,
        agendaItems: eventTemplate?.agendaItems ?? [],
        preEventCardData: eventTemplate?.preEventCardData,
        postEventCardData: eventTemplate?.postEventCardData,
        prerequisiteTemplateId: eventTemplate?.prerequisiteTemplateId,
        breakoutRoomDefinition: eventTemplate?.breakoutRoomDefinition,
        waitingRoomInfo: eventTemplate?.waitingRoomInfo,
        eventSettings:
            _selectedTemplate?.eventSettings ?? communityProvider.eventSettings,
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

  void setTemplate(Template template) {
    _selectedTemplate = template;
    notifyListeners();
  }

  void updateScheduledTime(DateTime date) {
    _event = _event.copyWith(scheduledTime: date);
    notifyListeners();
  }

  void updateVisibility({required bool isPublic}) {
    _event = _event.copyWith(isPublic: isPublic);
    notifyListeners();
  }

  void setEvent(Event event) {
    _event = event;
    notifyListeners();
  }

  void updateEventType(EventType type) {
    _event = _event.copyWith(nullableEventType: type);
    notifyListeners();
  }

  Future<Event?> submit(BuildContext context) async {
    Future<Event?> localSubmit() async {
      if (isEdit) {
        await _updateEvent();
        return null;
      } else {
        return await _createEvent();
      }
    }

    if (_event.isPublic) {
      return await guardCommunityMember<Event?>(
        context,
        communityProvider.community,
        localSubmit,
      );
    } else {
      return await localSubmit();
    }
  }

  Future<Event?> _createEvent() async {
    final agendaItemsCandidates = [
      _event.agendaItems,
      _selectedTemplate?.agendaItems ?? [],
      defaultAgendaItems(communityProvider.communityId)
          .map((item) => item.copyWith())
          .toList(),
    ];
    final agendaItems =
        agendaItemsCandidates.firstWhere((items) => items.isNotEmpty).toList();

    if (_event.isPublic == true && eventType == EventType.hosted) {
      final confirmed = await verifyAvailableForEvent(event);
      if (!confirmed) return null;
    }

    List<AgendaItem> templateAgendaItems = _event.agendaItems;
    if (templateAgendaItems.isEmpty) {
      templateAgendaItems = _selectedTemplate?.agendaItems ?? [];
    }

    _event = _event.copyWith(
      communityId: communityProvider.communityId,
      templateId: selectedTemplate?.id ?? defaultTemplateId,
      title: _event.title ?? selectedTemplate?.title ?? 'My Custom Event',
      description: _event.description ?? selectedTemplate?.description ?? '',
      image:
          _event.image ?? selectedTemplate?.image ?? generateRandomImageUrl(),
      minParticipants: _event.minParticipants ?? Event.defaultMinParticipants,
      maxParticipants: _event.maxParticipants ??
          (eventType == EventType.hosted
              ? Event.defaultMaxParticipants
              : Event.defaultMaxParticipantsInHostlessEvent),
      isLocked: false,
      agendaItems: agendaItems,
      preEventCardData:
          _event.preEventCardData ?? selectedTemplate?.preEventCardData,
      postEventCardData:
          _event.postEventCardData ?? selectedTemplate?.postEventCardData,
      prerequisiteTemplateId: _event.prerequisiteTemplateId ??
          selectedTemplate?.prerequisiteTemplateId,
      eventSettings:
          _selectedTemplate?.eventSettings ?? communityProvider.eventSettings,
    );

    PrivateLiveStreamInfo? privateLiveStreamInfo;

    if (_event.eventType == EventType.livestream) {
      privateLiveStreamInfo = await _processLiveStreamInfoForEvent();
    }

    _event = await firestoreEventService.createEventIfNotExists(
      event: _event,
      privateLiveStreamInfo: privateLiveStreamInfo,
    );
    unawaited(cloudFunctionsEventService.createEvent(_event));

    analytics.logEvent(
      AnalyticsCreateEventEvent(
        communityId: communityProvider.community.id,
        eventId: _event.id,
        guideId: _event.templateId,
      ),
    );

    final time = _event.scheduledTime;
    if (time != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final scheduledDay = DateTime(time.year, time.month, time.day);
      analytics.logEvent(
        AnalyticsScheduleEventEvent(
          communityId: communityProvider.community.id,
          eventId: _event.id,
          daysFromNow: today.difference(scheduledDay).inDays,
          guideId: _event.templateId,
        ),
      );
    }

    final analyticsEvent = _event.eventType == EventType.livestream
        ? 'create_event'
        : 'create_live_stream';
    unawaited(
      swallowErrors(
        () => firebaseAnalytics.logEvent(
          name: analyticsEvent,
          parameters: {'public': _event.isPublic.toString()},
        ),
      ),
    );

    return _event;
  }

  Future<void> _updateEvent() async {
    final maxParticipants = _event.maxParticipants;
    final participantCount = eventProvider?.participantCount;

    if (_event.eventType != EventType.livestream &&
        maxParticipants != null &&
        participantCount != null &&
        maxParticipants < participantCount) {
      throw VisibleException(
        'Cannot lower the number of participants below the current number registered.',
      );
    }

    if (_event.scheduledTime == null) {
      throw VisibleException('You must select a time.');
    }

    if (_eventTypeWhenEventWasCreated != _event.eventType) {
      _event = _event.copyWith(
        maxParticipants: _event.eventType == EventType.hosted
            ? Event.defaultMaxParticipants
            : Event.defaultMaxParticipantsInHostlessEvent,
      );

      if (_event.isPublic == true && _event.eventType == EventType.hosted) {
        final confirmed = await verifyAvailableForEvent(event);
        if (!confirmed) return;
      } else if (_event.eventType == EventType.livestream &&
          _event.liveStreamInfo == null) {
        PrivateLiveStreamInfo privateLiveStreamInfo =
            await _processLiveStreamInfoForEvent();
        await firestoreEventService.addLiveStreamEventDetails(
          event: _event,
          privateLiveStreamInfo: privateLiveStreamInfo,
        );
      }
    }

    await firestoreEventService.updateEvent(
      event: _event,
      keys: [
        Event.kFieldEventType,
        Event.kFieldScheduledTime,
        Event.kFieldIsPublic,
        Event.kFieldTitle,
        Event.kFieldMinParticipants,
        Event.kFieldMaxParticipants,
        Event.kFieldLiveStreamInfo,
      ],
    );

    analytics.logEvent(
      AnalyticsEditEventEvent(
        communityId: communityProvider.community.id,
        eventId: _event.id,
        guideId: _event.templateId,
      ),
    );
  }

  Future<PrivateLiveStreamInfo> _processLiveStreamInfoForEvent() async {
    final liveStreamResponse =
        await cloudFunctionsLiveMeetingService.createLiveStream(
      communityId: communityProvider.communityId,
    );

    _event = _event.copyWith(
      liveStreamInfo: LiveStreamInfo(
        muxId: liveStreamResponse.muxId,
        muxPlaybackId: liveStreamResponse.muxPlaybackId,
      ),
    );

    return PrivateLiveStreamInfo(
      streamServerUrl: liveStreamResponse.streamServerUrl,
      streamKey: liveStreamResponse.streamKey,
    );
  }
}
