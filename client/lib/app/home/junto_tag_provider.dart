import 'dart:async';

import 'package:flutter/material.dart';
import 'package:junto/services/firestore/firestore_utils.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/firestore/junto_tag.dart';

class CreateJuntoTagProvider with ChangeNotifier {
  final String juntoId;
  final bool isNewJunto;

  late BehaviorSubjectWrapper<List<JuntoTag>> _juntoTagsStream;

  Set<JuntoTag> _unsavedTags = {};
  Set<JuntoTag> get unsavedTags => _unsavedTags;
  late bool _isNewJunto;

  Stream<List<JuntoTag>> get juntoTagsStream => _juntoTagsStream.stream;
  List<JuntoTag> get tags {
    final juntoTags = _juntoTagsStream.stream.valueOrNull ?? [];
    final existingTagDefinitionIds = juntoTags.map((t) => t.definitionId).toSet();
    return [
      ...juntoTags,
      ...unsavedTags.where((t) => !existingTagDefinitionIds.contains(t.definitionId))
    ];
  }

  CreateJuntoTagProvider({
    required this.juntoId,
    this.isNewJunto = false,
  });

  void initialize() {
    _juntoTagsStream = wrapInBehaviorSubject(firestoreTagService.getJuntoTags(
      juntoId: juntoId,
      taggedItemId: juntoId,
      taggedItemType: TaggedItemType.junto,
    ));
    _isNewJunto = isNewJunto;
  }

  Future<void> addTag(String title) async {
    final definition = await firestoreTagService.lookupOrCreateTagDefinition(title);
    if (isNewJunto) {
      _unsavedTags.add(JuntoTag(
        taggedItemId: juntoId,
        taggedItemType: TaggedItemType.junto,
        juntoId: juntoId,
        definitionId: definition.id,
      ));
    } else {
      await _saveTag(title: title, definitionId: definition.id);
    }
    notifyListeners();
  }

  Future<void> _saveTag({String? title, required String definitionId}) async {
    await firestoreTagService.addJuntoTag(
      taggedItemId: juntoId,
      taggedItemType: TaggedItemType.junto,
      juntoId: juntoId,
      title: title,
      definitionId: definitionId,
    );
  }

  Future<void> submit() async {
    if (_unsavedTags.isEmpty) return;
    _isNewJunto = false;
    await Future.wait([for (final tag in _unsavedTags) _saveTag(definitionId: tag.definitionId)]);
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
      if (_isNewJunto) {
        _unsavedTags.removeWhere((t) => t.definitionId == tappedTag.definitionId);
      } else {
        await firestoreTagService.deleteJuntoTag(tappedTag);
      }
    } else {
      if (_isNewJunto) {
        _unsavedTags.add(tappedTag);
      } else {
        await firestoreTagService.addJuntoTag(
          taggedItemId: juntoId,
          taggedItemType: TaggedItemType.junto,
          juntoId: juntoId,
          definitionId: tappedTag.definitionId,
        );
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _juntoTagsStream.dispose();
    super.dispose();
  }
}
