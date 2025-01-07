// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discussion_thread_comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_DiscussionThreadComment _$$_DiscussionThreadCommentFromJson(
        Map<String, dynamic> json) =>
    _$_DiscussionThreadComment(
      id: json['id'] as String,
      createdAt: dateTimeFromTimestamp(json['createdAt']),
      replyToCommentId: json['replyToCommentId'] as String?,
      creatorId: json['creatorId'] as String,
      comment: json['comment'] as String,
      isDeleted: json['isDeleted'] as bool? ?? false,
      emotions: (json['emotions'] as List<dynamic>?)
              ?.map((e) => Emotion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$_DiscussionThreadCommentToJson(
        _$_DiscussionThreadComment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': serverTimestamp(instance.createdAt),
      'replyToCommentId': instance.replyToCommentId,
      'creatorId': instance.creatorId,
      'comment': instance.comment,
      'isDeleted': instance.isDeleted,
      'emotions': instance.emotions.map((e) => e.toJson()).toList(),
    };
