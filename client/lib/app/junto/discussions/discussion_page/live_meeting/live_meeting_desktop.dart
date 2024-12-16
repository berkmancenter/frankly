import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:junto/app/junto/chat/chat_model.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_tabs/discussion_tabs_model.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/hostless_meeting_info.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/live_meeting_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/meeting_dialog.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/video/conference/control_bar.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/video/conference/participant_widget.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/video/conference/video_flutter_meeting.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_stream/live_stream_widget.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/waiting_room/waiting_room.dart';
import 'package:junto/app/junto/discussions/instant_unify/unify_america_controller.dart';
import 'package:junto/app/junto/discussions/instant_unify/unify_america_typeform.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/common_widgets/tabs/tab_bar_view.dart';
import 'package:junto/common_widgets/user_profile_chip.dart';
import 'package:junto/junto_app.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/extensions.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto/utils/periodic_builder.dart';
import 'package:junto/utils/platform_utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/chat.dart';
import 'package:junto_models/firestore/live_meeting.dart';
import 'package:junto_models/firestore/membership.dart';
import 'package:linkify/linkify.dart';
import 'package:provider/provider.dart';

class LiveMeetingDesktopLayout extends StatefulWidget {
  const LiveMeetingDesktopLayout({Key? key}) : super(key: key);

  @override
  _LiveMeetingDesktopLayoutState createState() => _LiveMeetingDesktopLayoutState();
}

class _LiveMeetingDesktopLayoutState extends State<LiveMeetingDesktopLayout> {
  Widget _buildBreakoutRoom(String roomId) {
    return RefreshKeyWidget(
      child: RefreshableBreakoutRoom(
        key: Key('breakout-room-$roomId'),
        liveMeetingBuilder: (_) => VideoFlutterMeeting(),
      ),
    );
  }

  Widget _buildLiveMeeting() {
    return RefreshKeyWidget(
      child: VideoFlutterMeeting(),
    );
  }

  Widget _buildMeetingLoading() {
    final liveMeetingProvider = LiveMeetingProvider.watch(context);

    return JuntoStreamBuilder<GetMeetingJoinInfoResponse>(
      key: ObjectKey(liveMeetingProvider.getCurrentMeetingJoinInfo()),
      entryFrom: '_buildConferenceRoomWrapper.build',
      stream: liveMeetingProvider.getCurrentMeetingJoinInfo()!.asStream(),
      loadingMessage: 'Loading room. Please wait...',
      builder: (_, response) {
        if (liveMeetingProvider.activeUiState == MeetingUiState.breakoutRoom) {
          return _buildBreakoutRoom(liveMeetingProvider.currentBreakoutRoomId!);
        }
        return _buildLiveMeeting();
      },
    );
  }

  Widget _buildDiscussion(BuildContext context) {
    final liveMeetingProvider = Provider.of<LiveMeetingProvider>(context);
    Widget child;

    switch (liveMeetingProvider.activeUiState) {
      case MeetingUiState.leftMeeting:
        return Container(color: Colors.black45);
      case MeetingUiState.enterMeetingPrescreen:
        return EnterMeetingScreen();
      case MeetingUiState.breakoutRoom:
        child = _buildMeetingLoading();
        break;
      case MeetingUiState.waitingRoom:
        child = WaitingRoom();
        break;
      case MeetingUiState.liveStream:
        child = LiveStreamWidget();
        break;
      case MeetingUiState.inMeeting:
        child = _buildMeetingLoading();
        break;
    }
    child = GlobalKeyedSubtree(label: 'primary-content', child: child);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: child,
        ),
        BreakoutStatusInformation(),
      ],
    );
  }

  Widget _buildDiscussionTabsContent() {
    return GlobalKeyedSubtree(
      label: 'discussion-tabs-content',
      child: Container(
        width: 400,
        color: AppColor.darkBlue,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(
                    builder: (context) => Padding(
                      padding: const EdgeInsets.all(8),
                      child: JuntoInkWell(
                        onTap: () {
                          Provider.of<DiscussionTabsControllerState>(context, listen: false)
                              .expanded = false;
                        },
                        child: CircleAvatar(
                          backgroundColor: AppColor.darkerBlue,
                          child: Icon(
                            Icons.close,
                            color: AppColor.brightGreen,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: JuntoTabBarView(keepAlive: !responsiveLayoutService.isMobile(context)),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              color: AppColor.white.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingDiscussionTabsContent() {
    return Align(
      alignment: Alignment.centerRight,
      child: JuntoPointerInterceptor(
        child: GestureDetector(
          onTap: () {},
          child: RepaintBoundary(child: _buildDiscussionTabsContent()),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final liveMeetingProvider = LiveMeetingProvider.watch(context);

    final discussionProvider = Provider.of<DiscussionProvider>(context);

    return AnimatedBuilder(
      animation: liveMeetingProvider.conferenceRoomNotifier,
      builder: (context, _) {
        final isUnifyChallenge = UnifyAmericaController.watch(context) != null;
        final discussionTabsModel = Provider.of<DiscussionTabsControllerState>(context);
        return Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      color: AppColor.black.withOpacity(0.2),
                      child: Stack(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(child: _buildDiscussion(context)),
                              if (isUnifyChallenge)
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 450),
                                  child: UnifyAmericaTypeform(),
                                ),
                            ],
                          ),
                          if (discussionTabsModel.widget.enableChat &&
                              discussionProvider.enableFloatingChat)
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: FloatingChatDisplay(),
                            ),
                          if (discussionTabsModel.expanded) ...[
                            JuntoPointerInterceptor(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => discussionTabsModel.expanded = false,
                              ),
                            ),
                            _buildFloatingDiscussionTabsContent(),
                          ],
                        ],
                      ),
                    ),
                  ),
                  HostlessMeetingInfo(),
                ],
              ),
            ),
            ControlBar(),
          ],
        );
      },
    );
  }
}

