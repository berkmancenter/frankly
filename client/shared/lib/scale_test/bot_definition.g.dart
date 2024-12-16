// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bot_definition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BotDefinition _$BotDefinitionFromJson(Map<String, dynamic> json) =>
    BotDefinition(
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      discussionType:
          $enumDecode(_$DiscussionTypeEnumMap, json['discussionType']),
      juntoId: json['juntoId'] as String,
      topicId: json['topicId'] as String,
      discussionId: json['discussionId'] as String,
    );

Map<String, dynamic> _$BotDefinitionToJson(BotDefinition instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'discussionType': _$DiscussionTypeEnumMap[instance.discussionType]!,
      'juntoId': instance.juntoId,
      'topicId': instance.topicId,
      'discussionId': instance.discussionId,
    };

const _$DiscussionTypeEnumMap = {
  DiscussionType.hosted: 'hosted',
  DiscussionType.hostless: 'hostless',
  DiscussionType.livestream: 'livestream',
};
