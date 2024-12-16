import 'package:data_models/firestore/event.dart';

class WaitingRoomWidgetModel {
  final Event event;

  late WaitingRoomInfo waitingRoomInfo;

  WaitingRoomWidgetModel(this.event);
}
