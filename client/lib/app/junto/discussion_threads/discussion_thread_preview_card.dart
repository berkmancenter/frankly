import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:junto/app/junto/discussion_threads/widgets/emotion_section.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/app_clickable_widget.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/common_widgets/user_profile_chip.dart';
import 'package:junto/services/user_service.dart';
import 'package:junto/styles/app_asset.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/dialogs.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/firestore/discussion_thread.dart';
import 'package:junto_models/firestore/discussion_thread_comment.dart';
import 'package:junto_models/firestore/emotion.dart';

class DiscussionThreadPreviewCard extends StatelessWidget {
  final DiscussionThread discussionThread;
  final UserService userService;
  final void Function(LikeType) onLikeDislikeToggle;

  final void Function() onSeeMoreTap;
  final void Function() onCardTap;
  final void Function(EmotionType) onEmotionTypeSelect;
  final void Function(String) onAddNewComment;
  final bool isMobile;
  final Emotion? currentlySelectedDiscussionThreadEmotion;
  final DiscussionThreadComment? mostRecentDiscussionThreadComment;

  const DiscussionThreadPreviewCard({
    Key? key,
    required this.discussionThread,
    required this.userService,
    required this.onLikeDislikeToggle,
    required this.onSeeMoreTap,
    required this.onCardTap,
    required this.onEmotionTypeSelect,
    required this.onAddNewComment,
    required this.isMobile,
    required this.currentlySelectedDiscussionThreadEmotion,
    this.mostRecentDiscussionThreadComment,
  }) : super(key: key);

  AppAsset _getLikeImagePath() {
    final isLiked = discussionThread.isLiked(userService.isSignedIn, userService.currentUserId);
    return isLiked ? AppAsset.kLikeSelectedPng : AppAsset.kLikeNotSelectedPng;
  }

  AppAsset _getDislikeImagePath() {
    final isDisliked =
        discussionThread.isDisliked(userService.isSignedIn, userService.currentUserId);
    return isDisliked ? AppAsset.kDislikeSelectedPng : AppAsset.kDislikeNotSelectedPng;
  }

  String _getLikeDislikeCount() {
    final count = discussionThread.getLikeDislikeCount();
    final numberFormat = NumberFormat.compact();

    return numberFormat.format(count);
  }

  @override
  Widget build(BuildContext context) {
    final localImageUrl = discussionThread.imageUrl;

    return Material(
      color: AppColor.white,
      child: InkWell(
        onTap: onCardTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            _buildTopSection(),
            SizedBox(height: 20),
            if (localImageUrl != null) ...[
              _buildImage(localImageUrl, isMobile),
              SizedBox(height: 20),
            ],
            _buildContentSection(),
            SizedBox(height: 20),
            _buildCommentsAndEmotionsSection(context),
            SizedBox(height: 20),
            _buildReplySection(context),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    final likeImagePath = _getLikeImagePath();
    final dislikeImagePath = _getDislikeImagePath();
    final likeDislikeCount = _getLikeDislikeCount();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          UserProfileChip(
            userId: discussionThread.creatorId,
            textStyle: AppTextStyle.bodyMedium.copyWith(color: AppColor.gray2),
            showBorder: true,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                likeDislikeCount,
                style: AppTextStyle.bodyMedium.copyWith(color: AppColor.gray2),
              ),
              SizedBox(width: 10),
              AppClickableWidget(
                child: JuntoImage(null, asset: likeImagePath, width: 20, height: 20),
                onTap: () async {
                  await guardSignedIn(() async {
                    final isLiked = discussionThread.isLiked(
                      userService.isSignedIn,
                      userService.currentUserId,
                    );
                    onLikeDislikeToggle(isLiked ? LikeType.neutral : LikeType.like);
                  });
                },
              ),
              SizedBox(width: 5),
              AppClickableWidget(
                child: JuntoImage(null, asset: dislikeImagePath, width: 20, height: 20),
                onTap: () async {
                  await guardSignedIn(() async {
                    final isDisliked = discussionThread.isDisliked(
                      userService.isSignedIn,
                      userService.currentUserId,
                    );
                    onLikeDislikeToggle(isDisliked ? LikeType.neutral : LikeType.dislike);
                  });
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildImage(String imageUrl, bool isMobile) {
    if (isMobile) {
      return JuntoImage(imageUrl, width: double.maxFinite, height: 300, fit: BoxFit.cover);
    } else {
      return JuntoImage(imageUrl, width: double.maxFinite, fit: BoxFit.cover);
    }
  }

  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: JuntoText(
        discussionThread.content,
        style: AppTextStyle.body.copyWith(color: AppColor.gray2),
        maxLines: 5,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildCommentsAndEmotionsSection(BuildContext context) {
    final localMostRecentDiscussionThreadComment = mostRecentDiscussionThreadComment;
    final commentCount = discussionThread.commentCount;
    final commentsText = commentCount == 0
        ? 'No Comments'
        : commentCount == 1
            ? '1 Comment'
            : '$commentCount Comments';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                commentsText,
                style: AppTextStyle.bodyMedium.copyWith(color: AppColor.gray2),
              ),
              EmotionSection(
                emotions: discussionThread.emotions,
                currentlySelectedEmotion: currentlySelectedDiscussionThreadEmotion,
                onEmotionTypeSelect: (emotionType) => onEmotionTypeSelect(emotionType),
              ),
            ],
          ),
          if (localMostRecentDiscussionThreadComment != null)
            Stack(
              children: [
                Positioned(
                  top: 0,
                  bottom: 0,
                  child: Container(width: 1, color: AppColor.gray2),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      JuntoText(
                        localMostRecentDiscussionThreadComment.comment,
                        style: AppTextStyle.body.copyWith(color: AppColor.gray2),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppClickableWidget(
                        child: Text(
                          'See more',
                          style: AppTextStyle.bodyMedium.copyWith(color: AppColor.gray1),
                        ),
                        onTap: onSeeMoreTap,
                        isIcon: false,
                      ),
                    ],
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }

  Widget _buildReplySection(BuildContext context) {
    final borderRadius = BorderRadius.circular(10);
    final isSignedIn = userService.isSignedIn;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Material(
        borderRadius: borderRadius,
        color: AppColor.white,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: () async {
            await guardSignedIn(() async {
              final comment = await Dialogs.showComposeMessageDialog(
                context,
                title: 'Add comment',
                isMobile: isMobile,
                labelText: 'Comment',
                validator: (text) =>
                    text == null || text.isEmpty ? 'Comment cannot be empty' : null,
                positiveButtonText: 'Add Comment',
              );

              if (comment != null) {
                onAddNewComment(comment);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: Border.all(color: AppColor.gray5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (isSignedIn) ...[
                  UserProfileChip(
                    userId: userService.currentUserId,
                    showName: false,
                    showBorder: true,
                  ),
                  SizedBox(width: 10),
                ],
                JuntoText(
                  'Reply',
                  style: AppTextStyle.bodyMedium.copyWith(color: AppColor.gray2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
