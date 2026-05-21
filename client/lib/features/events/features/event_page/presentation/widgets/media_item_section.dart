import 'dart:async';

import 'package:client/features/events/features/live_meeting/features/live_stream/presentation/widgets/url_video_widget.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/widgets/vimeo_video_widget.dart';
import 'package:dotted_border/dotted_border.dart' as dotted_border;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:client/core/widgets/confirm_dialog.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/core/data/services/media_helper_service.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/events/media_item.dart';
import 'package:client/core/localization/localization_helper.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class MediaItemSection extends StatefulWidget {
  final MediaItem? mediaItem;
  final void Function() onDelete;
  final void Function(MediaItem) onUpdate;

  /// Called after a video upload or URL entry when the duration is known.
  final void Function(int durationInSeconds)? onVideoDurationDetected;

  const MediaItemSection({
    Key? key,
    required this.mediaItem,
    required this.onDelete,
    required this.onUpdate,
    this.onVideoDurationDetected,
  }) : super(key: key);

  @override
  State<MediaItemSection> createState() => _MediaItemSectionState();
}

class _MediaItemSectionState extends State<MediaItemSection> {
  late final TextEditingController _urlController;
  YoutubePlayerController? _youtubePlayerController;
  StreamSubscription<YoutubePlayerValue>? _youtubeStreamSubscription;
  String? _reportedDurationForVideoId;

  @override
  void initState() {
    super.initState();
    final existingUrl = widget.mediaItem?.url ?? '';
    _urlController = TextEditingController(
      text: _isExternalVideoUrl(existingUrl) ? existingUrl : '',
    );
  }

