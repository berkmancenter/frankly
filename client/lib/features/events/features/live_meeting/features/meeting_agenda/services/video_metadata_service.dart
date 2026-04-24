import 'package:video_player/video_player.dart';

/// Service to fetch video metadata like duration
class VideoMetadataService {
  /// Fetches the duration of a video from a URL.
  /// Returns the duration in seconds, or null if unable to fetch.
  Future<int?> getVideoDurationInSeconds(String videoUrl) async {
    if (videoUrl.isEmpty) {
      return null;
    }

    try {
      final controller = VideoPlayerController.network(videoUrl);
      await controller.initialize();
      final duration = controller.value.duration;
      await controller.dispose();

      if (duration.inSeconds > 0) {
        return duration.inSeconds;
      }
    } catch (e) {
      // If we can't fetch duration (e.g., video not accessible, cors issues),
      // just return null and let the user set it manually
      return null;
    }

    return null;
  }
}
