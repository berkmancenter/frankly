import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart'
    hide CloudFunction;
import '../../cloud_function.dart';
import '../../utils/infra/firestore_utils.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/utils/utils.dart';

/// Scheduled function that detects and cleans up participants whose heartbeat
/// has gone stale. Cloud Scheduler fires this every minute, but internally the
/// function repeats 6 times (every 10s) for faster ghost detection.
///
/// A participant is considered stale if their `mostRecentPresentTime` is older
/// than [staleThreshold] (2 missed heartbeats at the 20s interval, plus a 5s
/// buffer = 45s).
///
/// This is a fallback for `UpdatePresenceStatus` (RTDB-based cleanup), which
/// can be delayed or missed when the device loses connectivity before the
/// RTDB disconnect handler gets triggered.
///
/// Key difference from `UpdatePresenceStatus`: this function preserves
/// `currentBreakoutRoomId` (does not clear it to null) so that room-based
/// analytics and potential auto-rejoin remain possible. This is safe because
/// all room-based queries now filter by `isPresent`.
class CleanupStaleParticipants implements CloudFunction {
  @override
  final String functionName = 'CleanupStaleParticipants';

  /// Number of cleanup passes per Cloud Scheduler invocation.
  /// Cloud Scheduler minimum is 1 minute, so we subdivide internally.
  static const int _runsPerMinute = 6;

  /// Interval between internal cleanup passes.
  static final Duration _checkInterval =
      Duration(seconds: (60.0 / _runsPerMinute).round());

  /// Time without heartbeat before a participant is marked disconnected.
  ///
  /// Derived from: 2 missed heartbeats (2 × 20s = 40s) + 5s buffer for
  /// network/clock skew = 45s.
  static const staleThreshold = Duration(seconds: 45);

  FutureOr<void> action(EventContext context) async {
    try {
      await Future.wait([
        for (int i = 0; i < _runsPerMinute; i++)
          Future.delayed(
            _checkInterval * i,
            () => runCleanupPass(i),
          ),
      ]);
    } catch (e, stacktrace) {
      print('Error during action $functionName');
      print(e);
      print(stacktrace);
      rethrow;
    }
  }

  /// Executes a single cleanup pass: queries for stale participants and marks
  /// them offline in a transaction with a freshness guard.
  ///
  /// Called by [action] multiple times per minute with real-time delays.
  /// Exposed as public so unit tests can invoke a single pass without
  /// waiting through the scheduling delays.
  Future<void> runCleanupPass(int pass) async {
    print('$functionName: Starting cleanup pass $pass');
    final cutoff = DateTime.now().subtract(staleThreshold);

    final staleParticipants = await firestore
        .collectionGroup('event-participants')
        .where(Participant.kFieldIsPresent, isEqualTo: true)
        .where(
          Participant.kFieldMostRecentPresentTime,
          isLessThan: Timestamp.fromDateTime(cutoff),
        )
        .get();

    if (staleParticipants.documents.isEmpty) {
      print('$functionName pass $pass: No stale participants found.');
      return;
    }

    print(
      '$functionName pass $pass: Found ${staleParticipants.documents.length} '
      'stale participant(s). Cleaning up...',
    );

    int cleaned = 0;
    int skipped = 0;

    await Future.wait(
      staleParticipants.documents.map(
        (doc) => firestore.runTransaction((transaction) async {
          final freshSnapshot = await transaction.get(doc.reference);
          final participant = Participant.fromJson(
            firestoreUtils.fromFirestoreJson(freshSnapshot.data.toMap()),
          );

          // Guard: if the participant has sent a heartbeat since our query
          // ran, they are alive and we should not mark them offline.
          if (participant.isPresent != true) {
            skipped++;
            return;
          }

          final mostRecentPresentTime = participant.mostRecentPresentTime;
          if (mostRecentPresentTime != null &&
              mostRecentPresentTime.isAfter(cutoff)) {
            skipped++;
            return;
          }

          transaction.update(
            doc.reference,
            UpdateData.fromMap(
              jsonSubset(
                [
                  Participant.kFieldIsPresent,
                  Participant.kFieldLastUpdatedTime,
                ],
                firestoreUtils.toFirestoreJson(
                  participant.copyWith(isPresent: false).toJson()
                    ..[Participant.kFieldLastUpdatedTime] =
                        Timestamp.fromDateTime(DateTime.now()),
                ),
              ),
            ),
          );
          cleaned++;
        }),
      ),
    );

    print(
      '$functionName pass $pass: Done. Cleaned $cleaned participant(s), '
      'skipped $skipped (refreshed before write).',
    );
  }

  @override
  void register(FirebaseFunctions functions) {
    functions[functionName] = functions
        .runWith(
          RuntimeOptions(timeoutSeconds: 60, memory: '256MB', minInstances: 0),
        )
        .pubsub
        .schedule('every 1 minutes')
        .onRun((_, context) => action(context));
  }
}
