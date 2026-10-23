import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../../../utils/infra/firestore_event_function.dart';
import '../../../on_firestore_function.dart';
import '../../../utils/infra/firestore_utils.dart';
import 'check_advance_meeting_guide.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/meeting_guide.dart';

/// Reacts to writes on a breakout participant's per-agenda-item details doc and,
/// when their `readyToAdvance` vote changes, re-evaluates whether the breakout
/// should advance to the next agenda item.
///
/// Sibling fields (pollResponse, wordCloudResponses, suggestions, handRaisedTime)
/// write to the same doc, so the [onUpdate] guard skips writes that don't change
/// `readyToAdvance`.
class OnParticipantAgendaItemDetails
    extends OnFirestoreFunction<ParticipantAgendaItemDetails> {
  static const String _functionName = 'ParticipantAgendaItemDetailsOnWrite';

  OnParticipantAgendaItemDetails()
      : super(
          [
            AppFirestoreFunctionData(
              _functionName,
              FirestoreEventType.onWrite,
            ),
          ],
          (snapshot) {
            if (!snapshot.exists) {
              return ParticipantAgendaItemDetails();
            }
            return ParticipantAgendaItemDetails.fromJson(
              firestoreUtils.fromFirestoreJson(snapshot.data.toMap()),
            );
          },
        );

  // Only breakout participant-details docs drive the hostless advance, so the
  // pattern is scoped to the breakout room live-meeting.
  @override
  String get documentPath =>
      'community/{communityId}/templates/{templateId}/events/{eventId}'
      '/live-meetings/{liveMeetingId}'
      '/breakout-room-sessions/{breakoutSessionId}'
      '/breakout-rooms/{breakoutRoomId}'
      '/live-meetings/{roomLiveMeetingId}'
      '/participant-agenda-item-details/{agendaItemId}'
      '/participant-details/{userId}';

  // firestoreOnWrite (base class) dispatches to onUpdate for all event types.
  @override
  Future<void> onUpdate(
    Change<DocumentSnapshot> changes,
    ParticipantAgendaItemDetails before,
    ParticipantAgendaItemDetails after,
    DateTime updateTime,
    EventContext context,
  ) async {
    // Ignore writes that don't change the ready vote (poll/word-cloud/hand-raise
    // updates to the same doc).
    if ((before.readyToAdvance ?? false) == (after.readyToAdvance ?? false)) {
      return;
    }

    final reference = changes.after.exists
        ? changes.after.reference
        : changes.before.reference;

    await evaluateAdvanceForParticipantDetailsPath(reference.path);
  }

  /// Parses the breakout context out of a participant-details [docPath] and runs
  /// the shared advance evaluation.
  ///
  /// Public so tests can drive it directly (Firestore triggers don't auto-fire
  /// in the Firestore-only test emulator).
  Future<void> evaluateAdvanceForParticipantDetailsPath(String docPath) async {
    final eventPath = docPath.split('/live-meetings/').first;
    final segments = docPath.split('/');

    String? segmentAfter(String key) {
      final index = segments.indexOf(key);
      return (index >= 0 && index + 1 < segments.length)
          ? segments[index + 1]
          : null;
    }

    final breakoutSessionId = segmentAfter('breakout-room-sessions');
    final breakoutRoomId = segmentAfter('breakout-rooms');

    final event = await firestoreUtils.getFirestoreObject(
      path: eventPath,
      constructor: (map) => Event.fromJson(map),
    );

    await CheckAdvanceMeetingGuide().evaluateAndScheduleAdvance(
      event: event,
      eventPath: eventPath,
      breakoutSessionId: breakoutSessionId,
      breakoutRoomId: breakoutRoomId,
    );
  }

  @override
  Future<void> onWrite(
    Change<DocumentSnapshot> changes,
    ParticipantAgendaItemDetails before,
    ParticipantAgendaItemDetails after,
    DateTime updateTime,
    EventContext context,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<void> onCreate(
    DocumentSnapshot documentSnapshot,
    ParticipantAgendaItemDetails parsedData,
    DateTime updateTime,
    EventContext context,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<void> onDelete(
    DocumentSnapshot documentSnapshot,
    ParticipantAgendaItemDetails parsedData,
    DateTime updateTime,
    EventContext context,
  ) {
    throw UnimplementedError();
  }
}
