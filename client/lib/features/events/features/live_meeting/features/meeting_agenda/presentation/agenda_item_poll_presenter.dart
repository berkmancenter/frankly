import 'package:flutter/material.dart';

import 'views/agenda_item_poll_contract.dart';
import '../data/models/agenda_item_poll_model.dart';

class AgendaItemPollPresenter {
  final AgendaItemPollView _view;
  final AgendaItemPollModel _model;
  final AgendaItemPollHelper _helper;

  AgendaItemPollPresenter(
    this._view,
    this._model, {
    AgendaItemPollHelper? agendaItemPollHelper,
  }) : _helper = agendaItemPollHelper ?? AgendaItemPollHelper();

  void removeAnswer(int index) {
    _model.agendaItemPollData.answers.removeAt(index);
    _model.pollStateKey++;
    _view.updateView();

    _helper.updateParent(_model);
  }

  void updateAnswer(String value, int index) {
    _model.agendaItemPollData.answers[index] = value;
    _view.updateView();

    _helper.updateParent(_model);
  }

  void addAnswer(String value) {
    _model.agendaItemPollData.answers.add(value);
    _view.updateView();

    _helper.updateParent(_model);
  }

  void updatePollQuestion(String value) {
    _model.agendaItemPollData.question = value;
    _view.updateView();

    _helper.updateParent(_model);
  }
}

@visibleForTesting
class AgendaItemPollHelper {
  /// Sends data changes to `parent` widget.
  ///
  /// This method is used to that `parent` can be always aware of the changes done.
  /// Child might not receive changes due to custom handling of [State.didUpdateWidget] therefore
  /// we are making sure that latest data lives in `parent`.
  void updateParent(AgendaItemPollModel agendaItemPollModel) {
    agendaItemPollModel.onChanged(agendaItemPollModel.agendaItemPollData);
  }
}
