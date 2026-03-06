import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart'
    hide CloudFunction;
import '../../cloud_function.dart';
import '../../utils/infra/firestore_utils.dart';
import 'package:data_models/events/event.dart' as $models;

class UpdateLiveStreamParticipantCount implements CloudFunction {
  @override
  final String functionName = 'UpdateLiveStreamParticipantCount';

  static const int _timesPerMinute = 4;
  final Duration _updateInterval =
      Duration(seconds: (60.0 / _timesPerMinute).round());

  // Conservative upper bound on event duration used to derive the pre-check
  // Firestore query window. The precise per-event filter in
  // _updateEventParticipantCount uses the actual durationInMinutes from each
  // event document; this constant just needs to be >= the longest plausible
  // event so the pre-check doesn't exclude currently-running events.
  static const int _maxEventDurationMinutes = 240; // 4 hours

  // The per-event active window: [scheduledTime - _preEventWindowHours,
  //                                scheduledTime + durationInMinutes * _postEventDurationMultiplier]
  static const int _preEventWindowHours = 1;
  static const double _postEventDurationMultiplier = 1.5;

  FutureOr<void> action(EventContext context) async {
    try {
      // Fast early-exit: check whether any non-hosted event could currently
      // be in its active window, using the same constants as the precise
      // per-event filter in _updateEventParticipantCount:
      //
      //   active window = [scheduledTime - _preEventWindowHours,
      //                    scheduledTime + durationInMinutes * _postEventDurationMultiplier]
      //
      // Since Firestore can't do per-doc arithmetic, we invert the bounds
      // around `now` using _maxEventDurationMinutes as a conservative ceiling:
      //
      //   scheduledTime >= now - (_maxEventDurationMinutes * _postEventDurationMultiplier)
      //     -> catches events that started at most (maxDuration * 1.5) minutes ago
      //       (i.e. whose window end hasn't passed yet)
      //   scheduledTime < (now + _preEventWindowHours)
      //     -> catches events whose pre-event window has already begun
      //
      // The per-event filter then applies the exact formula using real
      // durationInMinutes, so any events the pre-check admits that are
      // actually outside their window are cheaply skipped there.
      final preCheckLowerBound = DateTime.now().subtract(
        Duration(
          minutes:
              (_maxEventDurationMinutes * _postEventDurationMultiplier).round(),
        ),
      );
      final preCheckUpperBound = DateTime.now().add(
        const Duration(hours: _preEventWindowHours),
      );
      final activeLivestreams = await firestore
          .collectionGroup('events')
          .whereNotEqual(
            $models.Event.kFieldEventType,
            notEqualTo: $models.EventType.hosted.name,
          )
          .where(
            $models.Event.kFieldScheduledTime,
            isGreaterThanOrEqualTo: Timestamp.fromDateTime(preCheckLowerBound),
          )
          .where(
            $models.Event.kFieldScheduledTime,
            isLessThan: Timestamp.fromDateTime(preCheckUpperBound),
          )
          .select([]).get();
      if (activeLivestreams.documents.isEmpty) {
        print(
          'No active/upcoming livestreams found in pre-check window '
          '[$preCheckLowerBound, $preCheckUpperBound].',
        );
        return;
      }

      // Start calculating.
      // This job runs once a minute, so to get more granular we repeat the
      // same action multiple times within this action.
      await Future.wait([
        for (int i = 0; i < _timesPerMinute; i++)
          Future.delayed(
            _updateInterval * i,
            () => _updateLiveStreamParticipants(i),
          ),
      ]);
    } catch (e, stacktrace) {
      print('Error during action $functionName');
      print(e);
      print(stacktrace);
      rethrow;
    }
  }

  Future<void> _updateLiveStreamParticipants(int i) async {
    print(
      'Starting livestream participant calculation $i: ${_updateInterval * i}',
    );
    final stopwatch = Stopwatch()..start();

    await _updateAllLivestreamCounts();

    print('finished run $i: ${stopwatch.elapsed}');
  }

