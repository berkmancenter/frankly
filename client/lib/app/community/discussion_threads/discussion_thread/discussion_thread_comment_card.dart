import 'package:flutter/material.dart';
import 'package:client/app/community/discussion_threads/discussion_thread/discussion_thread_comment_ui.dart';
import 'package:client/app/community/discussion_threads/widgets/emotion_section.dart';
import 'package:client/common_widgets/app_clickable_widget.dart';
import 'package:client/common_widgets/confirm_dialog.dart';
import 'package:client/common_widgets/proxied_image.dart';
import 'package:client/common_widgets/user_profile_chip.dart';
import 'package:client/services/user_service.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/utils/height_constained_text.dart';
import 'package:data_models/discussion_threads/discussion_thread_comment.dart';
import 'package:data_models/chat/emotion.dart';

class DiscussionThreadCommentCard extends StatelessWidget {
  final DiscussionThreadCommentUI discussionThreadCommentUI;
  final UserService userService;
  final Emotion? Function(DiscussionThreadComment) currentlySelectedEmotion;
  final void Function(DiscussionThreadComment) onDeleteComment;
  final void Function(EmotionType, DiscussionThreadComment) onEmotionTypeSelect;

  const DiscussionThreadCommentCard({
    Key? key,
    required this.discussionThreadCommentUI,
    required this.userService,
    required this.onDeleteComment,
    required this.onEmotionTypeSelect,
    required this.currentlySelectedEmotion,
  }) : super(key: key);

  Future<void> _showDeleteCommentDialog(
    DiscussionThreadComment discussionThreadComment,
  ) async {
    await ConfirmDialog(
      title: 'Delete Comment',
      mainText: 'Are you sure you want to delete this comment?',
      onConfirm: (context) {
        Navigator.pop(context);
        onDeleteComment(discussionThreadComment);
      },
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    final parentComment = discussionThreadCommentUI.parentComment;
    final childrenComments = discussionThreadCommentUI.childrenComments;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          if (parentComment.isDeleted)
            _buildCommentDeleted()
          else
            _buildCommentSection(parentComment),
          if (childrenComments.isNotEmpty)
            Stack(
              children: [
                Positioned(
                  top: 0,
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Container(width: 1, color: AppColor.gray3),
                  ),
                ),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(left: 40),
                  shrinkWrap: true,
                  itemCount: childrenComments.length,
                  itemBuilder: (context, index) {
                    final discussionThreadComment = childrenComments[index];

                    if (discussionThreadComment.isDeleted) {
                      return _buildCommentDeleted();
                    } else {
                      return _buildCommentSection(discussionThreadComment);
                    }
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCommentDeleted() {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: HeightConstrainedText(
            'Comment Deleted',
            style: AppTextStyle.bodyMedium.copyWith(color: AppColor.gray2),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildCommentSection(DiscussionThreadComment discussionThreadComment) {
    final commentCreatorId = discussionThreadComment.creatorId;
    final isUsersComment = userService.currentUserId == commentCreatorId;
    final emotion = currentlySelectedEmotion(discussionThreadComment);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            UserProfileChip(
              userId: commentCreatorId,
              textStyle:
                  AppTextStyle.bodyMedium.copyWith(color: AppColor.gray2),
              showName: true,
              showBorder: true,
            ),
            EmotionSection(
              emotions: discussionThreadComment.emotions,
              currentlySelectedEmotion: emotion,
              onEmotionTypeSelect: (emotionType) {
                onEmotionTypeSelect(emotionType, discussionThreadComment);
              },
            ),
          ],
        ),
        SizedBox(height: 10),
        HeightConstrainedText(
          discussionThreadComment.comment,
          style: AppTextStyle.body.copyWith(color: AppColor.gray2),
        ),
        if (isUsersComment) ...[
          SizedBox(height: 10),
          Container(
            alignment: Alignment.centerRight,
            child: AppClickableWidget(
              child: ProxiedImage(
                null,
                asset: AppAsset.kTrashPng,
                width: 20,
                height: 20,
              ),
              onTap: () => _showDeleteCommentDialog(discussionThreadComment),
            ),
          ),
        ],
        SizedBox(height: 20),
      ],
    );
  }
}
