import 'package:flutter/material.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/core/utils/extensions.dart';

class BreakoutCategoryPresenter extends ChangeNotifier {
  final EventProvider eventProvider;

  BreakoutCategoryPresenter({required this.eventProvider});

  List<BreakoutCategory> get breakoutCategories =>
      eventProvider.event.breakoutRoomDefinition?.categories ?? [];
}
