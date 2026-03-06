import 'package:client/core/utils/toast_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:client/features/community/data/providers/community_permissions_provider.dart';
import 'package:client/features/events/features/event_page/data/providers/event_permissions_provider.dart';
import 'package:client/features/events/features/live_meeting/data/providers/live_meeting_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/data/providers/meeting_guide_card_store.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_image_data.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_poll_data.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_text_data.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_user_suggestions_data.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_video_data.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_word_cloud_data.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/providers/meeting_agenda_provider.dart';
import 'package:client/features/templates/data/providers/template_page_provider.dart';
import 'package:client/core/utils/visible_exception.dart';
import 'package:client/services.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/templates/template.dart';
import 'package:provider/provider.dart';

import 'views/agenda_item_contract.dart';
import '../data/models/agenda_item_model.dart';

class AgendaItemPresenter {
  final AgendaItemView _view;
  final AgendaItemModel _model;
  final AgendaItemHelper _helper;
  final AgendaProvider _agendaProvider;
  final MeetingGuideCardStore? _meetingGuideCardModel;
  final EventPermissionsProvider? _eventPermissionsProvider;
  final CommunityPermissionsProvider _communityPermissionsProvider;
  final LiveMeetingProvider? _liveMeetingProvider;

  AgendaItemPresenter(
    BuildContext context,
    this._view,
    this._model, {
    AgendaItemHelper? agendaItemPresenterHelper,
    AgendaProvider? agendaProvider,
    MeetingGuideCardStore? meetingGuideCardStore,
    LiveMeetingProvider? liveMeetingProvider,
    EventPermissionsProvider? eventPermissionsProvider,
    CommunityPermissionsProvider? communityPermissionsProvider,
    TemplatePageProvider? templatePageProvider,
  })  : _helper = agendaItemPresenterHelper ?? AgendaItemHelper(),
        _agendaProvider = agendaProvider ?? context.read<AgendaProvider>(),
        _meetingGuideCardModel =
            meetingGuideCardStore ?? MeetingGuideCardStore.read(context),
        _eventPermissionsProvider =
            eventPermissionsProvider ?? EventPermissionsProvider.read(context),
        _liveMeetingProvider =
            liveMeetingProvider ?? LiveMeetingProvider.readOrNull(context),
        _communityPermissionsProvider = communityPermissionsProvider ??
            context.read<CommunityPermissionsProvider>();

  void init() {
    _helper.initialiseFields(_model);
    _view.updateView();
  }

  bool isCardActive() {
    return _agendaProvider.isCurrentAgendaItem(_model.agendaItem.id);
  }

  bool isPlayingVideo() {
    return _helper.isPlayingVideo(_meetingGuideCardModel, _agendaProvider);
  }

  bool isCompleted() {
    return _agendaProvider.isCompleted(_model.agendaItem.id);
  }

  bool isCollapsed() {
    return _agendaProvider.collapsedAgendaItemIds
        .contains(_model.agendaItem.id);
  }

  void changeAgendaType(AgendaItemType type) {
    switch (type) {
      case AgendaItemType.text:
        _model.agendaItemTextData = AgendaItemTextData.newItem();
        break;
      case AgendaItemType.video:
        _model.agendaItemVideoData = AgendaItemVideoData.newItem();
        break;
      case AgendaItemType.image:
        _model.agendaItemImageData = AgendaItemImageData.newItem();
        break;
      case AgendaItemType.poll:
        _model.agendaItemPollData = AgendaItemPollData.newItem();
        break;
      case AgendaItemType.wordCloud:
        _model.agendaItemWordCloudData = AgendaItemWordCloudData.newItem();
        break;
      case AgendaItemType.userSuggestions:
        _model.agendaItemUserSuggestionsData =
            AgendaItemUserSuggestionsData.newItem();
        break;
    }

    _model.agendaItem = _model.agendaItem.copyWith(nullableType: type);
    _view.updateView();
  }

  bool hasBeenEdited() {
    return _helper.hasBeenEdited(_model);
  }

