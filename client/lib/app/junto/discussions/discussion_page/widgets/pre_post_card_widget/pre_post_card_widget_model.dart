import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/pre_post_card_widget/pre_post_card_widget_page.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/pre_post_card.dart';
import 'package:junto_models/firestore/topic.dart';

class PrePostCardWidgetModel {
  PrePostCardType _prePostCardType;
  PrePostCardType get prePostCardType => _prePostCardType;
  @visibleForTesting
  set prePostCardType(PrePostCardType prePostCardType) {
    _prePostCardType = prePostCardType;
  }

  Discussion? _discussion;
  Discussion? get discussion => _discussion;
  @visibleForTesting
  set discussion(Discussion? discussion) {
    _discussion = discussion;
  }

  final Topic? _topic;
  Topic? get topic => _topic;

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
    this._discussion,
    this._isEditable,
    this._topic,
  );
}
