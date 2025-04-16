import 'package:flutter/material.dart';
import 'package:client/services.dart';
import 'package:data_models/templates/template.dart';

class AttendedPrerequisiteProvider extends ChangeNotifier {
  final Template template;
  final bool isAdmin;

  AttendedPrerequisiteProvider({required this.template, required this.isAdmin});

  late Future<bool> _hasParticipantAttendedPrerequisiteFuture;

  Future<bool> get hasParticipantAttendedPrerequisiteFuture =>
      _hasParticipantAttendedPrerequisiteFuture;

  void initialize() {
    _hasParticipantAttendedPrerequisiteFuture =
        _checkHasParticipantAttendedPrerequisite();
  }

  Future<bool> _checkHasParticipantAttendedPrerequisite() async {
    final prerequisiteId = template.prerequisiteTemplateId;
    if (prerequisiteId == null || isAdmin) {
      return true;
    }
    final hasAttendedPrerequisite =
        await firestoreEventService.userHasParticipatedInTemplate(
      templateId: prerequisiteId,
    );
    return hasAttendedPrerequisite;
  }
}
