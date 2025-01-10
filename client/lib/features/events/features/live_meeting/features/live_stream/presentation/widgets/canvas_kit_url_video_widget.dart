import 'package:flutter/material.dart';
import 'package:client/app.dart';
import 'package:client/core/utils/platform_utils.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_html/js.dart' as js;
import 'package:universal_html/js.dart' as universal_js;

class CanvasKitUrlVideoWidget extends StatefulWidget {
  final String playbackUrl;
  final String playbackType;
  final String autoplay;
  final bool showControls;
  final String? posterUrl;
  final Function()? onReady;
  final Function()? onEnded;
  final Function()? onError;

  CanvasKitUrlVideoWidget({
    required this.playbackUrl,
    this.playbackType = 'application/x-mpegURL',
    this.autoplay = 'auto',
    this.showControls = true,
    this.onReady,
    this.onEnded,
    this.onError,
    this.posterUrl,
  }) : super(key: Key(playbackUrl));

  @override
  _CanvasKitUrlVideoWidgetState createState() =>
      _CanvasKitUrlVideoWidgetState();
}

class _CanvasKitUrlVideoWidgetState extends State<CanvasKitUrlVideoWidget> {
  final _viewType = 'video-js-canvas-kit/${uuid.v1()}';

  html.DivElement? _div;

  @override
  void initState() {
    super.initState();

    registerWebViewFactory(_viewType, (_) {
      final localDiv = html.DivElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.backgroundColor = '#67717d'
        ..style.border = '0';

      localDiv.append(
        html.VideoElement()
          ..id = 'video-js-element'
          ..style.width = '100%'
          ..style.height = '100%'
          ..classes.addAll(['video-js', 'vjs-big-play-centered'])
          ..dataset['setup'] = '{}'
          ..controls = true
          ..preload = 'auto',
      );

      return _div = localDiv;
    });

    Future.delayed(
      Duration(milliseconds: 500),
      () => WidgetsBinding.instance.addPostFrameCallback(
        (_) => universal_js.context.callMethod(
          'playVideoJs',
          [
            'video-js-element',
            widget.playbackUrl,
            widget.playbackType,
            widget.autoplay,
            widget.showControls,
            widget.posterUrl,
            js.allowInterop(widget.onEnded ?? () {}),
            js.allowInterop(widget.onError ?? () {}),
            js.allowInterop(widget.onReady ?? () {}),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _div?.remove();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(
      viewType: _viewType,
    );
  }
}
