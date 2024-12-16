import 'dart:async';

import 'package:flutter/material.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/services/firestore/firestore_utils.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/firestore/junto_resource.dart';
import 'package:junto_models/firestore/junto_tag.dart';

class JuntoResourcesPresenter with ChangeNotifier {
  final JuntoProvider juntoProvider;

  JuntoResourcesPresenter({required this.juntoProvider});

  late BehaviorSubjectWrapper<List<JuntoTag>> _allResourceTags;
  late StreamSubscription _resourcesStreamSubscription;

  final Set<String> _selectedTagDefinitionIds = {};

  Stream<List<JuntoTag>> get allResourceTagsStream => _allResourceTags.stream;
  List<String> get selectedTagDefinitionIds => _selectedTagDefinitionIds.toList();
  List<JuntoTag> get allTags {
    final allResourceIds = allResources.map((resource) => resource.id).toSet();
    return _allResourceTags.value?.where((t) => allResourceIds.contains(t.taggedItemId)).toList() ??
        [];
  }

  List<JuntoResource> get allResources => juntoProvider.resourcesStream.value ?? [];
  List<JuntoResource> get filteredResources =>
      juntoProvider.resourcesStream.value?.where((item) => _isVisibleWithFilters(item)).toList() ??
      [];

  void initialize() async {
    _resourcesStreamSubscription = juntoProvider.resourcesStream.listen((resources) {
      notifyListeners();
    });

    _allResourceTags = wrapInBehaviorSubject(
        firestoreTagService.getResourceTagsStream(juntoId: juntoProvider.juntoId));
  }

  bool _isVisibleWithFilters(JuntoResource resource) {
    if (_selectedTagDefinitionIds.isEmpty) return true;

    final resourceTags =
        _allResourceTags.value?.where((tag) => tag.taggedItemId == resource.id) ?? [];

    return resourceTags.any((tag) => _selectedTagDefinitionIds.contains(tag.definitionId));
  }

  void selectTag(String tagDefinitionId) {
    if (_selectedTagDefinitionIds.contains(tagDefinitionId)) {
      _selectedTagDefinitionIds.remove(tagDefinitionId);
    } else {
      _selectedTagDefinitionIds.add(tagDefinitionId);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _allResourceTags.dispose();
    _resourcesStreamSubscription.cancel();
    super.dispose();
  }

  List<JuntoTag> getResourceTags(JuntoResource resource) =>
      allTags.where((t) => t.taggedItemId == resource.id).toList();
}
