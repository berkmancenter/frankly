import 'package:flutter/cupertino.dart';
import 'package:client/services.dart';
import 'package:data_models/events/event.dart';

class MyEventsPageProvider extends ChangeNotifier {
  late Future<List<Event>> _upcomingEvents;
  late Future<List<Event>> _previousEvents;

  Stream<List<Event>> get upcomingEvents => Stream.fromFuture(_upcomingEvents);
  Stream<List<Event>> get previousEvents => Stream.fromFuture(_previousEvents);

  void initialize() {
    final userEvents = firestoreEventService.userEventsForCommunity();

    final currentTime = clockService.now();
    _upcomingEvents = _futureEvents(userEvents, currentTime);
    _previousEvents = _pastEvents(userEvents, currentTime);
  }

  Future<List<Event>> _futureEvents(
    Future<List<Event>> eventsFuture,
    DateTime currentTime,
  ) async {
    final events = await eventsFuture;
    return events
        .where(
          (event) =>
              event.status == EventStatus.active &&
              (event.scheduledTime?.isAfter(currentTime) ?? false),
        )
        .toList()
      ..sort((a, b) {
        return a.scheduledTime!.compareTo(b.scheduledTime!);
      });
  }

  Future<List<Event>> _pastEvents(
    Future<List<Event>> eventsFuture,
    DateTime currentTime,
  ) async {
    final events = await eventsFuture;
    return events
        .where(
          (event) =>
              event.status == EventStatus.active &&
              (event.scheduledTime?.isBefore(currentTime) ?? false),
        )
        .toList()
      ..sort((a, b) {
        return b.scheduledTime!.compareTo(a.scheduledTime!);
      });
  }
}
