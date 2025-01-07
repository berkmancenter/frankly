import 'dart:async';

import 'package:flutter/material.dart';
import 'package:client/services/firestore/firestore_utils.dart';
import 'package:client/services/services.dart';
import 'package:data_models/events/event.dart';

class EventsPageProvider with ChangeNotifier {
  final String communityId;

  final _datesWithEvents = <DateTime>{};

  late BehaviorSubjectWrapper<List<Event>> _upcomingEvents;
  late StreamSubscription _eventSubscription;
  List<Event>? _filteredEvents;

  DateTime? _selectedDate;
  String? _searchQuery;
  Timer? _searchQueryTimer;

  EventsPageProvider({required this.communityId});

  Stream<List<Event>> get eventsStream => _upcomingEvents.stream;
  List<Event>? get filteredEvents => _filteredEvents;

  void initialize() {
    _upcomingEvents = firestoreEventService.futurePublicEventsForCommunity(
      communityId: communityId,
    );

    _eventSubscription = _upcomingEvents.stream.listen((events) {
      _datesWithEvents.clear();
      _datesWithEvents.addAll(
        events.map((event) => _toDate(event.scheduledTime!)),
      );
      _filterEvents();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _eventSubscription.cancel();
    _upcomingEvents.dispose();
    super.dispose();
  }

  void _filterEvents() {
    _filteredEvents =
        _upcomingEvents.stream.valueOrNull?.where(_filterEvent).toList();
    notifyListeners();
  }

  bool _filterEvent(Event event) {
    final localSelectedDate = _selectedDate;
    final localSearchQuery = _searchQuery;
    if (localSelectedDate != null &&
        !_isOnDate(event.scheduledTime!, localSelectedDate)) {
      return false;
    }

    if (localSearchQuery != null && localSearchQuery.trim().isNotEmpty) {
      return (event.title ?? '').toLowerCase().contains(localSearchQuery);
    }

    return true;
  }

  void setDate(DateTime? date) {
    _selectedDate = date;
    _filterEvents();
  }

  static DateTime _toDate(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  static bool _isOnDate(DateTime query, DateTime date) {
    return _toDate(query) == _toDate(date);
  }

  bool dateHasEvent(DateTime date) => _datesWithEvents.contains(_toDate(date));

  void onSearchChanged(String value) {
    _searchQuery = value.toLowerCase();
    _searchQueryTimer?.cancel();
    _searchQueryTimer = Timer(Duration(milliseconds: 500), () {
      _filterEvents();
    });
  }
}
