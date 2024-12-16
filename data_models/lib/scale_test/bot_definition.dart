import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:data_models/firestore/event.dart';

part 'bot_definition.g.dart';

@JsonSerializable()
class BotDefinition {
  final String name;
  final String email;
  final String password;

  final EventType eventType;
  final String communityId;
  final String templateId;
  final String eventId;

  BotDefinition({
    required this.name,
    required this.email,
    required this.password,
    required this.eventType,
    required this.communityId,
    required this.templateId,
    required this.eventId,
  });

  factory BotDefinition.fromJson(Map<String, dynamic> json) =>
      _$BotDefinitionFromJson(json);

  Map<String, dynamic> toJson() => _$BotDefinitionToJson(this);
}
