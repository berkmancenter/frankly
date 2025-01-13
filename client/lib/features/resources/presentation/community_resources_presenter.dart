import 'dart:async';

import 'package:flutter/material.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/utils/firestore_utils.dart';
import 'package:client/services.dart';
import 'package:data_models/resources/community_resource.dart';
import 'package:data_models/community/community_tag.dart';

class CommunityResourcesPresenter with ChangeNotifier {
  final CommunityProvider communityProvider;

  CommunityResourcesPresenter({required this.communityProvider});

  late BehaviorSubjectWrapper<List<CommunityTag>> _allResourceTags;
  late StreamSubscription _resourcesStreamSubscription;

  final Set<String> _selectedTagDefinitionIds = {};

  Stream<List<CommunityTag>> get allResourceTagsStream =>
      _allResourceTags.stream;
  List<String> get selectedTagDefinitionIds =>
      _selectedTagDefinitionIds.toList();
  List<CommunityTag> get allTags {
    final allResourceIds = allResources.map((resource) => resource.id).toSet();
    return _allResourceTags.value
            ?.where((t) => allResourceIds.contains(t.taggedItemId))
            .toList() ??
        [];
  }

  List<CommunityResource> get allResources =>
      communityProvider.resourcesStream.value ?? [];
  List<CommunityResource> get filteredResources =>
      communityProvider.resourcesStream.value
          ?.where((item) => _isVisibleWithFilters(item))
          .toList() ??
      [];

  void initialize() async {
    _resourcesStreamSubscription =
        communityProvider.resourcesStream.listen((resources) {
      notifyListeners();
    });

    _allResourceTags = wrapInBehaviorSubject(
      firestoreTagService.getResourceTagsStream(
        communityId: communityProvider.communityId,
      ),
    );
  }

  bool _isVisibleWithFilters(CommunityResource resource) {
    if (_selectedTagDefinitionIds.isEmpty) return true;

    final resourceTags = _allResourceTags.value
            ?.where((tag) => tag.taggedItemId == resource.id) ??
        [];

    return resourceTags
        .any((tag) => _selectedTagDefinitionIds.contains(tag.definitionId));
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

  List<CommunityTag> getResourceTags(CommunityResource resource) =>
      allTags.where((t) => t.taggedItemId == resource.id).toList();
}
