import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:junto/app/junto/chat/chat_model.dart';
import 'package:junto/app/junto/chat/chat_widget.dart';
import 'package:junto/app/junto/discussions/discussion_page/admin_panel/admin_panel.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_permissions_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_tabs/discussion_tabs.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_tabs/discussion_tabs_model.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/live_meeting_desktop.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/live_meeting_mobile/live_meeting_mobile_contract.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/live_meeting_mobile/live_meeting_mobile_model.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/live_meeting_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/meeting_guide/meeting_guide_card/meeting_guide_card.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/meeting_guide/meeting_guide_card_store.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/video/conference/agora_room.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/video/conference/audio_video_error.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/video/conference/audio_video_settings.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/video/conference/brady_bunch/brady_bunch_view_widget.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/video/conference/conference_room.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/video/conference/control_bar.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/video/conference/participant_widget.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/video/conference/video_flutter_meeting.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_stream/live_stream_widget.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/meeting_agenda_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/user_submitted_agenda/user_submitted_agenda.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/waiting_room/waiting_room.dart';
import 'package:junto/app/junto/discussions/instant_unify/unify_america_controller.dart';
import 'package:junto/app/junto/discussions/instant_unify/unify_america_typeform.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/app_clickable_widget.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/common_widgets/junto_ui_migration.dart';
import 'package:junto/junto_app.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_asset.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/live_meeting.dart';
import 'package:junto_models/firestore/meeting_guide.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

import 'live_meeting_mobile_presenter.dart';

enum LiveMeetingMobileBottomSheetState {
  fullyVisible,
  partiallyVisible,
  hidden,
}

class LiveMeetingMobilePage extends StatefulWidget {
  const LiveMeetingMobilePage({
    Key? key,
  }) : super(key: key);

  @override
  State<LiveMeetingMobilePage> createState() => _LiveMeetingMobilePageState();
}

