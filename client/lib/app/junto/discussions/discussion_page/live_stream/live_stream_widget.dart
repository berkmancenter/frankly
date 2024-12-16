import 'dart:async';

import 'package:flutter/material.dart';
import 'package:junto/app/junto/community_permissions_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/live_meeting_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_stream/live_stream_instructions.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_stream/url_video_widget.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/junto_app.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto/utils/platform_utils.dart';
import 'package:provider/provider.dart';

class LiveStreamWidget extends StatefulWidget {
  const LiveStreamWidget({Key? key}) : super(key: key);

  @override
  _LiveStreamWidgetState createState() => _LiveStreamWidgetState();
}

class _LiveStreamWidgetState extends State<LiveStreamWidget> {
  late StreamSubscription _discussionSubscription;
  bool _currentlyPlayingLiveStream = false;

  bool get _showLiveStream {
    final liveStreamInfo = DiscussionProvider.watch(context).discussion.liveStreamInfo;
    return liveStreamInfo?.muxStatus == 'active' ||
        (_currentlyPlayingLiveStream && !(liveStreamInfo?.resetStream ?? false));
  }

  @override
  void initState() {
    super.initState();

    _discussionSubscription =
        DiscussionProvider.read(context).discussionStream.listen((discussion) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();

    _discussionSubscription.cancel();
  }

  Widget _buildWaitingScreen() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColor.white,
      ),
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
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
            child: JuntoText(
              DiscussionProvider.watch(context)
                      .discussion
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
    final streamInfo = DiscussionProvider.read(context).discussion.liveStreamInfo;

    final playbackId = streamInfo?.muxPlaybackId;

    final url = 'https://stream.mux.com/$playbackId.m3u8';
    if (_showLiveStream) {
      _currentlyPlayingLiveStream = true;
      return RefreshKeyWidget(
        backgroundColor: AppColor.black,
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
          if (Provider.of<CommunityPermissionsProvider>(context).canEditCommunity &&
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
            child: JuntoPointerInterceptor(
              child: JuntoInkWell(
                onTap: () {
                  liveMeetingProvider.refreshMeeting();
                  () => setState(() => _randomKey = uuid.v1());
                },
                child: Container(
                  padding: EdgeInsets.all(4),
                  color: widget.backgroundColor ?? Color(0xFF262F4C),
                  child: Icon(Icons.refresh, size: 24, color: AppColor.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
