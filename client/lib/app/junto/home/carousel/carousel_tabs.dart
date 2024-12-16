import 'package:flutter/material.dart';
import 'package:junto/app/junto/home/carousel/time_indicator.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/common_widgets/junto_list_view.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/topic.dart';

/// Carousel tab that contains the name, icon, tagline, and description of the junto group.
class AboutJuntoCarouselTab extends StatelessWidget {
  final Junto junto;

  const AboutJuntoCarouselTab({
    required this.junto,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Center(
        child: JuntoListView(
          physics: const ClampingScrollPhysics(),
          shrinkWrap: true,
          children: [
            if (junto.profileImageUrl != null && junto.profileImageUrl!.trim().isNotEmpty)
              Align(
                alignment: Alignment.center,
                child: ClipOval(
                  child: JuntoImage(
                    junto.profileImageUrl,
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            SizedBox(height: 10),
            if (junto.name != null) ...[
              JuntoText(
                junto.name!.toUpperCase(),
                style: AppTextStyle.body.copyWith(color: AppColor.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.0),
            ],
            if (junto.tagLine != null) ...[
              Container(
                constraints:
                    BoxConstraints(minHeight: responsiveLayoutService.isMobile(context) ? 40 : 80),
                alignment: Alignment.center,
                child: JuntoText(
                  junto.tagLine!,
                  style: AppTextStyle.headline3.copyWith(
                      fontSize: responsiveLayoutService.getDynamicSize(context, 40),
                      color: AppColor.white),
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

/// Carousel tab that contains information on a featured discussion / event.
class FeaturedDiscussionCarouselTab extends StatelessWidget {
  final Discussion discussion;

  const FeaturedDiscussionCarouselTab({
    required this.discussion,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (discussion.scheduledTime != null) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: VerticalTimeAndDateIndicator(time: discussion.scheduledTime!),
          ),
          SizedBox(height: 8),
        ],
        JuntoText(
          discussion.title ?? 'Scheduled event',
          style: AppTextStyle.body.copyWith(color: AppColor.white),
          maxLines: 3,
        ),
        if (discussion.isLiveStream) ...[
          SizedBox(height: 8),
          Container(
            width: 82,
            height: 25,
            decoration: BoxDecoration(
              border: Border.all(color: AppColor.white),
              borderRadius: BorderRadius.circular(13),
            ),
            alignment: Alignment.center,
            child: JuntoText(
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

/// Carousel tab that contains information on a featured topic / event category.
class FeaturedTopicCarouselTab extends StatelessWidget {
  final Topic topic;

  const FeaturedTopicCarouselTab({
    required this.topic,
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
          JuntoText(
            topic.title ?? 'Event template',
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
            child: JuntoText(
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
