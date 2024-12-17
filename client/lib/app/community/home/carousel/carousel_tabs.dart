import 'package:flutter/material.dart';
import 'package:client/app/community/home/carousel/time_indicator.dart';
import 'package:client/common_widgets/proxied_image.dart';
import 'package:client/common_widgets/custom_list_view.dart';
import 'package:client/services/services.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/utils/height_constained_text.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/templates/template.dart';

/// Carousel tab that contains the name, icon, tagline, and description of the community group.
class AboutCommunityCarouselTab extends StatelessWidget {
  final Community community;

  const AboutCommunityCarouselTab({
    required this.community,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Center(
        child: CustomListView(
          physics: const ClampingScrollPhysics(),
          shrinkWrap: true,
          children: [
            if (community.profileImageUrl != null &&
                community.profileImageUrl!.trim().isNotEmpty)
              Align(
                alignment: Alignment.center,
                child: ClipOval(
                  child: ProxiedImage(
                    community.profileImageUrl,
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            SizedBox(height: 10),
            if (community.name != null) ...[
              HeightConstrainedText(
                community.name!.toUpperCase(),
                style: AppTextStyle.body.copyWith(color: AppColor.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.0),
            ],
            if (community.tagLine != null) ...[
              Container(
                constraints: BoxConstraints(
                  minHeight:
                      responsiveLayoutService.isMobile(context) ? 40 : 80,
                ),
                alignment: Alignment.center,
                child: HeightConstrainedText(
                  community.tagLine!,
                  style: AppTextStyle.headline3.copyWith(
                    fontSize:
                        responsiveLayoutService.getDynamicSize(context, 40),
                    color: AppColor.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}

/// Carousel tab that contains information on a featured event / event.
class FeaturedEventCarouselTab extends StatelessWidget {
  final Event event;

  const FeaturedEventCarouselTab({
    required this.event,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (event.scheduledTime != null) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: VerticalTimeAndDateIndicator(time: event.scheduledTime!),
          ),
          SizedBox(height: 8),
        ],
        HeightConstrainedText(
          event.title ?? 'Scheduled event',
          style: AppTextStyle.body.copyWith(color: AppColor.white),
          maxLines: 3,
        ),
        if (event.isLiveStream) ...[
          SizedBox(height: 8),
          Container(
            width: 82,
            height: 25,
            decoration: BoxDecoration(
              border: Border.all(color: AppColor.white),
              borderRadius: BorderRadius.circular(13),
            ),
            alignment: Alignment.center,
            child: HeightConstrainedText(
              'livestream',
              style: AppTextStyle.eyebrowSmall.copyWith(color: AppColor.white),
            ),
          ),
        ] else
          SizedBox(height: 20),
        SizedBox(height: 25),
      ],
    );
  }
}

/// Carousel tab that contains information on a featured template / event category.
class FeaturedTemplateCarouselTab extends StatelessWidget {
  final Template template;

  const FeaturedTemplateCarouselTab({
    required this.template,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeightConstrainedText(
            template.title ?? 'Event template',
            style: AppTextStyle.body.copyWith(color: AppColor.white),
            maxLines: 3,
          ),
          SizedBox(height: 8),
          Container(
            width: 82,
            height: 25,
            decoration: BoxDecoration(
              border: Border.all(color: AppColor.white),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: HeightConstrainedText(
              'template',
              style: AppTextStyle.eyebrowSmall.copyWith(color: AppColor.white),
            ),
          ),
          SizedBox(height: 25),
        ],
      ),
    );
  }
}
