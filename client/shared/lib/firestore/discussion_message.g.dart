// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discussion_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_DiscussionMessage _$$_DiscussionMessageFromJson(Map<String, dynamic> json) =>
    _$_DiscussionMessage(
      creatorId: json['creatorId'] as String,
      createdAt: dateTimeFromTimestamp(json['createdAt']),
      createdAtMillis: json['createdAtMillis'] as int?,
      message: json['message'] as String,
    );

Map<String, dynamic> _$$_DiscussionMessageToJson(
        _$_DiscussionMessage instance) =>
    <String, dynamic>{
      'creatorId': instance.creatorId,
      'createdAt': timestampFromDateTime(instance.createdAt),
      'createdAtMillis': instance.createdAtMillis,
      'message': instance.message,
    };
