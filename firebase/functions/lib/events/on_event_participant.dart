import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../utils/infra/firestore_event_function.dart';
import '../on_firestore_function.dart';
import '../utils/infra/firestore_utils.dart';
import 'package:data_models/events/event.dart';

/// Maintains Event.registrationCount by counting active participants whenever
/// any event-participants document is written (created, updated, or deleted).
class OnEventParticipant extends OnFirestoreFunction<Participant> {
  static const String _functionName = 'EventParticipantOnWrite';

  OnEventParticipant()
      : super(
          [
            AppFirestoreFunctionData(
              _functionName,
              FirestoreEventType.onWrite,
            ),
          ],
          (snapshot) {
            if (!snapshot.exists) {
              return Participant(id: snapshot.documentID);
            }
            return Participant.fromJson(
              firestoreUtils.fromFirestoreJson(snapshot.data.toMap()),
            ).copyWith(id: snapshot.documentID);
          },
        );

  @override
  String get documentPath =>
      'community/{communityId}/templates/{templateId}/events/{eventId}/event-participants/{participantId}';

  // firestoreOnWrite (base class) dispatches to onUpdate for all event
  // types (create, update, delete). For non-existent snapshots (create has
  // no before, delete has no after), the parser above returns a stub
  // Participant with null status, ensuring the status-change guard below
  // passes through to the recount query.
  @override
  Future<void> onUpdate(
    Change<DocumentSnapshot> changes,
    Participant before,
    Participant after,
    DateTime updateTime,
    EventContext context,
  ) async {
    // Skip writes that don't affect active status (presence, breakout room,
    // timestamp updates, etc.) to avoid rescanning all participants on every
    // live-meeting heartbeat.
    if (before.status == after.status) return;

    try {
      final participantRef = changes.after.exists
          ? changes.after.reference
          : changes.before.reference;
      final eventPath = participantRef.path.split('/event-participants/').first;

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

  @override
  Future<void> onWrite(
    Change<DocumentSnapshot> changes,
    Participant before,
    Participant after,
    DateTime updateTime,
    EventContext context,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<void> onCreate(
    DocumentSnapshot documentSnapshot,
    Participant parsedData,
    DateTime updateTime,
    EventContext context,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<void> onDelete(
    DocumentSnapshot documentSnapshot,
    Participant parsedData,
    DateTime updateTime,
    EventContext context,
  ) {
    throw UnimplementedError();
  }
}
