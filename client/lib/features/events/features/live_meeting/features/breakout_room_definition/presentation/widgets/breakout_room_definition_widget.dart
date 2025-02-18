import 'package:client/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:client/features/events/features/live_meeting/features/breakout_room_definition/presentation/views/breakout_room_definition_card.dart';
import 'package:client/features/events/features/live_meeting/features/breakout_room_definition/presentation/breakout_room_presenter.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
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
