import 'package:flutter/material.dart';
import 'package:junto/services/firestore/firestore_utils.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/firestore/junto_tag.dart';

class CreateProfileTagPresenter with ChangeNotifier {
  final String currentUserId;

  late BehaviorSubjectWrapper<List<JuntoTag>> _profileTagsStream;

  Stream<List<JuntoTag>> get tagsStream => _profileTagsStream.stream;
  List<JuntoTag> get tags {
    final profileTags = _profileTagsStream.stream.valueOrNull ?? [];
    final existingTagDefinitionIds = profileTags.map((t) => t.definitionId).toSet();
    return [
      ...profileTags,
      ...unsavedTags.where((t) => !existingTagDefinitionIds.contains(t.definitionId))
    ];
  }

  final Set<JuntoTag> _unsavedTags = {};
  Set<JuntoTag> get unsavedTags => _unsavedTags;

  CreateProfileTagPresenter({
    required this.currentUserId,
  });

  void initialize() {
    _profileTagsStream = wrapInBehaviorSubject(firestoreTagService.getJuntoTags(
      taggedItemId: currentUserId,
      taggedItemType: TaggedItemType.profile,
    ));
  }

  Future<void> addTag(String title) async {
    final definition = await firestoreTagService.lookupOrCreateTagDefinition(title);
    _unsavedTags.add(JuntoTag(
      taggedItemId: currentUserId,
      taggedItemType: TaggedItemType.profile,
      definitionId: definition.id,
    ));
    notifyListeners();
  }

  Future<void> _saveTag({String? title, JuntoTag? tag}) async {
    await firestoreTagService.addJuntoTag(
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

  bool isSelected(JuntoTag tag) {
    if (_unsavedTags.any((t) => tag.definitionId == t.definitionId)) {
      return true;
    }
    return tags.where((element) => element.definitionId == tag.definitionId).isNotEmpty;
  }

  Future<void> onTapTag(JuntoTag tappedTag) async {
    if (isSelected(tappedTag)) {
      _unsavedTags.removeWhere((t) => t.definitionId == tappedTag.definitionId);
      await firestoreTagService.deleteJuntoTag(tappedTag);
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
