import 'dart:async';

import 'package:flutter/material.dart';
import 'package:client/services/firestore/firestore_utils.dart';
import 'package:client/services/services.dart';
import 'package:data_models/community/community_tag.dart';

class CreateTemplateTagPresenter with ChangeNotifier {
  final String templateId;
  final String communityId;
  final bool isNewTemplate;

  late BehaviorSubjectWrapper<List<CommunityTag>> _templateTagsStream;

  Stream<List<CommunityTag>> get tagsStream => _templateTagsStream.stream;
  List<CommunityTag> get tags {
    final templateTags = _templateTagsStream.stream.valueOrNull ?? [];
    final existingTagDefinitionIds =
        templateTags.map((t) => t.definitionId).toSet();
    return [
      ...templateTags,
      ...unsavedTags
          .where((t) => !existingTagDefinitionIds.contains(t.definitionId)),
    ];
  }

  final Set<CommunityTag> _unsavedTags = {};
  Set<CommunityTag> get unsavedTags => _unsavedTags;
  late bool _isNewTemplate;

  CreateTemplateTagPresenter({
    required this.templateId,
    required this.communityId,
    required this.isNewTemplate,
  });

  void initialize() {
    _templateTagsStream = wrapInBehaviorSubject(
      firestoreTagService.getCommunityTags(
        communityId: communityId,
        taggedItemId: templateId,
        taggedItemType: TaggedItemType.template,
      ),
    );
    _isNewTemplate = isNewTemplate;
  }

  Future<void> addTag(String title) async {
    if (_isNewTemplate) {
      final definition =
          await firestoreTagService.lookupOrCreateTagDefinition(title);
      _unsavedTags.add(
        CommunityTag(
          taggedItemId: templateId,
          taggedItemType: TaggedItemType.template,
          communityId: communityId,
          definitionId: definition.id,
        ),
      );
    } else {
      await _saveTag(title: title);
    }
    notifyListeners();
  }

  Future<void> _saveTag({String? title, CommunityTag? tag}) async {
    await firestoreTagService.addCommunityTag(
      taggedItemId: templateId,
      taggedItemType: TaggedItemType.template,
      communityId: communityId,
      title: title,
      definitionId: tag?.definitionId,
    );
  }

  Future<void> submit() async {
    if (_unsavedTags.isEmpty) return;
    _isNewTemplate = false;
    await Future.wait([for (final tag in _unsavedTags) _saveTag(tag: tag)]);
    _unsavedTags.clear();
    notifyListeners();
  }

  bool isSelected(CommunityTag tag) {
    if (_unsavedTags.any((t) => tag.definitionId == t.definitionId)) {
      return true;
    }
    return tags
        .where((element) => element.definitionId == tag.definitionId)
        .isNotEmpty;
  }

  Future<void> onTapTag(CommunityTag tappedTag) async {
    if (isSelected(tappedTag)) {
      if (_isNewTemplate) {
        _unsavedTags
            .removeWhere((t) => t.definitionId == tappedTag.definitionId);
      } else {
        await firestoreTagService.deleteCommunityTag(tappedTag);
        tags.remove(tappedTag);
      }
    } else {
      if (_isNewTemplate) {
        _unsavedTags.add(tappedTag);
      } else {
        await firestoreTagService.addCommunityTag(
          taggedItemId: templateId,
          taggedItemType: TaggedItemType.template,
          communityId: communityId,
          definitionId: tappedTag.definitionId,
        );
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _templateTagsStream.dispose();
    super.dispose();
  }
}
