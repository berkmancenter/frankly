import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/live_meeting_provider.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/firestore/media_item.dart';

class WaitingRoomPresenter with ChangeNotifier {
  final JuntoProvider juntoProvider;
  final DiscussionProvider discussionProvider;
  final LiveMeetingProvider liveMeetingProvider;

  /// The amount of time that the intro video should be fast forwarded to.
  ///
  /// This helps the intro video be treated as more of a livestream where everyone is at roughly
  /// the same spot in the video.
  Duration? _introVideoStartTime;
  bool _introVideoCompleted = false;

  WaitingRoomPresenter({
    required this.juntoProvider,
    required this.discussionProvider,
    required this.liveMeetingProvider,
  });

  /// Indicates if the intro video should be fast forwarded in order to keep the user in sync.
  ///
  /// This happens if the user enters the room after the video was supposed to start.
  Duration? get introVideoStartTime => _introVideoStartTime;

  void initialize() {
    final timeUntilScheduledStart =
        discussionProvider.discussion.timeUntilScheduledStart(clockService.now());
    if (isWaitingRoomMediaIntro && timeUntilScheduledStart.isNegative) {
      /// We start the intro video at however long past the scheduled start time we are.
      _introVideoStartTime = timeUntilScheduledStart.abs();
    }
  }

  void update() {
    notifyListeners();
  }

  /// Indicates if the current waiting room media is the preroll media, or the intro media
  bool get isWaitingRoomMediaIntro {
    return discussionProvider.discussion.timeUntilScheduledStart(clockService.now()).isNegative;
  }

  bool get loopVideo {
    final waitingRoomInfo = discussionProvider.discussion.waitingRoomInfo;
    return !isWaitingRoomMediaIntro && (waitingRoomInfo?.loopWaitingVideo ?? false);
  }

  MediaItem get media {
    final waitingRoomInfo = discussionProvider.discussion.waitingRoomInfo;
    final mediaItem = isWaitingRoomMediaIntro
        ? waitingRoomInfo?.introMediaItem
        : waitingRoomInfo?.waitingMediaItem;

    final juntoImageUrl = juntoProvider.junto.profileImageUrl;
    final discussionImageUrl = discussionProvider.discussion.image;

    // After the intro video is completed, we override the image.
    final isCompletedIntroVideo = _introVideoCompleted && isWaitingRoomMediaIntro;
    if (isCompletedIntroVideo && juntoImageUrl != null && juntoImageUrl.isNotEmpty) {
      return MediaItem(
        type: MediaType.image,
        url: juntoImageUrl,
      );
    } else if (mediaItem != null) {
      return mediaItem;
    } else if (discussionImageUrl != null && discussionImageUrl.isNotEmpty) {
      return MediaItem(
        type: MediaType.image,
        url: discussionImageUrl,
      );
    } else {
      return MediaItem(
        type: MediaType.image,
        url: generateRandomImageUrl(seed: discussionProvider.discussion.id.hashCode),
      );
    }
  }

  void onIntroVideoCompleted() {
    _introVideoCompleted = true;
    notifyListeners();
  }
}