  @override
  void didUpdateWidget(MediaItemSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newUrl = widget.mediaItem?.url ?? '';
    if (_isExternalVideoUrl(newUrl) && _urlController.text != newUrl) {
      _urlController.text = newUrl;
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _youtubeStreamSubscription?.cancel();
    _youtubePlayerController?.close();
    super.dispose();
  }

  bool _isExternalVideoUrl(String url) {
    return url.contains('youtube.com') ||
        url.contains('youtu.be') ||
        url.contains('vimeo.com');
  }

  Future<void> _showMediaPickerDialog(BuildContext context) async {
    final result = await GetIt.instance<MediaHelperService>()
        .pickMediaViaCloudinaryWithDuration(
      uploadPreset: MediaHelperService.defaultMediaPreset,
    );

    if (result != null) {
      final isVideo = MediaHelperService.allowedVideoFormats
          .any((ext) => result.url.endsWith(ext));
      final mediaItem = MediaItem(
        url: result.url,
        type: isVideo ? MediaType.video : MediaType.image,
      );
      // Clear URL field when switching to a Cloudinary upload
      _urlController.clear();
      widget.onUpdate(mediaItem);
      if (isVideo && result.durationInSeconds != null) {
        widget.onVideoDurationDetected?.call(result.durationInSeconds!);
      }
    }
  }

  void _onUrlChanged(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return;

    final mediaHelperService = GetIt.instance<MediaHelperService>();
    final youtubeId = mediaHelperService.getYoutubeVideoId(trimmed);
    final vimeoId = mediaHelperService.getVimeoVideoId(trimmed);

    if (youtubeId != null || vimeoId != null) {
      widget.onUpdate(MediaItem(url: trimmed, type: MediaType.video));

      if (vimeoId != null) {
        _fetchVimeoDuration(vimeoId);
      }
      // YouTube duration is detected reactively via _attachYoutubeDurationListener
      // when the player renders.
    }
  }

  void _fetchVimeoDuration(String vimeoId) async {
    final seconds = await GetIt.instance<MediaHelperService>()
        .fetchVimeoDuration(vimeoId);
    if (!mounted || seconds == null) return;
    widget.onVideoDurationDetected?.call(seconds);
  }

  void _attachYoutubeDurationListener(
    YoutubePlayerController controller,
    String videoId,
  ) {
    _youtubeStreamSubscription?.cancel();

    if (_reportedDurationForVideoId == videoId) {
      _youtubeStreamSubscription = null;
      return;
    }

    void reportDuration(int seconds) {
      if (!mounted || _reportedDurationForVideoId == videoId) return;
      _youtubeStreamSubscription?.cancel();
      _youtubeStreamSubscription = null;
      _reportedDurationForVideoId = videoId;
      widget.onVideoDurationDetected?.call(seconds);
    }

    _youtubeStreamSubscription = controller.stream.listen((value) async {
      if (value.playerState == PlayerState.cued) {
        final seconds = await controller.duration;
        if (seconds > 0) reportDuration(seconds.round());
      } else if (value.metaData.duration > Duration.zero) {
        reportDuration(value.metaData.duration.inSeconds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const kDashPattern = <double>[10, 10];
    const kMediaSectionSize = Size(150, 100);

    final localMediaItem = widget.mediaItem;

    if (localMediaItem == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          dotted_border.DottedBorder(
            color: context.theme.colorScheme.primary,
            dashPattern: kDashPattern,
            child: CustomInkWell(
              onTap: () => _showMediaPickerDialog(context),
              child: Container(
                color: context.theme.colorScheme.surface,
                child: Row(
                  children: [
                    SizedBox.fromSize(
                      size: kMediaSectionSize,
                      child: Container(
                        color: context.theme.colorScheme.primary,
                        child: Icon(
                          Icons.upload,
                          size: 18,
                          color: context.theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.centerLeft,
                        child: HeightConstrainedText(
                          'Upload image or video',
                          style: context.theme.textTheme.bodyMedium!.copyWith(
                            color: context.theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
          _buildUrlField(context),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          dotted_border.DottedBorder(
            color: context.theme.colorScheme.primary,
            dashPattern: kDashPattern,
            child: Row(
              children: [
                SizedBox.fromSize(
                  size: kMediaSectionSize,
                  child: _buildMediaPreview(localMediaItem),
                ),
                Spacer(),
                Material(
                  color: context.theme.colorScheme.primary,
                  shape: CircleBorder(),
                  child: InkWell(
                    customBorder: CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.edit,
                        size: 20,
                        color: context.theme.colorScheme.onPrimary,
                      ),
                    ),
                    onTap: () => _showMediaPickerDialog(context),
                  ),
                ),
                SizedBox(width: 20),
                Material(
                  color: context.theme.colorScheme.primary,
                  shape: CircleBorder(),
                  child: InkWell(
                    customBorder: CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.delete,
                        size: 20,
                        color: context.theme.colorScheme.onPrimary,
                      ),
                    ),
                    onTap: () {
                      ConfirmDialog(
                        title: context.l10n.confirmDeleteMedia,
                        cancelText: context.l10n.cancel,
                        onConfirm: (_) {
                          Navigator.pop(context);
                          _urlController.clear();
                          widget.onDelete();
                        },
                      ).show();
                    },
                  ),
                ),
                SizedBox(width: 40),
              ],
            ),
          ),
          if (_isExternalVideoUrl(localMediaItem.url)) ...[
            SizedBox(height: 8),
            _buildUrlField(context),
          ],
        ],
      );
    }
  }

  Widget _buildUrlField(BuildContext context) {
    return CustomTextField(
      controller: _urlController,
      hintText: 'Or paste a YouTube / Vimeo URL',
      borderType: BorderType.outline,
      borderRadius: 8,
      maxLines: 1,
      onChanged: _onUrlChanged,
      textStyle: context.theme.textTheme.bodyMedium
          ?.copyWith(color: context.theme.colorScheme.onSurface),
    );
  }

  Widget _buildMediaPreview(MediaItem mediaItem) {
    final url = mediaItem.url;
    final mediaHelperService = GetIt.instance<MediaHelperService>();

    final youtubeId = mediaHelperService.getYoutubeVideoId(url);
    if (youtubeId != null) {
      return Builder(
        builder: (context) {
          _youtubePlayerController = YoutubePlayerController.fromVideoId(
            videoId: youtubeId,
            params: YoutubePlayerParams(showControls: false),
          );
          _attachYoutubeDurationListener(_youtubePlayerController!, youtubeId);
          return YoutubePlayer(
            controller: _youtubePlayerController!,
            aspectRatio: 16 / 9,
          );
        },
      );
    }

    final vimeoId = mediaHelperService.getVimeoVideoId(url);
    if (vimeoId != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: VimeoVideoWidget(vimeoId: vimeoId),
      );
    }

    switch (mediaItem.type) {
      case MediaType.image:
        return ProxiedImage(url, fit: BoxFit.cover);
      case MediaType.video:
        return UrlVideoWidget(playbackUrl: url, autoplay: false);
    }
  }
}
