import 'package:client/core/utils/image_utils.dart';
import 'package:flutter/material.dart';
import 'package:client/features/community/presentation/widgets/carousel/time_indicator.dart';
import 'package:client/features/home/presentation/widgets/hover_shadow_container.dart';
import 'package:client/features/community/presentation/widgets/community_icon_or_logo.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/features/events/presentation/widgets/participants_list.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/services.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/core/widgets/memoized_builder.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/templates/template.dart';

class HomePageEventCard extends StatefulWidget {
  final Event event;
  final Community? community;
  final Template? template;
  final List<String> participants;

  const HomePageEventCard({
    Key? key,
    required this.event,
    required this.community,
    required this.participants,
    this.template,
  }) : super(key: key);

  @override
  State<HomePageEventCard> createState() => _HomePageEventCardState();
}

class _HomePageEventCardState extends State<HomePageEventCard> {
  int get _maxParticipantsShown =>
      (MediaQuery.of(context).size.width < 400) ? 3 : 4;

  void _tapEvent(Event event) => routerDelegate.beamTo(
        CommunityPageRoutes(
          communityDisplayId: event.communityId,
        ).eventPage(
          templateId: event.templateId,
          eventId: event.id,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return HoverShadowContainer(
      shadowColor: AppColor.gray4,
      borderRadius: BorderRadius.circular(10),
      child: CustomInkWell(
        hoverColor: Colors.transparent,
        onTap: () => _tapEvent(widget.event),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: responsiveLayoutService.isMobile(context) ? 130 : 118,
          decoration: BoxDecoration(
            color: context.theme.colorScheme.surfaceContainerLowest,
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
          time: widget.event.scheduledTime ?? clockService.now(),
          shadow: false,
          padding: const EdgeInsets.all(3),
        ),
      );

  Widget _buildImage() => SizedBox(
        height: 90,
        width: 90,
        child: MemoizedBuilder<String>(
          getter: () => generateRandomImageUrl(
            seed: widget.event.id.hashCode,
            resolution: 160,
          ),
          builder: (_, randomUrl) => ProxiedImage(
            widget.event.image ?? widget.template?.image ?? randomUrl,
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
              HeightConstrainedText(
                widget.event.title ?? 'Upcoming Event',
                style: AppTextStyle.bodyMedium.copyWith(fontSize: 18),
                maxLines: responsiveLayoutService.isMobile(context) ? 3 : 2,
              ),
              if (widget.event.isLiveStream)
                HeightConstrainedText(
                  'Livestream',
                  style:
                      AppTextStyle.eyebrowSmall.copyWith(color: AppColor.gray3),
                ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ParticipantsList(
                      iconSize: 30,
                      participantIds: widget.participants,
                      event: widget.event,
                      numberOfIconsToShow: _maxParticipantsShown,
                    ),
                  ),
                  if (widget.community != null)
                    CommunityCircleIcon(
                      widget.community!,
                      withBorder: true,
                      imageHeight: AppSize.kHomePageCommunityIconSize,
                    ),
                ],
              ),
            ],
          ),
        ),
      );
}
