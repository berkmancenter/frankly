import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:client/core/widgets/custom_loading_indicator.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:client/features/events/features/event_page/data/providers/event_permissions_provider.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/live_meeting/data/providers/live_meeting_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/data/providers/meeting_guide_card_store.dart';
import 'package:client/features/events/features/live_meeting/features/video/data/providers/conference_room.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/views/video_flutter_meeting.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/providers/meeting_agenda_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/features/user/presentation/views/profile_tab.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/features/user/data/providers/user_info_builder.dart';
import 'package:client/features/user/presentation/widgets/user_profile_chip.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/utils/dialogs.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:provider/provider.dart';

import '../../data/providers/agora_room.dart';

class GlobalKeyedSubtree extends StatelessWidget {
  static final Map<String, GlobalKey> _globalKeys = {};

  final String label;
  final Widget child;

  const GlobalKeyedSubtree({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _globalKeys[label] ??= GlobalKey(debugLabel: label),
      child: child,
    );
  }
}

class ParticipantWidget extends StatefulWidget {
  static final aspectRatio = Size(16, 9).aspectRatio;

  final CommunityGlobalKey globalKey;
  final AgoraParticipant participant;
  final bool isScreenShare;
  final BorderRadius borderRadius;

  const ParticipantWidget({
    required this.globalKey,
    required this.participant,
    this.isScreenShare = false,
    this.borderRadius = BorderRadius.zero,
  }) : super(key: globalKey);

  @override
  _ParticipantWidgetState createState() => _ParticipantWidgetState();
}

class _ParticipantWidgetState extends State<ParticipantWidget> {
  Timer? _startedTimer;
  Timer? _showParticipantTimer;

  ConferenceRoom get conferenceRoom => ConferenceRoom.watch(context);

  bool get isDominant =>
      conferenceRoom.dominantSpeakerSid == widget.participant.userId;

  bool get isRemote => widget.participant.agoraUid != 0;

  bool get videoEnabled {
    return widget.participant.videoTrackEnabled;
  }

  bool get _isNewlyConnected {
    final timer = conferenceRoom
        .participantInitializationTimers[widget.participant.userId];
    return timer?.isActive ?? false;
  }

  bool get audioEnabled => isRemote
      ? _isRemoteAudioEnabled(widget.participant.userId)
      : conferenceRoom.audioEnabled;

  bool get isStarted => widget.participant.videoTrackEnabled;

  bool _isRemoteAudioEnabled(String participantId) {
    final hasMuteOverride = EventProvider.watch(context)
        .eventParticipants
        .any((d) => d.id == participantId && d.muteOverride);
    return !hasMuteOverride && (widget.participant.audioTrackEnabled);
  }

  bool _showName = false;

