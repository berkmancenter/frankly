import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:junto/app/junto/community_permissions_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_page_provider.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/services/firestore/firestore_database.dart';
import 'package:junto/services/firestore/firestore_discussion_service.dart';
import 'package:junto/services/firestore/firestore_utils.dart';
import 'package:junto/services/responsive_layout_service.dart';
import 'package:junto/services/services.dart';
import 'package:junto/utils/dialogs.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:provider/provider.dart';

import 'edit_discussion_contract.dart';
import 'edit_discussion_model.dart';

class EditDiscussionPresenter {
  final EditDiscussionView _view;
  final EditDiscussionModel _model;
  final EditDiscussionPresenterHelper _helper;
  final AppDrawerProvider _appDrawerProvider;
  final DiscussionPageProvider _discussionPageProvider;
  final JuntoProvider _juntoProvider;
  final CommunityPermissionsProvider _communityPermissionsProvider;
  final ResponsiveLayoutService _responsiveLayoutService;
  final FirestoreDiscussionService _firestoreDiscussionService;
  final FirestoreDatabase _firestoreDatabase;

  EditDiscussionPresenter(
    BuildContext context,
    this._view,
    this._model, {
    EditDiscussionPresenterHelper? editDiscussionPresenterHelper,
    AppDrawerProvider? appDrawerProvider,
    DiscussionPageProvider? discussionPageProvider,
    JuntoProvider? juntoProvider,
    CommunityPermissionsProvider? communityPermissionsProvider,
    ResponsiveLayoutService? responsiveLayoutService,
    FirestoreDiscussionService? firestoreDiscussionService,
    FirestoreDatabase? firestoreDatabase,
  })  : _helper = editDiscussionPresenterHelper ?? EditDiscussionPresenterHelper(),
        _appDrawerProvider = appDrawerProvider ?? context.read<AppDrawerProvider>(),
        _discussionPageProvider = discussionPageProvider ?? context.read<DiscussionPageProvider>(),
        _juntoProvider = juntoProvider ?? context.read<JuntoProvider>(),
        _communityPermissionsProvider =
            communityPermissionsProvider ?? context.read<CommunityPermissionsProvider>(),
        _responsiveLayoutService =
            responsiveLayoutService ?? GetIt.instance<ResponsiveLayoutService>(),
        _firestoreDiscussionService =
            firestoreDiscussionService ?? GetIt.instance<FirestoreDiscussionService>(),
        _firestoreDatabase = firestoreDatabase ?? GetIt.instance<FirestoreDatabase>();

  void init() {
    _appDrawerProvider.setOnSaveChanges(onSaveChanges: saveChanges);

    _model.discussion = _discussionPageProvider.discussionProvider.discussion;
    _model.initialDiscussion = _discussionPageProvider.discussionProvider.discussion;

    _discussionPageProvider.discussionProvider.addListener(_listenForByovChanges);

    _view.updateView();
  }

  void dispose() {
    _discussionPageProvider.discussionProvider.removeListener(_listenForByovChanges);
  }

  void _listenForByovChanges() {
    if (_model.discussion.externalPlatform !=
        _discussionPageProvider.discussionProvider.discussion.externalPlatform) {
      _model.discussion = _model.discussion.copyWith(
        externalPlatform: _discussionPageProvider.discussionProvider.discussion.externalPlatform,
      );
      _view.updateView();
    }
  }

  void updateDiscussionType(DiscussionType value) {
    _model.discussion = _model.discussion.copyWith(nullableDiscussionType: value);
    _appDrawerProvider.setUnsavedChanges(_helper.wereChangesMade(_model));
    _view.updateView();
  }

  String getDiscussionTypeTitle(DiscussionType discussionType) {
    switch (discussionType) {
      case DiscussionType.hosted:
        return 'Hosted';
      case DiscussionType.hostless:
        return 'Hostless';
      case DiscussionType.livestream:
        return 'Livestream';
    }
  }

  List<Duration> get durationOptions {
    const increment = Duration(minutes: 15);
    const threshold = Duration(hours: 4);
    return [
      for (var duration = increment; duration < threshold; duration = duration + increment) duration
    ];
  }

  void updateTitle(String value) {
    _model.discussion = _model.discussion.copyWith(title: value.trim());
    _appDrawerProvider.setUnsavedChanges(_helper.wereChangesMade(_model));
    _view.updateView();
  }

  void updateDescription(String value) {
    _model.discussion = _model.discussion.copyWith(description: value.trim());
    _appDrawerProvider.setUnsavedChanges(_helper.wereChangesMade(_model));
    _view.updateView();
  }

  void updateIsPublic(bool value) {
    _model.discussion = _model.discussion.copyWith(isPublic: value);
    _appDrawerProvider.setUnsavedChanges(_helper.wereChangesMade(_model));
    _view.updateView();
  }

  void updateDate(DateTime dateTime) {
    final timeOfDay = TimeOfDay.fromDateTime(_model.discussion.scheduledTime ?? clock.now());

    // Since we pick only date (year, month, day), make sure we update only
    // year, month and day and don't override the time.
    final updatedDateTime = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    _model.discussion = _model.discussion.copyWith(scheduledTime: updatedDateTime);
    _appDrawerProvider.setUnsavedChanges(_helper.wereChangesMade(_model));
    _view.updateView();
  }

