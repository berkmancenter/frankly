import 'package:flutter/material.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/core/widgets/navbar/custom_scaffold.dart';
import 'package:client/config/environment.dart';
import 'package:client/services.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/cloud_functions/requests.dart';

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
      _unsubscribeFuture =
          cloudFunctionsCommunityService.unsubscribeFromCommunityNotifications(
        request: UnsubscribeFromCommunityNotificationsRequest(
          data: widget.data,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext buildContext) {
    final localUnsubscribeFuture = _unsubscribeFuture;
    return CustomScaffold(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 50),
        alignment: Alignment.center,
        child: localUnsubscribeFuture == null
            ? Column(
                children: [
                  HeightConstrainedText(
                    'This will unsubscribe from ${Environment.appName} updates:',
                  ),
                  ActionButton(
                    text: 'Unsubscribe Now',
                    onPressed: _unsubscribe,
                  ),
                ],
              )
            : CustomStreamBuilder<void>(
                entryFrom: '_EmailUnsubscribePageState.build',
                stream: localUnsubscribeFuture.asStream(),
                builder: (_, __) {
                  return HeightConstrainedText(
                    'You have unsubscribed from ${Environment.appName} updates.',
                  );
                },
              ),
      ),
    );
  }
}
