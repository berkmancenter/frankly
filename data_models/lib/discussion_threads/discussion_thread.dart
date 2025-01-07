import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/chat/emotion.dart';
import 'package:data_models/utils/firestore_utils.dart';

part 'discussion_thread.freezed.dart';
part 'discussion_thread.g.dart';

enum LikeType {
  like,
  neutral,
  dislike,
}

@Freezed(makeCollectionsUnmodifiable: false)
class DiscussionThread with _$DiscussionThread implements SerializeableRequest {
  static const kFieldLikedByIds = 'likedByIds';
  static const kFieldDislikedByIds = 'dislikedByIds';
  static const kFieldEmotions = 'emotions';
  static const kFieldCreatedAt = 'createdAt';
  static const kFieldIsDeleted = 'isDeleted';
  static const kFieldCommentCount = 'commentCount';

  DiscussionThread._();

  factory DiscussionThread({
    required String id,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
    DateTime? createdAt,
    required String creatorId,
    @Default([]) List<String> likedByIds,
    @Default([]) List<String> dislikedByIds,
    @Default([]) List<Emotion> emotions,
    required String content,
    String? imageUrl,
    @Default(false) bool isDeleted,
    @Default(0) int commentCount,
  }) = _DiscussionThread;

  factory DiscussionThread.fromJson(Map<String, dynamic> json) =>
      _$DiscussionThreadFromJson(json);

  int getLikeDislikeCount() {
    final likeCount = likedByIds.length;
    final dislikeCount = dislikedByIds.length;
    final count = likeCount - dislikeCount;

    return count;
  }

  bool isLiked(bool isSignedIn, String? userId) {
    if (!isSignedIn || userId == null) {
      return false;
    }

    return likedByIds.any((element) => element == userId);
  }

  bool isDisliked(bool isSignedIn, String? userId) {
    if (!isSignedIn || userId == null) {
      return false;
    }

    return dislikedByIds.any((element) => element == userId);
  }
}
