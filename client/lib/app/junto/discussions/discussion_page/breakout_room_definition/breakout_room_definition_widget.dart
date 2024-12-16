import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/discussion_page/breakout_room_definition/breakout_room_definition_card.dart';
import 'package:junto/app/junto/discussions/discussion_page/breakout_room_definition/breakout_room_presenter.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:provider/provider.dart';

class BreakoutRoomDefinitionWidget extends StatelessWidget {
  const BreakoutRoomDefinitionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BreakoutRoomPresenter(
        showRegularToast: (message, toastType) =>
            showRegularToast(context, message, toastType: toastType),
        discussionProvider: DiscussionProvider.read(context),
      )..initialize(),
      child: BreakoutRoomDefinitionCard(),
    );
  }
}
