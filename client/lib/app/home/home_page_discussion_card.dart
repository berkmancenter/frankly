import 'package:flutter/material.dart';
import 'package:junto/app/junto/home/carousel/time_indicator.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/hover_shadow_container.dart';
import 'package:junto/common_widgets/junto_icon_or_logo.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/common_widgets/participants_list.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto/utils/memoized_builder.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/topic.dart';

class HomePageDiscussionCard extends StatefulWidget {
  final Discussion discussion;
  final Junto? junto;
  final Topic? topic;
  final List<String> participants;

  const HomePageDiscussionCard({
    Key? key,
    required this.discussion,
    required this.junto,
    required this.participants,
    this.topic,
  }) : super(key: key);

  @override
  State<HomePageDiscussionCard> createState() => _HomePageDiscussionCardState();
}

class _HomePageDiscussionCardState extends State<HomePageDiscussionCard> {
  int get _maxParticipantsShown => (MediaQuery.of(context).size.width < 400) ? 3 : 4;

  void _tapDiscussion(Discussion discussion) => routerDelegate.beamTo(
        JuntoPageRoutes(
          juntoDisplayId: discussion.juntoId,
        ).discussionPage(
          topicId: discussion.topicId,
          discussionId: discussion.id,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return HoverShadowContainer(
      shadowColor: AppColor.gray4,
      borderRadius: BorderRadius.circular(10),
      child: JuntoInkWell(
        hoverColor: Colors.transparent,
        onTap: () => _tapDiscussion(widget.discussion),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: responsiveLayoutService.isMobile(context) ? 130 : 118,
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [AppDecoration.lightBoxShadow],
          ),
          child: Row(
            children: [
              SizedBox(width: 10),
              _buildTimeSection(),
              SizedBox(width: 10),
              _buildImage(),
              SizedBox(width: 10),
              _buildRightSideOfCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSection() => SizedBox(
        height: 100,
        child: VerticalTimeAndDateIndicator(
          time: widget.discussion.scheduledTime ?? clockService.now(),
          shadow: false,
          padding: const EdgeInsets.all(3),
        ),
      );

  Widget _buildImage() => SizedBox(
        height: 90,
        width: 90,
        child: MemoizedBuilder<String>(
          getter: () =>
              generateRandomImageUrl(seed: widget.discussion.id.hashCode, resolution: 160),
          builder: (_, randomUrl) => JuntoImage(
            widget.discussion.image ?? widget.topic?.image ?? randomUrl,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

  Widget _buildRightSideOfCard() => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              JuntoText(
                widget.discussion.title ?? 'Upcoming Event',
                style: AppTextStyle.bodyMedium.copyWith(fontSize: 18),
                maxLines: responsiveLayoutService.isMobile(context) ? 3 : 2,
              ),
              if (widget.discussion.isLiveStream)
                JuntoText(
                  'Livestream',
                  style: AppTextStyle.eyebrowSmall.copyWith(color: AppColor.gray3),
                ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ParticipantsList(
                      iconSize: 30,
                      participantIds: widget.participants,
                      discussion: widget.discussion,
                      numberOfIconsToShow: _maxParticipantsShown,
                    ),
                  ),
                  if (widget.junto != null)
                    JuntoCircleIcon(widget.junto!,
                        withBorder: true, imageHeight: AppSize.kHomePageCommunityIconSize),
                ],
              )
            ],
          ),
        ),
      );
}
