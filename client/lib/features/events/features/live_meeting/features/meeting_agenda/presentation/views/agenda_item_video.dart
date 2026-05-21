import 'dart:async';

import 'package:client/features/events/features/live_meeting/features/meeting_agenda/utils/agenda_utils.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:client/features/events/features/live_meeting/features/live_stream/presentation/widgets/url_video_widget.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/views/agenda_item_video_contract.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_video_data.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_video_model.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/agenda_item_video_presenter.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/widgets/vimeo_video_widget.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/core/data/services/media_helper_service.dart';
import 'package:client/styles/app_asset.dart';
import 'package:data_models/events/event.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:client/core/localization/localization_helper.dart';

enum AgendaItemVideoTabType {
  /// Locally picked video from a file.
  local,

  /// Youtube URL.
  youtube,

  /// Vimeo URL.
  vimeo,

  /// URL from unknown source.
  url,
}

class AgendaItemVideo extends StatefulWidget {
  final bool isEditMode;
  final AgendaItemVideoData agendaItemVideoData;
  final void Function(AgendaItemVideoData) onChanged;

  /// Called after a direct Cloudinary upload when the video duration is known.
  /// Not called for YouTube/Vimeo/external URLs where duration is unavailable at upload time.
  final void Function(int durationInSeconds)? onVideoDurationDetected;

  const AgendaItemVideo({
    Key? key,
    required this.isEditMode,
    required this.agendaItemVideoData,
    required this.onChanged,
    this.onVideoDurationDetected,
  }) : super(key: key);

  @override
  _AgendaItemVideoState createState() => _AgendaItemVideoState();
}

