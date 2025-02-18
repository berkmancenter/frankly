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

  FutureOr<void> action(EventContext context) async {
    try {
      // Do a first pass to only check for active livestreams in the next day.
      // If not, we can skip the rest of this action.
      final activeLivestreams = await firestore
          .collectionGroup('events')
          .whereNotEqual(
            $models.Event.kFieldEventType,
            notEqualTo: $models.EventType.hosted.name,
          )
          .where(
            $models.Event.kFieldScheduledTime,
            isGreaterThanOrEqualTo: Timestamp.fromDateTime(DateTime.now()),
          )
          .where(
            $models.Event.kFieldScheduledTime,
            isLessThan: Timestamp.fromDateTime(
              DateTime.now().add(const Duration(days: 1)),
            ),
          )
          .select([]).get();
      if (activeLivestreams.documents.isEmpty) {
        print('No active/upcoming livestreams found.');
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
    // updated in the last duration + buffer seconds (limit 1)
    final updateWindow = DateTime.now()
        .subtract(_updateInterval)
        .subtract(const Duration(seconds: 4));
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
