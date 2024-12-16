import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/services/firestore/firestore_utils.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/firestore/junto_tag.dart';
import 'package:junto_models/firestore/topic.dart';

class SelectTopicProvider with ChangeNotifier {
  final String juntoId;

  SelectTopicProvider({required this.juntoId});
  static const _defaultNumTopicsShown = 30;

  int _numShownTopics = _defaultNumTopicsShown;
  late Future<List<Topic>> _topicsFuture;

  List<Topic>? _allTopics;
  List<Topic>? _filteredTopics;

  Topic? _selectedTopic;

  Set<String>? _allCategories;
  String? _selectedCategory;

  late BehaviorSubjectWrapper<List<JuntoTag>> _allTopicsTags;

  String _selectedTagDefinitionId = '';

  Stream<List<JuntoTag>> get allTagsStream => _allTopicsTags.stream;
  String get selectedTagDefinitionId => _selectedTagDefinitionId;
  List<JuntoTag> get allTags {
    final allTopicsIds = _allTopics
            ?.where((topic) => topic.status == TopicStatus.active)
            .map((topic) => topic.id)
            .toSet() ??
        {};

    return _allTopicsTags.value?.where((t) => allTopicsIds.contains(t.taggedItemId)).toList() ?? [];
  }

  Topic? get selectedTopic => _selectedTopic;

  Future<List<Topic>> get topicsFuture => _topicsFuture;
  List<Topic> get _filteredSelectedTopics {
    return _filteredTopics
            ?.where((topic) =>
                _isVisibleWithTopicFilters(topic) &&
                topic.status == TopicStatus.active &&
                (_selectedCategory == null || _selectedCategory == topic.category))
            .toList() ??
        [];
  }

  List<Topic> get displayTopics =>
      _filteredSelectedTopics.sublist(0, min(_filteredSelectedTopics.length, _numShownTopics));
  List<String> get allCategories => _allCategories?.toList() ?? [];
  bool get moreTopics => _numShownTopics < _filteredSelectedTopics.length;

  void initialize() {
    _topicsFuture = firestoreDatabase.allJuntoTopics(juntoId).then((topics) {
      topics.sort((a, b) {
        final aPriority = a.orderingPriority;
        final bPriority = b.orderingPriority;

        if (bPriority == null) {
          return -1;
        } else if (aPriority == null) {
          return 1;
        }
        return aPriority.compareTo(bPriority);
      });
      _filteredTopics = topics;
      _allTopics = topics;
      _allCategories = topics
          .where((topic) => !isNullOrEmpty(topic.category))
          .map((topic) => topic.category)
          .withoutNulls
          .toSet();
      return topics;
    });

    _allTopicsTags =
        wrapInBehaviorSubject(firestoreTagService.getTopicTagsStream(juntoId: juntoId));
  }

  void updateCategory(dynamic category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void updateSelectedTopic(topic) {
    _selectedTopic = topic;
    notifyListeners();
  }

  void _filterTopics(String searchQuery) {
    final searchQueryOption = searchQuery.toLowerCase();
    final results = _allTopics
            ?.where((topic) => topic.title?.toLowerCase().startsWith(searchQueryOption) ?? false)
            .toSet() ??
        {};

    results.addAll(_allTopics?.where((topic) =>
            !results.contains(topic) &&
            (topic.title?.toLowerCase().contains(searchQueryOption) ?? false)) ??
        {});

    results.addAll(_allTopics?.where((topic) =>
            !results.contains(topic) &&
            (topic.category?.toLowerCase().contains(searchQueryOption) ?? false)) ??
        {});
    _filteredTopics = results.toList();
  }

  void onSearchChanged(String text) {
    _filterTopics(text);

    notifyListeners();
  }

  void showMoreTopics() {
    _numShownTopics += _defaultNumTopicsShown;
    notifyListeners();
  }

  bool _isVisibleWithTopicFilters(Topic topic) {
    if (_selectedTagDefinitionId.isEmpty) return true;

    final topicTags = _allTopicsTags.value?.where((tag) => tag.taggedItemId == topic.id) ?? [];
    final isVisible = topicTags.any((tag) => _selectedTagDefinitionId.contains(tag.definitionId));

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
    _allTopicsTags.dispose();

    super.dispose();
  }
}
