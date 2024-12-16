// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discussion_thread.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_DiscussionThread _$$_DiscussionThreadFromJson(Map<String, dynamic> json) =>
    _$_DiscussionThread(
      id: json['id'] as String,
      createdAt: dateTimeFromTimestamp(json['createdAt']),
      creatorId: json['creatorId'] as String,
      likedByIds: (json['likedByIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      dislikedByIds: (json['dislikedByIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      emotions: (json['emotions'] as List<dynamic>?)
              ?.map((e) => Emotion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      commentCount: json['commentCount'] as int? ?? 0,
    );

Map<String, dynamic> _$$_DiscussionThreadToJson(_$_DiscussionThread instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': serverTimestamp(instance.createdAt),
      'creatorId': instance.creatorId,
      'likedByIds': instance.likedByIds,
      'dislikedByIds': instance.dislikedByIds,
      'emotions': instance.emotions.map((e) => e.toJson()).toList(),
      'content': instance.content,
      'imageUrl': instance.imageUrl,
      'isDeleted': instance.isDeleted,
      'commentCount': instance.commentCount,
    };
