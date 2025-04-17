import 'dart:math';

import 'package:client/core/utils/date_utils.dart';
import 'package:client/core/widgets/custom_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/live_meeting/data/providers/live_meeting_provider.dart';
import 'package:client/features/events/features/live_meeting/features/live_stream/presentation/widgets/url_video_widget.dart';
import 'package:client/features/events/features/event_page/presentation/waiting_room_presenter.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/features/user/presentation/widgets/user_profile_chip.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/features/events/presentation/widgets/periodic_builder.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/media_item.dart';
import 'package:provider/provider.dart';

/// Displays images or videos to the user before meetings start.
///
/// This can include just media before the scheduled time, or additional media such as informational
/// videos.
class WaitingRoom extends StatelessWidget {
  const WaitingRoom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider2<EventProvider, LiveMeetingProvider,
        WaitingRoomPresenter>(
      create: (context) => WaitingRoomPresenter(
        communityProvider: context.read<CommunityProvider>(),
        eventProvider: context.read<EventProvider>(),
        liveMeetingProvider: context.read<LiveMeetingProvider>(),
      )..initialize(),
      update: (_, __, ___, presenter) => presenter!..update(),
      child: _WaitingRoom(),
    );
  }
}

class _WaitingRoom extends StatelessWidget {
  const _WaitingRoom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final presenter = context.watch<WaitingRoomPresenter>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: presenter.media.type == MediaType.image
              ? Container(
                  color: Colors.black.withOpacity(0.2),
                  child: ProxiedImage(
                    presenter.media.url,
                    fit: BoxFit.contain,
                  ),
                )
              : UrlVideoWidget(
                  playbackUrl: presenter.media.url,
                  loop: presenter.loopVideo,
                  videoStartOffset: presenter.introVideoStartTime,
                  onEnded: presenter.isWaitingRoomMediaIntro
                      ? () => presenter.onIntroVideoCompleted()
                      : null,
                ),
        ),
        if (responsiveLayoutService.isMobile(context))
          _buildMobileLayout(context)
        else
          _buildDesktopLayout(context),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30.0),
      color: AppColor.darkBlue,
      child: Row(
        children: [
          Expanded(
            child: _buildMeetingInfo(context),
          ),
          SizedBox(width: 10),
          _buildTimeRemaining(context),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: AppColor.darkBlue,
      child: Column(
        children: [
          _buildMeetingInfo(context),
          SizedBox(height: 16),
          _buildTimeRemaining(context),
        ],
      ),
    );
  }

  Widget _buildMeetingInfo(BuildContext context) {
    final bool isMobile = responsiveLayoutService.isMobile(context);
    final eventProvider = EventProvider.watch(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: HeightConstrainedText(
            eventProvider.event.title ?? 'Your Event',
            style: AppTextStyle.headline2.copyWith(color: AppColor.white),
            textAlign: TextAlign.start,
            maxLines: isMobile ? 2 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(
          height: responsiveLayoutService.getDynamicSize(
            context,
            13,
            scale: 2.0,
          ),
        ),
        if (eventProvider.event.waitingRoomInfo?.content?.isNotEmpty == true)
          Flexible(
            child: HeightConstrainedText(
              eventProvider.event.waitingRoomInfo?.content ?? '',
              style: AppTextStyle.subhead.copyWith(color: AppColor.white),
              textAlign: TextAlign.start,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        SizedBox(height: 13),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (eventProvider.event.eventType == EventType.hosted) ...[
              RowParticipants(),
              SizedBox(width: 10),
            ],
            Flexible(
              child: Text(
                _buildPresentCountText(context),
                style: AppTextStyle.body.copyWith(color: AppColor.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _buildPresentCountText(BuildContext context) {
    final areBreakoutsActive =
        context.watch<LiveMeetingProvider>().breakoutsActive;
    if (areBreakoutsActive) {
      // If breakouts have already started, the present participant count will not reflect everyone
      // who is in breakouts, so we show the registered count.
      final registeredCount = EventProvider.watch(context).participantCount;
      if (registeredCount == 1) {
        return '1 registered participant';
      }

      return '$registeredCount registered participants';
    } else {
      final presentCount = EventProvider.watch(context).presentParticipantCount;
      if (presentCount == 1) {
        return '1 person is here';
      }

      return '$presentCount people are here';
    }
  }

  Widget _buildTimeRemaining(BuildContext context) {
    final event = context.watch<EventProvider>().event;
    final isInBreakouts = context.watch<LiveMeetingProvider>().breakoutsActive;
    final waitingRoomMediaIsActive =
        event.timeUntilScheduledStart(clockService.now()).isNegative &&
            (event.waitingRoomInfo?.durationSeconds ?? 0) > 0;
    return Container(
      padding: EdgeInsets.symmetric(
        vertical:
            responsiveLayoutService.getDynamicSize(context, 33.5, scale: 0.5),
        horizontal:
            responsiveLayoutService.getDynamicSize(context, 20, scale: 0.5),
      ),
      color: AppColor.darkerBlue,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _buildWaitingRoomInfoText(isInBreakouts, waitingRoomMediaIsActive),
            style: AppTextStyle.body.copyWith(color: AppColor.white),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          if (!isInBreakouts)
            PeriodicBuilder(
              period: Duration(seconds: 1),
              builder: (context) {
                final timeTillStart = waitingRoomMediaIsActive
                    ? event.timeUntilWaitingRoomFinished(clockService.now())
                    : event.timeUntilScheduledStart(clockService.now());
                if (timeTillStart.isNegative) {
                  return CustomLoadingIndicator();
                }
                return Text(
                  _buildTimeToStart(timeTillStart),
                  style: AppTextStyle.headline1.copyWith(color: AppColor.white),
                  textAlign: TextAlign.center,
                );
              },
            ),
        ],
      ),
    );
  }

  String _buildWaitingRoomInfoText(
    bool isInBreakouts,
    bool waitingRoomMediaIsActive,
  ) {
    if (isInBreakouts) return 'Users are in breakout rooms';

    return waitingRoomMediaIsActive
        ? 'Event starting in:'
        : "We'll get started in:";
  }

  String _buildTimeToStart(Duration remainingTime) {
    if (remainingTime.isNegative) {
      remainingTime = Duration.zero;
    }
    return durationString(remainingTime);
  }
}

class RowParticipants extends StatelessWidget {
  const RowParticipants({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double kSize = 32;
    const double kOffset = 20;

    final participants = EventProvider.watch(context)
        .eventParticipants
        .where((p) => p.isPresent)
        .toList();

    final participantCount = min(participants.length, 8);
    final double width = _getWidth(kSize, kOffset, participantCount);
    return SizedBox(
      height: kSize,
      width: width,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                for (var i = 0; i < participantCount; i++)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: (i * kOffset).toDouble(),
                    child: SizedBox(
                      width: kSize,
                      height: kSize,
                      child: UserProfileChip(
                        userId: participants[i].id,
                        showName: false,
                        enableOnTap: false,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Returns precisely calculated width of the widget.
  double _getWidth(double size, double offset, int count) {
    final double offsetRemainder = size - offset;
    return (count * size + offsetRemainder) - count * offsetRemainder;
  }
}
