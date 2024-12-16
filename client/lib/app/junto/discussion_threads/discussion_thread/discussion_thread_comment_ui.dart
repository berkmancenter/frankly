import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:junto_models/firestore/discussion_thread_comment.dart';
part 'discussion_thread_comment_ui.g.dart';

@JsonSerializable(createFactory: false)
class DiscussionThreadCommentUI {
  final DiscussionThreadComment parentComment;
  final List<DiscussionThreadComment> childrenComments;

  DiscussionThreadCommentUI(this.parentComment, this.childrenComments);

  Map<String, dynamic> toJson() => _$DiscussionThreadCommentUIToJson(this);
}
