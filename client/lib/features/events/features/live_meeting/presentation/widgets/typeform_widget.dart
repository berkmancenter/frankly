import 'dart:async';

import 'package:flutter/material.dart';
import 'package:client/services.dart';
import 'package:client/core/utils/platform_utils.dart';
import 'package:universal_html/html.dart' as html;

class TypeformWidget extends StatefulWidget {
  final String typeformLink;
  final Function(html.MessageEvent event)? onSubmit;

  const TypeformWidget({
    required this.typeformLink,
    this.onSubmit,
  });

  @override
  _TypeformWidgetState createState() => _TypeformWidgetState();
}

class _TypeformWidgetState extends State<TypeformWidget> {
  late final StreamSubscription _onTypeformSubmit;

  static const _viewType = 'typeform-embed';

  @override
  void initState() {
    super.initState();

    _initializeDiv();

    _onTypeformSubmit = html.window.onMessage.listen((event) {
      final onSubmit = widget.onSubmit;

      if (onSubmit != null) {
        onSubmit(event);
      }
    });
  }

  void _initializeDiv() {
    registerWebViewFactory(_viewType, (_) {
      loggingService
          .log('getting typeformIframe from factory ${widget.typeformLink}');
      final encodedLink = Uri.encodeQueryComponent(widget.typeformLink);
      return html.IFrameElement()
        ..id = _viewType
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.backgroundColor = '#FFFFFF'
        ..style.border = '0'
        ..src = '/typeform/typeform.html?link=$encodedLink';
    });
  }

  @override
  void dispose() {
    _onTypeformSubmit.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(
      viewType: _viewType,
    );
  }
}
