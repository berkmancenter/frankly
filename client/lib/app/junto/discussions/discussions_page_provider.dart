import 'dart:async';

import 'package:flutter/material.dart';
import 'package:junto/services/firestore/firestore_utils.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/firestore/discussion.dart';

class DiscussionsPageProvider with ChangeNotifier {
  final String juntoId;

  final _datesWithDiscussions = <DateTime>{};

  late BehaviorSubjectWrapper<List<Discussion>> _upcomingDiscussions;
  late StreamSubscription _discussionSubscription;
  List<Discussion>? _filteredDiscussions;

  DateTime? _selectedDate;
  String? _searchQuery;
  Timer? _searchQueryTimer;

  DiscussionsPageProvider({required this.juntoId});

  Stream<List<Discussion>> get discussionsStream => _upcomingDiscussions.stream;
  List<Discussion>? get filteredDiscussions => _filteredDiscussions;

  void initialize() {
    _upcomingDiscussions = firestoreDiscussionService.futurePublicDiscussionsForJunto(
      juntoId: juntoId,
    );

    _discussionSubscription = _upcomingDiscussions.stream.listen((discussions) {
      _datesWithDiscussions.clear();
      _datesWithDiscussions
          .addAll(discussions.map((discussion) => _toDate(discussion.scheduledTime!)));
      _filterDiscussions();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _discussionSubscription.cancel();
    _upcomingDiscussions.dispose();
    super.dispose();
  }

  void _filterDiscussions() {
    _filteredDiscussions =
        _upcomingDiscussions.stream.valueOrNull?.where(_filterDiscussion).toList();
    notifyListeners();
  }

  bool _filterDiscussion(Discussion discussion) {
    final localSelectedDate = _selectedDate;
    final localSearchQuery = _searchQuery;
    if (localSelectedDate != null && !_isOnDate(discussion.scheduledTime!, localSelectedDate)) {
      return false;
    }

    if (localSearchQuery != null && localSearchQuery.trim().isNotEmpty) {
      return (discussion.title ?? '').toLowerCase().contains(localSearchQuery);
    }

    return true;
  }

  void setDate(DateTime? date) {
    _selectedDate = date;
    _filterDiscussions();
  }

  static DateTime _toDate(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  static bool _isOnDate(DateTime query, DateTime date) {
    return _toDate(query) == _toDate(date);
  }

  bool dateHasDiscussion(DateTime date) => _datesWithDiscussions.contains(_toDate(date));

  void onSearchChanged(String value) {
    _searchQuery = value.toLowerCase();
    _searchQueryTimer?.cancel();
    _searchQueryTimer = Timer(Duration(milliseconds: 500), () {
      _filterDiscussions();
    });
  }
}
