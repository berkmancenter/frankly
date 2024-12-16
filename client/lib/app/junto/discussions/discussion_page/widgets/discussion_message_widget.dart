import 'package:flutter/material.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/common_widgets/user_profile_chip.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_asset.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/extensions.dart';
import 'package:junto_models/firestore/discussion_message.dart';

class DiscussionMessageWidget extends StatelessWidget {
  final DiscussionMessage discussionMessage;
  final Function() onRemoveMessage;
  final bool isMod;
  final bool isDocCreator;

  const DiscussionMessageWidget({
    Key? key,
    required this.discussionMessage,
    required this.onRemoveMessage,
    this.isMod = false,
    this.isDocCreator = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final createdAt = discussionMessage.createdAt ?? clockService.now();
    final String formattedTime = createdAt.getFormattedTime(format: 'MM.dd.yy HH:mma');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColor.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedTime,
                style: AppTextStyle.eyebrow.copyWith(color: AppColor.gray2),
              ),
              if (isMod || isDocCreator)
                JuntoInkWell(
                  onTap: onRemoveMessage,
                  child: JuntoImage(null, asset: AppAsset.kDeletePng),
                )
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserProfileChip(
                userId: discussionMessage.creatorId,
                showBorder: false,
                showName: false,
                imageHeight: 30,
                enableOnTap: false,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  discussionMessage.message,
                  style: AppTextStyle.eyebrow.copyWith(color: AppColor.gray1),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
