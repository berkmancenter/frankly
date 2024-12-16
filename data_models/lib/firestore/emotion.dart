import 'package:freezed_annotation/freezed_annotation.dart';

part 'emotion.freezed.dart';
part 'emotion.g.dart';

enum EmotionType {
  thumbsUp,
  heart,
  hundred,
  exclamation,
  plusOne,
  laughWithTears,
  heartEyes,
}

@Freezed(makeCollectionsUnmodifiable: false)
class Emotion with _$Emotion {
  Emotion._();

  factory Emotion({
    required String creatorId,
    required EmotionType emotionType,
  }) = _Emotion;

  factory Emotion.fromJson(Map<String, dynamic> json) =>
      _$EmotionFromJson(json);
}
