import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:client/features/events/features/live_meeting/features/video/presentation/views/video_flutter_meeting.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/localization/localization_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:client/features/events/features/event_page/data/providers/event_permissions_provider.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/live_meeting/data/providers/live_meeting_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/data/providers/meeting_guide_card_store.dart';
import 'package:client/features/events/features/live_meeting/features/video/data/providers/conference_room.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/providers/meeting_agenda_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/features/user/presentation/views/profile_tab.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/features/user/data/providers/user_info_builder.dart';
import 'package:client/features/user/presentation/widgets/user_profile_chip.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/core/utils/dialogs.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:provider/provider.dart';

import '../../data/providers/agora_room.dart';

const kParticipantVideoWidgetDimensions = Size(854.0, 480.0);

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
  const ParticipantWidget({
    required this.globalKey,
    required this.participant,
    this.isScreenShare = false,
    this.borderRadius = BorderRadius.zero,
  }) : super(key: globalKey);

  static final aspectRatio = Size(4, 3).aspectRatio;

  final CommunityGlobalKey globalKey;
  final AgoraParticipant participant;
  final bool isScreenShare;
  final BorderRadius borderRadius;

  @override
  ParticipantWidgetState createState() => ParticipantWidgetState();
}

class ParticipantWidgetState extends State<ParticipantWidget> {
  Timer? _startedTimer;
  Timer? _showParticipantTimer;

  ConferenceRoom get conferenceRoom => ConferenceRoom.watch(context);

  late final VideoViewController? videoViewController;
  bool isVideoViewInitialized = false;

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
  void initState() {
    super.initState();
    if (widget.participant is FakeParticipant) {
      videoViewController = null;
      isVideoViewInitialized = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isVideoViewInitialized) {
      if (!widget.participant.isLocal) {
        videoViewController = VideoViewController.remote(
          rtcEngine: conferenceRoom.room!.engine,
          canvas: VideoCanvas(uid: widget.participant.agoraUid),
          connection: RtcConnection(channelId: conferenceRoom.roomName),
        );
      } else {
        videoViewController = VideoViewController(
          rtcEngine: conferenceRoom.room!.engine,
          // The local Agora user's UID is set to 0.
          canvas: VideoCanvas(uid: 0),
        );
      }
      isVideoViewInitialized = true;
    }
    if (isStarted) {
      _startedTimer ??= Timer(Duration(seconds: 2), () => setState(() {}));
    }
  }

  @override
  void dispose() {
    loggingService
        .log('disposing ${widget.participant.userId} videoViewController');
    videoViewController?.dispose();
    _startedTimer?.cancel();
    _showParticipantTimer?.cancel();
    super.dispose();
  }

  Future<void> _showParticipantName() async {
    if (mounted) setState(() => _showName = true);
    _showParticipantTimer?.cancel();
    _showParticipantTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showName = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = responsiveLayoutService.isMobile(context);

    return Listener(
      onPointerDown: isMobile ? (_) => _showParticipantName() : null,
      child: Stack(
        children: [
          Container(
            color: context.theme.colorScheme.surfaceContainerHighest,
            child: (!videoEnabled)
                ? _DisabledVideoWidget(
                    participant: widget.participant,
                    isNewlyConnected: _isNewlyConnected,
                    isRemote: isRemote,
                    startedTimer: _startedTimer,
                  )
                : widget.participant is FakeParticipant ||
                        videoViewController == null
                    ? Container(color: Colors.orange)
                    : AgoraVideoView(
                        controller: videoViewController!,
                      ),
          ),
          _VideoOverlayWidget(
            participant: widget.participant,
            showName: _showName,
            audioEnabled: audioEnabled,
            isDominant: isDominant,
          ),
        ],
      ),
    );
  }
}

class _DisabledVideoWidget extends StatelessWidget {
  const _DisabledVideoWidget({
    super.key,
    required this.participant,
    required this.isNewlyConnected,
    required this.didReceiveFrames,
    required this.isRemote,
    required this.startedTimer,
  });

