import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_settings/discussion_settings_drawer.dart';
import 'package:junto/app/junto/discussions/discussion_page/topic_provider.dart';
import 'package:junto/app/junto/templates/topic_page_provider.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/services/firestore/firestore_database.dart';
import 'package:junto/services/logging_service.dart';
import 'package:junto/services/services.dart';
import 'package:junto/utils/dialogs.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/topic.dart';
import 'package:provider/provider.dart';

import 'discussion_settings_contract.dart';
import 'discussion_settings_model.dart';

class DiscussionSettingsPresenter {
  final DiscussionSettingsView _view;
  final DiscussionSettingsModel _model;
  final DiscussionSettingsPresenterHelper _helper;
  final AppDrawerProvider _appDrawerProvider;
  final JuntoProvider _juntoProvider;
  final FirestoreDatabase _firestoreDatabase;
  late final DiscussionProvider _discussionProvider;
  late final TopicPageProvider _topicPageProvider;

  DiscussionSettingsPresenter(
    BuildContext context,
    this._view,
    this._model, {
    DiscussionSettingsPresenterHelper? discussionSettingsPresenterHelper,
    AppDrawerProvider? appDrawerProvider,
    JuntoProvider? juntoProvider,
    FirestoreDatabase? firestoreDatabase,
    DiscussionProvider? discussionProvider,
    TopicPageProvider? topicPageProvider,
  })  : _helper = discussionSettingsPresenterHelper ?? DiscussionSettingsPresenterHelper(),
        _appDrawerProvider = appDrawerProvider ?? context.read<AppDrawerProvider>(),
        _juntoProvider = juntoProvider ?? context.read<JuntoProvider>(),
        _firestoreDatabase = firestoreDatabase ?? GetIt.instance<FirestoreDatabase>() {
    // Depending on which page we are in, we initialise right provider.
    switch (_model.discussionSettingsDrawerType) {
      case DiscussionSettingsDrawerType.topic:
        _topicPageProvider = topicPageProvider ?? context.read<TopicPageProvider>();
        break;
      case DiscussionSettingsDrawerType.discussion:
        _discussionProvider = discussionProvider ?? context.read<DiscussionProvider>();
        break;
    }
  }

  void init() {
    _appDrawerProvider.setOnSaveChanges(onSaveChanges: saveSettings);
    final discussionSettingsOnCommunity = _juntoProvider.discussionSettings;

    switch (_model.discussionSettingsDrawerType) {
      case DiscussionSettingsDrawerType.topic:
        final discussionSettingsOnTopic = _topicPageProvider.topic?.discussionSettings;
        _model.discussionSettings = discussionSettingsOnTopic ?? discussionSettingsOnCommunity;
        break;
      case DiscussionSettingsDrawerType.discussion:
        final discussionSettings = _discussionProvider.discussion.discussionSettings;
        _model.discussionSettings = discussionSettings ?? discussionSettingsOnCommunity;
        break;
    }

    _model.initialDiscussionSettings = _model.discussionSettings;
    getDefaultSettings();
    _view.updateView();
  }

  @visibleForTesting
  void getDefaultSettings() {
    final discussionSettingsOnCommunity = _juntoProvider.discussionSettings;
    switch (_model.discussionSettingsDrawerType) {
      case DiscussionSettingsDrawerType.topic:
        _model.defaultSettings = discussionSettingsOnCommunity;
        break;
      case DiscussionSettingsDrawerType.discussion:
        final topicId = _discussionProvider.discussion.topicId;
        if (topicId == defaultTopicId) {
          _model.defaultSettings = discussionSettingsOnCommunity;
        } else {
          final topic = _discussionProvider.topic;
          _model.defaultSettings = topic?.discussionSettings ?? discussionSettingsOnCommunity;
        }
        break;
    }
  }

  bool isSettingNotDefaultIndicatorShown(bool? Function(DiscussionSettings) getSetting) {
    final defaultSettingsLocal = _model.defaultSettings;
    final defaultValue = getSetting(defaultSettingsLocal) ?? false;
    return defaultValue != getSetting(_model.discussionSettings);
  }

  void updateSetting(String setting, bool isSelected) async {
    final settings = DiscussionSettings.fromJson(
      _model.discussionSettings.toJson()
        ..addEntries([
          MapEntry(setting, isSelected),
        ]),
    );
    _model.discussionSettings = settings;
    _appDrawerProvider.setUnsavedChanges(_helper.wereChangesMade(_model));
    _view.updateView();
  }

  Future<void> saveSettings() async {
    switch (_model.discussionSettingsDrawerType) {
      case DiscussionSettingsDrawerType.topic:
        final topic = _topicPageProvider.topic;
        // Should never happen
        if (topic == null) {
          loggingService.log(
            'DiscussionSettingsPresenter.saveSettings: Template is null',
            logType: LogType.error,
          );
          return;
        }

        await _firestoreDatabase.updateTopic(
          juntoId: _juntoProvider.juntoId,
          topic: topic.copyWith(discussionSettings: _model.discussionSettings),
          keys: [Topic.kFieldDiscussionSettings],
        );
        break;
      case DiscussionSettingsDrawerType.discussion:
        await _discussionProvider.updateDiscussionSettings(_model.discussionSettings);
        break;
    }

    _view.closeDrawer();
  }

  Future<void> restoreDefaultSettings() async {
    final settings = _model.defaultSettings;
    _model.discussionSettings = settings;
    _appDrawerProvider.setUnsavedChanges(_helper.wereChangesMade(_model));
    _view.updateView();
  }

  bool get isDefaultSettingsButtonEnabled {
    return _model.discussionSettings != _model.defaultSettings;
  }

  void showConfirmChangesDialog() {
    _appDrawerProvider.showConfirmChangesDialogLayer();
  }

  bool wereChangesMade() {
    return _helper.wereChangesMade(_model);
  }

  String getTitle() {
    switch (_model.discussionSettingsDrawerType) {
      case DiscussionSettingsDrawerType.topic:
        return 'Template Settings';
      case DiscussionSettingsDrawerType.discussion:
        return 'Event Settings';
    }
  }

  bool getFloatingChatToggleValue() {
    return (_model.discussionSettings.showChatMessagesInRealTime ?? false) &&
        (_model.discussionSettings.chat ?? false);
  }
}

@visibleForTesting
class DiscussionSettingsPresenterHelper {
  bool wereChangesMade(DiscussionSettingsModel model) {
    return model.discussionSettings != model.initialDiscussionSettings;
  }
}