  Future<void> _updateAllLivestreamCounts() async {
    // Get all events that have a event participant that has been
    // updated in the last heartbeat interval + buffer seconds.
    // The heartbeat interval is 20s; we add a generous buffer to account
    // for network latency and clock skew.
    final updateWindow = DateTime.now()
        .subtract(_updateInterval)
        .subtract(const Duration(seconds: 25));
    print('Checking last update time greater than: $updateWindow');
    final eventParticipants = await firestore
        .collectionGroup('event-participants')
        .where(
          $models.Participant.kFieldLastUpdatedTime,
          isGreaterThan: Timestamp.fromDateTime(updateWindow.toUtc()),
        )
        .select([]).get();

    final eventPaths = eventParticipants.documents
        .map((d) => _getEventPathFromParticipantPath(d.reference.path))
        .toSet();

    await Future.wait([
      for (final path in eventPaths) _updateEventParticipantCount(path),
    ]);
  }

  Future<void> _updateEventParticipantCount(String eventPath) async {
    print('updating event count for $eventPath');

    // Read the event document to apply the precise time-window filter.
    // Only update events where now falls within:
    //   [scheduledTime - _preEventWindowHours,
    //    scheduledTime + durationInMinutes * _postEventDurationMultiplier]
    // This prevents stale isPresent flags (e.g. from missed RTDB disconnect
    // callbacks) from driving unnecessary writes for long-finished events.
    final event = await firestoreUtils.getFirestoreObject(
      path: eventPath,
      constructor: (map) => $models.Event.fromJson(map),
    );
    final scheduledTime = event.scheduledTime;
    if (scheduledTime != null) {
      final now = DateTime.now();
      final windowStart =
          scheduledTime.subtract(Duration(hours: _preEventWindowHours));
      final windowEnd = scheduledTime.add(
        Duration(
          minutes:
              (event.durationInMinutes * _postEventDurationMultiplier).round(),
        ),
      );
      if (now.isBefore(windowStart) || now.isAfter(windowEnd)) {
        print(
          'Skipping $eventPath: now ($now) is outside active window '
          '[$windowStart, $windowEnd]',
        );
        return;
      }
    }

    final participantDocs =
        await firestore.collection('$eventPath/event-participants').get();
    final participants = participantDocs.documents
        .map(
          (d) => $models.Participant.fromJson(
            firestoreUtils.fromFirestoreJson(d.data.toMap()),
          ),
        )
        .where((p) => p.status == $models.ParticipantStatus.active)
        .toList();

    final participantCount = participants.length;
    final presentParticipantCount =
        participants.where((p) => p.isPresent).length;

    final updateMap = {
      $models.Event.kFieldPresentParticipantCountEstimate:
          presentParticipantCount,
      $models.Event.kFieldParticipantCountEstimate: participantCount,
    };
    print('updated counts for $eventPath: $updateMap');
    await firestore.document(eventPath).updateData(
          UpdateData.fromMap(firestoreUtils.toFirestoreJson(updateMap)),
        );
  }

  String _getEventPathFromParticipantPath(String participantPath) {
    print('getting event path from participant path: $participantPath');
    final eventMatch =
        RegExp('community/([^/]+)/templates/([^/]+)/events/([^/]+)')
            .matchAsPrefix(participantPath);
    return eventMatch?.group(0) ?? '';
  }

  @override
  void register(FirebaseFunctions functions) {
    functions[functionName] = functions
        .runWith(
          RuntimeOptions(
            timeoutSeconds: 60,
            memory: '256MB',
            minInstances: int.parse(
              functions.config.get(
                'functions.update_live_stream_participant_count.min_instances',
              ),
            ),
          ),
        )
        .pubsub
        .schedule('every 1 minutes')
        .onRun((_, context) => action(context));
  }
}
