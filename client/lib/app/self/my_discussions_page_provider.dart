import 'package:flutter/cupertino.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/firestore/discussion.dart';

class MyDiscussionsPageProvider extends ChangeNotifier {
  late Future<List<Discussion>> _upcomingDiscussions;
  late Future<List<Discussion>> _previousDiscussions;

  Stream<List<Discussion>> get upcomingDiscussions => Stream.fromFuture(_upcomingDiscussions);
  Stream<List<Discussion>> get previousDiscussions => Stream.fromFuture(_previousDiscussions);

  void initialize() {
    final userDiscussions = firestoreDiscussionService.userDiscussionsForJunto();

    final currentTime = clockService.now();
    _upcomingDiscussions = _futureDiscussions(userDiscussions, currentTime);
    _previousDiscussions = _pastDiscussions(userDiscussions, currentTime);
  }

  Future<List<Discussion>> _futureDiscussions(
      Future<List<Discussion>> discussionsFuture, DateTime currentTime) async {
    final discussions = await discussionsFuture;
    return discussions
        .where((discussion) =>
            discussion.status == DiscussionStatus.active &&
            (discussion.scheduledTime?.isAfter(currentTime) ?? false))
        .toList()
      ..sort((a, b) {
        return a.scheduledTime!.compareTo(b.scheduledTime!);
      });
  }

  Future<List<Discussion>> _pastDiscussions(
      Future<List<Discussion>> discussionsFuture, DateTime currentTime) async {
    final discussions = await discussionsFuture;
    return discussions
        .where((discussion) =>
            discussion.status == DiscussionStatus.active &&
            (discussion.scheduledTime?.isBefore(currentTime) ?? false))
        .toList()
      ..sort((a, b) {
        return b.scheduledTime!.compareTo(a.scheduledTime!);
      });
  }
}
