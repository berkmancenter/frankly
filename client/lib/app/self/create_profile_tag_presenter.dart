import 'package:flutter/material.dart';
import 'package:client/services/firestore/firestore_utils.dart';
import 'package:client/services/services.dart';
import 'package:data_models/community/community_tag.dart';

class CreateProfileTagPresenter with ChangeNotifier {
  final String currentUserId;

  late BehaviorSubjectWrapper<List<CommunityTag>> _profileTagsStream;

  Stream<List<CommunityTag>> get tagsStream => _profileTagsStream.stream;
  List<CommunityTag> get tags {
    final profileTags = _profileTagsStream.stream.valueOrNull ?? [];
    final existingTagDefinitionIds =
        profileTags.map((t) => t.definitionId).toSet();
    return [
      ...profileTags,
      ...unsavedTags
          .where((t) => !existingTagDefinitionIds.contains(t.definitionId)),
    ];
  }

  final Set<CommunityTag> _unsavedTags = {};
  Set<CommunityTag> get unsavedTags => _unsavedTags;

  CreateProfileTagPresenter({
    required this.currentUserId,
  });

  void initialize() {
    _profileTagsStream = wrapInBehaviorSubject(
      firestoreTagService.getCommunityTags(
        taggedItemId: currentUserId,
        taggedItemType: TaggedItemType.profile,
      ),
    );
  }

  Future<void> addTag(String title) async {
    final definition =
        await firestoreTagService.lookupOrCreateTagDefinition(title);
    _unsavedTags.add(
      CommunityTag(
        taggedItemId: currentUserId,
        taggedItemType: TaggedItemType.profile,
        definitionId: definition.id,
      ),
    );
    notifyListeners();
  }

  Future<void> _saveTag({String? title, CommunityTag? tag}) async {
    await firestoreTagService.addCommunityTag(
      taggedItemId: currentUserId,
      title: title,
      taggedItemType: TaggedItemType.profile,
      definitionId: tag?.definitionId,
    );
  }

  Future<void> submit() async {
    if (_unsavedTags.isEmpty) return;
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
      _unsavedTags.removeWhere((t) => t.definitionId == tappedTag.definitionId);
      await firestoreTagService.deleteCommunityTag(tappedTag);
    } else {
      _unsavedTags.add(tappedTag);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _profileTagsStream.dispose();
    super.dispose();
  }
}
