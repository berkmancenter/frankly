import 'package:freezed_annotation/freezed_annotation.dart';

import 'emotion.dart';

part 'chat_suggestion_data.freezed.dart';
part 'chat_suggestion_data.g.dart';

enum ChatSuggestionType {
  chat,
  suggestion,
}

@Freezed(makeCollectionsUnmodifiable: false)
class ChatSuggestionData with _$ChatSuggestionData {
  factory ChatSuggestionData({
    String? id,
    String? creatorId,
    String? creatorEmail,
    String? creatorName,
    DateTime? createdDate,
    String? message,
    EmotionType? emotionType,
    int? upvotes,
    int? downvotes,
    @Default(ChatSuggestionType.chat)
    @JsonKey(unknownEnumValue: ChatSuggestionType.chat)
    ChatSuggestionType type,
    String? roomId,
    String? agendaItemId,
    bool? deleted,
  }) = _ChatSuggestionData;

  factory ChatSuggestionData.fromJson(Map<String, dynamic> json) =>
      _$ChatSuggestionDataFromJson(json);
}