  String getFormattedDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    final parts = <String>[
      if (duration.inHours > 0) ...[
        duration.inHours.toString(),
        twoDigits(minutes),
      ] else
        minutes.toString(),
      twoDigits(seconds),
    ];
    return parts.join(':');
  }

  void duplicateCard() {
    _agendaProvider.addNewUnsavedItem(agendaItem: _model.agendaItem);
    _view.showMessage(
      'Agenda item was duplicated!',
      toastType: ToastType.success,
    );
  }

  Future<void> saveContent() async {
    final agendaItemType = _model.agendaItem.type;

    final errorMessage = _helper.areRequiredFieldsInput(_model);
    if (errorMessage != null) {
      _view.showMessage(errorMessage, toastType: ToastType.failed);
      return;
    }

    final bool wasEdited = isCardUnsaved() || _helper.hasBeenEdited(_model);

    if (wasEdited) {
      if (_model.agendaItem.type == AgendaItemType.poll &&
          _model.agendaItemPollData.answers.length !=
              _model.agendaItemPollData.answers.toSet().length) {
        throw VisibleException('Please remove duplicate answers.');
      }

      String title = '';
      String content = '';
      String buttonText = '';

      // Very confusing set-up. Potentially because of tech. debt from Agenda Item data type.
      // Due to different types, we have combination of data into one data item (AgendaItem).
      // For where `text` has `title` in its data, `word cloud` doesn't. It might be tricky to understand
      // what `title` really is since we have its concept in `data model (Agenda Item)` and UI.
      //
      // TL;DR
      // `title` as a data field is only saved for those items where item `seems to have` a title.
      // For others (poll, WC) - only content is saved and `title` is left blank.
      // For those items where `title` does not exist (isEmpty) we render text in UI (getTitle() method).
      switch (agendaItemType) {
        case AgendaItemType.text:
          title = _model.agendaItemTextData.title;
          content = _model.agendaItemTextData.content;
          break;
        case AgendaItemType.video:
          title = _model.agendaItemVideoData.title;
          break;
        case AgendaItemType.image:
          title = _model.agendaItemImageData.title;
          break;
        case AgendaItemType.poll:
          content = _model.agendaItemPollData.question;
          break;
        case AgendaItemType.wordCloud:
          content = _model.agendaItemWordCloudData.prompt;
          break;
        case AgendaItemType.userSuggestions:
          title = _model.agendaItemUserSuggestionsData.headline;
          break;
      }

      final AgendaItem updatedItem = _model.agendaItem.copyWith(
        title: title,
        content: content,
        videoType: _model.agendaItemVideoData.type,
        videoUrl: _model.agendaItemVideoData.url,
        imageUrl: _model.agendaItemImageData.url,
        pollAnswers: List.from(_model.agendaItemPollData.answers),
        timeInSeconds: _model.timeInSeconds,
        suggestionsButtonText: buttonText,
      );
      loggingService.log(
        'AgendaItemPresenter.saveContent: Update: ${updatedItem.toJson()}',
      );

      try {
        await _agendaProvider.upsertAgendaItem(updatedItem: updatedItem);
      } catch (e) {
        debugPrint('Error during upsert agenda item');
        debugPrint(e.toString());
        rethrow;
      }
      _view.showMessage('Agenda item was saved', toastType: ToastType.success);
    }

    _model.isEditMode = false;
    _view.updateView();
  }

  Future<void> finishEditingItem() async {
    await _agendaProvider.finishAgendaItem(_model.agendaItem.id);
  }

  bool isCardUnsaved() {
    return _agendaProvider.unsavedItems
        .any((element) => element.id == _model.agendaItem.id);
  }

  void toggleEditMode() {
    _model.isEditMode = true;
    _view.updateView();
  }

  bool doesAllowEdit() {
    final params = _agendaProvider.params;
    if (params.isNotOnEventPage) {
      final Template? localTemplate = params.template;
      return localTemplate != null
          ? _communityPermissionsProvider.canEditTemplate(localTemplate)
          : false;
    } else {
      final canEditEvent = _eventPermissionsProvider?.canEditEvent ?? false;
      final isInBreakout = _liveMeetingProvider?.isInBreakout ?? false;

      return canEditEvent && !isInBreakout;
    }
  }

  // Note: currently it's not possible to collapse items if it's in `edit mode`.
  void toggleCardExpansion() {
    if (!_model.isEditMode) {
      final itemIds = _agendaProvider.collapsedAgendaItemIds;
      final itemId = _model.agendaItem.id;

      if (itemIds.contains(itemId)) {
        itemIds.remove(itemId);
      } else {
        itemIds.add(itemId);
      }

      _view.updateView();
    }
  }

  void reorder() {
    _agendaProvider.startReorder();
  }

  bool isInLiveMeeting() {
    return _agendaProvider.inLiveMeeting;
  }

  bool isBrandNew() {
    return _helper.isBrandNew(_model);
  }

  Future<void> deleteAgendaItem() async {
    await _agendaProvider.deleteAgendaItem(_model.agendaItem.id);
    _view.showMessage('Agenda item was deleted', toastType: ToastType.success);
  }

  bool canExpand(bool inLiveMeeting, bool isCompleted, bool isCardActive) {
    return !inLiveMeeting || (!isCompleted && !isCardActive);
  }

  bool canReorder(
    bool allowEdit,
    bool isEditMode,
    bool isCompleted,
    bool isCardActive,
  ) {
    return allowEdit && !isEditMode && !isCompleted && !isCardActive;
  }

  void updateAgendaItemTextData(AgendaItemTextData data) {
    _model.agendaItemTextData = data;
    _view.updateView();
  }

  void updateAgendaItemImageData(AgendaItemImageData data) {
    _model.agendaItemImageData = data;
    _view.updateView();
  }

  void updateAgendaItemVideoData(AgendaItemVideoData data) {
    _model.agendaItemVideoData = data;
    _view.updateView();
  }

  void updateAgendaItemPollData(AgendaItemPollData data) {
    _model.agendaItemPollData = data;
    _view.updateView();
  }

  void updateAgendaItemWordCloudData(AgendaItemWordCloudData data) {
    _model.agendaItemWordCloudData = data;
    _view.updateView();
  }

  void updateAgendaItemUserSuggestionsData(AgendaItemUserSuggestionsData data) {
    _model.agendaItemUserSuggestionsData = data;
    _view.updateView();
  }

  String getTitle() {
    final agendaItemType = _model.agendaItem.type;

    switch (agendaItemType) {
      case AgendaItemType.text:
        final title = _model.agendaItemTextData.title;
        return title.isEmpty ? 'Text Title' : title;
      case AgendaItemType.video:
        final title = _model.agendaItemVideoData.title;
        return title.isEmpty ? 'Video' : title;
      case AgendaItemType.image:
        final title = _model.agendaItemImageData.title;
        return title.isEmpty ? 'Image' : title;
      case AgendaItemType.poll:
        final question = _model.agendaItemPollData.question;
        return question.isEmpty ? 'Question' : question;
      case AgendaItemType.wordCloud:
        final prompt = _model.agendaItemWordCloudData.prompt;
        return prompt.isEmpty ? 'Word Cloud' : prompt;
      case AgendaItemType.userSuggestions:
        final title = _model.agendaItemUserSuggestionsData.headline;
        return title.isEmpty ? 'Suggestions' : title;
    }
  }

  void cancelChanges() {
    _agendaProvider.deleteUnsavedItem(_model.agendaItem.id);
    // Reset fields to the original value before changes were applied
    _helper.initialiseFields(_model);
    _model.isEditMode = false;

    _view.updateView();
  }

  void updateTime(Duration duration) {
    loggingService.log('AgendaItemPresenter.updateTime: $duration');
    _model.timeInSeconds = duration.inSeconds;
    _view.updateView();
  }
}

