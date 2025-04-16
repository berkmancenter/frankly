import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:client/features/resources/presentation/community_resources_presenter.dart';
import 'package:client/config/environment.dart';
import 'package:client/services.dart';
import 'package:data_models/resources/community_resource.dart';
import 'package:data_models/community/community_tag.dart';
import 'package:data_models/community/community_tag_definition.dart';
import 'package:data_models/resources/link_preview_response.dart';

class CreateCommunityResourcePresenter with ChangeNotifier {
  final CommunityResourcesPresenter resourcesPresenter;
  final String communityId;
  final CommunityResource? initialResource;

  late CommunityResource _updatedResource;

  late bool _isNewResource;
  String? _url;
  String? _lastLoadedUrl;

  String? _error;
  bool _isLoading = false;
  bool _showTitleField = false;
  bool _isEditingTitle = false;

  final Set<CommunityTag> _unsavedTags = {};
  Set<CommunityTag> get unsavedTags => _unsavedTags;

  String? get url => _url;
  List<CommunityTag> get tags {
    final existingTagDefinitionIds =
        resourcesPresenter.allTags.map((t) => t.definitionId).toSet();
    final thisResourceTags =
        resourcesPresenter.allTags.where((t) => t.taggedItemId == resource.id);
    final otherResourceTags =
        resourcesPresenter.allTags.where((t) => t.taggedItemId != resource.id);
    final orderedAllTags = [
      ...thisResourceTags,
      ...otherResourceTags,
    ];

    final dedupedResoureTagLookup = <String, CommunityTag>{};
    for (final tag in orderedAllTags) {
      dedupedResoureTagLookup.putIfAbsent(tag.definitionId, () => tag);
    }
    return [
      ...dedupedResoureTagLookup.values,
      ..._unsavedTags
          .where((t) => !existingTagDefinitionIds.contains(t.definitionId)),
    ];
  }

  bool get isLoading => _isLoading;
  bool get showTitleField => _showTitleField;
  bool get isEditingTitle => _isEditingTitle;
  String get error => _error ?? '';
  CommunityResource get resource => _updatedResource;
  String? get lastLoadedUrl => _lastLoadedUrl;

  CommunityTagDefinition? tagDefinition;

  CreateCommunityResourcePresenter({
    required this.resourcesPresenter,
    required this.communityId,
    this.initialResource,
  });

  void initialize() {
    _isNewResource = initialResource == null;
    _updatedResource = initialResource?.copyWith() ??
        CommunityResource(
          id: firestoreDatabase.generateNewDocId(
            collectionPath: firestoreCommunityResourceService
                .communityResourcesCollection(communityId: communityId)
                .path,
          ),
        );
    _url = initialResource?.url;
    _lastLoadedUrl = _url;

    notifyListeners();
  }

  void setResource(CommunityResource communityResource) {
    _updatedResource = communityResource;
    notifyListeners();
  }

  void onUrlChange(String value) {
    if (error.isNotEmpty) _error = '';
    _url = value;
    notifyListeners();
  }

  Future<void> urlLookup() async {
    if (url == null) return;
    setLoading(true);

    try {
      final response = await http.get(
        Uri.parse('https://api.linkpreview.net/?'
            'key=${Environment.linkPreviewApiKey}&q=$url'),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        _error = 'Error loading URL';
      } else {
        final data = LinkPreviewResponse.fromJson(jsonDecode(response.body));
        _updatedResource = _updatedResource.copyWith(
          url: url,
          image: data.image,
          title: data.title,
          createdDate: clockService.now(),
        );
        _lastLoadedUrl = url;
      }
    } catch (error) {
      _error = 'Error loading URL';
    }
    setLoading(false);
  }

  Future<void> addTag({String? title, CommunityTag? tag}) async {
    if (_isNewResource) {
      final definition =
          await firestoreTagService.lookupOrCreateTagDefinition(title!);
      _unsavedTags.add(
        CommunityTag(
          taggedItemId: _updatedResource.id,
          taggedItemType: TaggedItemType.resource,
          communityId: communityId,
          definitionId: definition.id,
        ),
      );
    } else {
      await firestoreTagService.addCommunityTag(
        taggedItemId: _updatedResource.id,
        taggedItemType: TaggedItemType.resource,
        communityId: communityId,
        title: title,
        definitionId: tag?.definitionId,
      );
    }

    notifyListeners();
  }

  Future<void> submit() async {
    await firestoreCommunityResourceService.createCommunityResource(
      communityId: communityId,
      resource: _updatedResource,
    );
    _isNewResource = false;
    await Future.wait([for (final tag in _unsavedTags) addTag(tag: tag)]);
    _unsavedTags.clear();
    notifyListeners();
  }

  void setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  void updateTitle(String title) {
    if (title.isEmpty) return;
    _isEditingTitle = true;
    _updatedResource = _updatedResource.copyWith(title: title);
    notifyListeners();
  }

  void updateImage(String url) {
    _updatedResource = _updatedResource.copyWith(image: url);
    notifyListeners();
  }

  void onTapEditTitle() {
    _showTitleField = !_showTitleField;
    notifyListeners();
  }

  Future<void> selectTag(CommunityTag tag) async {
    if (isSelected(tag)) {
      if (_isNewResource) {
        _unsavedTags.removeWhere((t) => t.definitionId == tag.definitionId);
      } else {
        await firestoreTagService.deleteCommunityTag(
          tag,
        );
      }
    } else {
      if (_isNewResource) {
        _unsavedTags.add(tag);
      } else {
        await firestoreTagService.addCommunityTag(
          taggedItemId: _updatedResource.id,
          taggedItemType: TaggedItemType.resource,
          communityId: communityId,
          definitionId: tag.definitionId,
        );
      }
    }
    notifyListeners();
  }

  bool isSelected(CommunityTag tag) {
    if (_unsavedTags.any((t) => tag.definitionId == t.definitionId)) {
      return true;
    }

    return resourcesPresenter
        .getResourceTags(_updatedResource)
        .any((resourceTag) => resourceTag.definitionId == tag.definitionId);
  }
}
