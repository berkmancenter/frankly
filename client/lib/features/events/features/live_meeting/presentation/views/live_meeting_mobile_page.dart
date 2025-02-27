import 'dart:async';

import 'package:client/core/utils/toast_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:client/features/chat/data/providers/chat_model.dart';
import 'package:client/features/chat/presentation/widgets/chat_widget.dart';
import 'package:client/features/events/features/live_meeting/features/admin_panel/presentation/widgets/admin_panel.dart';
import 'package:client/features/events/features/event_page/data/providers/event_permissions_provider.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/event_page/presentation/widgets/event_tabs.dart';
import 'package:client/features/events/features/event_page/presentation/event_tabs_model.dart';
import 'package:client/features/events/features/live_meeting/presentation/widgets/live_meeting_desktop.dart';
import 'package:client/features/events/features/live_meeting/presentation/views/live_meeting_mobile_contract.dart';
import 'package:client/features/events/features/live_meeting/data/models/live_meeting_mobile_model.dart';
import 'package:client/features/events/features/live_meeting/data/providers/live_meeting_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/presentation/views/meeting_guide_card.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/data/providers/meeting_guide_card_store.dart';
import 'package:client/features/events/features/live_meeting/features/video/data/providers/agora_room.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/views/audio_video_error.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/views/audio_video_settings.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/views/brady_bunch_view_widget.dart';
import 'package:client/features/events/features/live_meeting/features/video/data/providers/conference_room.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/widgets/control_bar.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/widgets/participant_widget.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/views/video_flutter_meeting.dart';
import 'package:client/features/events/features/live_meeting/features/live_stream/presentation/widgets/live_stream_widget.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/providers/meeting_agenda_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/widgets/user_submitted_agenda.dart';
import 'package:client/features/events/features/event_page/presentation/widgets/waiting_room.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/app_clickable_widget.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:data_models/events/live_meetings/meeting_guide.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

