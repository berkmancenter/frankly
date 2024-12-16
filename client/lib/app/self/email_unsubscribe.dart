import 'package:flutter/material.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/common_widgets/navbar/junto_scaffold.dart';
import 'package:junto/services/services.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/cloud_functions/requests.dart';

class EmailUnsubscribePage extends StatefulWidget {
  final String data;

  const EmailUnsubscribePage({required this.data});

  @override
  _EmailUnsubscribePageState createState() => _EmailUnsubscribePageState();
}

class _EmailUnsubscribePageState extends State<EmailUnsubscribePage> {
  Future<void>? _unsubscribeFuture;

  void _unsubscribe() {
    setState(() {
      _unsubscribeFuture = cloudFunctionsService.unsubscribeFromJuntoNotifications(
          request: UnsubscribeFromJuntoNotificationsRequest(data: widget.data));
    });
  }

  @override
  Widget build(BuildContext buildContext) {
    final localUnsubscribeFuture = _unsubscribeFuture;
    return JuntoScaffold(
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 50),
          alignment: Alignment.center,
          child: localUnsubscribeFuture == null
              ? Column(children: [
                  JuntoText('This will unsubscribe from Frankly updates:'),
                  ActionButton(
                    text: 'Unsubscribe Now',
                    onPressed: _unsubscribe,
                  ),
                ])
              : JuntoStreamBuilder<void>(
                  entryFrom: '_EmailUnsubscribePageState.build',
                  stream: localUnsubscribeFuture.asStream(),
                  builder: (_, __) {
                    return JuntoText('You have unsubscribed from Frankly updates.');
                  },
                )),
    );
  }
}
