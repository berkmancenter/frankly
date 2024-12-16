// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emotion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Emotion _$$_EmotionFromJson(Map<String, dynamic> json) => _$_Emotion(
      creatorId: json['creatorId'] as String,
      emotionType: $enumDecode(_$EmotionTypeEnumMap, json['emotionType']),
    );

Map<String, dynamic> _$$_EmotionToJson(_$_Emotion instance) =>
    <String, dynamic>{
      'creatorId': instance.creatorId,
      'emotionType': _$EmotionTypeEnumMap[instance.emotionType]!,
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
