import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/live_meeting/presentation/views/leave_regular_dialog.dart';
import 'package:client/features/events/features/live_meeting/data/providers/live_meeting_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/presentation/widgets/meeting_guide_card_item_image.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/presentation/views/meeting_guide_card_item_poll.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/presentation/widgets/meeting_guide_card_item_text.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/presentation/views/meeting_guide_card_item_user_suggestions.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/presentation/views/meeting_guide_card_item_video.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/presentation/views/meeting_guide_card_item_word_cloud.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/presentation/views/meeting_guide_card_contract.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/data/models/meeting_guide_card_model.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/presentation/meeting_guide_card_presenter.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/presentation/widgets/meeting_guide_card_tutorial.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/data/providers/meeting_guide_card_store.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/presentation/widgets/raising_hand.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/providers/meeting_agenda_provider.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/localization/localization_helper.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/presentation/widgets/fade_scroll_view.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/features/user/data/providers/user_info_builder.dart';
import 'package:client/app.dart';
import 'package:client/features/user/data/services/user_data_service.dart';
import 'package:client/services.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/data/providers/dialog_provider.dart';
import 'package:client/core/utils/extensions.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/features/events/presentation/widgets/periodic_builder.dart';
import 'package:data_models/events/live_meetings/meeting_guide.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';
import 'package:skeleton_text/skeleton_text.dart';

class MeetingGuideCard extends StatefulWidget {
  final void Function() onMinimizeCard;

  const MeetingGuideCard({
    Key? key,
    required this.onMinimizeCard,
  }) : super(key: key);

  @override
  _MeetingGuideCardState createState() => _MeetingGuideCardState();
}

class _MeetingGuideCardState extends State<MeetingGuideCard> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Only show tutorial is it was not shown before and if meeting is not hosted (only in hostLess).
      final canShowTutorial = !responsiveLayoutService.isMobile(context) &&
          !sharedPreferencesService.wasMeetingTutorialShown() &&
          !EventProvider.read(context).event.isHosted &&
          Provider.of<AgendaProvider>(context, listen: false).isInBreakouts &&
          !useBotControls;

      if (canShowTutorial) {
        unawaited(sharedPreferencesService.setMeetingTutorialShown(true));

        await showCustomDialog(
          context: context,
          builder: (context) => MeetingGuideTutorial(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AgendaProvider>();
    context.watch<MeetingGuideCardStore>();

    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: MeetingGuideCardContent(onMinimizeCard: widget.onMinimizeCard),
      ),
    );
  }
}

class MeetingGuideCardContent extends StatefulWidget {
  final void Function() onMinimizeCard;

  const MeetingGuideCardContent({
    Key? key,
    required this.onMinimizeCard,
  }) : super(key: key);

  @override
  _MeetingGuideCardContentState createState() =>
      _MeetingGuideCardContentState();
}

