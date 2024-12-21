import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:client/app/community/events/event_page/event_provider.dart';
import 'package:client/app/community/events/event_page/event_settings/event_settings_drawer.dart';
import 'package:client/app/community/events/event_page/template_provider.dart';
import 'package:client/app/community/templates/template_page_provider.dart';
import 'package:client/app/community/community_provider.dart';
import 'package:client/services/firestore/firestore_database.dart';
import 'package:client/services/logging_service.dart';
import 'package:client/services/services.dart';
import 'package:client/utils/dialogs.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/templates/template.dart';
import 'package:provider/provider.dart';

import 'event_settings_contract.dart';
import 'event_settings_model.dart';

class EventSettingsPresenter {
  final EventSettingsView _view;
  final EventSettingsModel _model;
  final EventSettingsPresenterHelper _helper;
  final AppDrawerProvider _appDrawerProvider;
  final CommunityProvider _communityProvider;
  final FirestoreDatabase _firestoreDatabase;
  late final EventProvider _eventProvider;
  late final TemplatePageProvider _templatePageProvider;

  EventSettingsPresenter(
    BuildContext context,
    this._view,
    this._model, {
    EventSettingsPresenterHelper? eventSettingsPresenterHelper,
    AppDrawerProvider? appDrawerProvider,
    CommunityProvider? communityProvider,
    FirestoreDatabase? firestoreDatabase,
    EventProvider? eventProvider,
    TemplatePageProvider? templatePageProvider,
  })  : _helper =
            eventSettingsPresenterHelper ?? EventSettingsPresenterHelper(),
        _appDrawerProvider =
            appDrawerProvider ?? context.read<AppDrawerProvider>(),
        _communityProvider =
            communityProvider ?? context.read<CommunityProvider>(),
        _firestoreDatabase =
            firestoreDatabase ?? GetIt.instance<FirestoreDatabase>() {
    // Depending on which page we are in, we initialise right provider.
    switch (_model.eventSettingsDrawerType) {
      case EventSettingsDrawerType.template:
        _templatePageProvider =
            templatePageProvider ?? context.read<TemplatePageProvider>();
        break;
      case EventSettingsDrawerType.event:
        _eventProvider = eventProvider ?? context.read<EventProvider>();
        break;
    }
  }

  void init() {
    _appDrawerProvider.setOnSaveChanges(onSaveChanges: saveSettings);
    final eventSettingsOnCommunity = _communityProvider.eventSettings;

    switch (_model.eventSettingsDrawerType) {
      case EventSettingsDrawerType.template:
        final eventSettingsOnTemplate =
            _templatePageProvider.template?.eventSettings;
        _model.eventSettings =
            eventSettingsOnTemplate ?? eventSettingsOnCommunity;
        break;
      case EventSettingsDrawerType.event:
        final eventSettings = _eventProvider.event.eventSettings;
        _model.eventSettings = eventSettings ?? eventSettingsOnCommunity;
        break;
    }

    _model.initialEventSettings = _model.eventSettings;
    getDefaultSettings();
    _view.updateView();
  }

  @visibleForTesting
  void getDefaultSettings() {
    final eventSettingsOnCommunity = _communityProvider.eventSettings;
    switch (_model.eventSettingsDrawerType) {
      case EventSettingsDrawerType.template:
        _model.defaultSettings = eventSettingsOnCommunity;
        break;
      case EventSettingsDrawerType.event:
        final templateId = _eventProvider.event.templateId;
        if (templateId == defaultTemplateId) {
          _model.defaultSettings = eventSettingsOnCommunity;
        } else {
          final template = _eventProvider.template;
          _model.defaultSettings =
              template?.eventSettings ?? eventSettingsOnCommunity;
        }
        break;
    }
  }

  bool isSettingNotDefaultIndicatorShown(
    bool? Function(EventSettings) getSetting,
  ) {
    final defaultSettingsLocal = _model.defaultSettings;
    final defaultValue = getSetting(defaultSettingsLocal) ?? false;
    return defaultValue != getSetting(_model.eventSettings);
  }

  void updateSetting(String setting, bool isSelected) async {
    final settings = EventSettings.fromJson(
      _model.eventSettings.toJson()
        ..addEntries([
          MapEntry(setting, isSelected),
        ]),
    );
    _model.eventSettings = settings;
    _appDrawerProvider.setUnsavedChanges(_helper.wereChangesMade(_model));
    _view.updateView();
  }

  Future<void> saveSettings() async {
    switch (_model.eventSettingsDrawerType) {
      case EventSettingsDrawerType.template:
        final template = _templatePageProvider.template;
        // Should never happen
        if (template == null) {
          loggingService.log(
            'EventSettingsPresenter.saveSettings: Template is null',
            logType: LogType.error,
          );
          return;
        }

        await _firestoreDatabase.updateTemplate(
          communityId: _communityProvider.communityId,
          template: template.copyWith(eventSettings: _model.eventSettings),
          keys: [Template.kFieldEventSettings],
        );
        break;
      case EventSettingsDrawerType.event:
        await _eventProvider.updateEventSettings(_model.eventSettings);
        break;
    }

    _view.closeDrawer();
  }

  Future<void> restoreDefaultSettings() async {
    final settings = _model.defaultSettings;
    _model.eventSettings = settings;
    _appDrawerProvider.setUnsavedChanges(_helper.wereChangesMade(_model));
    _view.updateView();
  }

  bool get isDefaultSettingsButtonEnabled {
    return _model.eventSettings != _model.defaultSettings;
  }

  void showConfirmChangesDialog() {
    _appDrawerProvider.showConfirmChangesDialogLayer();
  }

  bool wereChangesMade() {
    return _helper.wereChangesMade(_model);
  }

  String getTitle() {
    switch (_model.eventSettingsDrawerType) {
      case EventSettingsDrawerType.template:
        return 'Template Settings';
      case EventSettingsDrawerType.event:
        return 'Event Settings';
    }
  }

  bool getFloatingChatToggleValue() {
    return (_model.eventSettings.showChatMessagesInRealTime ?? false) &&
        (_model.eventSettings.chat ?? false);
  }
}

@visibleForTesting
class EventSettingsPresenterHelper {
  bool wereChangesMade(EventSettingsModel model) {
    return model.eventSettings != model.initialEventSettings;
  }
}
