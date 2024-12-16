import 'package:flutter/material.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/firestore/topic.dart';

class AttendedPrerequisiteProvider extends ChangeNotifier {
  final Topic topic;
  final bool isAdmin;

  AttendedPrerequisiteProvider({required this.topic, required this.isAdmin});

  late Future<bool> _hasParticipantAttendedPrerequisiteFuture;

  Future<bool> get hasParticipantAttendedPrerequisiteFuture =>
      _hasParticipantAttendedPrerequisiteFuture;

  void initialize() {
    _hasParticipantAttendedPrerequisiteFuture = _checkHasParticipantAttendedPrerequisite();
  }

  Future<bool> _checkHasParticipantAttendedPrerequisite() async {
    final prerequisiteId = topic.prerequisiteTopicId;
    if (prerequisiteId == null || isAdmin) {
      return true;
    }
    final _hasAttendedPrerequisite = await firestoreDiscussionService.userHasParticipatedInTopic(
      topicId: prerequisiteId,
    );
    return _hasAttendedPrerequisite;
  }
}