  @override
  void dispose() {
    loggingService.log('disposing ${widget.globalKey.distinctLabel}');
    _startedTimer?.cancel();
    _showParticipantTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isStarted) {
      _startedTimer ??= Timer(Duration(seconds: 2), () => setState(() {}));
    }
  }

  Widget _buildVideoElement() {
    Widget videoWidget;
    if (widget.participant is FakeParticipant) {
      videoWidget = Container(color: Colors.orange);
    } else if (isRemote) {
      videoWidget = AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: conferenceRoom.room!.engine,
          canvas: VideoCanvas(uid: widget.participant.agoraUid),
          connection: RtcConnection(channelId: 'test-channel'),
        ),
      );
    } else {
      videoWidget = AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: conferenceRoom.room!.engine,
          canvas: const VideoCanvas(uid: 0),
        ),
        onAgoraVideoViewCreated: (viewId) {
          //conferenceRoom.room!.engine.startPreview();
        },
      );
    }

    final child = GlobalKeyedSubtree(
      label: '${widget.globalKey.distinctLabel}-video-element',
      child: videoWidget,
    );

    if (isRemote || widget.isScreenShare) return child;

    return child;
  }

  Widget _buildVideo() {
    final dimensions = Size(854.0, 480.0);

    var fit = BoxFit.contain;
    // If the aspect ratio is close to 16:9 or 4:3 or somewhere in between
    // cover the whole area. Otherwise, fit it within the bounds
    if (dimensions.aspectRatio <= Size(17, 9).aspectRatio &&
        dimensions.aspectRatio >= Size(3.5, 3).aspectRatio &&
        !widget.isScreenShare) {
      fit = BoxFit.cover;
    }

    return RepaintBoundary(
      child: FittedBox(
        fit: fit,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          height: dimensions.height,
          width: dimensions.width,
          child: _buildVideoElement(),
        ),
      ),
    );
  }

  Widget _buildMutedOverlayEntry() {
    return Icon(
      Icons.mic_off_outlined,
      color: context.theme.colorScheme.error,
      size: 17,
    );
  }

  Widget _buildOverlay() {
    final bool isHandRaised = Provider.of<MeetingGuideCardStore>(context)
        .getHandIsRaised(widget.participant.identity);
    final conferenceRoom = ConferenceRoom.watch(context);
    final handRaisedIndex =
        conferenceRoom.handRaisedParticipants.indexOf(widget.participant);
    final isUpNext = isHandRaised && handRaisedIndex == 0;
    final isMobile = responsiveLayoutService.isMobile(context);

    return Align(
      alignment: Alignment.bottomLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isMobile && !audioEnabled && !_showName) ...[
            Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.scrim.withScrimOpacity,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(5),
                ),
              ),
              child: _buildMutedOverlayEntry(),
            ),
          ],
          Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: isMobile
                  ? _buildParticipantDetailsMobile()
                  : _buildParticipantDetails(),
            ),
          ),
          if (isDominant)
            _buildEndRowIcon(AppAsset.kSpeaking)
          else if (isUpNext)
            _buildEndRowIcon(AppAsset.kUpNext)
          else if (isHandRaised)
            _buildEndRowIcon(AppAsset.kHandRaise)
          else
            SizedBox(width: 3),
        ],
      ),
    );
  }

  Widget _buildEndRowIcon(AppAsset appAsset) {
    final size = responsiveLayoutService.isMobile(context) ? 28.0 : 52.0;
    final margin = responsiveLayoutService.isMobile(context) ? 4.0 : 8.0;
    return Padding(
      padding: EdgeInsets.only(right: margin, bottom: margin),
      child: ProxiedImage(null, asset: appAsset, width: size, height: size),
    );
  }

  Widget _buildParticipantDetailsMobile() {
    return _showName ? _buildParticipantDetails() : SizedBox.shrink();
  }

  Widget _buildParticipantDetails() {
    final showPin =
        context.watch<EventPermissionsProvider>().canPinItemInParticipantWidget;
    final showMute = context
        .watch<EventPermissionsProvider>()
        .canMuteParticipantInParticipantWidget(widget.participant.identity);
    final showKick = context
        .watch<EventPermissionsProvider>()
        .canKickParticipantInParticipantWidget(widget.participant.identity);

    return IntrinsicWidth(
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.scrim.withScrimOpacity,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: UserInfoBuilder(
                userId: widget.participant.identity,
                builder: (_, isLoading, snapshot) => HeightConstrainedText(
                  isLoading
                      ? 'Loading...'
                      : snapshot.data?.displayName ?? 'Participant',
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.body
                      .copyWith(color: context.theme.colorScheme.onPrimary),
                ),
              ),
            ),
            if (!audioEnabled) ...[
              SizedBox(width: 5),
              _buildMutedOverlayEntry(),
            ],
            SizedBox(width: 2),
            _ParticipantOptionsMenu(
              userId: widget.participant.identity,
              showPin: showPin,
              showMute: showMute,
              showKick: showKick,
              isVisible:
                  _showName || !responsiveLayoutService.isMobile(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showParticipantName() async {
    if (mounted) setState(() => _showName = true);
    _showParticipantTimer?.cancel();
    _showParticipantTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showName = false);
    });
  }

  Widget _buildVideoDisabled({bool switchedOff = false}) {
    final isConnecting =
        _isNewlyConnected || (_startedTimer?.isActive ?? false);
    final isMobile = responsiveLayoutService.isMobile(context);

    return Container(
      color: context.theme.colorScheme.surfaceContainerHigh,
      child: Container(
        padding: const EdgeInsets.all(8),
        alignment: Alignment.center,
        child: IntrinsicHeight(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: isMobile ? 16 : 30),
              Flexible(
                child: Container(
                  constraints: BoxConstraints(maxHeight: 200, maxWidth: 200),
                  child: UserProfileChip(
                    userId: widget.participant.identity,
                    showName: false,
                    enableOnTap: false,
                    imageHeight: 200,
                    alignment: Alignment.center,
                  ),
                ),
              ),
              if (!isMobile) SizedBox(height: 10),
              if (isConnecting)
                HeightConstrainedText(
                  'Connecting...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: isMobile ? 12 : 16,
                  ),
                )
              else if (switchedOff && (_startedTimer?.isActive ?? false))
                Container(
                  height: 20,
                  alignment: Alignment.center,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: CustomLoadingIndicator(),
                  ),
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HeightConstrainedText(
                      'Video Off',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: isMobile ? 12 : 16,
                      ),
                    ),
                    if (switchedOff) ...[
                      SizedBox(width: 6),
                      Icon(
                        Icons.wifi_off,
                        color: Theme.of(context).colorScheme.secondary,
                        size: isMobile ? 12 : 16,
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAspectRatioClipped(Widget child) {
    // ignore: parameter_assignments
    child = GlobalKeyedSubtree(
      label: '${widget.globalKey.distinctLabel}-aspect-ratio-clipped',
      child: child,
    );

    if (widget.isScreenShare) return child;

    if (widget.borderRadius != BorderRadius.zero) {
      // ignore: parameter_assignments
      child = ClipRRect(
        borderRadius: widget.borderRadius,
        child: child,
      );
    }

    return AspectRatio(
      aspectRatio: ParticipantWidget.aspectRatio,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = responsiveLayoutService.isMobile(context);

    return Listener(
      onPointerDown: isMobile ? (_) => _showParticipantName() : null,
      child: RepaintBoundary(
        child: _buildAspectRatioClipped(
          Container(
            color: Theme.of(context).primaryColor,
            child: Container(
              color: context.theme.colorScheme.scrim.withScrimOpacity,
              child: AnimatedBuilder(
                animation: widget.participant,
                builder: (_, __) => Stack(
                  children: [
                    Container(),
                    if (videoEnabled)
                      Positioned.fill(
                        child: _buildVideo(),
                      ),
                    if (!videoEnabled)
                      Positioned.fill(
                        child: _buildVideoDisabled(),
                      ),
                    _buildOverlay(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ParticipantOptionsMenu extends StatefulWidget {
  final String userId;
  final bool showPin;
  final bool showMute;
  final bool showKick;
  final bool isVisible;

  const _ParticipantOptionsMenu({
    required this.userId,
    required this.showPin,
    required this.showMute,
    required this.showKick,
    required this.isVisible,
  });

  @override
  State<_ParticipantOptionsMenu> createState() =>
      _ParticipantOptionsMenuState();
}

class _ParticipantOptionsMenuState extends State<_ParticipantOptionsMenu> {
  bool _isLoading = false;

  bool? _isPinnedLocal;
  bool _isHovered = false;

  final _menuKey = GlobalKey();

  List<PopupMenuEntry<Function()>> _getMenuItems({
    required BuildContext context,
  }) {
    final liveMeetingProvider = LiveMeetingProvider.read(context);
    final userId = widget.userId;
    final isPinned = _isPinnedLocal ??
        liveMeetingProvider.liveMeeting?.pinnedUserIds
            .any((id) => id == widget.userId) ??
        false;

    final liveMeeting = AgendaProvider.read(context).currentLiveMeeting!;

    final isCurrentUser = userId == userService.currentUserId;

    return [
      if (widget.showPin)
        PopupMenuItem<Function()>(
          value: _isLoading
              ? null
              : () => alertOnError(context, () async {
                    final pinned = liveMeeting.pinnedUserIds.toSet();
                    if (isPinned) {
                      pinned.remove(userId);
                    } else {
                      pinned.add(userId);
                    }
                    setState(() => _isLoading = true);
                    try {
                      await firestoreLiveMeetingService.update(
                        liveMeetingPath:
                            AgendaProvider.read(context).liveMeetingPath,
                        liveMeeting: liveMeeting.copyWith(
                          pinnedUserIds: pinned.toList(),
                        ),
                        keys: [LiveMeeting.kFieldPinnedUserIds],
                      );
                    } finally {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                    setState(() => _isPinnedLocal = !isPinned);
                  }),
          child: HeightConstrainedText(
            isPinned ? 'Unpin' : 'Pin',
            style: AppTextStyle.bodyMedium
                .copyWith(color: context.theme.colorScheme.primary),
          ),
        ),
      if (widget.showMute)
        PopupMenuItem<Function()>(
          value: () => alertOnError(
            context,
            () => liveMeetingProvider.mute(userId: userId),
          ),
          child: HeightConstrainedText(
            'Mute',
            style: AppTextStyle.bodyMedium
                .copyWith(color: context.theme.colorScheme.primary),
          ),
        ),
      if (widget.showKick)
        PopupMenuItem<Function()>(
          value: () => alertOnError(
            context,
            () => liveMeetingProvider.confirmProposeKick(userId),
          ),
          child: HeightConstrainedText(
            'Propose to remove user',
            style: AppTextStyle.bodyMedium
                .copyWith(color: context.theme.colorScheme.error),
          ),
        ),
      PopupMenuItem<Function()>(
        value: () => alertOnError(
          context,
          () => Dialogs.showAppDrawer(
            context,
            AppDrawerSide.right,
            ProfileTab(
              communityId: liveMeetingProvider.communityProvider.communityId,
              showTitle: true,
              allowEdit: isCurrentUser,
              currentUserId: userId,
            ),
          ),
        ),
        child: HeightConstrainedText(
          isCurrentUser ? 'Edit Profile' : 'View Profile',
          style: AppTextStyle.bodyMedium
              .copyWith(color: context.theme.colorScheme.primary),
        ),
      ),
    ];
  }

  Future<void> _showMoreMenu(List<PopupMenuEntry<Function()>> items) async {
    final button = _menuKey.currentContext?.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay?.context.findRenderObject() as RenderBox;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );
    final resultFunction = await showMenu<Function()>(
      context: context,
      position: position,
      items: items,
    );

    if (resultFunction != null) {
      resultFunction();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPinned = _isPinnedLocal ??
        LiveMeetingProvider.read(context)
            .liveMeeting
            ?.pinnedUserIds
            .any((id) => id == widget.userId) ??
        false;
    return Semantics(
      label: 'Participant Actions for user with ID ${widget.userId}',
      child: CustomInkWell(
        onTap: widget.isVisible
            ? () => _showMoreMenu(_getMenuItems(context: context))
            : null,
        onHover: widget.isVisible
            ? (isHovered) => setState(() => _isHovered = isHovered)
            : null,
        child: Container(
          key: _menuKey,
          padding: const EdgeInsets.all(5),
          child: Icon(
            isPinned ? Icons.push_pin : CupertinoIcons.ellipsis,
            size: 16,
            color: _isHovered
                ? context.theme.colorScheme.onSurface
                : context.theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
