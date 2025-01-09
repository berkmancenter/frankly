import 'package:universal_html/html.dart' as html;
import 'package:universal_html/js.dart' as js;
import 'package:client/core/utils/platform_utils.dart' as platform_utils;

import 'package:flutter/material.dart';

class VimeoVideoWidget extends StatefulWidget {
  final String? vimeoId;
  final Function()? onEnded;
  final bool showControls;

  VimeoVideoWidget({
    this.vimeoId,
    this.onEnded,
    this.showControls = true,
  }) : super(key: Key('$vimeoId-vimeo-video'));

  @override
  _VimeoVideoWidgetState createState() => _VimeoVideoWidgetState();
}

class _VimeoVideoWidgetState extends State<VimeoVideoWidget> {
  html.DivElement? _div;

  String get _viewType => 'vimeo-video-${widget.vimeoId}';

  @override
  void initState() {
    super.initState();

    // ignore: undefined_prefixed_name
    platform_utils.registerWebViewFactory(_viewType, (_) {
      return _div ??= html.DivElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = '0';
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      js.context.callMethod(
        'playVimeoVideo',
        [_div, widget.vimeoId, js.allowInterop(widget.onEnded ?? () {})],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(
      viewType: _viewType,
    );
  }
}
