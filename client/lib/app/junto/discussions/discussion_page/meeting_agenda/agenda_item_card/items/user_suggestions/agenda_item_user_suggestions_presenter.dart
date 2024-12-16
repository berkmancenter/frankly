import 'package:flutter/material.dart';
import 'package:junto/app/junto/community_permissions_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_permissions_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/meeting_agenda_provider.dart';
import 'package:junto_models/firestore/topic.dart';
import 'package:provider/provider.dart';

import 'agenda_item_user_suggestions_contract.dart';
import 'agenda_item_user_suggestions_model.dart';

class AgendaItemUserSuggestionsPresenter {
  final AgendaItemUserSuggestionsView _view;
  final AgendaItemUserSuggestionsModel _model;
  final AgendaItemUserSuggestionsPresenterHelper _helper;
  final AgendaProvider _agendaProvider;
  final DiscussionPermissionsProvider? _discussionPermissions;
  final CommunityPermissionsProvider _communityPermissions;

  AgendaItemUserSuggestionsPresenter(
    BuildContext context,
    this._view,
    this._model, {
    AgendaItemUserSuggestionsPresenterHelper? helper,
    AgendaProvider? agendaProvider,
    DiscussionPermissionsProvider? discussionPermissions,
    CommunityPermissionsProvider? communityPermissions,
  })  : _helper = helper ?? AgendaItemUserSuggestionsPresenterHelper(),
        _agendaProvider = agendaProvider ?? context.read<AgendaProvider>(),
        _discussionPermissions =
            discussionPermissions ?? DiscussionPermissionsProvider.read(context),
        _communityPermissions =
            communityPermissions ?? context.read<CommunityPermissionsProvider>();

  bool allowEdit() {
    if (_agendaProvider.params.isNotOnDiscussionPage) {
      final Topic? localTopic = _agendaProvider.params.topic;
      return localTopic != null ? _communityPermissions.canEditTopic(localTopic) : false;
    } else {
      return _discussionPermissions?.canEditDiscussion ?? false;
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
