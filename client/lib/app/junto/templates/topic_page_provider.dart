import 'dart:async';

import 'package:flutter/material.dart';
import 'package:junto/services/firestore/firestore_utils.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/junto_tag.dart';
import 'package:junto_models/firestore/topic.dart';
import 'package:provider/provider.dart';

class TopicPageProvider with ChangeNotifier {
  final String juntoId;
  final String topicId;

  late BehaviorSubjectWrapper<Topic?> _topicStream;
  late StreamSubscription _topicSubscription;

  late BehaviorSubjectWrapper<List<Discussion>> _discussions;

  late BehaviorSubjectWrapper<List<JuntoTag>> _topicTagsStream;
  late StreamSubscription _topicTagListener;

  late Future<List<Topic>> _topicsFuture;

  bool _isNewPrerequisite = false;
  bool _isHelpExpanded = false;
  TopicPageProvider({required this.juntoId, required this.topicId});

  Stream<Topic?> get topicStream => _topicStream;

  Future<List<Topic>> get topicsFuture => _topicsFuture;

  Topic? get topic => _topicStream.stream.valueOrNull;

  List<JuntoTag> get tags => _topicTagsStream.stream.valueOrNull ?? [];

  Stream<List<Discussion>> get discussions => _discussions.stream;

  bool get hasUpcomingEvents => (_discussions.value?.length ?? 0) > 0;

  bool get isNewPrerequisite => _isNewPrerequisite;

  bool get isHelpExpanded => _isHelpExpanded;

  void initialize() {
    _topicStream =
        wrapInBehaviorSubject(firestoreDatabase.topicStream(juntoId: juntoId, topicId: topicId));
    _topicSubscription = _topicStream.listen((topic) {
      notifyListeners();
    });
    _discussions =
        firestoreDiscussionService.futurePublicDiscussions(juntoId: juntoId, topicId: topicId);

    _topicsFuture = _loadAllTopics();

    _topicTagsStream = wrapInBehaviorSubject(firestoreTagService.getJuntoTags(
      juntoId: juntoId,
      taggedItemId: topicId,
      taggedItemType: TaggedItemType.topic,
    ));
    _topicTagListener = _topicTagsStream.stream.listen((tags) {
      notifyListeners();
    });
  }

  Future<List<Topic>> _loadAllTopics() async {
    final allTopics = await firestoreDatabase.allJuntoTopics(juntoId, includeRemovedTopics: false);

    return allTopics;
  }

  set isNewPrerequisite(bool value) {
    _isNewPrerequisite = value;

    notifyListeners();
  }

  set isHelpExpanded(bool value) {
    _isHelpExpanded = value;
    notifyListeners();
  }

  static TopicPageProvider? read(BuildContext context) {
    try {
      return Provider.of<TopicPageProvider>(context, listen: false);
    } on ProviderNotFoundException {
      return null;
    }
  }

  static TopicPageProvider? watch(BuildContext context) {
    try {
      return Provider.of<TopicPageProvider>(context);
    } on ProviderNotFoundException {
      return null;
    }
  }

  @override
  void dispose() {
    _discussions.dispose();
    _topicStream.dispose();
    _topicSubscription.cancel();
    _topicTagListener.cancel();
    _topicTagsStream.dispose();
    super.dispose();
  }
}
