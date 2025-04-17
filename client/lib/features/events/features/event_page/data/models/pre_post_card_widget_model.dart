import 'package:flutter/material.dart';
import 'package:client/features/events/features/event_page/presentation/views/pre_post_card_widget_page.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/pre_post_card.dart';
import 'package:data_models/templates/template.dart';

class PrePostCardWidgetModel {
  PrePostCardType _prePostCardType;
  PrePostCardType get prePostCardType => _prePostCardType;
  @visibleForTesting
  set prePostCardType(PrePostCardType prePostCardType) {
    _prePostCardType = prePostCardType;
  }

  Event? _event;
  Event? get event => _event;
  @visibleForTesting
  set event(Event? event) {
    _event = event;
  }

  final Template? _template;
  Template? get template => _template;

  bool _isEditable;
  bool get isEditable => _isEditable;
  @visibleForTesting
  set isEditable(bool isEditable) {
    _isEditable = isEditable;
  }

  late PrePostCard prePostCard;
  late PrePostCardWidgetType prePostCardWidgetType;
  bool isExpanded = true;
  bool isAddURLParamsSectionVisible = false;
  String? email;

  PrePostCardWidgetModel(
    this._prePostCardType,
    this._event,
    this._isEditable,
    this._template,
  );
}