@visibleForTesting
class AgendaItemHelper {
  bool isBrandNew(AgendaItemModel agendaItemModel) {
    return agendaItemModel.agendaItemTextData.isNew() &&
        agendaItemModel.agendaItemVideoData.isNew() &&
        agendaItemModel.agendaItemImageData.isNew() &&
        agendaItemModel.agendaItemPollData.isNew() &&
        agendaItemModel.agendaItemWordCloudData.isNew() &&
        agendaItemModel.agendaItemUserSuggestionsData.isNew();
  }

  bool hasBeenEdited(AgendaItemModel agendaItemModel) {
    final agendaItem = agendaItemModel.agendaItem;
    final agendaItemTitle = agendaItem.title ?? '';
    final agendaItemContent = agendaItem.content ?? '';
    final agendaItemType = agendaItem.type;

    // External fields which belong to agenda are being checked here
    if (agendaItemModel.timeInSeconds != agendaItem.timeInSeconds) {
      return true;
    }

    switch (agendaItemType) {
      case AgendaItemType.text:
        return agendaItemTitle != agendaItemModel.agendaItemTextData.title ||
            agendaItemContent != agendaItemModel.agendaItemTextData.content;
      case AgendaItemType.video:
        return agendaItemTitle != agendaItemModel.agendaItemVideoData.title ||
            (agendaItem.videoUrl ?? '') !=
                agendaItemModel.agendaItemVideoData.url ||
            agendaItemModel.agendaItemVideoData.type != agendaItem.videoType;
      case AgendaItemType.image:
        return agendaItemTitle != agendaItemModel.agendaItemImageData.title ||
            (agendaItem.imageUrl ?? '') !=
                agendaItemModel.agendaItemImageData.url;
      case AgendaItemType.poll:
        return agendaItemContent !=
                agendaItemModel.agendaItemPollData.question ||
            !ListEquality().equals(
              agendaItemModel.agendaItemPollData.answers,
              agendaItem.pollAnswers ?? [],
            );
      case AgendaItemType.wordCloud:
        return agendaItemContent !=
            agendaItemModel.agendaItemWordCloudData.prompt;
      case AgendaItemType.userSuggestions:
        return agendaItemTitle !=
            agendaItemModel.agendaItemUserSuggestionsData.headline;
    }
  }

