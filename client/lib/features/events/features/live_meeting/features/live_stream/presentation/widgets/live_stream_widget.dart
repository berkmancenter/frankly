import 'dart:async';

import 'package:flutter/material.dart';
import 'package:client/features/community/data/providers/community_permissions_provider.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/live_meeting/data/providers/live_meeting_provider.dart';
import 'package:client/features/events/features/live_meeting/features/live_stream/presentation/widgets/live_stream_instructions.dart';
import 'package:client/features/events/features/live_meeting/features/live_stream/presentation/widgets/url_video_widget.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/app.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/core/utils/platform_utils.dart';
import 'package:provider/provider.dart';

class LiveStreamWidget extends StatefulWidget {
  const LiveStreamWidget({Key? key}) : super(key: key);

  @override
  _LiveStreamWidgetState createState() => _LiveStreamWidgetState();
}

class _LiveStreamWidgetState extends State<LiveStreamWidget> {
  late StreamSubscription _eventSubscription;
  bool _currentlyPlayingLiveStream = false;

  bool get _showLiveStream {
    final liveStreamInfo = EventProvider.watch(context).event.liveStreamInfo;
    return liveStreamInfo?.muxStatus == 'active' ||
        (_currentlyPlayingLiveStream &&
            !(liveStreamInfo?.resetStream ?? false));
  }

  @override
  void initState() {
    super.initState();

    _eventSubscription =
        EventProvider.read(context).eventStream.listen((event) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();

    _eventSubscription.cancel();
  }

  Widget _buildWaitingScreen() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: context.theme.colorScheme.surfaceContainerLowest,
      ),
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
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
            child: HeightConstrainedText(
              EventProvider.watch(context)
                      .event
                      .liveStreamInfo
                      ?.liveStreamWaitingTextOverride ??
                  'Stream will show here when it is active.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    final streamInfo = EventProvider.read(context).event.liveStreamInfo;

    final playbackId = streamInfo?.muxPlaybackId;

    final url = 'https://stream.mux.com/$playbackId.m3u8';
    if (_showLiveStream) {
      _currentlyPlayingLiveStream = true;
      return RefreshKeyWidget(
        backgroundColor: context.theme.colorScheme.primary,
        child: UrlVideoWidget(
          playbackUrl: url,
          playbackType: 'application/x-mpegURL',
          showControls: false,
          refreshOnError: true,
          onEnded: () => setState(() => _currentlyPlayingLiveStream = false),
        ),
      );
    } else {
      return _buildWaitingScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          if (Provider.of<CommunityPermissionsProvider>(context)
                  .canEditCommunity &&
              !_showLiveStream)
            LiveStreamInstructions(),
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }
}

class RefreshKeyWidget extends StatefulWidget {
  final Color? backgroundColor;
  final Widget child;

  const RefreshKeyWidget({
    Key? key,
    this.backgroundColor,
    required this.child,
  }) : super(key: key);

  @override
  _RefreshKeyWidgetState createState() => _RefreshKeyWidgetState();
}

class _RefreshKeyWidgetState extends State<RefreshKeyWidget> {
  String _randomKey = uuid.v1();

  @override
  Widget build(BuildContext context) {
    final liveMeetingProvider = LiveMeetingProvider.watch(context);
    return Stack(
      children: [
        KeyedSubtree(
          key: Key(_randomKey),
          child: SizedBox.expand(
            child: widget.child,
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Tooltip(
            message: 'Refresh Connection',
            child: CustomPointerInterceptor(
              child: CustomInkWell(
                onTap: () {
                  liveMeetingProvider.refreshMeeting();
                  () => setState(() => _randomKey = uuid.v1());
                },
                child: Container(
                  padding: EdgeInsets.all(4),
                  color: widget.backgroundColor ??
                      context.theme.colorScheme.primary,
                  child: Icon(
                    Icons.refresh,
                    size: 24,
                    color: context.theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
