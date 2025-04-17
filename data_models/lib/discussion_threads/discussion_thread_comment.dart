import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/chat/emotion.dart';
import 'package:data_models/utils/firestore_utils.dart';

part 'discussion_thread_comment.freezed.dart';
part 'discussion_thread_comment.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class DiscussionThreadComment
    with _$DiscussionThreadComment
    implements SerializeableRequest {
  static const kFieldCreatedAt = 'createdAt';
  static const kFieldIsDeleted = 'isDeleted';
  static const kFieldEmotions = 'emotions';

  DiscussionThreadComment._();

  factory DiscussionThreadComment({
    required String id,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
    DateTime? createdAt,
    String? replyToCommentId,
    required String creatorId,
    required String comment,
    @Default(false) bool isDeleted,
    @Default([]) List<Emotion> emotions,
  }) = _DiscussionThreadComment;

  factory DiscussionThreadComment.fromJson(Map<String, dynamic> json) =>
      _$DiscussionThreadCommentFromJson(json);
}
