import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:junto/app/junto/resources/junto_resources_presenter.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/firestore/junto_resource.dart';
import 'package:junto_models/firestore/junto_tag.dart';
import 'package:junto_models/firestore/junto_tag_definition.dart';
import 'package:junto_models/firestore/link_preview_response.dart';

class CreateJuntoResourcePresenter with ChangeNotifier {
  final JuntoResourcesPresenter resourcesPresenter;
  final String juntoId;
  final JuntoResource? initialResource;

  late JuntoResource _updatedResource;

  late bool _isNewResource;
  String? _url;
  String? _lastLoadedUrl;

  String? _error;
  bool _isLoading = false;
  bool _showTitleField = false;
  bool _isEditingTitle = false;

  Set<JuntoTag> _unsavedTags = {};
  Set<JuntoTag> get unsavedTags => _unsavedTags;

  String? get url => _url;
  List<JuntoTag> get tags {
    final existingTagDefinitionIds = resourcesPresenter.allTags.map((t) => t.definitionId).toSet();
    final thisResourceTags = resourcesPresenter.allTags.where((t) => t.taggedItemId == resource.id);
    final otherResourceTags =
        resourcesPresenter.allTags.where((t) => t.taggedItemId != resource.id);
    final orderedAllTags = [
      ...thisResourceTags,
      ...otherResourceTags,
    ];

    final dedupedResoureTagLookup = <String, JuntoTag>{};
    for (final tag in orderedAllTags) {
      dedupedResoureTagLookup.putIfAbsent(tag.definitionId, () => tag);
    }
    return [
      ...dedupedResoureTagLookup.values,
      ..._unsavedTags.where((t) => !existingTagDefinitionIds.contains(t.definitionId)),
    ];
  }

  bool get isLoading => _isLoading;
  bool get showTitleField => _showTitleField;
  bool get isEditingTitle => _isEditingTitle;
  String get error => _error ?? '';
  JuntoResource get resource => _updatedResource;
  String? get lastLoadedUrl => _lastLoadedUrl;

  JuntoTagDefinition? tagDefinition;

  CreateJuntoResourcePresenter({
    required this.resourcesPresenter,
    required this.juntoId,
    this.initialResource,
  });

  void initialize() {
    _isNewResource = initialResource == null;
    _updatedResource = initialResource?.copyWith() ??
        JuntoResource(
          id: firestoreDatabase.generateNewDocId(
            collectionPath:
                firestoreJuntoResourceService.juntoResourcesCollection(juntoId: juntoId).path,
          ),
        );
    _url = initialResource?.url;
    _lastLoadedUrl = _url;

    notifyListeners();
  }

  void setResource(JuntoResource juntoResource) {
    _updatedResource = juntoResource;
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
      final response = await http.get(Uri.parse('https://api.linkpreview.net/?'
          'key=6124b88bfc42235b03765e0166747220&q=$url'));

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

  Future<void> addTag({String? title, JuntoTag? tag}) async {
    if (_isNewResource) {
      final definition = await firestoreTagService.lookupOrCreateTagDefinition(title!);
      _unsavedTags.add(JuntoTag(
        taggedItemId: _updatedResource.id,
        taggedItemType: TaggedItemType.resource,
        juntoId: juntoId,
        definitionId: definition.id,
      ));
    } else {
      await firestoreTagService.addJuntoTag(
        taggedItemId: _updatedResource.id,
        taggedItemType: TaggedItemType.resource,
        juntoId: juntoId,
        title: title,
        definitionId: tag?.definitionId,
      );
    }

    notifyListeners();
  }

  Future<void> submit() async {
    await firestoreJuntoResourceService.createJuntoResource(
      juntoId: juntoId,
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

  Future<void> selectTag(JuntoTag tag) async {
    if (isSelected(tag)) {
      if (_isNewResource) {
        _unsavedTags.removeWhere((t) => t.definitionId == tag.definitionId);
      } else {
        await firestoreTagService.deleteJuntoTag(
          tag,
        );
      }
    } else {
      if (_isNewResource) {
        _unsavedTags.add(tag);
      } else {
        await firestoreTagService.addJuntoTag(
          taggedItemId: _updatedResource.id,
          taggedItemType: TaggedItemType.resource,
          juntoId: juntoId,
          definitionId: tag.definitionId,
        );
      }
    }
    notifyListeners();
  }

  bool isSelected(JuntoTag tag) {
    if (_unsavedTags.any((t) => tag.definitionId == t.definitionId)) {
      return true;
    }

    return resourcesPresenter
        .getResourceTags(_updatedResource)
        .any((resourceTag) => resourceTag.definitionId == tag.definitionId);
  }
}
