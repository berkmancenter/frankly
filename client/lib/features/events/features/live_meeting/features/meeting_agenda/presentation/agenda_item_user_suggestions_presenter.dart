import 'package:flutter/material.dart';
import 'package:client/features/community/data/providers/community_permissions_provider.dart';
import 'package:client/features/events/features/event_page/data/providers/event_permissions_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/providers/meeting_agenda_provider.dart';
import 'package:data_models/templates/template.dart';
import 'package:provider/provider.dart';

import 'views/agenda_item_user_suggestions_contract.dart';
import '../data/models/agenda_item_user_suggestions_model.dart';

class AgendaItemUserSuggestionsPresenter {
  final AgendaItemUserSuggestionsView _view;
  final AgendaItemUserSuggestionsModel _model;
  final AgendaItemUserSuggestionsPresenterHelper _helper;
  final AgendaProvider _agendaProvider;
  final EventPermissionsProvider? _eventPermissions;
  final CommunityPermissionsProvider _communityPermissions;

  AgendaItemUserSuggestionsPresenter(
    BuildContext context,
    this._view,
    this._model, {
    AgendaItemUserSuggestionsPresenterHelper? helper,
    AgendaProvider? agendaProvider,
    EventPermissionsProvider? eventPermissions,
    CommunityPermissionsProvider? communityPermissions,
  })  : _helper = helper ?? AgendaItemUserSuggestionsPresenterHelper(),
        _agendaProvider = agendaProvider ?? context.read<AgendaProvider>(),
        _eventPermissions =
            eventPermissions ?? EventPermissionsProvider.read(context),
        _communityPermissions = communityPermissions ??
            context.read<CommunityPermissionsProvider>();

  bool allowEdit() {
    if (_agendaProvider.params.isNotOnEventPage) {
      final Template? localTemplate = _agendaProvider.params.template;
      return localTemplate != null
          ? _communityPermissions.canEditTemplate(localTemplate)
          : false;
    } else {
      return _eventPermissions?.canEditEvent ?? false;
    }
  }

  void updateTitle(String value) {
    _model.agendaItemUserSuggestionsData.headline = value;
    _view.updateView();

    _helper.updateParent(_model);
  }
}

@visibleForTesting
class AgendaItemUserSuggestionsPresenterHelper {
  /// Sends data changes to `parent` widget.
  ///
  /// This method is used to that `parent` can be always aware of the changes done.
  /// Child might not receive changes due to custom handling of [State.didUpdateWidget] therefore
  /// we are making sure that latest data lives in `parent`.
  void updateParent(AgendaItemUserSuggestionsModel model) {
    model.onChanged(model.agendaItemUserSuggestionsData);
  }
}
