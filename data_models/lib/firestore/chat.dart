import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:data_models/firestore/emotion.dart';
import 'package:data_models/firestore/membership.dart';
import 'package:data_models/firestore/utils.dart';

part 'chat.freezed.dart';
part 'chat.g.dart';

enum ChatMessageStatus {
  active,
  removed,
}

@Freezed(makeCollectionsUnmodifiable: false)
class ChatMessage with _$ChatMessage {
  static const String kFieldCreatedDate = 'createdDate';
  static const String kFieldMessageStatus = 'messageStatus';

  ChatMessage._();

  factory ChatMessage({
    String? id,
    String? collectionPath,
    String? message,
    @JsonKey(unknownEnumValue: null) EmotionType? emotionType,
    String? creatorId,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
    DateTime? createdDate,
    @Default(ChatMessageStatus.active)
    @JsonKey(
        defaultValue: ChatMessageStatus.active,
        unknownEnumValue: ChatMessageStatus.active)
    ChatMessageStatus messageStatus,
    @JsonKey(unknownEnumValue: null) MembershipStatus? membershipStatusSnapshot,

    /// Setting this field to true indicates it should show up in all breakout
    /// rooms and show in the floating display on screen
    @Default(false) bool? broadcast,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  bool get isFloatingEmoji => emotionType != null;
}
