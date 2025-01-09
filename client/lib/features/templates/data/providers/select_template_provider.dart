import 'dart:math';

import 'package:client/core/utils/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/utils/firestore_utils.dart';
import 'package:client/services.dart';
import 'package:data_models/community/community_tag.dart';
import 'package:data_models/templates/template.dart';

class SelectTemplateProvider with ChangeNotifier {
  final String communityId;

  SelectTemplateProvider({required this.communityId});
  static const _defaultNumTemplatesShown = 30;

  int _numShownTemplates = _defaultNumTemplatesShown;
  late Future<List<Template>> _templatesFuture;

  List<Template>? _allTemplates;
  List<Template>? _filteredTemplates;

  Template? _selectedTemplate;

  Set<String>? _allCategories;
  String? _selectedCategory;

  late BehaviorSubjectWrapper<List<CommunityTag>> _allTemplatesTags;

  String _selectedTagDefinitionId = '';

  Stream<List<CommunityTag>> get allTagsStream => _allTemplatesTags.stream;
  String get selectedTagDefinitionId => _selectedTagDefinitionId;
  List<CommunityTag> get allTags {
    final allTemplatesIds = _allTemplates
            ?.where((template) => template.status == TemplateStatus.active)
            .map((template) => template.id)
            .toSet() ??
        {};

    return _allTemplatesTags.value
            ?.where((t) => allTemplatesIds.contains(t.taggedItemId))
            .toList() ??
        [];
  }

  Template? get selectedTemplate => _selectedTemplate;

  Future<List<Template>> get templatesFuture => _templatesFuture;
  List<Template> get _filteredSelectedTemplates {
    return _filteredTemplates
            ?.where(
              (template) =>
                  _isVisibleWithTemplateFilters(template) &&
                  template.status == TemplateStatus.active &&
                  (_selectedCategory == null ||
                      _selectedCategory == template.category),
            )
            .toList() ??
        [];
  }

  List<Template> get displayTemplates => _filteredSelectedTemplates.sublist(
        0,
        min(_filteredSelectedTemplates.length, _numShownTemplates),
      );
  List<String> get allCategories => _allCategories?.toList() ?? [];
  bool get moreTemplates =>
      _numShownTemplates < _filteredSelectedTemplates.length;

  void initialize() {
    _templatesFuture =
        firestoreDatabase.allCommunityTemplates(communityId).then((templates) {
      templates.sort((a, b) {
        final aPriority = a.orderingPriority;
        final bPriority = b.orderingPriority;

        if (bPriority == null) {
          return -1;
        } else if (aPriority == null) {
          return 1;
        }
        return aPriority.compareTo(bPriority);
      });
      _filteredTemplates = templates;
      _allTemplates = templates;
      _allCategories = templates
          .where((template) => !isNullOrEmpty(template.category))
          .map((template) => template.category)
          .withoutNulls
          .toSet();
      return templates;
    });

    _allTemplatesTags = wrapInBehaviorSubject(
      firestoreTagService.getTemplateTagsStream(communityId: communityId),
    );
  }

  void updateCategory(dynamic category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void updateSelectedTemplate(template) {
    _selectedTemplate = template;
    notifyListeners();
  }

  void _filterTemplates(String searchQuery) {
    final searchQueryOption = searchQuery.toLowerCase();
    final results = _allTemplates
            ?.where(
              (template) =>
                  template.title?.toLowerCase().startsWith(searchQueryOption) ??
                  false,
            )
            .toSet() ??
        {};

    results.addAll(
      _allTemplates?.where(
            (template) =>
                !results.contains(template) &&
                (template.title?.toLowerCase().contains(searchQueryOption) ??
                    false),
          ) ??
          {},
    );

    results.addAll(
      _allTemplates?.where(
            (template) =>
                !results.contains(template) &&
                (template.category?.toLowerCase().contains(searchQueryOption) ??
                    false),
          ) ??
          {},
    );
    _filteredTemplates = results.toList();
  }

  void onSearchChanged(String text) {
    _filterTemplates(text);

    notifyListeners();
  }

  void showMoreTemplates() {
    _numShownTemplates += _defaultNumTemplatesShown;
    notifyListeners();
  }

  bool _isVisibleWithTemplateFilters(Template template) {
    if (_selectedTagDefinitionId.isEmpty) return true;

    final templateTags = _allTemplatesTags.value
            ?.where((tag) => tag.taggedItemId == template.id) ??
        [];
    final isVisible = templateTags
        .any((tag) => _selectedTagDefinitionId.contains(tag.definitionId));

    return isVisible;
  }

  void selectTag(String tagDefinitionId) {
    if (_selectedTagDefinitionId.contains(tagDefinitionId)) {
      _selectedTagDefinitionId = '';
    } else {
      _selectedTagDefinitionId = tagDefinitionId;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _allTemplatesTags.dispose();

    super.dispose();
  }
}
