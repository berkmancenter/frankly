// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_suggestion_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ChatSuggestionData _$$_ChatSuggestionDataFromJson(
        Map<String, dynamic> json) =>
    _$_ChatSuggestionData(
      id: json['id'] as String?,
      creatorId: json['creatorId'] as String?,
      creatorEmail: json['creatorEmail'] as String?,
      creatorName: json['creatorName'] as String?,
      createdDate: json['createdDate'] == null
          ? null
          : DateTime.parse(json['createdDate'] as String),
      message: json['message'] as String?,
      emotionType:
          $enumDecodeNullable(_$EmotionTypeEnumMap, json['emotionType']),
      upvotes: json['upvotes'] as int?,
      downvotes: json['downvotes'] as int?,
      type: $enumDecodeNullable(_$ChatSuggestionTypeEnumMap, json['type'],
              unknownValue: ChatSuggestionType.chat) ??
          ChatSuggestionType.chat,
      roomId: json['roomId'] as String?,
      agendaItemId: json['agendaItemId'] as String?,
      deleted: json['deleted'] as bool?,
    );

Map<String, dynamic> _$$_ChatSuggestionDataToJson(
        _$_ChatSuggestionData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'creatorId': instance.creatorId,
      'creatorEmail': instance.creatorEmail,
      'creatorName': instance.creatorName,
      'createdDate': instance.createdDate?.toIso8601String(),
      'message': instance.message,
      'emotionType': _$EmotionTypeEnumMap[instance.emotionType],
      'upvotes': instance.upvotes,
      'downvotes': instance.downvotes,
      'type': _$ChatSuggestionTypeEnumMap[instance.type]!,
      'roomId': instance.roomId,
      'agendaItemId': instance.agendaItemId,
      'deleted': instance.deleted,
    };

const _$EmotionTypeEnumMap = {
  EmotionType.thumbsUp: 'thumbsUp',
  EmotionType.heart: 'heart',
  EmotionType.hundred: 'hundred',
  EmotionType.exclamation: 'exclamation',
  EmotionType.plusOne: 'plusOne',
  EmotionType.laughWithTears: 'laughWithTears',
  EmotionType.heartEyes: 'heartEyes',
};

const _$ChatSuggestionTypeEnumMap = {
  ChatSuggestionType.chat: 'chat',
  ChatSuggestionType.suggestion: 'suggestion',
};