  final AgoraParticipant participant;
  final bool isNewlyConnected;
  final bool didReceiveFrames;
  final bool isRemote;
  final Timer? startedTimer;

  @override
  Widget build(BuildContext context) {
    final isConnecting = isNewlyConnected || (startedTimer?.isActive ?? false);
    final isMobile = responsiveLayoutService.isMobile(context);

    return Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
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
                userId: participant.identity,
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
          else if (!didReceiveFrames && isRemote)
            HeightConstrainedText(
              'No video received',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.theme.colorScheme.secondary,
                fontSize: isMobile ? 12 : 16,
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
              ],
            ),
        ],
      ),
    );
  }
}

class _VideoOverlayWidget extends StatelessWidget {
  const _VideoOverlayWidget({
    super.key,
    required this.participant,
    required this.showName,
    required this.audioEnabled,
    required this.isDominant,
  });

  final AgoraParticipant participant;
  final bool showName;
  final bool audioEnabled;
  final bool isDominant;

  @override
  Widget build(BuildContext context) {
    final bool isHandRaised = Provider.of<MeetingGuideCardStore>(context)
        .getHandIsRaised(participant.identity);
    final conferenceRoom = ConferenceRoom.watch(context);
    final handRaisedIndex =
        conferenceRoom.handRaisedParticipants.indexOf(participant);
    final isUpNext = isHandRaised && handRaisedIndex == 0;
    final isMobile = responsiveLayoutService.isMobile(context);

    final showPin =
        context.watch<EventPermissionsProvider>().canPinItemInParticipantWidget;
    final showMute = context
        .watch<EventPermissionsProvider>()
        .canMuteParticipantInParticipantWidget(participant.identity);
    final showKick = context
        .watch<EventPermissionsProvider>()
        .canKickParticipantInParticipantWidget(participant.identity);

    return Align(
      alignment: Alignment.bottomLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isMobile && !audioEnabled && !showName) ...[
            Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: context.theme.colorScheme.scrim.withScrimOpacity,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(5),
                ),
              ),
              child: Icon(
                Icons.mic_off_outlined,
                color: context.theme.colorScheme.error,
                size: 17,
              ),
            ),
          ],
          Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: isMobile && !showName
                  ? const SizedBox.shrink()
                  : Container(
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
                              userId: participant.identity,
                              builder: (_, isLoading, snapshot) =>
                                  HeightConstrainedText(
                                isLoading
                                    ? 'Loading...'
                                    : snapshot.data?.displayName ??
                                        'Participant',
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyle.body.copyWith(
                                  color: context.theme.colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                          if (!audioEnabled) ...[
                            SizedBox(width: 5),
                            Icon(
                              Icons.mic_off_outlined,
                              color: context.theme.colorScheme.error,
                              size: 17,
                            ),
                          ],
                          SizedBox(width: 2),
                          _ParticipantOptionsMenu(
                            userId: participant.identity,
                            showPin: showPin,
                            showMute: showMute,
                            showKick: showKick,
                            isVisible: showName ||
                                !responsiveLayoutService.isMobile(context),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          if (isDominant)
            _EndRowIcon(asset: AppAsset.kSpeaking)
          else if (isUpNext)
            _EndRowIcon(asset: AppAsset.kUpNext)
          else if (isHandRaised)
            _EndRowIcon(asset: AppAsset.kHandRaise)
          else
            SizedBox(width: 3),
        ],
      ),
    );
  }
}

class _EndRowIcon extends StatelessWidget {
  const _EndRowIcon({
    super.key,
    required this.asset,
  });

  final AppAsset asset;

  @override
  Widget build(BuildContext context) {
    final size = responsiveLayoutService.isMobile(context) ? 28.0 : 52.0;
    final margin = responsiveLayoutService.isMobile(context) ? 4.0 : 8.0;
    return Padding(
      padding: EdgeInsets.only(right: margin, bottom: margin),
      child: ProxiedImage(null, asset: asset, width: size, height: size),
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
      label: context.l10n.participantActionsForUserWithId(widget.userId ?? ''),
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
