import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:junto_models/firestore/discussion.dart';

part 'bot_definition.g.dart';

@JsonSerializable()
class BotDefinition {
  final String name;
  final String email;
  final String password;

  final DiscussionType discussionType;
  final String juntoId;
  final String topicId;
  final String discussionId;

  BotDefinition({
    required this.name,
    required this.email,
    required this.password,
    required this.discussionType,
    required this.juntoId,
    required this.topicId,
    required this.discussionId,
  });

  factory BotDefinition.fromJson(Map<String, dynamic> json) => _$BotDefinitionFromJson(json);

  Map<String, dynamic> toJson() => _$BotDefinitionToJson(this);
}
