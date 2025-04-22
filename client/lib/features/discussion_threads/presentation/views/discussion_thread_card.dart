import 'package:client/features/auth/utils/auth_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:client/features/discussion_threads/presentation/widgets/emotion_section.dart';
import 'package:client/core/widgets/buttons/app_clickable_widget.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/features/user/presentation/widgets/user_profile_chip.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/utils/extensions.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/discussion_threads/discussion_thread.dart';

class DiscussionThreadCard extends StatelessWidget {
  final DiscussionThread discussionThread;
  final UserService userService;
  final void Function(LikeType) onLikeDislikeToggle;
  final void Function(EmotionType) onEmotionTypeSelect;
  final Emotion? currentlySelectedDiscussionThreadEmotion;
  final bool isMobile;

  const DiscussionThreadCard({
    Key? key,
    required this.discussionThread,
    required this.userService,
    required this.onLikeDislikeToggle,
    required this.onEmotionTypeSelect,
    required this.currentlySelectedDiscussionThreadEmotion,
    required this.isMobile,
  }) : super(key: key);

  AppAsset _getLikeImagePath() {
    final isLiked = discussionThread.isLiked(
      userService.isSignedIn,
      userService.currentUserId,
    );
    return isLiked ? AppAsset.kLikeSelectedPng : AppAsset.kLikeNotSelectedPng;
  }

  AppAsset _getDislikeImagePath() {
    final isDisliked = discussionThread.isDisliked(
      userService.isSignedIn,
      userService.currentUserId,
    );
    return isDisliked
        ? AppAsset.kDislikeSelectedPng
        : AppAsset.kDislikeNotSelectedPng;
  }

  String _getLikeDislikeCount() {
    final count = discussionThread.getLikeDislikeCount();
    final numberFormat = NumberFormat.compact();

    return numberFormat.format(count);
  }

  @override
  Widget build(BuildContext context) {
    final localImageURL = discussionThread.imageUrl;

    return Container(
      color: AppColor.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          _buildTopSection(),
          SizedBox(height: 20),
          if (localImageURL != null) ...[
            _buildImage(localImageURL),
            SizedBox(height: 20),
          ],
          _buildContentSection(),
          SizedBox(height: 20),
          _buildEmotionsSection(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTopSection() {
    final likeImagePath = _getLikeImagePath();
    final dislikeImagePath = _getDislikeImagePath();
    final likeDislikeCount = _getLikeDislikeCount();

    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            UserProfileChip(
              userId: discussionThread.creatorId,
              textStyle:
                  AppTextStyle.bodyMedium.copyWith(color: AppColor.gray2),
              showName: true,
              showBorder: true,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  likeDislikeCount,
                  style:
                      AppTextStyle.bodyMedium.copyWith(color: AppColor.gray2),
                ),
                SizedBox(width: 5),
                AppClickableWidget(
                  child: ProxiedImage(
                    null,
                    asset: likeImagePath,
                    width: 20,
                    height: 20,
                  ),
                  onTap: () async {
                    await guardSignedIn(() async {
                      final isLiked = discussionThread.isLiked(
                        userService.isSignedIn,
                        userService.currentUserId,
                      );
                      onLikeDislikeToggle(
                        isLiked ? LikeType.neutral : LikeType.like,
                      );
                    });
                  },
                ),
                SizedBox(width: 5),
                AppClickableWidget(
                  child: ProxiedImage(
                    null,
                    asset: dislikeImagePath,
                    width: 20,
                    height: 20,
                  ),
                  onTap: () async {
                    await guardSignedIn(() async {
                      final isDisliked = discussionThread.isDisliked(
                        userService.isSignedIn,
                        userService.currentUserId,
                      );
                      onLikeDislikeToggle(
                        isDisliked ? LikeType.neutral : LikeType.dislike,
                      );
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    return ProxiedImage(
      imageUrl,
      width: double.maxFinite,
      height: 500,
      fit: BoxFit.cover,
    );
  }

  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: HeightConstrainedText(
        discussionThread.content,
        style: AppTextStyle.body.copyWith(color: AppColor.gray2),
      ),
    );
  }

  Widget _buildEmotionsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      alignment: Alignment.centerRight,
      child: EmotionSection(
        emotions: discussionThread.emotions,
        currentlySelectedEmotion: currentlySelectedDiscussionThreadEmotion,
        onEmotionTypeSelect: (emotionType) => onEmotionTypeSelect(emotionType),
      ),
    );
  }
}
