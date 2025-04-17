import 'package:flutter/material.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/features/user/presentation/widgets/user_profile_chip.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/utils/extensions.dart';
import 'package:data_models/events/event_message.dart';

class EventMessageWidget extends StatelessWidget {
  final EventMessage eventMessage;
  final Function() onRemoveMessage;
  final bool isMod;
  final bool isDocCreator;

  const EventMessageWidget({
    Key? key,
    required this.eventMessage,
    required this.onRemoveMessage,
    this.isMod = false,
    this.isDocCreator = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final createdAt = eventMessage.createdAt ?? clockService.now();
    final String formattedTime =
        createdAt.getFormattedTime(format: 'MM.dd.yy HH:mma');

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
                CustomInkWell(
                  onTap: onRemoveMessage,
                  child: ProxiedImage(null, asset: AppAsset.kDeletePng),
                ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserProfileChip(
                userId: eventMessage.creatorId,
                showBorder: false,
                showName: false,
                imageHeight: 30,
                enableOnTap: false,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  eventMessage.message,
                  style: AppTextStyle.eyebrow.copyWith(color: AppColor.gray1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
