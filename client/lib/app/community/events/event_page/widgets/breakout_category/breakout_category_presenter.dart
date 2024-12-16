import 'package:flutter/material.dart';
import 'package:client/app/community/events/event_page/event_provider.dart';
import 'package:client/utils/extensions.dart';

class BreakoutCategoryPresenter extends ChangeNotifier {
  final EventProvider eventProvider;

  BreakoutCategoryPresenter({required this.eventProvider});

  List<BreakoutCategory> get breakoutCategories =>
      eventProvider.event.breakoutRoomDefinition?.categories ?? [];
}
