import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../../../utils/infra/firestore_event_function.dart';
import '../../../on_firestore_function.dart';
import '../../../utils/infra/firestore_utils.dart';
import '../agora_api.dart';
import 'stop_breakout_session_recordings.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';

/// Reacts to writes on an event's main live meeting doc and, when the current
/// breakout session ends (cleared, replaced, or set inactive), stops that
/// session's room recordings and STT agents. Without this they run until the
/// event ends or Agora's idle timeout, leaving a black tail on each recording.
class OnLiveMeeting extends OnFirestoreFunction<LiveMeeting> {
  static const String _functionName = 'LiveMeetingOnWrite';

  final AgoraUtils agoraUtils;

  OnLiveMeeting({AgoraUtils? agoraUtils})
      : agoraUtils = agoraUtils ?? AgoraUtils(),
        super(
          [
            AppFirestoreFunctionData(
              _functionName,
              FirestoreEventType.onWrite,
            ),
          ],
          (snapshot) {
            if (!snapshot.exists) {
              return LiveMeeting();
            }
            return LiveMeeting.fromJson(
              firestoreUtils.fromFirestoreJson(snapshot.data.toMap()),
            );
          },
        );

  // Single-segment wildcards, so nested breakout room live meetings do not
  // match.
  @override
  String get documentPath =>
      'community/{communityId}/templates/{templateId}/events/{eventId}'
      '/live-meetings/{liveMeetingId}';

  // firestoreOnWrite (base class) dispatches to onUpdate for all event types.
  @override
  Future<void> onUpdate(
    Change<DocumentSnapshot> changes,
    LiveMeeting before,
    LiveMeeting after,
    DateTime updateTime,
    EventContext context,
  ) async {
    final reference = changes.after.exists
        ? changes.after.reference
        : changes.before.reference;

    await handleBreakoutSessionChange(
      liveMeetingPath: reference.path,
      before: before.currentBreakoutSession,
      after: after.currentBreakoutSession,
    );
  }

  /// Stops recordings for [before]'s breakout session if it ended in the
  /// transition to [after].
  ///
  /// Public so tests can drive it directly (Firestore triggers don't auto-fire
  /// in the Firestore-only test emulator).
  Future<void> handleBreakoutSessionChange({
    required String liveMeetingPath,
    required BreakoutRoomSession? before,
    required BreakoutRoomSession? after,
  }) async {
    if (before == null) return;

    final ended = after == null ||
        after.breakoutRoomSessionId != before.breakoutRoomSessionId ||
        (after.breakoutRoomStatus == BreakoutRoomStatus.inactive &&
            before.breakoutRoomStatus != BreakoutRoomStatus.inactive);
    if (!ended) return;

    await stopBreakoutSessionRecordings(
      liveMeetingPath: liveMeetingPath,
      breakoutSessionId: before.breakoutRoomSessionId,
      agoraUtils: agoraUtils,
    );
  }

  @override
  Future<void> onWrite(
    Change<DocumentSnapshot> changes,
    LiveMeeting before,
    LiveMeeting after,
    DateTime updateTime,
    EventContext context,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<void> onCreate(
    DocumentSnapshot documentSnapshot,
    LiveMeeting parsedData,
    DateTime updateTime,
    EventContext context,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<void> onDelete(
    DocumentSnapshot documentSnapshot,
    LiveMeeting parsedData,
    DateTime updateTime,
    EventContext context,
  ) {
    throw UnimplementedError();
  }
}