import '../live_meeting_mobile_presenter.dart';

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

    final LiveMeetingMobileBottomSheetState initialSheetState;

    final suppressGuide = ConferenceRoom.read(context) == null ||
        context.read<AgendaProvider>().agendaItems.isEmpty;

    if (suppressGuide) {
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

    final eventTabsController =
        Provider.of<EventTabsControllerState>(context, listen: false);
    final selectedTabIndex =
        eventTabsController.selectedTabController.selectedIndex;
    final selectedTab = eventTabsController.tabs[selectedTabIndex];

    final isLargeAgendaItem = selectedTab == TabType.guide &&
        [AgendaItemType.wordCloud, AgendaItemType.userSuggestions].contains(
          context
              .read<MeetingGuideCardStore>()
              .meetingGuideCardAgendaItem
              ?.type,
        );

    if (keyboardIsOpen) {
      _presenter
          .toggleBottomSheetState(LiveMeetingMobileBottomSheetState.hidden);
    } else if ((isLargeAgendaItem || selectedTab == TabType.suggestions) &&
        _model.bottomSheetState ==
            LiveMeetingMobileBottomSheetState.partiallyVisible) {
      _presenter.toggleBottomSheetState(
        LiveMeetingMobileBottomSheetState.fullyVisible,
      );
    }
  }

  void _checkConnectToRoom() {
    final conferenceRoom = ConferenceRoom.read(context);
    final inRoom = conferenceRoom != null;
    if (inRoom && conferenceRoom.hasStartedConnecting == false) {
      _connectToRoom();

      _onUnloadSubscription = html.window.onBeforeUnload.listen((event) {
        final conferenceRoom = ConferenceRoom.read(context);
        conferenceRoom?.room?.dispose();
      });
    }
  }

  Future<void> _connectToRoom() async {
    final conferenceRoom = ConferenceRoom.read(context);
    _onConferenceRoomException =
        conferenceRoom?.onException.listen((err) async {
      loggingService.log('showing alert in listener');
      await showAlert(
        context,
        err is PlatformException ? err.details : err.toString(),
      );
    });
    await conferenceRoom?.connect();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<MeetingGuideCardStore>();

    final isBottomSheetPresent = _presenter.isBottomSheetPresent();
    final isRaisedHandVisible = _presenter.isRaisedHandVisible;

    final showAppBar = ![
      MeetingUiState.leftMeeting,
      MeetingUiState.enterMeetingPrescreen,
    ].contains(LiveMeetingProvider.watch(context).activeUiState);
    final showBottomBar = ConferenceRoom.read(context) != null;
    return Scaffold(
      backgroundColor: AppColor.darkerBlue,
      appBar: showAppBar ? _buildAppBar() : null,
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: isBottomSheetPresent && isRaisedHandVisible
          ? FloatingActionButton(
              backgroundColor: AppColor.darkBlue,
              child: ProxiedImage(
                null,
                asset: AppAsset.raisedHand(),
                width: 20.0,
                height: 20.0,
              ),
              onPressed: () => _presenter.toggleHandRaise(),
            )
          : null,
      body: _buildBody(),
      bottomNavigationBar:
          showBottomBar ? _buildBottomNavBar(isBottomSheetPresent) : null,
    );
  }

  PreferredSize _buildAppBar() {
    final eventTabsController = Provider.of<EventTabsControllerState>(context);
    final agendaProvider = Provider.of<AgendaProvider>(context);

    const showShareButton = false;

    final suppressGuide = ConferenceRoom.read(context) == null ||
        agendaProvider.agendaItems.isEmpty;

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
                    if (eventTabsController.widget.enableGuide &&
                        !suppressGuide)
                      AppClickableWidget(
                        child: ProxiedImage(
                          null,
                          asset: AppAsset.guideDarkBlue(),
                          width: 30,
                          height: 30,
                        ),
                        onTap: () {
                          final eventTabsController =
                              Provider.of<EventTabsControllerState>(
                            context,
                            listen: false,
                          );
                          eventTabsController.openTab(TabType.guide);
                          _presenter.toggleBottomSheetState(
                            LiveMeetingMobileBottomSheetState.fullyVisible,
                          );
                        },
                      ),
                    if (eventTabsController.widget.enableChat)
                      AppClickableWidget(
                        child: ProxiedImage(
                          null,
                          asset: AppAsset.chatBubble3White(),
                          width: 30,
                          height: 30,
                        ),
                        onTap: () {
                          final eventTabsController =
                              Provider.of<EventTabsControllerState>(
                            context,
                            listen: false,
                          );
                          eventTabsController.openTab(TabType.chat);
                          _presenter.toggleBottomSheetState(
                            LiveMeetingMobileBottomSheetState.fullyVisible,
                          );
                        },
                      ),
                    if (eventTabsController.widget.enableUserSubmittedAgenda)
                      AppClickableWidget(
                        child: ProxiedImage(
                          null,
                          asset: AppAsset.lightBulbWhite(),
                          width: 30,
                          height: 30,
                        ),
                        onTap: () {
                          final eventTabsController =
                              Provider.of<EventTabsControllerState>(
                            context,
                            listen: false,
                          );
                          eventTabsController.openTab(TabType.suggestions);
                          _presenter.toggleBottomSheetState(
                            LiveMeetingMobileBottomSheetState.fullyVisible,
                          );
                        },
                      ),
                    Spacer(),
                    if (showShareButton)
                      AppClickableWidget(
                        child: ProxiedImage(
                          null,
                          asset: AppAsset.shareWhite(),
                          width: 30,
                          height: 30,
                        ),
                        onTap: () {},
                      ),
                    if (eventTabsController.widget.enableAdminPanel)
                      AppClickableWidget(
                        child: ProxiedImage(
                          null,
                          asset: AppAsset.gearWhite(),
                          width: 30,
                          height: 30,
                        ),
                        onTap: () {
                          final eventTabsController =
                              Provider.of<EventTabsControllerState>(
                            context,
                            listen: false,
                          );
                          eventTabsController.openTab(TabType.admin);
                          _presenter.toggleBottomSheetState(
                            LiveMeetingMobileBottomSheetState.fullyVisible,
                          );
                        },
                      ),
                    AppClickableWidget(
                      child: ProxiedImage(
                        null,
                        asset: AppAsset.needHelpWhite(),
                        width: 30,
                        height: 30,
                      ),
                      onTap: () => GetHelpButton.getHelp(context),
                    ),
                    AppClickableWidget(
                      child: ProxiedImage(
                        null,
                        asset: AppAsset.hangUpRed(),
                        width: 30,
                        height: 30,
                      ),
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
            key: Key(
              'breakout-room-${liveMeetingProvider.currentBreakoutRoomId}',
            ),
            liveMeetingBuilder: (_) {
              if (liveMeetingProvider.currentBreakoutRoomId ==
                  breakoutsWaitingRoomId) {
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
              child: ProxiedImage(
                Provider.of<CommunityProvider>(context)
                    .community
                    .profileImageUrl,
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
    return HeightConstrainedText(
      'You are in the waiting room.',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).primaryColor,
          ),
    );
  }

  Widget _buildNonMeeting({required Widget child}) {
    final eventTabsController = Provider.of<EventTabsControllerState>(context);
    final eventProvider = EventProvider.watch(context);
    final isInLiveStreamLobby = eventProvider.isLiveStream &&
        !LiveMeetingProvider.watch(context).isInBreakout;
    final isFloatingChatEnabled = eventTabsController.widget.enableChat &&
        eventProvider.enableFloatingChat;

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
            if (isFloatingChatEnabled && !isInLiveStreamLobby)
              ChatAndEmojisInput(),
          ],
        ),
        if (_model.bottomSheetState ==
            LiveMeetingMobileBottomSheetState.fullyVisible)
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
          ),
      ],
    );
  }

  Widget _buildMeetingLoading() {
    final liveMeetingProvider = LiveMeetingProvider.watch(context);

    return CustomStreamBuilder<GetMeetingJoinInfoResponse>(
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

        return CustomStreamBuilder(
          entryFrom: 'LiveMeetingMobilePage._buildMeetingLoading',
          stream: Stream.fromFuture(conferenceRoom.connectionFuture),
          errorMessage: 'Something went wrong loading room. Please refresh!',
          loadingMessage: 'Connecting to room...',
          textStyle: TextStyle(color: AppColor.white),
          builder: (_, __) => Stack(
            children: [
              _buildMeeting(),
              if (EventProvider.watch(context)
                      .event
                      .eventSettings
                      ?.alwaysRecord ==
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
    final eventTabsController = Provider.of<EventTabsControllerState>(context);
    final eventProvider = EventProvider.watch(context);

    final isFloatingChatEnabled = eventTabsController.widget.enableChat &&
        eventProvider.enableFloatingChat;

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
                onClose: _presenter.isDismissableTabOpen
                    ? () => _presenter.openGuide()
                    : null,
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
                        Expanded(
                          child: _buildFeaturedParticipant(dominantSpeaker),
                        ),
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
      globalKey: CommunityGlobalKey.fromLabel(participant.userId),
      participant: participant,
    );
  }

  Widget _buildReadyText(
    List<ParticipantAgendaItemDetails> participantAgendaItemDetailsList,
  ) {
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

    final participantAgendaItemDetailsStream =
        _presenter.getParticipantAgendaItemDetailsStream();

    return CustomStreamBuilder<List<ParticipantAgendaItemDetails>>(
      entryFrom: '_MeetingGuideCard._buildBottomSection',
      stream: participantAgendaItemDetailsStream,
      height: 100,
      builder: (context, participantAgendaItemDetailsList) {
        final readyToAdvance =
            _presenter.isReadyToAdvance(participantAgendaItemDetailsList);
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(height: 1, color: AppColor.gray5),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                child: Row(
                  children: [
                    AppClickableWidget(
                      child: ProxiedImage(
                        null,
                        asset: isVideoOn
                            ? AppAsset.videoOnDarkBlue()
                            : AppAsset.videoOffDarkBlue(),
                        width: kIconSize,
                        height: kIconSize,
                      ),
                      onTap: () async => await alertOnError(
                        context,
                        () => _presenter.toggleVideo(),
                      ),
                    ),
                    SizedBox(width: 10),
                    AppClickableWidget(
                      onTap: isAudioTemporarilyDisabled
                          ? () => showRegularToast(
                                context,
                                'All participants are muted during video!',
                                toastType: ToastType.success,
                              )
                          : () => AudioVideoErrorDialog.showOnError(
                                context,
                                () => _presenter.toggleAudio(),
                              ),
                      child: ProxiedImage(
                        null,
                        asset: isMicOn
                            ? AppAsset.audioOnDarkBlue()
                            : AppAsset.audioOffDarkBlue(),
                        width: kIconSize,
                        height: kIconSize,
                      ),
                    ),
                    SizedBox(width: 10),
                    PopupMenuButton<FutureOr<void> Function()>(
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            value: () => AudioVideoSettingsDialog(
                              conferenceRoom: context.read<ConferenceRoom>(),
                            ).show(),
                            child: HeightConstrainedText(
                              'Audio/Video Settings',
                            ),
                          ),
                        ];
                      },
                      onSelected: (itemAction) => itemAction(),
                      child: ProxiedImage(
                        null,
                        asset: AppAsset.dotsVertical(),
                        width: kIconSize,
                        height: kIconSize,
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
                              child: ProxiedImage(
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
                            child: ProxiedImage(
                              null,
                              asset: AppAsset.arrowLeft(),
                              width: kIconSize,
                              height: kIconSize,
                            ),
                            onTap: () => alertOnError(
                              context,
                              () => meetingGuideCardStore
                                  .goToPreviousAgendaItem(),
                            ),
                          ),
                        SizedBox(width: 10),
                        if (showReadyToMoveOn)
                          _buildReadyText(
                            participantAgendaItemDetailsList ?? [],
                          ),
                        SizedBox(width: 10),
                        if (!meetingFinished &&
                            agendaProvider.agendaItems.isNotEmpty)
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: FloatingActionButton(
                              backgroundColor: AppColor.darkBlue,
                              child: ProxiedImage(
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
                                ),
                              ),
                            ),
                          ),
                      ],
                    ],
                    if (!isBottomSheetPresent &&
                        agendaProvider.agendaItems.isNotEmpty) ...[
                      SizedBox(width: 10),
                      AppClickableWidget(
                        child: ProxiedImage(
                          null,
                          asset: AppAsset.maximizeBlue(),
                          width: kIconSize,
                          height: kIconSize,
                        ),
                        onTap: () => _presenter.toggleBottomSheetState(
                          LiveMeetingMobileBottomSheetState.partiallyVisible,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
      onVerticalDragStart: (details) =>
          _startingPosition = details.globalPosition,
      onVerticalDragUpdate: (details) =>
          _currentPosition = details.globalPosition,
      onVerticalDragEnd: (details) {
        final startYPosition = _startingPosition?.dy;
        final endYPosition = _currentPosition?.dy;

        if (startYPosition == null || endYPosition == null) {
          return;
        }

        final eventTabsController =
            Provider.of<EventTabsControllerState>(context, listen: false);
        final selectedTabIndex =
            eventTabsController.selectedTabController.selectedIndex;
        final selectedTab = eventTabsController.tabs[selectedTabIndex];
        final isWordCloud = selectedTab == TabType.guide &&
            context
                    .read<MeetingGuideCardStore>()
                    .meetingGuideCardAgendaItem
                    ?.type ==
                AgendaItemType.wordCloud;

        final bool canSwipeDown;

        canSwipeDown = widget.onClose == null && !isWordCloud;

        // Swipe down
        if (canSwipeDown && startYPosition < endYPosition) {
          widget.onChange(
            widget.bottomSheetState ==
                    LiveMeetingMobileBottomSheetState.fullyVisible
                ? LiveMeetingMobileBottomSheetState.partiallyVisible
                : LiveMeetingMobileBottomSheetState.hidden,
          );
        }
        // Swipe Up
        else if (widget.bottomSheetState ==
                LiveMeetingMobileBottomSheetState.partiallyVisible &&
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

    final eventTabsController = Provider.of<EventTabsControllerState>(context);

    final selectedTabIndex =
        eventTabsController.selectedTabController.selectedIndex;
    final selectedTab = eventTabsController.tabs[selectedTabIndex];

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
                child: CustomInkWell(
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
              child: _buildSelectedContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedContent(BuildContext context) {
    final eventTabsController = Provider.of<EventTabsControllerState>(context);

    final selectedTabIndex =
        eventTabsController.selectedTabController.selectedIndex;
    final selectedTab = eventTabsController.tabs[selectedTabIndex];

    if (selectedTab == TabType.chat) {
      return ChatWidget(
        parentPath: context.watch<ChatModel>().parentPath,
        messageInputHint: 'Say something',
        allowBroadcast: context.watch<LiveMeetingProvider>().isInBreakout &&
            context.watch<EventPermissionsProvider>().canBroadcastChat,
      );
    } else if (selectedTab == TabType.suggestions) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: UserSubmittedAgenda(),
      );
    } else if (selectedTab == TabType.admin) {
      return AdminPanel(
        padding: EdgeInsets.symmetric(horizontal: 6),
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
            globalKey: CommunityGlobalKey.fromLabel(participant.userId),
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
    return CustomStreamBuilder(
      entryFrom: '_RefreshableBreakoutRoomState.build',
      stream: Provider.of<LiveMeetingProvider>(context)
          .breakoutRoomLiveMeetingStream,
      loadingMessage: 'Loading breakout room. Please wait...',
      builder: (context, __) {
        return liveMeetingBuilder(context);
      },
    );
  }
}
