import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/pre_post_card.dart';
import 'package:junto_models/firestore/utils.dart';

part 'topic.freezed.dart';
part 'topic.g.dart';

String defaultTopicImage(String? id) => 'https://picsum.photos/seed/$id/300';

enum TopicStatus {
  active,
  removed,
}

@Freezed(makeCollectionsUnmodifiable: false)
class Topic with _$Topic implements SerializeableRequest {
  static const String fieldPrerequisiteTopic = 'prerequisiteTopicId';
  static const String kFieldAgendaItems = 'agendaItems';
  static const String kFieldTopicImage = 'image';
  static const String kFieldTopicStatus = 'status';
  static const String kFieldTopicUrl = 'url';
  static const String kFieldTopicTitle = 'title';
  static const String kFieldTopicDescription = 'description';
  static const String kFieldPreEventCardData = 'preEventCardData';
  static const String kFieldPostEventCardData = 'postEventCardData';
  static const String kFieldDiscussionSettings = 'discussionSettings';

  const Topic._();

  const factory Topic({
    required String id,
    required String collectionPath,

    /// If set indicates where in the order this topic should be. Lower priorities are shown first
    /// followed by any topics with null.
    ///
    /// Currently only applies to the "What we're talking about" section.
    int? orderingPriority,
    required String creatorId,
    String? prerequisiteTopicId,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp) DateTime? createdDate,
    String? title,
    String? url,
    String? image,
    String? description,
    String? category,
    DiscussionSettings? discussionSettings,
    @Default(true) bool isOfficial,
    @Default(TopicStatus.active)
    @JsonKey(defaultValue: TopicStatus.active, unknownEnumValue: TopicStatus.active)
        TopicStatus status,
    @Default([]) List<AgendaItem> agendaItems,
    PrePostCard? preEventCardData,
    PrePostCard? postEventCardData,
  }) = _Topic;

  factory Topic.fromJson(Map<String, dynamic> json) => _$TopicFromJson(json);

  String get juntoId {
    final pathSegments = collectionPath.split('/');
    return pathSegments[1];
  }
}
