import 'dart:async';

import 'package:client/core/utils/image_utils.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/live_meeting/data/providers/live_meeting_provider.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/services.dart';
import 'package:data_models/events/media_item.dart';
import 'package:flutter/material.dart';

class WaitingRoomPresenter with ChangeNotifier {
  final CommunityProvider communityProvider;
  final EventProvider eventProvider;
  final LiveMeetingProvider liveMeetingProvider;

  /// The amount of time that the intro video should be fast forwarded to.
  ///
  /// This helps the intro video be treated as more of a livestream where everyone is at roughly
  /// the same spot in the video.
  Duration? _introVideoStartTime;
  bool _introVideoCompleted = false;
  Timer? _introTransitionTimer;

  WaitingRoomPresenter({
    required this.communityProvider,
    required this.eventProvider,
    required this.liveMeetingProvider,
  });

  /// Indicates if the intro video should be fast forwarded in order to keep the user in sync.
  ///
  /// This happens if the user enters the room after the video was supposed to start.
  Duration? get introVideoStartTime => _introVideoStartTime;

  void _logTransition(String label, {bool? wasIntroVideo, String? playbackUrl}) {
    final now = clockService.now();
    final timeUntilScheduledStart =
        eventProvider.event.timeUntilScheduledStart(now);
    loggingService.log(
      '[TEMP waiting-room] $label '
      'now=$now '
      'scheduledTime=${eventProvider.event.scheduledTime} '
      'timeUntilScheduledStart=${timeUntilScheduledStart.inMilliseconds}ms '
      'isWaitingRoomMediaIntro=$isWaitingRoomMediaIntro '
      'wasIntroVideo=$wasIntroVideo '
      'introVideoStartTime=$_introVideoStartTime '
      'introVideoCompleted=$_introVideoCompleted '
      'playbackUrl=$playbackUrl',
    );
  }

  void initialize() {
    _logTransition('initialize:start');
    _configureIntroTransition();
    _logTransition('initialize:end');
  }

  void _configureIntroTransition() {
    _logTransition('configureIntroTransition:start');
    _introTransitionTimer?.cancel();

    final timeUntilScheduledStart =
        eventProvider.event.timeUntilScheduledStart(clockService.now());
    if (isWaitingRoomMediaIntro && timeUntilScheduledStart.isNegative) {
      /// We start the intro video at however long past the scheduled start time we are.
      _introVideoStartTime = timeUntilScheduledStart.abs();
      _logTransition('configureIntroTransition:alreadyInIntro');
      return;
    }

    _introVideoStartTime = null;

    if (!timeUntilScheduledStart.isNegative) {
      _introTransitionTimer = Timer(timeUntilScheduledStart, () {
        _logTransition('configureIntroTransition:timerFired:beforeNotify');
        _introVideoStartTime = Duration.zero;
        notifyListeners();
        _logTransition('configureIntroTransition:timerFired:afterNotify');
      });
      _logTransition(
        'configureIntroTransition:timerScheduled',
      );
    }

    _logTransition('configureIntroTransition:end');
  }

  void update() {
    _logTransition('update:start');
    _configureIntroTransition();
    notifyListeners();
    _logTransition('update:end');
  }

  /// Indicates if the current waiting room media is the preroll media, or the intro media
  bool get isWaitingRoomMediaIntro {
    return eventProvider.event
        .timeUntilScheduledStart(clockService.now())
        .isNegative;
  }

  bool get loopVideo {
    final waitingRoomInfo = eventProvider.event.waitingRoomInfo;
    return !isWaitingRoomMediaIntro &&
        (waitingRoomInfo?.loopWaitingVideo ?? false);
  }

  MediaItem get media {
    final waitingRoomInfo = eventProvider.event.waitingRoomInfo;
    final mediaItem = isWaitingRoomMediaIntro
        ? waitingRoomInfo?.introMediaItem
        : waitingRoomInfo?.waitingMediaItem;

    final communityImageUrl = communityProvider.community.profileImageUrl;
    final eventImageUrl = eventProvider.event.image;

    // After the intro video is completed, we override the image.
    final isCompletedIntroVideo =
        _introVideoCompleted && isWaitingRoomMediaIntro;
    if (isCompletedIntroVideo &&
        communityImageUrl != null &&
        communityImageUrl.isNotEmpty) {
      return MediaItem(
        type: MediaType.image,
        url: communityImageUrl,
      );
    } else if (mediaItem != null) {
      return mediaItem;
    } else if (eventImageUrl != null && eventImageUrl.isNotEmpty) {
      return MediaItem(
        type: MediaType.image,
        url: eventImageUrl,
      );
    } else {
      return MediaItem(
        type: MediaType.image,
        url: generateRandomImageUrl(
          seed: eventProvider.event.id.hashCode,
        ),
      );
    }
  }

  void onVideoEnded({required bool wasIntroVideo}) {
    _logTransition('onVideoEnded:start', wasIntroVideo: wasIntroVideo);
    if (wasIntroVideo) {
      _introVideoCompleted = true;
      notifyListeners();
      _logTransition('onVideoEnded:intro:afterNotify', wasIntroVideo: wasIntroVideo);
      return;
    }

    final timeUntilScheduledStart =
        eventProvider.event.timeUntilScheduledStart(clockService.now());
    if (timeUntilScheduledStart.isNegative) {
      _introVideoStartTime = timeUntilScheduledStart.abs();
      notifyListeners();
      _logTransition('onVideoEnded:waitingToIntro:afterNotify', wasIntroVideo: wasIntroVideo);
      return;
    }

    _logTransition('onVideoEnded:waiting:beforeScheduledStartNoTransition', wasIntroVideo: wasIntroVideo);
  }

  void onVideoReady({required bool wasIntroVideo, required String playbackUrl}) {
    _logTransition(
      'onVideoReady',
      wasIntroVideo: wasIntroVideo,
      playbackUrl: playbackUrl,
    );
  }

  @override
  void dispose() {
    _introTransitionTimer?.cancel();
    super.dispose();
  }
}