class _LiveMeetingMobilePageState extends State<LiveMeetingMobilePage>
    implements LiveMeetingMobileView {
  final chatTextEditingController = TextEditingController();
  late final LiveMeetingMobileModel _model;
  late final LiveMeetingMobilePresenter _presenter;

  StreamSubscription? _onConferenceRoomException;
  StreamSubscription? _onUnloadSubscription;

  @override
  void initState() {
    super.initState();

    final isUnifyAmerica = UnifyAmericaController.read(context) != null;
    final LiveMeetingMobileBottomSheetState initialSheetState;

    final suppressGuide =
        ConferenceRoom.read(context) == null || context.read<AgendaProvider>().agendaItems.isEmpty;

    if (isUnifyAmerica || suppressGuide) {
      initialSheetState = LiveMeetingMobileBottomSheetState.hidden;
    } else {
      initialSheetState = LiveMeetingMobileBottomSheetState.partiallyVisible;
    }
    _model = LiveMeetingMobileModel(
      bottomSheetState: initialSheetState,
    );
    _presenter = LiveMeetingMobilePresenter(context, this, _model);
  }

  @override
  void dispose() {
    super.dispose();

    _onConferenceRoomException?.cancel();
    _onUnloadSubscription?.cancel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _checkUpdateBottomSheet();

    _checkConnectToRoom();
  }

  @override
  void updateView() {
    setState(() {});
  }

  void _checkUpdateBottomSheet() {
    final keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    final discussionTabsController =
        Provider.of<DiscussionTabsControllerState>(context, listen: false);
    final selectedTabIndex = discussionTabsController.selectedTabController.selectedIndex;
    final selectedTab = discussionTabsController.tabs[selectedTabIndex];

    final isLargeAgendaItem = selectedTab == TabType.guide &&
        [AgendaItemType.wordCloud, AgendaItemType.userSuggestions]
            .contains(context.read<MeetingGuideCardStore>().meetingGuideCardAgendaItem?.type);

    if (keyboardIsOpen) {
      _presenter.toggleBottomSheetState(LiveMeetingMobileBottomSheetState.hidden);
    } else if ((isLargeAgendaItem || selectedTab == TabType.suggestions) &&
        _model.bottomSheetState == LiveMeetingMobileBottomSheetState.partiallyVisible) {
      _presenter.toggleBottomSheetState(LiveMeetingMobileBottomSheetState.fullyVisible);
    }
  }

  void _checkConnectToRoom() {
    final conferenceRoom = ConferenceRoom.read(context);
    final inRoom = conferenceRoom != null;
    if (inRoom && conferenceRoom?.hasStartedConnecting == false) {
      _connectToRoom();

      _onUnloadSubscription = html.window.onBeforeUnload.listen((event) {
        final conferenceRoom = ConferenceRoom.read(context);
        conferenceRoom?.room?.dispose();
      });
    }
  }

  Future<void> _connectToRoom() async {
    final conferenceRoom = ConferenceRoom.read(context);
    _onConferenceRoomException = conferenceRoom?.onException.listen((err) async {
      loggingService.log('showing alert in listener');
      await showAlert(context, err is PlatformException ? err.details : err.toString());
    });
    await conferenceRoom?.connect();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<MeetingGuideCardStore>();

    final isBottomSheetPresent = _presenter.isBottomSheetPresent();
    final isRaisedHandVisible = _presenter.isRaisedHandVisible;

    final showAppBar = ![MeetingUiState.leftMeeting, MeetingUiState.enterMeetingPrescreen]
        .contains(LiveMeetingProvider.watch(context).activeUiState);
    final showBottomBar = ConferenceRoom.read(context) != null;
    return Scaffold(
      backgroundColor: AppColor.darkerBlue,
      appBar: showAppBar ? _buildAppBar() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: isBottomSheetPresent && isRaisedHandVisible
          ? FloatingActionButton(
              backgroundColor: AppColor.darkBlue,
              child: JuntoImage(
                null,
                asset: AppAsset.raisedHand(),
                width: 20.0,
                height: 20.0,
              ),
              onPressed: () => _presenter.toggleHandRaise(),
            )
          : null,
      body: _buildBody(),
      bottomNavigationBar: showBottomBar ? _buildBottomNavBar(isBottomSheetPresent) : null,
    );
  }

  PreferredSize _buildAppBar() {
    final discussionTabsController = Provider.of<DiscussionTabsControllerState>(context);
    final agendaProvider = Provider.of<AgendaProvider>(context);

    const showShareButton = false;

    final suppressGuide =
        ConferenceRoom.read(context) == null || agendaProvider.agendaItems.isEmpty;

    return PreferredSize(
      preferredSize: Size.fromHeight(60),
      child: Container(
        color: AppColor.darkBlue,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (discussionTabsController.widget.enableGuide && !suppressGuide)
                      AppClickableWidget(
                        child: JuntoImage(
                          null,
                          asset: AppAsset.guideDarkBlue(),
                          width: 30,
                          height: 30,
                        ),
                        onTap: () {
                          final discussionTabsController =
                              Provider.of<DiscussionTabsControllerState>(context, listen: false);
                          discussionTabsController.openTab(TabType.guide);
                          _presenter.toggleBottomSheetState(
                              LiveMeetingMobileBottomSheetState.fullyVisible);
                        },
                      ),
                    if (discussionTabsController.widget.enableChat)
                      AppClickableWidget(
                        child: JuntoImage(
                          null,
                          asset: AppAsset.chatBubble3White(),
                          width: 30,
                          height: 30,
                        ),
                        onTap: () {
                          final discussionTabsController =
                              Provider.of<DiscussionTabsControllerState>(context, listen: false);
                          discussionTabsController.openTab(TabType.chat);
                          _presenter.toggleBottomSheetState(
                              LiveMeetingMobileBottomSheetState.fullyVisible);
                        },
                      ),
                    if (discussionTabsController.widget.enableUserSubmittedAgenda)
                      AppClickableWidget(
                        child: JuntoImage(
                          null,
                          asset: AppAsset.lightBulbWhite(),
                          width: 30,
                          height: 30,
                        ),
                        onTap: () {
                          final discussionTabsController =
                              Provider.of<DiscussionTabsControllerState>(context, listen: false);
                          discussionTabsController.openTab(TabType.suggestions);
                          _presenter.toggleBottomSheetState(
                              LiveMeetingMobileBottomSheetState.fullyVisible);
                        },
                      ),
                    Spacer(),
                    if (showShareButton)
                      AppClickableWidget(
                        child:
                            JuntoImage(null, asset: AppAsset.shareWhite(), width: 30, height: 30),
                        onTap: () {},
                      ),
                    if (discussionTabsController.widget.enableAdminPanel)
                      AppClickableWidget(
                        child: JuntoImage(null, asset: AppAsset.gearWhite(), width: 30, height: 30),
                        onTap: () {
                          final discussionTabsController =
                              Provider.of<DiscussionTabsControllerState>(context, listen: false);
                          discussionTabsController.openTab(TabType.admin);
                          _presenter.toggleBottomSheetState(
                              LiveMeetingMobileBottomSheetState.fullyVisible);
                        },
                      ),
                    AppClickableWidget(
                      child:
                          JuntoImage(null, asset: AppAsset.needHelpWhite(), width: 30, height: 30),
                      onTap: () => GetHelpButton.getHelp(context),
                    ),
                    AppClickableWidget(
                      child: JuntoImage(null, asset: AppAsset.hangUpRed(), width: 30, height: 30),
                      onTap: () async => await alertOnError(
                        context,
                        () => _presenter.leaveMeeting(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final liveMeetingProvider = LiveMeetingProvider.watch(context);

    Widget? child;
    switch (liveMeetingProvider.activeUiState) {
      case MeetingUiState.leftMeeting:
        child = Container(color: Colors.black45);
        break;
      case MeetingUiState.enterMeetingPrescreen:
        child = EnterMeetingScreen();
        break;
      case MeetingUiState.breakoutRoom:
        child = RefreshKeyWidget(
          child: BreakoutRoomLoader(
            key: Key('breakout-room-${liveMeetingProvider.currentBreakoutRoomId}'),
            liveMeetingBuilder: (_) {
              if (liveMeetingProvider.currentBreakoutRoomId == breakoutsWaitingRoomId) {
                return _buildNonMeeting(child: _buildWaitingRoom());
              }

              return _buildMeetingLoading();
            },
          ),
        );
        break;
      case MeetingUiState.waitingRoom:
        child = _buildNonMeeting(child: WaitingRoom());
        break;
      case MeetingUiState.liveStream:
        child = _buildNonMeeting(child: LiveStreamWidget());
        break;
      case MeetingUiState.inMeeting:
        child = RefreshKeyWidget(
          child: _buildMeetingLoading(),
        );
        break;
    }

    return GlobalKeyedSubtree(label: 'primary-content', child: child);
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

  Widget _buildNonMeeting({required Widget child}) {
    final discussionTabsController = Provider.of<DiscussionTabsControllerState>(context);
    final discussionProvider = DiscussionProvider.watch(context);
    final isInLiveStreamLobby =
        discussionProvider.isLiveStream && !LiveMeetingProvider.watch(context).isInBreakout;
    final isFloatingChatEnabled =
        discussionTabsController.widget.enableChat && discussionProvider.enableFloatingChat;

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(child: child),
                      BreakoutStatusInformation(),
                    ],
                  ),
                  if (isFloatingChatEnabled)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: FloatingChatDisplay(),
                    ),
                ],
              ),
            ),
            if (isFloatingChatEnabled && !isInLiveStreamLobby) ChatAndEmojisInput(),
          ],
        ),
        if (_model.bottomSheetState == LiveMeetingMobileBottomSheetState.fullyVisible)
          Column(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _presenter.dismissFullBottomSheet(),
                child: SizedBox(height: 100),
              ),
              Expanded(
                child: LiveMeetingBottomSheet(
                  bottomSheetState: _model.bottomSheetState,
                  onChange: (state) => _presenter.toggleBottomSheetState(state),
                  onClose: () => _presenter.dismissFullBottomSheet(),
                ),
              ),
            ],
          )
      ],
    );
  }

  Widget _buildUnifyAmerica() {
    return Stack(
      children: [
        Column(
          children: const [
            Expanded(flex: 2, child: BradyBunchViewWidget()),
            Expanded(flex: 3, child: UnifyAmericaTypeform()),
          ],
        ),
        if (_model.bottomSheetState == LiveMeetingMobileBottomSheetState.fullyVisible)
          Column(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _presenter.dismissFullBottomSheet(),
                child: SizedBox(height: 100),
              ),
              Expanded(
                child: LiveMeetingBottomSheet(
                  bottomSheetState: _model.bottomSheetState,
                  onChange: (state) => _presenter.toggleBottomSheetState(state),
                  onClose: () => _presenter.dismissFullBottomSheet(),
                ),
              ),
            ],
          )
      ],
    );
  }

  Widget _buildMeetingLoading() {
    final liveMeetingProvider = LiveMeetingProvider.watch(context);

    return JuntoStreamBuilder<GetMeetingJoinInfoResponse>(
      entryFrom: '_buildConferenceRoomWrapper.build',
      stream: liveMeetingProvider.getCurrentMeetingJoinInfo()!.asStream(),
      loadingMessage: 'Loading room. Please wait...',
      builder: (_, response) {
        final conferenceRoom = ConferenceRoom.watch(context);
        final error = conferenceRoom.connectError;
        if (error != null && error.trim().isNotEmpty) {
          return Center(
            child: AudioVideoErrorDisplay(error: error),
          );
        }

        const recordingPulseSize = 16.0;

        final isUnifyAmerica = UnifyAmericaController.watch(context) != null;

        return JuntoStreamBuilder(
          entryFrom: 'LiveMeetingMobilePage._buildMeetingLoading',
          stream: Stream.fromFuture(conferenceRoom.connectionFuture),
          errorMessage: 'Something went wrong loading room. Please refresh!',
          loadingMessage: 'Connecting to room...',
          textStyle: TextStyle(color: AppColor.white),
          builder: (_, __) => Stack(
            children: [
              if (isUnifyAmerica) _buildUnifyAmerica() else _buildMeeting(),
              if (DiscussionProvider.watch(context).discussion.discussionSettings?.alwaysRecord ==
                  true)
                Container(
                  alignment: Alignment.topRight,
                  child: Container(
                    color: AppColor.black.withOpacity(0.5),
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: recordingPulseSize,
                          width: recordingPulseSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColor.redDarkMode,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Recording',
                          style: TextStyle(color: AppColor.white),
                        ),
                        SizedBox(width: 26),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMeeting() {
    ConferenceRoom.watchOrNull(context);

    final participants = _presenter.getParticipants();
    final dominantSpeaker = participants.firstOrNull;
    final discussionTabsController = Provider.of<DiscussionTabsControllerState>(context);
    final discussionProvider = DiscussionProvider.watch(context);

    final isFloatingChatEnabled =
        discussionTabsController.widget.enableChat && discussionProvider.enableFloatingChat;

    switch (_model.bottomSheetState) {
      case LiveMeetingMobileBottomSheetState.fullyVisible:
        return Column(
          children: [
            SizedBox(
              height: 100,
              child: ParticipantsWidget(
                participants: participants,
              ),
            ),
            BreakoutStatusInformation(),
            Expanded(
              child: LiveMeetingBottomSheet(
                bottomSheetState: _model.bottomSheetState,
                onChange: (state) => _presenter.toggleBottomSheetState(state),
                onClose: _presenter.isDismissableTabOpen ? () => _presenter.openGuide() : null,
              ),
            ),
          ],
        );
      case LiveMeetingMobileBottomSheetState.partiallyVisible:
        return Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Column(
                    children: [
                      if (participants.length > 1)
                        SizedBox(
                          height: 100,
                          child: ParticipantsWidget(
                            participants: participants.skip(1).toList(),
                          ),
                        ),
                      if (dominantSpeaker != null)
                        Expanded(child: _buildFeaturedParticipant(dominantSpeaker)),
                      SizedBox(height: 10),
                      BreakoutStatusInformation(),
                    ],
                  ),
                  if (isFloatingChatEnabled)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: FloatingChatDisplay(),
                    ),
                ],
              ),
            ),
            if (isFloatingChatEnabled) ChatAndEmojisInput(),
            SizedBox(height: 10),
            Expanded(
              child: LiveMeetingBottomSheet(
                bottomSheetState: _model.bottomSheetState,
                onChange: (state) => _presenter.toggleBottomSheetState(state),
              ),
            ),
          ],
        );
      case LiveMeetingMobileBottomSheetState.hidden:
        return Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Column(
                    children: const [
                      Expanded(
                        child: BradyBunchViewWidget(),
                      ),
                      BreakoutStatusInformation(),
                      SizedBox(height: 10),
                    ],
                  ),
                  if (isFloatingChatEnabled)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: FloatingChatDisplay(),
                    ),
                ],
              ),
            ),
            if (isFloatingChatEnabled) ChatAndEmojisInput(),
            SizedBox(height: 10),
          ],
        );
    }
  }

  Widget _buildFeaturedParticipant(AgoraParticipant participant) {
    return ParticipantWidget(
      globalKey: JuntoGlobalKey.fromLabel(participant.userId),
      participant: participant,
    );
  }

  Widget _buildReadyText(List<ParticipantAgendaItemDetails> participantAgendaItemDetailsList) {
    final presentParticipantIds = _presenter.getPresentParticipantIds().toSet();
    final readyToMoveOnCount = _presenter.readyToMoveOnCount(
      participantAgendaItemDetailsList,
      presentParticipantIds,
    );
    return Text('$readyToMoveOnCount/${presentParticipantIds.length}');
  }

  Widget _buildBottomNavBar(bool isBottomSheetPresent) {
    context.watch<LiveMeetingProvider>();

    final meetingGuideCardStore = context.watch<MeetingGuideCardStore>();
    final agendaProvider = context.watch<AgendaProvider>();

    const kIconSize = 20.0;
    final isVideoOn = _presenter.isVideoOn();
    final isMicOn = _presenter.isMicOn();
    final isBottomSheetPresent = _presenter.isBottomSheetPresent();
    final isAudioTemporarilyDisabled = _presenter.isAudioTemporarilyDisabled();

    final participantAgendaItemDetailsStream = _presenter.getParticipantAgendaItemDetailsStream();

    return JuntoUiMigration(
      whiteBackground: true,
      child: JuntoStreamBuilder<List<ParticipantAgendaItemDetails>>(
        entryFrom: '_MeetingGuideCard._buildBottomSection',
        stream: participantAgendaItemDetailsStream,
        height: 100,
        builder: (context, participantAgendaItemDetailsList) {
          final readyToAdvance = _presenter.isReadyToAdvance(participantAgendaItemDetailsList);
          final canUserControlMeeting = _presenter.canUserControlMeeting;

          final currentItem = _presenter.getCurrentAgendaItem();
          final isMeetingStarted = _presenter.isMeetingStarted();
          final meetingFinished = currentItem == null && isMeetingStarted;
          final isHosted = _presenter.isHosted();
          final isBackButtonShown = _presenter.isBackButtonShown();

          final isRaisedHandVisible = _presenter.isRaisedHandVisible;

          final showReadyToMoveOn = !isHosted;
          final isCardPending = _presenter.isCardPending();

          return Container(
            color: AppColor.white,
            child: JuntoUiMigration(
              whiteBackground: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Divider(height: 1, color: AppColor.gray5),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Row(
                      children: [
                        AppClickableWidget(
                          child: JuntoImage(
                            null,
                            asset: isVideoOn
                                ? AppAsset.videoOnDarkBlue()
                                : AppAsset.videoOffDarkBlue(),
                            width: kIconSize,
                            height: kIconSize,
                          ),
                          onTap: () async =>
                              await alertOnError(context, () => _presenter.toggleVideo()),
                        ),
                        SizedBox(width: 10),
                        AppClickableWidget(
                          child: JuntoImage(
                            null,
                            asset:
                                isMicOn ? AppAsset.audioOnDarkBlue() : AppAsset.audioOffDarkBlue(),
                            width: kIconSize,
                            height: kIconSize,
                          ),
                          onTap: isAudioTemporarilyDisabled
                              ? () => showRegularToast(
                                    context,
                                    'All participants are muted during video!',
                                    toastType: ToastType.success,
                                  )
                              : () => AudioVideoErrorDialog.showOnError(
                                  context, () => _presenter.toggleAudio()),
                        ),
                        SizedBox(width: 10),
                        JuntoUiMigration(
                          whiteBackground: true,
                          child: PopupMenuButton<FutureOr<void> Function()>(
                            itemBuilder: (context) {
                              return [
                                PopupMenuItem(
                                  value: () => AudioVideoSettingsDialog(
                                    conferenceRoom: context.read<ConferenceRoom>(),
                                  ).show(),
                                  child: JuntoText('Audio/Video Settings'),
                                ),
                              ];
                            },
                            onSelected: (itemAction) => itemAction(),
                            child: JuntoImage(
                              null,
                              asset: AppAsset.dotsVertical(),
                              width: kIconSize,
                              height: kIconSize,
                            ),
                          ),
                        ),
                        if (!isBottomSheetPresent && isRaisedHandVisible)
                          Expanded(
                            child: Center(
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: FloatingActionButton(
                                  backgroundColor: AppColor.darkBlue,
                                  child: JuntoImage(
                                    null,
                                    asset: AppAsset.raisedHand(),
                                    width: kIconSize,
                                    height: kIconSize,
                                  ),
                                  onPressed: () => _presenter.toggleHandRaise(),
                                ),
                              ),
                            ),
                          )
                        else
                          Spacer(),
                        if (isCardPending)
                          CountdownWidget()
                        else ...[
                          if (!isHosted || canUserControlMeeting) ...[
                            if (isBackButtonShown)
                              AppClickableWidget(
                                child: JuntoImage(
                                  null,
                                  asset: AppAsset.arrowLeft(),
                                  width: kIconSize,
                                  height: kIconSize,
                                ),
                                onTap: () => alertOnError(
                                    context, () => meetingGuideCardStore.goToPreviousAgendaItem()),
                              ),
                            SizedBox(width: 10),
                            if (showReadyToMoveOn)
                              _buildReadyText(participantAgendaItemDetailsList ?? []),
                            SizedBox(width: 10),
                            if (!meetingFinished && agendaProvider.agendaItems.isNotEmpty)
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: FloatingActionButton(
                                  backgroundColor: AppColor.darkBlue,
                                  child: JuntoImage(
                                    null,
                                    asset: readyToAdvance
                                        ? AppAsset.kSpokenCheckMark
                                        : AppAsset.arrowRightGreen(),
                                    width: kIconSize,
                                    height: kIconSize,
                                  ),
                                  onPressed: () => alertOnError(
                                      context,
                                      () => agendaProvider.moveForward(
                                            currentAgendaItemId:
                                                _presenter.getCurrentAgendaItemId()!,
                                          )),
                                ),
                              ),
                          ],
                        ],
                        if (!isBottomSheetPresent && agendaProvider.agendaItems.isNotEmpty) ...[
                          SizedBox(width: 10),
                          AppClickableWidget(
                            child: JuntoImage(
                              null,
                              asset: AppAsset.maximizeBlue(),
                              width: kIconSize,
                              height: kIconSize,
                            ),
                            onTap: () => _presenter.toggleBottomSheetState(
                                LiveMeetingMobileBottomSheetState.partiallyVisible),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class LiveMeetingBottomSheet extends StatefulWidget {
  final LiveMeetingMobileBottomSheetState bottomSheetState;
  final void Function(LiveMeetingMobileBottomSheetState) onChange;
  final void Function()? onClose;

  const LiveMeetingBottomSheet({
    Key? key,
    required this.bottomSheetState,
    required this.onChange,
    this.onClose,
  }) : super(key: key);

  @override
  State<LiveMeetingBottomSheet> createState() => _LiveMeetingBottomSheetState();
}

class _LiveMeetingBottomSheetState extends State<LiveMeetingBottomSheet> {
  Offset? _startingPosition;
  Offset? _currentPosition;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: (details) => _startingPosition = details.globalPosition,
      onVerticalDragUpdate: (details) => _currentPosition = details.globalPosition,
      onVerticalDragEnd: (details) {
        final startYPosition = _startingPosition?.dy;
        final endYPosition = _currentPosition?.dy;

        if (startYPosition == null || endYPosition == null) {
          return;
        }

        /// For unify america dont allow them to fully dismiss the typeform
        final isUnifyAmerica = UnifyAmericaController.read(context) != null;

        final discussionTabsController =
            Provider.of<DiscussionTabsControllerState>(context, listen: false);
        final selectedTabIndex = discussionTabsController.selectedTabController.selectedIndex;
        final selectedTab = discussionTabsController.tabs[selectedTabIndex];
        final isWordCloud = selectedTab == TabType.guide &&
            context.read<MeetingGuideCardStore>().meetingGuideCardAgendaItem?.type ==
                AgendaItemType.wordCloud;

        final bool canSwipeDown;
        if (isUnifyAmerica) {
          canSwipeDown = widget.bottomSheetState == LiveMeetingMobileBottomSheetState.fullyVisible;
        } else {
          canSwipeDown = widget.onClose == null && !isWordCloud;
        }

        // Swipe down
        if (canSwipeDown && startYPosition < endYPosition) {
          widget.onChange(widget.bottomSheetState == LiveMeetingMobileBottomSheetState.fullyVisible
              ? LiveMeetingMobileBottomSheetState.partiallyVisible
              : LiveMeetingMobileBottomSheetState.hidden);
        }
        // Swipe Up
        else if (widget.bottomSheetState == LiveMeetingMobileBottomSheetState.partiallyVisible &&
            startYPosition > endYPosition) {
          widget.onChange(LiveMeetingMobileBottomSheetState.fullyVisible);
        }
      },
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pillWidth = size.width / 3.5;

    final discussionTabsController = Provider.of<DiscussionTabsControllerState>(context);

    final selectedTabIndex = discussionTabsController.selectedTabController.selectedIndex;
    final selectedTab = discussionTabsController.tabs[selectedTabIndex];

    final localOnClose = widget.onClose;
    final isAdmin = selectedTab == TabType.admin;
    final Color backgroundColor;
    if ([TabType.chat, TabType.suggestions].contains(selectedTab)) {
      backgroundColor = AppColor.gray6;
    } else if (isAdmin) {
      backgroundColor = AppColor.darkBlue;
    } else {
      backgroundColor = AppColor.white;
    }
    return PointerInterceptor(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 3,
              offset: Offset(2, 2),
              color: Colors.black.withOpacity(0.5),
            ),
          ],
          color: backgroundColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (localOnClose == null) ...[
              SizedBox(height: 12),
              Center(
                child: Container(
                  width: pillWidth,
                  height: 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppColor.gray5,
                  ),
                ),
              ),
              SizedBox(height: 12),
            ] else
              Align(
                alignment: Alignment.centerRight,
                child: JuntoInkWell(
                  onTap: () => localOnClose(),
                  boxShape: BoxShape.circle,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.close,
                      color: isAdmin ? AppColor.white : AppColor.gray2,
                      size: 20,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: JuntoUiMigration(
                whiteBackground: true,
                child: _buildSelectedContent(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedContent(BuildContext context) {
    final discussionTabsController = Provider.of<DiscussionTabsControllerState>(context);

    final selectedTabIndex = discussionTabsController.selectedTabController.selectedIndex;
    final selectedTab = discussionTabsController.tabs[selectedTabIndex];

    if (selectedTab == TabType.chat) {
      return ChatWidget(
        parentPath: context.watch<ChatModel>().parentPath,
        messageInputHint: 'Say something',
        allowBroadcast: context.watch<LiveMeetingProvider>().isInBreakout &&
            context.watch<DiscussionPermissionsProvider>().canBroadcastChat,
      );
    } else if (selectedTab == TabType.suggestions) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: UserSubmittedAgenda(),
      );
    } else if (selectedTab == TabType.admin) {
      return JuntoUiMigration(
        whiteBackground: false,
        child: AdminPanel(
          padding: EdgeInsets.symmetric(horizontal: 6),
        ),
      );
    } else {
      return MeetingGuideCardContent(
        // Not implemented on mobile
        onMinimizeCard: () {},
      );
    }
  }
}

class ParticipantsWidget extends StatelessWidget {
  final List<AgoraParticipant> participants;

  const ParticipantsWidget({
    Key? key,
    required this.participants,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final participant = participants[index];
        return AspectRatio(
          aspectRatio: 1.0,
          child: ParticipantWidget(
            globalKey: JuntoGlobalKey.fromLabel(participant.userId),
            participant: participant,
          ),
        );
      },
    );
  }
}

class BreakoutRoomLoader extends StatelessWidget {
  final WidgetBuilder liveMeetingBuilder;

  const BreakoutRoomLoader({
    Key? key,
    required this.liveMeetingBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return JuntoStreamBuilder(
      entryFrom: '_RefreshableBreakoutRoomState.build',
      stream: Provider.of<LiveMeetingProvider>(context).breakoutRoomLiveMeetingStream,
      loadingMessage: 'Loading breakout room. Please wait...',
      builder: (context, __) {
        return liveMeetingBuilder(context);
      },
    );
  }
}
