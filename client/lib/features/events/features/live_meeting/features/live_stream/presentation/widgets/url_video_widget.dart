import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/app.dart';
import 'package:client/services.dart';
import 'package:client/core/utils/platform_utils.dart';
import 'package:client/core/widgets/stream_utils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:universal_html/html.dart' as html;

class UrlVideoPlayheadInfo {
  final double currentTime;
  final double videoDuration;

  UrlVideoPlayheadInfo(this.currentTime, this.videoDuration);
}

class UrlVideoWidget extends StatefulHookWidget {
  final String playbackUrl;

  /// Playback video source type such as 'application/x-mpegURL'.
  ///
  /// This is often left blank because videoJS will automatically determine the video type from the
  /// URL.
  final String? playbackType;
  final void Function()? onReady;
  final void Function()? onEnded;
  final void Function()? onError;
  final void Function(UrlVideoPlayheadInfo)? onPlayheadUpdate;
  final bool showControls;
  final bool autoplay;
  final String? posterUrl;
  final bool refreshOnError;
  final bool loop;
  final Duration? videoStartOffset;

  UrlVideoWidget({
    required this.playbackUrl,
    this.playbackType,
    this.onReady,
    this.onEnded,
    this.onError,
    this.onPlayheadUpdate,
    this.showControls = true,
    this.autoplay = true,
    this.posterUrl,
    this.refreshOnError = false,
    this.loop = false,
    this.videoStartOffset,
    Key? key,
  }) : super(key: key ?? Key(playbackUrl));

  @override
  _UrlVideoWidgetState createState() => _UrlVideoWidgetState();
}

class _UrlVideoWidgetState extends State<UrlVideoWidget> {
  String _keyValue = uuid.v1();
  Timer? _errorTimer;

  String get encodedUrl {
    String playbackUrl = widget.playbackUrl;
    if (playbackUrl.startsWith('http://') &&
        playbackUrl.contains('cloudinary')) {
      playbackUrl = playbackUrl.replaceFirst('http://', 'https://');
    }
    final encodedLink = Uri.encodeQueryComponent(playbackUrl);
    String url = './stream/playback.html?url=$encodedLink'
        '&showControls=${widget.showControls}&autoplay=${widget.autoplay}&loop=${widget.loop}';

    String? playbackType = widget.playbackType;
    if (playbackType == null && playbackUrl.endsWith('.mp4')) {
      playbackType = 'video/mp4';
    } else if (playbackType == null && playbackUrl.endsWith('.webm')) {
      playbackType = 'video/webm';
    }
    if (playbackType != null && playbackType.trim().isNotEmpty) {
      final encodedType = Uri.encodeQueryComponent(playbackType);
      url = '$url&urlType=$encodedType';
    }
    if (!isNullOrEmpty(widget.posterUrl)) {
      url = '$url&posterUrl=${widget.posterUrl ?? ''}';
    }

    final startTimeOffset = widget.videoStartOffset?.inSeconds;
    if (startTimeOffset != null) {
      url = '$url&currentTime=$startTimeOffset';
    }

    return url;
  }

  @override
  void dispose() {
    super.dispose();
    _errorTimer?.cancel();
  }

  /// Manages video listener and forwards events to widget callbacks, if any
  void _useVideoListener() {
    // Provision stream controller through which playhead updates are rate limited
    final controller = useStreamController<UrlVideoPlayheadInfo>(keys: []);

    // Listen to stream; forward maximum of one playhead update per second to callback
    useStreamListener<UrlVideoPlayheadInfo>(
      stream: controller.stream.sampleTime(Duration(seconds: 1)),
      function: (status) {
        final onPlayheadUpdate = widget.onPlayheadUpdate;
        if (onPlayheadUpdate != null) {
          onPlayheadUpdate(status);
        }
      },
    );

    // Attach HTML window listener (receives messages from videojs)
    useEffect(
      () {
        final subscription = html.window.onMessage.listen((event) {
          final messageObj = event.data;

          print(messageObj);
          if (messageObj['source'] == 'videojs') {
            final String messageType = messageObj['type'];
            print(
              'currentTime type: ${messageObj['currentTime']?.runtimeType}',
            );
            print(
              'videoDuration type: ${messageObj['videoDuration']?.runtimeType}',
            );
            final double currentTime = messageObj['currentTime'];
            final double videoDuration = messageObj['videoDuration'];
            final onReady = widget.onReady;
            if (messageType == 'video-ready' && onReady != null) {
              loggingService.log('message ready received: ${event.data}');
              onReady();
            }
            final onEnded = widget.onEnded;
            if (messageType == 'video-ended' && onEnded != null) {
              loggingService.log('message ended received: ${event.data}');
              onEnded();
            }
            if (messageType == 'video-error') {
              loggingService.log('message error event received: ${event.data}');
              if (widget.refreshOnError && !(_errorTimer?.isActive ?? false)) {
                // Don't constantly restart due to an error. If another error occurs
                // during this window, then it will not refresh.
                _errorTimer = Timer(Duration(seconds: 5), () {});
                setState(() => _keyValue = uuid.v1());
              }

              final onError = widget.onError;
              if (onError != null) {
                onError();
              }
            }
            if (messageType == 'video-update') {
              loggingService
                  .log('message update event received: ${event.data}');
              controller.add(UrlVideoPlayheadInfo(currentTime, videoDuration));
            }
          }
        });
        return () => subscription.cancel();
      },
      [],
    );
  }

  @override
  Widget build(BuildContext context) {
    _useVideoListener();

    return _UrlVideoInternal(
      key: ValueKey(_keyValue),
      url: encodedUrl,
    );
  }
}

class _UrlVideoInternal extends StatefulWidget {
  final String url;

  const _UrlVideoInternal({required Key key, required this.url})
      : super(key: key);

  @override
  _UrlVideoInternalState createState() => _UrlVideoInternalState();
}

class _UrlVideoInternalState extends State<_UrlVideoInternal> {
  final _videoWidgetViewType = 'url-video/${uuid.v1()}';

  html.IFrameElement? _iframe;

  @override
  void initState() {
    super.initState();

    loggingService
        .log('reinitializing state of url video widget: ${widget.url}');

    registerWebViewFactory(_videoWidgetViewType, (_) {
      loggingService.log('getting iframe from factory');
      return _iframe = html.IFrameElement()
        ..id = _videoWidgetViewType
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.backgroundColor = '#303B5F'
        ..style.border = '0'
        ..allow =
            'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture'
        ..allowFullscreen = true
        ..src = widget.url;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _iframe?.remove();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(
      viewType: _videoWidgetViewType,
    );
  }
}
