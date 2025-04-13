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
import 'package:client/core/widgets/action_button.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/presentation/widgets/fade_scroll_view.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/core/widgets/ui_migration.dart';
import 'package:client/features/user/data/providers/user_info_builder.dart';
import 'package:client/app.dart';
import 'package:client/features/user/data/services/user_data_service.dart';
import 'package:client/services.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/app_styles.dart';
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
  TextStyle get bodyStyle => body.copyWith(fontSize: 14);

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

    return UIMigration(
      whiteBackground: true,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: MeetingGuideCardContent(onMinimizeCard: widget.onMinimizeCard),
        ),
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
                type: ActionButtonType.flat,
                tooltipText: context.l10n.hideAgendaItem,
                sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.none,
                onPressed: widget.onMinimizeCard,
                color: AppColor.white,
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
                style: AppTextStyle.headline4.copyWith(color: AppColor.gray1),
              ),
            ),
            if (agendaItem.timeInSeconds != null)
              Container(
                width: 60,
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
                      formattedTime =
                          timeRemaining.getFormattedTime(showHours: false);
                    }
                    return HeightConstrainedText(
                      formattedTime,
                      style: AppTextStyle.body.copyWith(
                        color: negativeTimeRemaining
                            ? AppColor.redLightMode
                            : AppColor.gray2,
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
                                    color: AppColor.gray5,
                                    height: 24,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return HeightConstrainedText(
                              isNullOrEmpty(info.data?.displayName)
                                  ? context.l10n.welcome
                                  : context.l10n.welcomeName(info.data?.displayName ?? ''),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.headline3.copyWith(
                                fontSize: isMobile ? 18 : 24,
                                color: AppColor.darkBlue,
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
                            color: AppColor.darkBlue,
                          ),
                        ),
                        SizedBox(height: 20),
                        ActionButton(
                          color: Colors.transparent,
                          type: ActionButtonType.outline,
                          textColor: AppColor.darkBlue,
                          sendingIndicatorAlign:
                              ActionButtonSendingIndicatorAlign.none,
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
                            color: AppColor.darkBlue,
                          ),
                        ),
                    ],
                  ),
                ),
                if (!isMobile) ...[
                  Spacer(),
                  Expanded(
                    flex: symmetricFlex,
                    child: ProxiedImage(
                      null,
                      asset: AppAsset.kStartEventCardImage,
                      fit: BoxFit.contain,
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

    final isCardPending = _presenter.isCardPending();
    if (isCardPending) {
      return CountdownWidget();
    }

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
        Divider(height: 1, thickness: 1, color: AppColor.gray5),
        SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColor.white,
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
                        textColor: AppColor.darkBlue,
                        sendingIndicatorAlign:
                            ActionButtonSendingIndicatorAlign.none,
                        icon: Icons.arrow_back_ios,
                        text: 'Back',
                        onPressed: () => _presenter.goToPreviousAgendaItem(),
                      ),
                    Spacer(),
                    if (!meetingFinished)
                      Align(
                        alignment: Alignment.centerRight,
                        child: _ReadyButton(
                          currentAgendaItemId: currentAgendaItemId ?? '',
                        ),
                      ),
                  ],
                );
              } else {
                return Row(
                  children: [
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Tooltip(
                        message:
                            '$readyToMoveOnCount out of ${presentParticipantIds.length} participants '
                            'are ready to move on.',
                        child: Text(
                          '$readyToMoveOnCount/${presentParticipantIds.length}',
                          style: AppTextStyle.body
                              .copyWith(color: AppColor.darkBlue),
                        ),
                      ),
                    ),
                    if (readyToAdvance)
                      ActionButton(
                        type: ActionButtonType.outline,
                        textColor: AppColor.darkBlue,
                        sendingIndicatorAlign:
                            ActionButtonSendingIndicatorAlign.none,
                        text: 'Ready',
                        icon: Icons.check_circle_outline,
                      )
                    else
                      _ReadyButton(
                        currentAgendaItemId: currentAgendaItemId ?? '',
                      ),
                  ],
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

class CountdownWidget extends StatelessWidget {
  const CountdownWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PeriodicBuilder(
      period: Duration(seconds: 1),
      builder: (context) {
        final countdownSeconds = 3 -
            Provider.of<MeetingGuideCardStore>(context)
                .pendingMeetingGuideAgendaItemElapsed
                .elapsed
                .inSeconds;
        final isMobile = responsiveLayoutService.isMobile(context);
        return Row(
          children: [
            if (!isMobile) ...[
              Expanded(
                child: HeightConstrainedText(
                  'Moving to the next agenda item...',
                  style:
                      AppTextStyle.subhead.copyWith(color: AppColor.darkBlue),
                ),
              ),
              SizedBox(width: 10),
            ],
            HeightConstrainedText(
              math.max(1, countdownSeconds).toString(),
              style: TextStyle(fontSize: isMobile ? 24 : 38),
            ),
          ],
        );
      },
    );
  }
}

class _ReadyButton extends HookWidget {
  final String currentAgendaItemId;

  const _ReadyButton({
    Key? key,
    required this.currentAgendaItemId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final agendaProvider = AgendaProvider.watch(context);
    return ActionButton(
      tooltipText: 'Click Next when you’re ready to move on.',
      color: Colors.transparent,
      type: ActionButtonType.outline,
      textColor: AppColor.darkBlue,
      sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.none,
      icon: Icons.arrow_forward_ios,
      iconSide: ActionButtonIconSide.right,
      onPressed: () => alertOnError(context, () async {
        await agendaProvider.moveForward(
          currentAgendaItemId: currentAgendaItemId,
        );
      }),
      text: 'Next',
    );
  }
}
