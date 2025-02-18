import 'package:client/core/utils/toast_utils.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:client/features/community/data/providers/community_permissions_provider.dart';
import 'package:client/features/events/features/event_page/data/providers/event_page_provider.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/data/services/firestore_database.dart';
import 'package:client/features/events/data/services/firestore_event_service.dart';
import 'package:client/core/utils/firestore_utils.dart';
import 'package:client/core/data/services/responsive_layout_service.dart';
import 'package:client/services.dart';
import 'package:client/core/utils/dialogs.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/community/community.dart';
import 'package:provider/provider.dart';

import 'views/edit_event_contract.dart';
import '../data/models/edit_event_model.dart';

class EditEventPresenter {
  final EditEventView _view;
  final EditEventModel _model;
  final EditEventPresenterHelper _helper;
  final AppDrawerProvider _appDrawerProvider;
  final EventPageProvider _eventPageProvider;
  final CommunityProvider _communityProvider;
  final CommunityPermissionsProvider _communityPermissionsProvider;
  final ResponsiveLayoutService _responsiveLayoutService;
  final FirestoreEventService _firestoreEventService;
  final FirestoreDatabase _firestoreDatabase;

  EditEventPresenter(
    BuildContext context,
    this._view,
    this._model, {
    EditEventPresenterHelper? editEventPresenterHelper,
    AppDrawerProvider? appDrawerProvider,
    EventPageProvider? eventPageProvider,
    CommunityProvider? communityProvider,
    CommunityPermissionsProvider? communityPermissionsProvider,
    ResponsiveLayoutService? responsiveLayoutService,
    FirestoreEventService? firestoreEventService,
    FirestoreDatabase? firestoreDatabase,
  })  : _helper = editEventPresenterHelper ?? EditEventPresenterHelper(),
        _appDrawerProvider =
            appDrawerProvider ?? context.read<AppDrawerProvider>(),
        _eventPageProvider =
            eventPageProvider ?? context.read<EventPageProvider>(),
        _communityProvider =
            communityProvider ?? context.read<CommunityProvider>(),
        _communityPermissionsProvider = communityPermissionsProvider ??
            context.read<CommunityPermissionsProvider>(),
        _responsiveLayoutService = responsiveLayoutService ??
            GetIt.instance<ResponsiveLayoutService>(),
        _firestoreEventService =
            firestoreEventService ?? GetIt.instance<FirestoreEventService>(),
        _firestoreDatabase =
            firestoreDatabase ?? GetIt.instance<FirestoreDatabase>();

  void init() {
    _appDrawerProvider.setOnSaveChanges(onSaveChanges: saveChanges);

    _model.event = _eventPageProvider.eventProvider.event;
    _model.initialEvent = _eventPageProvider.eventProvider.event;

    _eventPageProvider.eventProvider.addListener(_listenForByovChanges);

    _view.updateView();
  }

  void dispose() {
    _eventPageProvider.eventProvider.removeListener(_listenForByovChanges);
  }

  void _listenForByovChanges() {
    if (_model.event.externalPlatform !=
        _eventPageProvider.eventProvider.event.externalPlatform) {
      _model.event = _model.event.copyWith(
        externalPlatform:
            _eventPageProvider.eventProvider.event.externalPlatform,
      );
      _view.updateView();
    }
  }

  void updateEventType(EventType value) {
    _model.event = _model.event.copyWith(nullableEventType: value);
    _appDrawerProvider.setUnsavedChanges(_helper.wereChangesMade(_model));
    _view.updateView();
  }

  String getEventTypeTitle(EventType eventType) {
    switch (eventType) {
      case EventType.hosted:
        return 'Hosted';
      case EventType.hostless:
        return 'Hostless';
      case EventType.livestream:
        return 'Livestream';
    }
  }

  List<Duration> get durationOptions {
    const increment = Duration(minutes: 15);
    const threshold = Duration(hours: 4);
    return [
      for (var duration = increment;
          duration < threshold;
          duration = duration + increment)
        duration,
    ];
  }

  void updateTitle(String value) {
    _model.event = _model.event.copyWith(title: value.trim());
    _appDrawerProvider.setUnsavedChanges(_helper.wereChangesMade(_model));
    _view.updateView();
  }

  void updateDescription(String value) {
    _model.event = _model.event.copyWith(description: value.trim());
    _appDrawerProvider.setUnsavedChanges(_helper.wereChangesMade(_model));
    _view.updateView();
  }

  void updateIsPublic(bool value) {
    _model.event = _model.event.copyWith(isPublic: value);
    _appDrawerProvider.setUnsavedChanges(_helper.wereChangesMade(_model));
    _view.updateView();
  }

  void updateDate(DateTime dateTime) {
    final timeOfDay =
        TimeOfDay.fromDateTime(_model.event.scheduledTime ?? clock.now());

    // Since we pick only date (year, month, day), make sure we update only
    // year, month and day and don't override the time.
    final updatedDateTime = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    _model.event = _model.event.copyWith(scheduledTime: updatedDateTime);
    _appDrawerProvider.setUnsavedChanges(_helper.wereChangesMade(_model));
    _view.updateView();
  }

