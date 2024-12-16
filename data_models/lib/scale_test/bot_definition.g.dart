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
      eventType: $enumDecode(_$EventTypeEnumMap, json['eventType']),
      communityId: json['communityId'] as String,
      templateId: json['templateId'] as String,
      eventId: json['eventId'] as String,
    );

Map<String, dynamic> _$BotDefinitionToJson(BotDefinition instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'eventType': _$EventTypeEnumMap[instance.eventType]!,
      'communityId': instance.communityId,
      'templateId': instance.templateId,
      'eventId': instance.eventId,
    };

const _$EventTypeEnumMap = {
  EventType.hosted: 'hosted',
  EventType.hostless: 'hostless',
  EventType.livestream: 'livestream',
};