class FloatingChatDisplay extends StatefulWidget {
  @override
  _FloatingChatDisplayState createState() => _FloatingChatDisplayState();
}

class _FloatingChatDisplayState extends State<FloatingChatDisplay> {
  final _floatingMessages = <String, ChatMessage>{};

  StreamSubscription? _onNewMessageSubscription;
  StreamSubscription? _onMainMeetingNewMessageSubscription;

  void _onNewMessage(ChatMessage newMessage, {bool onlyShowBroadcast = false}) {
    final snapshotIsAdmin = newMessage.membershipStatusSnapshot?.isAdmin ?? false;
    final isBroadcast = (newMessage.broadcast ?? false) && snapshotIsAdmin;
    final floatMessage = !onlyShowBroadcast || isBroadcast;
    if (floatMessage) {
      setState(() => _floatingMessages[newMessage.id!] = newMessage);
    }
  }

  @override
  void initState() {
    super.initState();

    final liveMeetingProvider = LiveMeetingProvider.readOrNull(context);

    if (liveMeetingProvider == null) {
      return;
    }

    final isInBreakout = liveMeetingProvider.isInBreakout;
    final isInLiveStreamLobby = DiscussionProvider.read(context).isLiveStream && !isInBreakout;

    _onNewMessageSubscription =
        context.read<ChatModel>().newMessages?.listen((message) => _onNewMessage(
              message,
              onlyShowBroadcast: isInLiveStreamLobby,
            ));

    if (liveMeetingProvider.isInBreakout) {
      _onMainMeetingNewMessageSubscription =
          context.read<ChatModel>()?.newMessages?.listen((message) => _onNewMessage(
                message,
                onlyShowBroadcast: true,
              ));
    }
  }