class _AgendaItemVideoState extends State<AgendaItemVideo>
    with TickerProviderStateMixin
    implements AgendaItemVideoView {
  late List<AgendaItemVideoTabType> _agendaItemVideoTabTypes;
  late TextEditingController _textEditingController;
  late TabController _tabController;
  YoutubePlayerController? _youtubePlayerController;
  StreamSubscription<YoutubePlayerValue>? _youtubeStreamSubscription;
  // Tracks whether the duration callback has already fired for a video ID so
  // it doesn't fire again if the controller is recreated on a rebuild.
  String? _reportedDurationForVideoId;
  late VideoPlayerController _videoController;

  late AgendaItemVideoModel _model;
  late AgendaItemVideoPresenter _presenter;
  bool _presenterInitialized = false;

  void _init() {
    if (_presenterInitialized) {
      _presenter.dispose();
    }
    _model = AgendaItemVideoModel(
      widget.isEditMode,
      widget.agendaItemVideoData,
      widget.onChanged,
    );
    _presenter = AgendaItemVideoPresenter(context, this, _model);
    _presenterInitialized = true;
    _presenter.init();

    // Only temporarily made solution. Once we get rid of the flag, we should only read from
    // AgendaItemVideoTabType.values.
    _agendaItemVideoTabTypes = _presenter.isMultipleVideoTypesEnabled()
        ? AgendaItemVideoTabType.values
        : [AgendaItemVideoTabType.local, AgendaItemVideoTabType.url];

    final String url = _model.agendaItemVideoData.url;
    _updateTextInController(url);

    _videoController = VideoPlayerController.network(url);
    final initialIndex = _presenter.getInitialIndex();
    _tabController = TabController(
      initialIndex: initialIndex,
      length: _agendaItemVideoTabTypes.length,
      vsync: this,
    );
  }

  void _updateTextInController(String text) {
    _textEditingController.text = text;
    _textEditingController.selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    );
  }

  @override
  void initState() {
    super.initState();

    _textEditingController =
        TextEditingController(text: widget.agendaItemVideoData.url);
    _init();
  }

  @override
  void didUpdateWidget(AgendaItemVideo oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isEditMode != widget.isEditMode ||
        oldWidget.agendaItemVideoData != widget.agendaItemVideoData) {
      _init();
    }
  }

  @override
  void dispose() {
    _presenter.dispose();
    _youtubeStreamSubscription?.cancel();
    _videoController.dispose();
    _youtubePlayerController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const kMaxHeight = 500.0;
    final videoUrl = _presenter.getVideoUrl();
    final isMultipleVideoTypesEnabled =
        _presenter.isMultipleVideoTypesEnabled();

    if (_model.isEditMode) {
      return Column(
        children: [
          CustomTextField(
            initialValue: _model.agendaItemVideoData.title,
            labelText: 'Title',
            hintText: context.l10n.enterVideoTitle,
            maxLines: 1,
            maxLength: agendaTitleCharactersLength,
            counterStyle: context.theme.textTheme.bodySmall,
            onChanged: (value) => _presenter.updateVideoTitle(value),
          ),
          SizedBox(height: 40),
          Row(
            children: List.generate(_agendaItemVideoTabTypes.length, (index) {
              final agendaItemVideoTabType = _agendaItemVideoTabTypes[index];
              final isSelected =
                  _model.agendaItemVideoTabType == agendaItemVideoTabType;
              final color = isSelected
                  ? context.theme.colorScheme.primary
                  : context.theme.colorScheme.onSurface.withOpacity(0.38);
              final tabName = _presenter.getTabName(agendaItemVideoTabType);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      _presenter.updateVideoType(agendaItemVideoTabType);
                      _tabController.animateTo(index);
                    },
                    child: Column(
                      children: [
                        Text(
                          tabName,
                          style: context.theme.textTheme.labelMedium!
                              .copyWith(color: color),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Container(height: 4, color: color),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: kMaxHeight),
            child: TabBarView(
              controller: _tabController,
              physics: NeverScrollableScrollPhysics(),
              children: isMultipleVideoTypesEnabled
                  ? [
                      _buildLocalVideo(videoUrl),
                      _buildYoutube(videoUrl),
                      _buildVimeo(videoUrl),
                      _buildUrlVideo(videoUrl),
                    ]
                  : [
                      _buildLocalVideo(videoUrl),
                      _buildUrlVideo(videoUrl),
                    ],
            ),
          ),
        ],
      );
    } else {
      // Replace '/upload' in the URL with '/upload/q_auto:good' for Cloudinary optimization, if not present
      final optimizedUrl = videoUrl.replaceFirst('/upload', '/upload/q_auto:good');
      return _buildInitializedVideo(!videoUrl.contains('/upload/q_auto:good') ? optimizedUrl : videoUrl);

    }
  }

  @override
  void updateView() {
    setState(() {});
  }

  @override
  void notifyVideoDurationDetected(int seconds) {
    if (!mounted) return;
    widget.onVideoDurationDetected?.call(seconds);
  }

  /// Subscribes to a YouTube controller's stream to fire [onVideoDurationDetected]
  /// once when the player reports a non-zero duration.
  ///
  /// Always resubscribes to the supplied [controller] (the Builder may produce a
  /// fresh instance on each rebuild) but won't fire the callback again if the
  /// same [videoId] already reported a duration.
  ///
  /// Two detection paths:
  ///  1. [PlayerState.cued] — calls [YoutubePlayerController.duration] directly;
  ///     works in Chrome even without playback (metadata loaded eagerly).
  ///  2. [YoutubePlayerValue.metaData.duration] — fallback populated by the
  ///     event handler only after the video actually plays.
  void _attachYoutubeDurationListener(
    YoutubePlayerController controller,
    String videoId,
  ) {
    // Always cancel the old subscription — it may be targeting a stale controller.
    _youtubeStreamSubscription?.cancel();

    // Don't fire the callback again for the same video.
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
        // getDuration() works for cued videos in Chrome (metadata loaded eagerly).
        final seconds = await controller.duration;
        if (seconds > 0) reportDuration(seconds.round());
      } else if (value.metaData.duration > Duration.zero) {
        // Fallback: metaData is populated by the event handler once playing.
        reportDuration(value.metaData.duration.inSeconds);
      }
    });
  }

  Widget _buildVideoPicker(String text) {
    return ActionButton(
      text: text,
      onPressed: () async {
        final result =
            await GetIt.instance<MediaHelperService>().pickVideoViaCloudinary();
        if (result != null) {
          _updateTextInController(result.url);
          _presenter.updateVideoUrl(result.url);
          if (result.durationInSeconds != null) {
            widget.onVideoDurationDetected?.call(result.durationInSeconds!);
          }
        }
      },
    );
  }

  Widget _buildInitializedVideo(String videoUrl) {
    switch (_model.agendaItemVideoData.type) {
      case AgendaItemVideoType.youtube:
        final youtubeVideoId = _presenter.getYoutubeVideoId(videoUrl);
        if (youtubeVideoId != null) {
          return Builder(
            builder: (context) {
              _youtubePlayerController = YoutubePlayerController.fromVideoId(
                videoId: youtubeVideoId,
                params: YoutubePlayerParams(showControls: true),
              );

              return YoutubePlayer(
                controller: _youtubePlayerController!,
                aspectRatio: 16 / 9,
              );
            },
          );
        } else {
          return Text(context.l10n.youtubeVideoLookupFailed);
        }
      case AgendaItemVideoType.vimeo:
        final vimeoVideoId = _presenter.getVimeoVideoId(videoUrl);

        if (vimeoVideoId != null) {
          return AspectRatio(
            aspectRatio: 16 / 9,
            child: VimeoVideoWidget(vimeoId: vimeoVideoId),
          );
        } else {
          return Text(context.l10n.vimeoVideoLookupFailed);
        }
      case AgendaItemVideoType.url:
        return AspectRatio(
          aspectRatio: 16 / 9,
          child: UrlVideoWidget(
            playbackUrl: videoUrl,
            autoplay: false,
          ),
        );
    }
  }

  Widget _buildLocalVideo(String videoUrl) {
    final isVideoUploaded = _presenter.isValidVideo();

    if (isVideoUploaded) {
      return UrlVideoWidget(playbackUrl: videoUrl, autoplay: false);
    } else {
      return Column(
        children: [
          SizedBox(height: 20),
          Expanded(
            child: Container(
              color: context.theme.colorScheme.surface,
              child: Center(
                child: _buildVideoPicker('Upload Video'),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildVideoDurationReminder() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: context.theme.colorScheme.secondary),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              'Remember to set the slot time to match the video length.',
              style: context.theme.textTheme.bodySmall!
                  .copyWith(color: context.theme.colorScheme.secondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYoutube(String videoUrl) {
    final youtubeVideoId = _presenter.getYoutubeVideoId(videoUrl);

    return Column(
      children: [
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                padding: EdgeInsets.zero,
                controller: _textEditingController,
                labelText: 'YouTube URL',
                onChanged: (value) => _presenter.updateVideoUrl(value),
              ),
            ),
          ],
        ),
        _buildVideoDurationReminder(),
        SizedBox(height: 8),
        if (youtubeVideoId != null)
          Builder(
            builder: (context) {
              _youtubePlayerController = YoutubePlayerController.fromVideoId(
                videoId: youtubeVideoId,
                params: YoutubePlayerParams(showControls: true),
              );
              _attachYoutubeDurationListener(_youtubePlayerController!, youtubeVideoId);

              return YoutubePlayer(
                controller: _youtubePlayerController!,
                aspectRatio: 16 / 9,
              );
            },
          )
        else
          Expanded(
            child: Container(
              color: context.theme.colorScheme.surface,
              child: Center(
                child: ProxiedImage(
                  null,
                  asset: AppAsset('media/youtube.png'),
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVimeo(String videoUrl) {
    final vimeoVideoId = _presenter.getVimeoVideoId(videoUrl);

    return Column(
      children: [
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                padding: EdgeInsets.zero,
                controller: _textEditingController,
                labelText: 'Vimeo URL',
                onChanged: (value) => _presenter.updateVideoUrl(value),
              ),
            ),
          ],
        ),
        _buildVideoDurationReminder(),
        SizedBox(height: 8),
        if (vimeoVideoId != null)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: VimeoVideoWidget(vimeoId: vimeoVideoId),
          )
        else
          Expanded(
            child: Container(
              color: context.theme.colorScheme.surface,
              child: Center(
                child: ProxiedImage(
                  null,
                  asset: AppAsset('media/vimeo.png'),
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUrlVideo(String videoUrl) {
    final url = _model.agendaItemVideoData.url;

    return Column(
      children: [
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                padding: EdgeInsets.zero,
                controller: _textEditingController,
                labelText: 'Link must be MP4',
                onChanged: (value) => _presenter.updateVideoUrl(value),
              ),
            ),
          ],
        ),
        _buildVideoDurationReminder(),
        SizedBox(height: 8),
        if (url.isEmpty)
          Expanded(
            child: Container(
              color: context.theme.colorScheme.surface,
              child: Center(
                child: ProxiedImage(
                  null,
                  asset: AppAsset('media/social-link-grey.png'),
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          )
        else
          _buildUrlVideoPreview(url),
      ],
    );
  }

  /// Renders the correct preview widget for a URL, routing YouTube and Vimeo
  /// links to their dedicated players so Video.js is never asked to play them.
  Widget _buildUrlVideoPreview(String url) {
    final youtubeId = _presenter.getYoutubeVideoId(url);
    if (youtubeId != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Builder(
          builder: (context) {
            _youtubePlayerController = YoutubePlayerController.fromVideoId(
              videoId: youtubeId,
              params: YoutubePlayerParams(showControls: true),
            );
            _attachYoutubeDurationListener(_youtubePlayerController!, youtubeId);
            return YoutubePlayer(
              controller: _youtubePlayerController!,
              aspectRatio: 16 / 9,
            );
          },
        ),
      );
    }

    final vimeoId = _presenter.getVimeoVideoId(url);
    if (vimeoId != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: VimeoVideoWidget(vimeoId: vimeoId),
      );
    }

    return Expanded(
      child: UrlVideoWidget(playbackUrl: url, autoplay: false),
    );
  }
}
