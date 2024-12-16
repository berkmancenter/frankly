import 'package:flutter/material.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/firestore/topic.dart';
import 'package:provider/provider.dart';

const _kDefaultLogoImageUrl = 'https://res.cloudinary.com/dh0vegjku/image/upload/v1725488238/frankly_assets/Frankly-Icon-144x144_ex8nky.png';

String get defaultInstantMeetingTopicId => defaultInstantMeetingTopic.id;
Topic get defaultInstantMeetingTopic => Topic(
      id: 'instant-meeting-topic',
      // This required field will be set before writing to firestore.
      collectionPath: '',
      creatorId: userService.currentUserId!,
      title: 'Instant Meeting',
      image: _kDefaultLogoImageUrl,
    );

const defaultTopicId = 'misc';
Topic get defaultTopic => Topic(
      id: defaultTopicId,
      // This required field will be set before writing to firestore.
      collectionPath: '',
      creatorId: userService.currentUserId!,
      title: 'Miscellaneous',
      image: _kDefaultLogoImageUrl,
    );

class TopicProvider with ChangeNotifier {
  final String juntoId;
  final String topicId;

  TopicProvider({
    required this.juntoId,
    required this.topicId,
  });

  factory TopicProvider.fromDocumentPath(String documentPath) {
    final discussionMatch = RegExp('/?junto/([^/]+)/topics/([^/]+)').matchAsPrefix(documentPath);
    final juntoId = discussionMatch!.group(1)!;
    final topicId = discussionMatch.group(2)!;

    return TopicProvider(
      juntoId: juntoId,
      topicId: topicId,
    );
  }

  TopicProvider copy() {
    return TopicProvider(juntoId: juntoId, topicId: topicId)
      .._topicFuture = _topicFuture
      .._topic = _topic;
  }

  late Future<Topic> _topicFuture;
  Topic? _topic;

  Future<Topic> get topicFuture => _topicFuture;
  Topic get topic {
    final topicValue = _topic;
    if (topicValue == null) {
      throw Exception('Topic must be loaded before being accessed.');
    }

    return topicValue;
  }

  void initialize() {
    _topicFuture = _loadTopic();
  }

  Future<Topic> _loadTopic() async {
    final topic = await firestoreDatabase.juntoTopic(
      juntoId: juntoId,
      topicId: topicId,
    );

    _topic = topic;
    notifyListeners();
    return topic;
  }

  static TopicProvider watch(BuildContext context) => Provider.of<TopicProvider>(context);

  static TopicProvider read(BuildContext context) =>
      Provider.of<TopicProvider>(context, listen: false);

  static TopicProvider? readOrNull(BuildContext context) =>
      providerOrNull(() => Provider.of<TopicProvider>(context, listen: false));
}