  @override
  void dispose() {
    _onNewMessageSubscription?.cancel();
    _onMainMeetingNewMessageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20) +
          EdgeInsets.only(bottom: responsiveLayoutService.isMobile(context) ? 0 : 10),
      constraints: BoxConstraints(maxWidth: 500),
      alignment: Alignment.bottomCenter,
      child: Stack(
        children: [
          Positioned.fill(
            top: null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final message in _floatingMessages.values.toList())
                  Container(
                    key: ValueKey(message),
                    padding: const EdgeInsets.only(bottom: 8),
                    alignment: Alignment.centerLeft,
                    child: FloatingChat(
                      chatMessage: message,
                      onComplete: () => setState(() => _floatingMessages.remove(message.id)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FloatingChat extends StatefulHookWidget {
  final ChatMessage chatMessage;
  final void Function()? onComplete;

  const FloatingChat({
    Key? key,
    required this.chatMessage,
    this.onComplete,
  }) : super(key: key);

  @override
  _FloatingChatState createState() => _FloatingChatState();
}

class _FloatingChatState extends State<FloatingChat> {
  Interval get _animationInterval => Interval(0.85, 1);

  Duration get _animationDuration => Duration(seconds: 8);

  Animation<Offset> _getPositionTransition(AnimationController controller) {
    return Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(0, -6),
    ).animate(
      CurvedAnimation(parent: controller, curve: _animationInterval),
    );
  }

  Animation<double> _getOpacityTransition(AnimationController controller) {
    return Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(parent: controller, curve: _animationInterval),
    );
  }

  @override
  Widget build(BuildContext context) {
    final animation = useAnimationController(duration: _animationDuration);
    useMemoized(() async {
      await animation.forward();

      final localOnComplete = widget.onComplete;
      if (localOnComplete != null) localOnComplete();
    });

    return FadeTransition(
      opacity: _getOpacityTransition(animation),
      child: SlideTransition(
        position: _getPositionTransition(animation),
        child: Container(
          decoration: BoxDecoration(
            color: AppColor.darkBlue,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                blurRadius: 3,
                offset: Offset(2, 2),
                color: Colors.black.withOpacity(0.5),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              UserProfileChip(
                userId: widget.chatMessage.creatorId,
                showName: false,
                enableOnTap: false,
                imageHeight: 32,
              ),
              SizedBox(width: 8),
              if (widget.chatMessage.isFloatingEmoji)
                JuntoImage(
                  null,
                  asset: widget.chatMessage.emotionType?.imageAssetPath,
                  loadingColor: Colors.transparent,
                  width: 18,
                  height: 18,
                )
              else
                Flexible(
                  child: Linkify(
                    text: widget.chatMessage.message ?? '',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                    options: LinkifyOptions(looseUrl: true),
                    onOpen: (link) => launch(link.url),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class RefreshableBreakoutRoom extends StatefulWidget {
  final WidgetBuilder liveMeetingBuilder;

  const RefreshableBreakoutRoom({
    Key? key,
    required this.liveMeetingBuilder,
  }) : super(key: key);

  @override
  _RefreshableBreakoutRoomState createState() => _RefreshableBreakoutRoomState();
}

class _RefreshableBreakoutRoomState extends State<RefreshableBreakoutRoom> {
  Widget _buildWaitingRoomTextWidget() {
    if (JuntoProvider.watch(context).isMeetingOfAmerica) {
      final domain = isDev ? 'gen-hls-bkc-7627.web.app' : 'app.frankly.org';
      final linkValue = 'https://$domain/home/junto/meetingofamerica';
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        constraints: BoxConstraints(maxWidth: 700),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Thank you for joining Meeting of America! Unfortunately, you\'ve missed the '
                    'introduction and participants have already begun their small group '
                    'conversations. We hope you\'ll be able to join at another time. ',
                style: AppTextStyle.body.copyWith(color: Theme.of(context).primaryColor),
              ),
              TextSpan(
                text: 'Please click here',
                style: AppTextStyle.body.copyWith(
                  color: AppColor.accentBlue,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()..onTap = () => launch(linkValue),
              ),
              TextSpan(
                text: ' to find and RSVP for an upcoming event. Thanks again!',
                style: AppTextStyle.body.copyWith(color: Theme.of(context).primaryColor),
              ),
            ],
          ),
        ),
      );
    } else {
      return JuntoText(
        'You are in the waiting room.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).primaryColor,
            ),
      );
    }
  }

  Widget _buildWaitingRoom() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColor.white,
      ),
      margin: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              constraints: BoxConstraints(maxWidth: 200, maxHeight: 200),
              child: JuntoImage(
                Provider.of<JuntoProvider>(context).junto.profileImageUrl,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: _buildWaitingRoomTextWidget(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final liveMeetingProvider = LiveMeetingProvider.watch(context);

    return JuntoStreamBuilder(
      entryFrom: '_RefreshableBreakoutRoomState.build',
      stream: Provider.of<LiveMeetingProvider>(context).breakoutRoomLiveMeetingStream,
      loadingMessage: 'Loading breakout room. Please wait...',
      builder: (context, __) {
        if (liveMeetingProvider.currentBreakoutRoomId == breakoutsWaitingRoomId) {
          return _buildWaitingRoom();
        }

        return widget.liveMeetingBuilder(context);
      },
    );
  }
}

class EnterMeetingScreen extends StatelessWidget {
  const EnterMeetingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = LiveMeetingProvider.watch(context);
    return Center(
      child: JuntoStreamBuilder<bool>(
          entryFrom: '_MeetingDialogState._buildEnterMeetingScreen',
          stream: provider.canAutoplayLookupFuture.asStream(),
          builder: (_, canAutoplay) {
            if (canAutoplay ?? false) {
              return SizedBox.shrink();
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  JuntoText(
                    'Welcome! Click here to enter the event:',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 16),
                  ActionButton(
                    key: MeetingDialog.enterMeetingPromptButton,
                    onPressed: () => provider.clickedEnterMeeting = true,
                    text: 'Join Now',
                  ),
                ],
              );
            }
          }),
    );
  }
}

class BreakoutStatusInformation extends StatelessWidget {
  const BreakoutStatusInformation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final liveMeetingProvider = LiveMeetingProvider.watch(context);

    final breakoutsAreActiveWithoutUser = liveMeetingProvider.breakoutsActive &&
        !liveMeetingProvider.assignedBreakoutRoomIsLoading &&
        !liveMeetingProvider.shouldBeInBreakout &&
        !liveMeetingProvider.userLeftBreakouts;

    final breakoutsPending = [
          BreakoutRoomStatus.pending,
          BreakoutRoomStatus.processingAssignments
        ].contains(liveMeetingProvider.liveMeeting?.currentBreakoutSession?.breakoutRoomStatus) ||
        (liveMeetingProvider.liveMeeting?.currentBreakoutSession?.breakoutRoomStatus ==
                BreakoutRoomStatus.active &&
            liveMeetingProvider.assignedBreakoutRoomIsLoading);

    final breakoutSession = liveMeetingProvider.liveMeeting?.currentBreakoutSession;

    final showSubscribe = liveMeetingProvider.juntoProvider.isAmericaTalks &&
        liveMeetingProvider.discussionProvider.selfParticipant?.optInToAmericaTalks == false &&
        liveMeetingProvider.discussionProvider.discussion.discussionType ==
            DiscussionType.hostless &&
        !liveMeetingProvider.breakoutsActive &&
        !responsiveLayoutService.isMobile(context);

    if (breakoutsAreActiveWithoutUser) {
      return _buildUsersAreInBreakoutsMessage(context);
    } else if (breakoutsPending) {
      return PeriodicBuilder(
        period: Duration(seconds: 1),
        builder: (context) {
          final breakoutRoomScheduledTime = breakoutSession?.scheduledTime ?? clockService.now();
          final breakoutRoomRemainingTime =
              breakoutRoomScheduledTime.difference(clockService.now());
          final breakoutRoomRemainingTimeDisplay =
              breakoutRoomRemainingTime.getFormattedTime(showHours: false);

          final areBreakoutsPending =
              breakoutSession?.breakoutRoomStatus == BreakoutRoomStatus.pending &&
                  !breakoutRoomRemainingTime.isNegative;
          final breakoutsMessage = areBreakoutsPending
              ? 'Breakout room matching starting in $breakoutRoomRemainingTimeDisplay'
              : 'Generating breakout room assignments';
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: JuntoText(breakoutsMessage),
                ),
                SizedBox(width: 8),
                if (!areBreakoutsPending)
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: JuntoLoadingIndicator(),
                  ),
              ],
            ),
          );
        },
      );
    } else if (showSubscribe) {
      return _buildSubscribeMessage(context);
    } else {
      return SizedBox.shrink();
    }
  }

  Widget _buildSubscribeMessage(BuildContext context) {
    final discussionProvider = DiscussionProvider.watch(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: JuntoText(
              'Click to stay in the loop with updates & offers from America Talks & its partners',
              maxLines: 2,
            ),
          ),
          SizedBox(width: 10),
          ActionButton(
            onPressed: () => alertOnError(context, () async {
              await discussionProvider.optInForAmericaTalks();

              showRegularToast(context, 'Joined!', toastType: ToastType.success);
            }),
            height: 45,
            text: 'Join',
          ),
        ],
      ),
    );
  }

  Widget _buildUsersAreInBreakoutsMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: JuntoText('Users are in breakout rooms.')),
          SizedBox(width: 10),
          ActionButton(
            text: 'JOIN',
            height: 45,
            onPressed: () async {
              final discussion = context.read<DiscussionProvider>().discussion;

              await alertOnError(
                context,
                () => cloudFunctionsService.getBreakoutRoomAssignment(
                  GetBreakoutRoomAssignmentRequest(
                    discussionId: discussion.id,
                    discussionPath: discussion.fullPath,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