  void updateTime(TimeOfDay timeOfDay) {
    final currentlySelectedTime = _model.discussion.scheduledTime ?? clock.now();
    final updatedDateTime = DateTime(
      currentlySelectedTime.year,
      currentlySelectedTime.month,
      currentlySelectedTime.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    _model.discussion = _model.discussion.copyWith(scheduledTime: updatedDateTime);
    _appDrawerProvider.setUnsavedChanges(_helper.wereChangesMade(_model));
    _view.updateView();
  }

  void updateIsFeatured(bool value) {
    _model.isFeatured = value;
    _appDrawerProvider.setUnsavedChanges(_helper.wereChangesMade(_model));
    _view.updateView();
  }

  void updateMaxParticipants(double selectedNumber) {
    _model.discussion = _model.discussion.copyWith(maxParticipants: selectedNumber.toInt());
    _appDrawerProvider.setUnsavedChanges(_helper.wereChangesMade(_model));
    _view.updateView();
  }

  void updateEventDuration(Duration duration) {
    _model.discussion = _model.discussion.copyWith(durationInMinutes: duration.inMinutes);
    _appDrawerProvider.setUnsavedChanges(_helper.wereChangesMade(_model));
    _view.updateView();
  }

  bool isMobile(BuildContext context) {
    return _responsiveLayoutService.isMobile(context);
  }

  bool get showFeatureToggle => _communityPermissionsProvider.canFeatureItems;

  bool isPlatformSelectionFeatureEnabled() {
    return _juntoProvider.settings.enablePlatformSelection;
  }

  Future<void> saveChanges() async {
    final validationError = _helper.areChangesValid(_model.discussion);
    if (validationError != null) {
      _view.showMessage(validationError, toastType: ToastType.failed);
      _appDrawerProvider.hideConfirmChangesDialogLayer();
      return;
    }

    final junto = _juntoProvider.junto;
    final discussionDocPath = getDiscussionDocumentPath();

    // It might be little confusing here. We are not only updating discussion doc,
    // but also updating featured state.
    await Future.wait([
      if (_communityPermissionsProvider.canFeatureItems)
        _firestoreDatabase.updateFeaturedItem(
          juntoId: junto.id,
          documentId: _model.discussion.id,
          featured: Featured(
            documentPath: discussionDocPath,
            featuredType: FeaturedType.conversation,
          ),
          isFeatured: _model.isFeatured ?? false,
        ),
      _updateDiscussion(),
    ]);

    _view.closeDrawer();
  }

  Future<void> _updateDiscussion() async {
    final addLivesStreamInfo = _model.discussion.discussionType == DiscussionType.livestream &&
        _model.discussion.liveStreamInfo == null;

    if (addLivesStreamInfo) {
      final liveStreamResponse =
          await cloudFunctionsService.createLiveStream(juntoId: _juntoProvider.juntoId);

      _model.discussion = _model.discussion.copyWith(
        liveStreamInfo: LiveStreamInfo(
          muxId: liveStreamResponse.muxId,
          muxPlaybackId: liveStreamResponse.muxPlaybackId,
        ),
      );

      final privateLiveStreamInfo = PrivateLiveStreamInfo(
        streamServerUrl: liveStreamResponse.streamServerUrl,
        streamKey: liveStreamResponse.streamKey,
      );

      await _firestoreDiscussionService.addLiveStreamDiscussionDetails(
        discussion: _model.discussion,
        privateLiveStreamInfo: privateLiveStreamInfo,
      );
    }

    await _firestoreDiscussionService.updateDiscussion(
      discussion: _model.discussion,
      keys: [
        Discussion.kFieldDiscussionType,
        Discussion.kFieldTitle,
        Discussion.kFieldImage,
        Discussion.kFieldDescription,
        Discussion.kFieldIsPublic,
        Discussion.kFieldScheduledTime,
        Discussion.kFieldMaxParticipants,
        Discussion.kDurationInMinutes,
        if (addLivesStreamInfo) Discussion.kFieldLiveStreamInfo,
      ],
    );
  }

  bool isFeatured(List<Featured>? featuredItems) {
    final discussionDocPath = getDiscussionDocumentPath();
    return featuredItems == null
        ? false
        : featuredItems.any((f) => f.documentPath == discussionDocPath);
  }

  BehaviorSubjectWrapper<List<Featured>>? getFeaturedStream() {
    final juntoId = _juntoProvider.junto.id;
    return _firestoreDatabase.getJuntoFeaturedItems(juntoId);
  }

  String getDiscussionDocumentPath() {
    return '${_model.discussion.collectionPath}/${_model.discussion.id}';
  }

  void updateImage(String url) {
    _model.discussion = _model.discussion.copyWith(image: url);
    _appDrawerProvider.setUnsavedChanges(_helper.wereChangesMade(_model));
    _view.updateView();
  }

  Future<void> cancelEvent() async {
    final bool isSuccess = await _discussionPageProvider.cancelDiscussion();
    if (isSuccess) _view.closeDrawer();
  }

  bool wereChangesMade() {
    return _helper.wereChangesMade(_model);
  }

  void showConfirmChangesDialog() {
    _appDrawerProvider.showConfirmChangesDialogLayer();
  }

  bool canBuildParticipantCountSection() {
    switch (_model.discussion.discussionType) {
      case DiscussionType.hosted:
        return true;
      case DiscussionType.hostless:
      case DiscussionType.livestream:
        return false;
    }
  }
}

@visibleForTesting
class EditDiscussionPresenterHelper {
  String? areChangesValid(Discussion discussion) {
    final title = discussion.title;
    if (title == null || title.isEmpty) {
      return 'Title cannot be empty';
    }

    return null;
  }

  bool wereChangesMade(EditDiscussionModel model) {
    return model.discussion != model.initialDiscussion || model.isFeatured != model.initialFeatured;
  }
}