  void updateTime(TimeOfDay timeOfDay) {
    final currentlySelectedTime = _model.event.scheduledTime ?? clock.now();
    final updatedDateTime = DateTime(
      currentlySelectedTime.year,
      currentlySelectedTime.month,
      currentlySelectedTime.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    _model.event = _model.event.copyWith(scheduledTime: updatedDateTime);
    _appDrawerProvider.setUnsavedChanges(_helper.wereChangesMade(_model));
    _view.updateView();
  }

  void updateIsFeatured(bool value) {
    _model.isFeatured = value;
    _appDrawerProvider.setUnsavedChanges(_helper.wereChangesMade(_model));
    _view.updateView();
  }

  void updateMaxParticipants(double selectedNumber) {
    _model.event =
        _model.event.copyWith(maxParticipants: selectedNumber.toInt());
    _appDrawerProvider.setUnsavedChanges(_helper.wereChangesMade(_model));
    _view.updateView();
  }

  void updateEventDuration(Duration duration) {
    _model.event = _model.event.copyWith(durationInMinutes: duration.inMinutes);
    _appDrawerProvider.setUnsavedChanges(_helper.wereChangesMade(_model));
    _view.updateView();
  }

  bool isMobile(BuildContext context) {
    return _responsiveLayoutService.isMobile(context);
  }

  bool get showFeatureToggle => _communityPermissionsProvider.canFeatureItems;

  bool isPlatformSelectionFeatureEnabled() {
    return _communityProvider.settings.enablePlatformSelection;
  }

  Future<void> saveChanges() async {
    final validationError = _helper.areChangesValid(_model.event);
    if (validationError != null) {
      _view.showMessage(validationError, toastType: ToastType.failed);
      _appDrawerProvider.hideConfirmChangesDialogLayer();
      return;
    }

    final community = _communityProvider.community;
    final eventDocPath = getEventDocumentPath();

    // It might be little confusing here. We are not only updating event doc,
    // but also updating featured state.
    await Future.wait([
      if (_communityPermissionsProvider.canFeatureItems)
        _firestoreDatabase.updateFeaturedItem(
          communityId: community.id,
          documentId: _model.event.id,
          featured: Featured(
            documentPath: eventDocPath,
            featuredType: FeaturedType.event,
          ),
          isFeatured: _model.isFeatured ?? false,
        ),
      _updateEvent(),
    ]);

    _view.closeDrawer();
  }

  Future<void> _updateEvent() async {
    final addLivesStreamInfo = _model.event.eventType == EventType.livestream &&
        _model.event.liveStreamInfo == null;

    if (addLivesStreamInfo) {
      final liveStreamResponse =
          await cloudFunctionsLiveMeetingService.createLiveStream(
        communityId: _communityProvider.communityId,
      );

      _model.event = _model.event.copyWith(
        liveStreamInfo: LiveStreamInfo(
          muxId: liveStreamResponse.muxId,
          muxPlaybackId: liveStreamResponse.muxPlaybackId,
        ),
      );

      final privateLiveStreamInfo = PrivateLiveStreamInfo(
        streamServerUrl: liveStreamResponse.streamServerUrl,
        streamKey: liveStreamResponse.streamKey,
      );

      await _firestoreEventService.addLiveStreamEventDetails(
        event: _model.event,
        privateLiveStreamInfo: privateLiveStreamInfo,
      );
    }

    await _firestoreEventService.updateEvent(
      event: _model.event,
      keys: [
        Event.kFieldEventType,
        Event.kFieldTitle,
        Event.kFieldImage,
        Event.kFieldDescription,
        Event.kFieldIsPublic,
        Event.kFieldScheduledTime,
        Event.kFieldMaxParticipants,
        Event.kDurationInMinutes,
        if (addLivesStreamInfo) Event.kFieldLiveStreamInfo,
      ],
    );
  }

  bool isFeatured(List<Featured>? featuredItems) {
    final eventDocPath = getEventDocumentPath();
    return featuredItems == null
        ? false
        : featuredItems.any((f) => f.documentPath == eventDocPath);
  }

  BehaviorSubjectWrapper<List<Featured>>? getFeaturedStream() {
    final communityId = _communityProvider.community.id;
    return _firestoreDatabase.getCommunityFeaturedItems(communityId);
  }

  String getEventDocumentPath() {
    return '${_model.event.collectionPath}/${_model.event.id}';
  }

  void updateImage(String url) {
    _model.event = _model.event.copyWith(image: url);
    _appDrawerProvider.setUnsavedChanges(_helper.wereChangesMade(_model));
    _view.updateView();
  }

  Future<void> cancelEvent() async {
    final bool isSuccess = await _eventPageProvider.cancelEvent();
    if (isSuccess) _view.closeDrawer();
  }

  bool wereChangesMade() {
    return _helper.wereChangesMade(_model);
  }

  void showConfirmChangesDialog() {
    _appDrawerProvider.showConfirmChangesDialogLayer();
  }

  bool canBuildParticipantCountSection() {
    switch (_model.event.eventType) {
      case EventType.hosted:
        return true;
      case EventType.hostless:
      case EventType.livestream:
        return false;
    }
  }
}

@visibleForTesting
class EditEventPresenterHelper {
  String? areChangesValid(Event event) {
    final title = event.title;
    if (title == null || title.isEmpty) {
      return 'Title cannot be empty';
    }

    return null;
  }

  bool wereChangesMade(EditEventModel model) {
    return model.event != model.initialEvent ||
        model.isFeatured != model.initialFeatured;
  }
}