class _MeetingGuideCardContentState extends State<MeetingGuideCardContent>
    implements MeetingGuideCardView {
  late final MeetingGuideCardModel _model;
  late final MeetingGuideCardPresenter _presenter;

  final GlobalKey<TooltipState> tooltipKey = GlobalKey<TooltipState>();

  @override
  void initState() {
    super.initState();

    _model = MeetingGuideCardModel();
    _presenter = MeetingGuideCardPresenter(context, this, _model);
  }

  @override
  Widget build(BuildContext context) {
    final agendaProvider = context.watch<AgendaProvider>();
    context.watch<MeetingGuideCardStore>();

    final currentItem = _presenter.getCurrentAgendaItem();
    final isMeetingStarted = _presenter.isMeetingStarted();
    final isCardPending = _presenter.isCardPending();

    final meetingFinished =
        currentItem == null && isMeetingStarted && !isCardPending;

    final isInBreakout = agendaProvider.isInBreakouts;
    final canUserControlMeeting = _presenter.canUserControlMeeting;
    final isHosted = agendaProvider.event?.isHosted ?? false;

    if (meetingFinished) {
      return _buildEndCardContent();
    } else if (currentItem == null && !isInBreakout && canUserControlMeeting) {
      return _buildStartCardContent(isInControl: true);
    } else if (currentItem == null && !isInBreakout && isHosted) {
      return _buildStartCardContent(isInControl: false);
    } else {
      final agendaItem = currentItem ?? agendaProvider.getHostlessStartCard();
      return _buildAgendaItemContent(agendaItem);
    }
  }

  Widget _buildAgendaItemContent(AgendaItem? currentItem) {
    if (currentItem == null) {
      return SizedBox.shrink();
    }

    final isMobile = responsiveLayoutService.isMobile(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          _buildTopSection(currentItem),
          SizedBox(height: 10),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: 200),
              child: _buildCardBody(currentItem),
            ),
          ),
          if (!isMobile) _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildTopSection(AgendaItem agendaItem) {
    context.watch<MeetingGuideCardStore>();

    final isHandRaised = _presenter.isHandRaised();
    final title = _presenter.getTitle(agendaItem);
    final isMobile = _presenter.isMobile(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isMobile)
          Row(
            children: [
              RaisingHandToggle(
                isHandRaised: isHandRaised,
                isCardMinimized: false,
              ),
              Spacer(),
              ActionButton(
                type: ActionButtonType.filled,
                tooltipText: context.l10n.hideAgendaItem,
                onPressed: widget.onMinimizeCard,
                color: context.theme.colorScheme.surfaceContainerLowest,
                padding: EdgeInsets.zero,
                child: ProxiedImage(
                  null,
                  asset: AppAsset.kMinimizePng,
                  height: 22,
                  width: 22,
                  loadingColor: Colors.transparent,
                ),
              ),
            ],
          ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: HeightConstrainedText(
                title,
                style: AppTextStyle.headline4
                    .copyWith(color: context.theme.colorScheme.secondary),
              ),
            ),
            if (agendaItem.timeInSeconds != null)
              Container(
                width: 120,
                alignment: Alignment.centerRight,
                child: PeriodicBuilder(
                  period: const Duration(seconds: 1),
                  builder: (context) {
                    final timeRemaining = _presenter.getTimeRemainingInCard();
                    final bool negativeTimeRemaining;
                    final String formattedTime;
                    if (timeRemaining == null) {
                      negativeTimeRemaining = false;
                      formattedTime = context.l10n.start;
                    } else {
                      negativeTimeRemaining = timeRemaining.isNegative;
                      formattedTime = timeRemaining.getFormattedTime(
                        showHours: timeRemaining.inHours.abs() > 0,
                      );
                    }
                    return HeightConstrainedText(
                      formattedTime,
                      style: AppTextStyle.body.copyWith(
                        color: negativeTimeRemaining
                            ? context.theme.colorScheme.error
                            : context.theme.colorScheme.onSurface,
                      ),
                    );
                  },
                ),
              ),
            SizedBox(width: 10),
            ProxiedImage(null, asset: AppAsset.clock(), width: 20, height: 20),
            SizedBox(width: 10),
          ],
        ),
      ],
    );
  }

  /// Very first card in the live meeting.
  Widget _buildStartCardContent({required bool isInControl}) {
    // Very specific flex. Less than 9 will make `Start Event` button to overflow,
    // since it won't be enough space for its rendering.
    const symmetricFlex = 9;

    context.watch<LiveMeetingProvider>();
    context.watch<AgendaProvider>();
    context.watch<UserService>();

    final userId = _presenter.getUserId();
    final isMobile = _presenter.isMobile(context);

    final minCardHeight =
        responsiveLayoutService.isMobile(context) ? 280.0 : 400.0;
    return IntrinsicHeight(
      child: Container(
        padding: const EdgeInsets.all(10),
        constraints: BoxConstraints(minHeight: minCardHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Spacer(),
            Row(
              children: [
                Spacer(),
                Expanded(
                  flex: symmetricFlex,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      UserInfoBuilder(
                        userId: userId,
                        builder: (_, isLoading, info) {
                          if (isLoading) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: 0.5,
                                child: SkeletonAnimation(
                                  child: Container(
                                    color: context
                                        .theme.colorScheme.onPrimaryContainer,
                                    height: 24,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return HeightConstrainedText(
                              isNullOrEmpty(info.data?.displayName)
                                  ? context.l10n.welcome
                                  : context.l10n.welcomeName(
                                      info.data?.displayName ?? '',
                                    ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.headline3.copyWith(
                                fontSize: isMobile ? 18 : 24,
                                color: context.theme.colorScheme.primary,
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(height: 20),
                      if (isInControl) ...[
                        HeightConstrainedText(
                          context.l10n.agendaPromptReady,
                          style: AppTextStyle.subhead.copyWith(
                            fontSize: isMobile ? 15 : 18,
                            color: context.theme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: 20),
                        ActionButton(
                          type: ActionButtonType.filled,
                          color: context.theme.colorScheme.primary,
                          textColor: context.theme.colorScheme.onPrimary,
                          onPressed: () => alertOnError(context, () async {
                            final currentAgendaItemId =
                                _presenter.getCurrentAgendaItemId();
                            await _presenter.moveForward(currentAgendaItemId!);
                          }),
                          text: context.l10n.startEvent,
                        ),
                      ] else
                        HeightConstrainedText(
                          context.l10n.agendaPromptWaiting,
                          style: AppTextStyle.subhead.copyWith(
                            fontSize: isMobile ? 15 : 18,
                            color: context.theme.colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                ),
                if (!isMobile) ...[
                  Spacer(),
                  Expanded(
                    flex: symmetricFlex,
                    child: Icon(
                      Icons.meeting_room_rounded,
                      size: 100,
                      color: context.theme.colorScheme.secondary,
                    ),
                  ),
                ],
                Spacer(),
              ],
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildEndCardContent() {
    context.watch<CommunityProvider>();
    context.watch<UserDataService>();
    context.watch<LiveMeetingProvider>();

    final community = _presenter.getCommunity();
    final isMember = _presenter.isMember(community.id);

    return Column(
      children: [
        Expanded(
          child: LeaveRegularDialog(
            community: community,
            isMember: isMember,
            onMinimizeCard: widget.onMinimizeCard,
          ),
        ),
        if (_presenter.canUserControlMeeting)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: _buildBottomSection(),
          ),
      ],
    );
  }

  Widget _buildCardBody(AgendaItem item) {
    final itemType = item.type;

    switch (itemType) {
      case AgendaItemType.text:
        return FadeScrollView(
          child: MeetingGuideCardItemText(agendaItem: item),
        );
      case AgendaItemType.video:
        return MeetingGuideCardItemVideo();
      case AgendaItemType.image:
        return FadeScrollView(
          maxFadeExtent: 0,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: MeetingGuideCardItemImage(agendaItem: item),
          ),
        );
      case AgendaItemType.poll:
        return FadeScrollView(
          child: MeetingGuideCardItemPoll(),
        );
      case AgendaItemType.wordCloud:
        return MeetingGuideCardItemWordCloud();
      case AgendaItemType.userSuggestions:
        return MeetingGuideCardItemUserSuggestions();
    }
  }

  Widget _buildBottomSection() {
    context.watch<AgendaProvider>();
    context.watch<MeetingGuideCardStore>();
    context.watch<LiveMeetingProvider>();
    context.watch<UserService>();
    context.watch<CommunityProvider>();
    context.watch<UserDataService>();
    context.watch<MeetingGuideCardStore>();

    final participantAgendaItemDetailsStream =
        _presenter.getParticipantAgendaItemDetailsStream();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(
          height: 1,
          thickness: 1,
          color: context.theme.colorScheme.onPrimaryContainer,
        ),
        SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: context.theme.colorScheme.surfaceContainerLowest,
          ),
          child: CustomStreamBuilder<List<ParticipantAgendaItemDetails>>(
            entryFrom: '_MeetingGuideCard._buildBottomSection',
            stream: participantAgendaItemDetailsStream,
            height: 100,
            builder: (context, participantAgendaItemDetailsList) {
              final readyToAdvance =
                  _presenter.isReadyToAdvance(participantAgendaItemDetailsList);
              final canUserControlMeeting = _presenter.canUserControlMeeting;
              final currentAgendaItemId = _presenter.getCurrentAgendaItemId();
              final currentItem = _presenter.getCurrentAgendaItem();
              final presentParticipantIds =
                  _presenter.getPresentParticipantIds().toSet();
              final readyThreshold =
                  _presenter.getReadyThreshold(presentParticipantIds);
              final readyToMoveOnCount = _presenter.readyToMoveOnCount(
                participantAgendaItemDetailsList,
                presentParticipantIds,
              );
              final isMeetingStarted = _presenter.isMeetingStarted();
              final isCardPending = _presenter.isCardPending();
              final meetingFinished =
                  currentItem == null && isMeetingStarted && !isCardPending;
              final isHosted = _presenter.isHosted();

              if (isHosted) {
                if (!canUserControlMeeting) return SizedBox.shrink();

                final isBackButtonShown = _presenter.isBackButtonShown();
                return Row(
                  children: [
                    if (isBackButtonShown)
                      ActionButton(
                        color: Colors.transparent,
                        textColor: context.theme.colorScheme.primary,
                        icon: Icons.arrow_back_ios,
                        text: context.l10n.back,
                        onPressed: () => _presenter.goToPreviousAgendaItem(),
                      ),
                    Spacer(),
                    if (!meetingFinished)
                      Align(
                        alignment: Alignment.centerRight,
                        child: NextButton(
                          currentAgendaItemId: currentAgendaItemId ?? '',
                        ),
                      ),
                  ],
                );
              } else {
                if (_presenter.isPendingAdvance(currentAgendaItemId)) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        context.l10n.movingOntoNextAgendaItem,
                        style: AppTextStyle.body.copyWith(
                          color: context.theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(width: 10),
                      ConstrainedBox(
                        constraints:
                            BoxConstraints(maxWidth: 64, maxHeight: 64),
                        child: Countdown(
                          startingPendingAdvanceTime: Duration(
                            seconds: 10,
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return ReadyToMoveOnBuilder(
                  isMobile: responsiveLayoutService.isMobile(context),
                  readyToMoveOnCount: readyToMoveOnCount,
                  tooltipKey: tooltipKey,
                  readyThreshold: readyThreshold,
                  presentParticipantIds: presentParticipantIds,
                  userIsReady: participantAgendaItemDetailsList
                          ?.firstWhere(
                            (p) => p.userId == _presenter.getUserId(),
                            orElse: () => ParticipantAgendaItemDetails(
                              readyToAdvance: false,
                            ),
                          )
                          .readyToAdvance ??
                      false,
                  currentAgendaItemId: currentAgendaItemId,
                );
              }
            },
          ),
        ),
        SizedBox(height: 6),
      ],
    );
  }

  @override
  void updateView() {
    setState(() {});
  }
}

/// Information about how many participants are ready to move on to the next agenda item.
/// [isMobile] Whether the user is on a mobile device.
/// [userIsReady] Whether the current user has marked themselves as ready to move on.
/// [readyToMoveOnCount] The number of participants ready to move on.
/// [readyThreshold] The number of participants required to be ready to move on.
/// [currentAgendaItemId] The ID of the current agenda item.
/// [tooltipKey] The key for the tooltip widget.
/// [presentParticipantIds] The set of participant IDs who are present.
class ReadyToMoveOnBuilder extends StatelessWidget {
  final bool isMobile;
  final bool userIsReady;
  final int readyToMoveOnCount;
  final int readyThreshold;
  final String? currentAgendaItemId;
  final GlobalKey<TooltipState> tooltipKey;
  final Set<String> presentParticipantIds;

  const ReadyToMoveOnBuilder({
    Key? key,
    required this.isMobile,
    required this.userIsReady,
    required this.currentAgendaItemId,
    required this.readyToMoveOnCount,
    required this.tooltipKey,
    required this.readyThreshold,
    required this.presentParticipantIds,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            ReadyButton(
              currentAgendaItemId: currentAgendaItemId ?? '',
              userIsReady: userIsReady,
              isMobile: isMobile,
            ),
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildReadyCountText(context, true),
                  _buildInfoTooltip(context),
                  SizedBox(width: 20),
                  _buildInfoButton(context),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Row(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildReadyCountText(context),
                _buildInfoTooltip(context),
                SizedBox(width: 10),
                _buildInfoButton(context),
              ],
            ),
            _buildThresholdText(context),
          ],
        ),
        SizedBox(width: 20),
        ReadyButton(
          currentAgendaItemId: currentAgendaItemId ?? '',
          userIsReady: userIsReady,
          isMobile: isMobile,
        ),
      ],
    );
  }

  Widget _buildReadyCountText(BuildContext context, [bool isMobile = false]) {
    return Text(
      isMobile
          ? context.l10n.peopleRequiredToMoveOn(
              readyToMoveOnCount,
              presentParticipantIds.length,
            )
          : '$readyToMoveOnCount ${context.l10n.peopleReady}',
      style: AppTextStyle.body.copyWith(
        color: isMobile
            ? context.theme.colorScheme.onPrimary
            : context.theme.colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoTooltip(BuildContext context) {
    return Tooltip(
      key: tooltipKey,
      enableTapToDismiss: false,
      triggerMode: TooltipTriggerMode.manual,
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.24),
            blurRadius: 8,
            spreadRadius: 2,
            offset: Offset(
              2,
              2,
            ),
          ),
        ],
        color: context.theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      richMessage: TextSpan(
        children: <InlineSpan>[
          WidgetSpan(
            child: _buildTooltipContent(context),
          ),
        ],
      ),
      child: SizedBox.shrink(),
    );
  }

  Widget _buildTooltipContent(BuildContext context) {
    return Container(
      // Apply your size constraints here instead
      constraints: BoxConstraints(
        maxWidth: 315,
        maxHeight: 250,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.startingNextAgendaItem,
                  style: TextStyle(
                    color: context.theme.colorScheme.onSurfaceVariant,
                    fontSize: context.theme.textTheme.bodySmall?.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                // Description
                Text(
                  '${context.l10n.majorityOfParticipants}\n\n'
                  '${context.l10n.majorityOfParticipantsExample(readyThreshold, presentParticipantIds.length)}',
                  style: TextStyle(
                    color: context.theme.colorScheme.onSurfaceVariant,
                    fontSize: context.theme.textTheme.bodySmall?.fontSize,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
              ),
              child: ActionButton(
                type: ActionButtonType.text,
                text: context.l10n.close,
                textStyle: TextStyle(
                  color: context.theme.colorScheme.onSurfaceVariant,
                  fontSize: context.theme.textTheme.bodySmall?.fontSize,
                  fontWeight: FontWeight.bold,
                ),
                onPressed: () {
                  Tooltip.dismissAllToolTips();
                },
                minWidth: 0,
                height: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.question_mark),
      iconSize: 17,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(maxHeight: 30, maxWidth: 30),
      onPressed: () {
        tooltipKey.currentState?.ensureTooltipVisible();
      },
      color: isMobile
          ? context.theme.colorScheme.onPrimary
          : context.theme.colorScheme.onSurfaceVariant,
      style: IconButton.styleFrom(
        side: BorderSide(
          color: isMobile
              ? context.theme.colorScheme.onPrimary
              : context.theme.colorScheme.outline,
        ),
      ),
    );
  }

  Widget _buildThresholdText(BuildContext context) {
    // Majority (51%) required to move on
    return Text(
      '$readyThreshold ${context.l10n.requiredToMoveOn}',
      style: AppTextStyle.body.copyWith(
        color: isMobile
            ? context.theme.colorScheme.onPrimary
            : context.theme.colorScheme.secondary,
      ),
    );
  }
}

/// Countdown timer shown to all participants once a majority have voted to move on, counting down to the moment
/// [startingPendingAdvanceTime] The duration for which the countdown should run.
/// [isMobile] Whether the user is on a mobile device.
class Countdown extends StatefulWidget {
  final Duration startingPendingAdvanceTime;
  final bool isMobile;

  const Countdown({
    required this.startingPendingAdvanceTime,
    this.isMobile = false,
  });

  @override
  SyncedAdvanceCountdownWidget createState() => SyncedAdvanceCountdownWidget();
}

/// Shown to all participants once a majority have voted to move on, counting down to the moment
/// the meeting guide actually advances.
class SyncedAdvanceCountdownWidget extends State<Countdown>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: widget.startingPendingAdvanceTime,
    )..reverse(from: 1.0);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PeriodicBuilder(
      period: Duration(seconds: 1),
      builder: (context) {
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  return CircularProgressIndicator(
                    // The countdown is reversed from the starting pending advance time, so we need to divide by 1 to get the correct value.f
                    value: controller.value,
                    strokeWidth: 5.0,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.isMobile
                          ? context.theme.colorScheme.onPrimary
                          : context.theme.colorScheme.primary,
                    ),
                    backgroundColor: widget.isMobile
                        ? context.theme.colorScheme.secondary
                        : context.theme.colorScheme.onPrimaryContainer,
                  );
                },
              ),
            ),
            AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return Text(
                  '${(controller.value * widget.startingPendingAdvanceTime.inSeconds).ceil()}',
                  style: TextStyle(
                    fontSize: widget.isMobile
                        ? context.theme.textTheme.titleMedium?.fontSize
                        : context.theme.textTheme.titleLarge?.fontSize,
                    fontWeight: FontWeight.bold,
                    color: widget.isMobile
                        ? context.theme.colorScheme.onPrimary
                        : context.theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// Button for participants to indicate they are ready to move on to the next agenda item.
class ReadyButton extends HookWidget {
  final String currentAgendaItemId;
  final bool userIsReady;
  final bool isMobile;

  const ReadyButton({
    Key? key,
    required this.currentAgendaItemId,
    required this.userIsReady,
    this.isMobile = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final agendaProvider = AgendaProvider.watch(context);
    return ActionButton(
      minWidth: isMobile ? 350 : null,
      color: isMobile
          ? context.theme.colorScheme.onPrimary
          : context.theme.colorScheme.outline,
      type: ActionButtonType.outline,
      textColor: isMobile
          ? context.theme.colorScheme.onPrimary
          : context.theme.colorScheme.primary,
      onPressed: () => alertOnError(context, () async {
        await agendaProvider.toggleMoveForward(
          currentAgendaItemId: currentAgendaItemId,
          ready: !userIsReady,
        );
      }),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: userIsReady,
            onChanged: null,
            activeColor: isMobile
                ? context.theme.colorScheme.onPrimary
                : context.theme.colorScheme.primary,
            fillColor: WidgetStateProperty.all(Colors.transparent),
            checkColor: isMobile
                ? context.theme.colorScheme.onPrimary
                : context.theme.colorScheme.primary,
            side: BorderSide(
              width: 2,
              color: isMobile
                  ? context.theme.colorScheme.onPrimary
                  : context.theme.colorScheme.primary,
            ),
            semanticLabel: context.l10n.imReadyToMoveOn,
          ),
          SizedBox(width: 8),
          Text(
            context.l10n.imReadyToMoveOn,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isMobile
                  ? context.theme.colorScheme.onPrimary
                  : context.theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class NextButton extends HookWidget {
  final String currentAgendaItemId;

  const NextButton({
    Key? key,
    required this.currentAgendaItemId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final agendaProvider = AgendaProvider.watch(context);
    return ActionButton(
      tooltipText: context.l10n.clickNextWhenReady,
      color: Colors.transparent,
      type: ActionButtonType.outline,
      textColor: context.theme.colorScheme.primary,
      icon: Icons.arrow_forward_ios,
      onPressed: () => alertOnError(context, () async {
        await agendaProvider.toggleMoveForward(
          currentAgendaItemId: currentAgendaItemId,
        );
      }),
      text: context.l10n.next,
    );
  }
}
