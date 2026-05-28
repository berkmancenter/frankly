import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../utils/infra/firestore_event_function.dart';
import '../utils/infra/firestore_utils.dart';
import 'package:data_models/events/event.dart';

/// Maintains Event.registrationCount by counting active participants whenever
/// any event-participants document is written (created, updated, or deleted).
class OnEventParticipant implements FirestoreEventFunction {
  static const String _functionName = 'EventParticipantOnWrite';

  static const String _documentPath =
      'community/{communityId}/templates/{templateId}/events/{eventId}/event-participants/{participantId}';

  @override
  List<AppFirestoreFunctionData> get appFirestoreFunctionData => [
        AppFirestoreFunctionData(_functionName, FirestoreEventType.onWrite),
      ];

  @override
  void register(FirebaseFunctions functions) {
    functions[_functionName] = functions
        .runWith(
          RuntimeOptions(
            timeoutSeconds: 60,
            memory: '256MB',
            minInstances: int.parse(
              functions.config.get('functions.on_firestore.min_instances'),
            ),
          ),
        )
        .firestore
        .document(_documentPath)
        .onWrite((changes, context) => _onWrite(changes));
  }

  Future<void> _onWrite(Change<DocumentSnapshot> changes) async {
    try {
      // Resolve the participant path regardless of whether this is a create,
      // update, or delete (after may not exist on delete).
      final participantRef = changes.after.exists
          ? changes.after.reference
          : changes.before.reference;
      final eventPath =
          participantRef.path.split('/event-participants/').first;

      // Count participants whose status is 'active'.
      final activeDocs = await firestore
          .collection('$eventPath/event-participants')
          .where(
            Participant.kFieldStatus,
            isEqualTo: ParticipantStatus.active.name,
          )
          .select([]).get();

      final count = activeDocs.documents.length;

      await firestore.document(eventPath).updateData(
            UpdateData.fromMap({Event.kFieldRegistrationCount: count}),
          );

      print('$_functionName: set registrationCount=$count on $eventPath');
    } catch (e, s) {
      print('Error in $_functionName: $e\n$s');
      rethrow;
    }
  }
}
