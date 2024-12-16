// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Topic _$$_TopicFromJson(Map<String, dynamic> json) => _$_Topic(
      id: json['id'] as String,
      collectionPath: json['collectionPath'] as String,
      orderingPriority: json['orderingPriority'] as int?,
      creatorId: json['creatorId'] as String,
      prerequisiteTopicId: json['prerequisiteTopicId'] as String?,
      createdDate: dateTimeFromTimestamp(json['createdDate']),
      title: json['title'] as String?,
      url: json['url'] as String?,
      image: json['image'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      discussionSettings: json['discussionSettings'] == null
          ? null
          : DiscussionSettings.fromJson(
              json['discussionSettings'] as Map<String, dynamic>),
      isOfficial: json['isOfficial'] as bool? ?? true,
      status: $enumDecodeNullable(_$TopicStatusEnumMap, json['status'],
              unknownValue: TopicStatus.active) ??
          TopicStatus.active,
      agendaItems: (json['agendaItems'] as List<dynamic>?)
              ?.map((e) => AgendaItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      preEventCardData: json['preEventCardData'] == null
          ? null
          : PrePostCard.fromJson(
              json['preEventCardData'] as Map<String, dynamic>),
      postEventCardData: json['postEventCardData'] == null
          ? null
          : PrePostCard.fromJson(
              json['postEventCardData'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_TopicToJson(_$_Topic instance) => <String, dynamic>{
      'id': instance.id,
      'collectionPath': instance.collectionPath,
      'orderingPriority': instance.orderingPriority,
      'creatorId': instance.creatorId,
      'prerequisiteTopicId': instance.prerequisiteTopicId,
      'createdDate': serverTimestamp(instance.createdDate),
      'title': instance.title,
      'url': instance.url,
      'image': instance.image,
      'description': instance.description,
      'category': instance.category,
      'discussionSettings': instance.discussionSettings?.toJson(),
      'isOfficial': instance.isOfficial,
      'status': _$TopicStatusEnumMap[instance.status]!,
      'agendaItems': instance.agendaItems.map((e) => e.toJson()).toList(),
      'preEventCardData': instance.preEventCardData?.toJson(),
      'postEventCardData': instance.postEventCardData?.toJson(),
    };

const _$TopicStatusEnumMap = {
  TopicStatus.active: 'active',
  TopicStatus.removed: 'removed',
};
