import 'dart:async';

import 'package:flutter/material.dart';
import 'package:junto/services/firestore/firestore_utils.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/firestore/junto_tag.dart';

class CreateTopicTagPresenter with ChangeNotifier {
  final String topicId;
  final String juntoId;
  final bool isNewTopic;

  late BehaviorSubjectWrapper<List<JuntoTag>> _topicTagsStream;

  Stream<List<JuntoTag>> get tagsStream => _topicTagsStream.stream;
  List<JuntoTag> get tags {
    final topicTags = _topicTagsStream.stream.valueOrNull ?? [];
    final existingTagDefinitionIds = topicTags.map((t) => t.definitionId).toSet();
    return [
      ...topicTags,
      ...unsavedTags.where((t) => !existingTagDefinitionIds.contains(t.definitionId))
    ];
  }

  Set<JuntoTag> _unsavedTags = {};
  Set<JuntoTag> get unsavedTags => _unsavedTags;
  late bool _isNewTopic;

  CreateTopicTagPresenter({
    required this.topicId,
    required this.juntoId,
    required this.isNewTopic,
  });

  void initialize() {
    _topicTagsStream = wrapInBehaviorSubject(firestoreTagService.getJuntoTags(
      juntoId: juntoId,
      taggedItemId: topicId,
      taggedItemType: TaggedItemType.topic,
    ));
    _isNewTopic = isNewTopic;
  }

  Future<void> addTag(String title) async {
    if (_isNewTopic) {
      final definition = await firestoreTagService.lookupOrCreateTagDefinition(title);
      _unsavedTags.add(JuntoTag(
        taggedItemId: topicId,
        taggedItemType: TaggedItemType.topic,
        juntoId: juntoId,
        definitionId: definition.id,
      ));
    } else {
      await _saveTag(title: title);
    }
    notifyListeners();
  }

  Future<void> _saveTag({String? title, JuntoTag? tag}) async {
    await firestoreTagService.addJuntoTag(
      taggedItemId: topicId,
      taggedItemType: TaggedItemType.topic,
      juntoId: juntoId,
      title: title,
      definitionId: tag?.definitionId,
    );
  }

  Future<void> submit() async {
    if (_unsavedTags.isEmpty) return;
    _isNewTopic = false;
    await Future.wait([for (final tag in _unsavedTags) _saveTag(tag: tag)]);
    _unsavedTags.clear();
    notifyListeners();
  }

  bool isSelected(JuntoTag tag) {
    if (_unsavedTags.any((t) => tag.definitionId == t.definitionId)) {
      return true;
    }
    return tags.where((element) => element.definitionId == tag.definitionId).isNotEmpty;
  }

  Future<void> onTapTag(JuntoTag tappedTag) async {
    if (isSelected(tappedTag)) {
      if (_isNewTopic) {
        _unsavedTags.removeWhere((t) => t.definitionId == tappedTag.definitionId);
      } else {
        await firestoreTagService.deleteJuntoTag(tappedTag);
        tags.remove(tappedTag);
      }
    } else {
      if (_isNewTopic) {
        _unsavedTags.add(tappedTag);
      } else {
        await firestoreTagService.addJuntoTag(
          taggedItemId: topicId,
          taggedItemType: TaggedItemType.topic,
          juntoId: juntoId,
          definitionId: tappedTag.definitionId,
        );
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _topicTagsStream.dispose();
    super.dispose();
  }
}
