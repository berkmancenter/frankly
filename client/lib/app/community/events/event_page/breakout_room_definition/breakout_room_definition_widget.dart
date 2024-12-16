import 'package:flutter/material.dart';
import 'package:client/app/community/events/event_page/breakout_room_definition/breakout_room_definition_card.dart';
import 'package:client/app/community/events/event_page/breakout_room_definition/breakout_room_presenter.dart';
import 'package:client/app/community/events/event_page/event_provider.dart';
import 'package:client/app/community/utils.dart';
import 'package:provider/provider.dart';

class BreakoutRoomDefinitionWidget extends StatelessWidget {
  const BreakoutRoomDefinitionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BreakoutRoomPresenter(
        showRegularToast: (message, toastType) =>
            showRegularToast(context, message, toastType: toastType),
        eventProvider: EventProvider.read(context),
      )..initialize(),
      child: BreakoutRoomDefinitionCard(),
    );
  }
}