  void initialiseFields(AgendaItemModel agendaItemModel) {
    agendaItemModel.timeInSeconds = agendaItemModel.agendaItem.timeInSeconds ??
        AgendaItem.kDefaultTimeInSeconds;

    agendaItemModel.agendaItemTextData = AgendaItemTextData(
      agendaItemModel.agendaItem.title ?? '',
      agendaItemModel.agendaItem.content ?? '',
    );
    agendaItemModel.agendaItemVideoData = AgendaItemVideoData(
      agendaItemModel.agendaItem.title ?? '',
      agendaItemModel.agendaItem.videoType,
      agendaItemModel.agendaItem.videoUrl ?? '',
    );
    agendaItemModel.agendaItemImageData = AgendaItemImageData(
      agendaItemModel.agendaItem.title ?? '',
      agendaItemModel.agendaItem.imageUrl ?? '',
    );
    agendaItemModel.agendaItemPollData = AgendaItemPollData(
      agendaItemModel.agendaItem.content ?? '',
      agendaItemModel.agendaItem.pollAnswers != null
          ? List.of(agendaItemModel.agendaItem.pollAnswers!)
          : [],
    );
    agendaItemModel.agendaItemWordCloudData =
        AgendaItemWordCloudData(agendaItemModel.agendaItem.content ?? '');

    agendaItemModel.agendaItemUserSuggestionsData =
        AgendaItemUserSuggestionsData(
      agendaItemModel.agendaItem.title ?? '',
    );
  }

  bool isPlayingVideo(
    MeetingGuideCardStore? meetingGuideCardModel,
    AgendaProvider agendaProvider,
  ) {
    if (meetingGuideCardModel == null) {
      return false;
    }

    return meetingGuideCardModel.isPlayingVideo && agendaProvider.inLiveMeeting;
  }

  String? areRequiredFieldsInput(AgendaItemModel model) {
    final agendaItemType = model.agendaItem.type;

    switch (agendaItemType) {
      case AgendaItemType.text:
        if (model.agendaItemTextData.title.trim().isEmpty) {
          return 'Title is required';
        }

        if (model.agendaItemTextData.content.trim().isEmpty) {
          return 'Message is required';
        }
        break;
      case AgendaItemType.video:
        if (model.agendaItemVideoData.title.trim().isEmpty) {
          return 'Title is required';
        }

        if (model.agendaItemVideoData.url.trim().isEmpty) {
          return 'Video URL is required';
        }
        break;
      case AgendaItemType.image:
        if (model.agendaItemImageData.title.trim().isEmpty) {
          return 'Title is required';
        }

        if (model.agendaItemImageData.url.trim().isEmpty) {
          return 'Image URL is required';
        }
        break;
      case AgendaItemType.poll:
        if (model.agendaItemPollData.question.trim().isEmpty) {
          return 'Question is required';
        }

        if (model.agendaItemPollData.answers.isEmpty) {
          return 'Please add some answers';
        }

        break;
      case AgendaItemType.wordCloud:
        if (model.agendaItemWordCloudData.prompt.trim().isEmpty) {
          return 'Word Cloud prompt is required';
        }
        break;
      case AgendaItemType.userSuggestions:
        if (model.agendaItemUserSuggestionsData.headline.trim().isEmpty) {
          return 'Headline is required';
        }
        break;
    }
    return null;
  }
}
