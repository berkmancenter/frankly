import 'dart:async';

import 'package:flutter/material.dart';
import 'package:client/core/utils/firestore_utils.dart';
import 'package:client/services.dart';
import 'package:data_models/community/community_tag.dart';

class CreateCommunityTagProvider with ChangeNotifier {
  final String communityId;
  final bool isNewCommunity;

  late BehaviorSubjectWrapper<List<CommunityTag>> _communityTagsStream;

  final Set<CommunityTag> _unsavedTags = {};
  Set<CommunityTag> get unsavedTags => _unsavedTags;
  late bool _isNewCommunity;

  Stream<List<CommunityTag>> get communityTagsStream =>
      _communityTagsStream.stream;
  List<CommunityTag> get tags {
    final communityTags = _communityTagsStream.stream.valueOrNull ?? [];
    final existingTagDefinitionIds =
        communityTags.map((t) => t.definitionId).toSet();
    return [
      ...communityTags,
      ...unsavedTags
          .where((t) => !existingTagDefinitionIds.contains(t.definitionId)),
    ];
  }

  CreateCommunityTagProvider({
    required this.communityId,
    this.isNewCommunity = false,
  });

  void initialize() {
    _communityTagsStream = wrapInBehaviorSubject(
      firestoreTagService.getCommunityTags(
        communityId: communityId,
        taggedItemId: communityId,
        taggedItemType: TaggedItemType.community,
      ),
    );
    _isNewCommunity = isNewCommunity;
  }

  Future<void> addTag(String title) async {
    final definition =
        await firestoreTagService.lookupOrCreateTagDefinition(title);
    if (isNewCommunity) {
      _unsavedTags.add(
        CommunityTag(
          taggedItemId: communityId,
          taggedItemType: TaggedItemType.community,
          communityId: communityId,
          definitionId: definition.id,
        ),
      );
    } else {
      await _saveTag(title: title, definitionId: definition.id);
    }
    notifyListeners();
  }

  Future<void> _saveTag({String? title, required String definitionId}) async {
    await firestoreTagService.addCommunityTag(
      taggedItemId: communityId,
      taggedItemType: TaggedItemType.community,
      communityId: communityId,
      title: title,
      definitionId: definitionId,
    );
  }

  Future<void> submit() async {
    if (_unsavedTags.isEmpty) return;
    _isNewCommunity = false;
    await Future.wait([
      for (final tag in _unsavedTags) _saveTag(definitionId: tag.definitionId),
    ]);
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
      if (_isNewCommunity) {
        _unsavedTags
            .removeWhere((t) => t.definitionId == tappedTag.definitionId);
      } else {
        await firestoreTagService.deleteCommunityTag(tappedTag);
      }
    } else {
      if (_isNewCommunity) {
        _unsavedTags.add(tappedTag);
      } else {
        await firestoreTagService.addCommunityTag(
          taggedItemId: communityId,
          taggedItemType: TaggedItemType.community,
          communityId: communityId,
          definitionId: tappedTag.definitionId,
        );
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _communityTagsStream.dispose();
    super.dispose();
  }
}
