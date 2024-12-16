import 'package:flutter/material.dart';
import 'package:junto/app/junto/templates/create_topic/create_custom_topic_page.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/meeting_agenda_provider.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto_models/analytics/analytics_entities.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/firestore/topic.dart';

class CreateTopicPresenter extends ChangeNotifier {
  final JuntoProvider juntoProvider;
  final TopicActionType topicActionType;
  final Topic? topic;
  final String topicId;
  late Topic _topic;

  CreateTopicPresenter({
    required this.juntoProvider,
    required this.topicActionType,
    this.topic,
    required this.topicId,
  });

  Topic get updatedTopic => _topic;

  void initialize() {
    switch (topicActionType) {
      // If user selected to update the topic, topic must be provided.
      case TopicActionType.edit:
        _topic = topic!;
        break;
      // If user is not updating the topic - assign it to template OR brand new one.
      case TopicActionType.create:
      case TopicActionType.duplicate:
        _topic = topic ??
            Topic(
              id: topicId,
              collectionPath: firestoreDatabase.topicsCollection(juntoProvider.juntoId).path,
              creatorId: userService.currentUserId!,
              isOfficial: false,
              image: defaultTopicImage(randomString()),
              agendaItems: defaultAgendaItems(juntoProvider.junto.id).toList(),
              discussionSettings: juntoProvider.discussionSettings,
            );
        break;
    }
  }

  Future<Topic> createTopic() async {
    final topic = await firestoreDatabase.createTopic(
      juntoId: juntoProvider.junto.id,
      topic: _topic,
    );
    var juntoId = topic.juntoId;
    var topicId = topic.id;
    analytics.logEvent(AnalyticsCompleteNewGuideEvent(juntoId: juntoId, guideId: topicId));
    return topic;
  }

  Future<void> updateTopic() async {
    return await firestoreDatabase.updateTopic(
      juntoId: juntoProvider.junto.id,
      topic: _topic,
      keys: [
        Topic.kFieldTopicUrl,
        Topic.kFieldTopicTitle,
        Topic.kFieldTopicDescription,
        Topic.kFieldTopicImage,
      ],
    );
  }

  void updateTopicImage(String imageUrl) {
    _topic = _topic.copyWith(image: imageUrl);
    notifyListeners();
  }

  void onChangeTitle(value) {
    _topic = _topic.copyWith(title: value);
    notifyListeners();
  }

  void onChangeDescription(value) {
    _topic = _topic.copyWith(description: value);
    notifyListeners();
  }

  String getPageTitle() {
    switch (topicActionType) {
      case TopicActionType.create:
      case TopicActionType.duplicate:
        return 'Create a template';
      case TopicActionType.edit:
        return 'Update template';
    }
  }

  String getButtonTitle() {
    switch (topicActionType) {
      case TopicActionType.create:
        return 'Create';
      case TopicActionType.edit:
        return 'Update';
      case TopicActionType.duplicate:
        return 'Duplicate';
    }
  }
}
