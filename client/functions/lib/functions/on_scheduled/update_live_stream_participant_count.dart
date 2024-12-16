import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/junto_cloud_function.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_models/firestore/discussion.dart';

class UpdateLiveStreamParticipantCount implements JuntoCloudFunction {
  @override
  final String functionName = 'UpdateLiveStreamParticipantCount';

  static const int _timesPerMinute = 4;
  final Duration _updateInterval = Duration(seconds: (60.0 / _timesPerMinute).round());

  FutureOr<void> _action( EventContext context) async {
    try {
      /// This job runs once a minute, so to get more granular we repeat the
      /// same action multiple times within this action.
      await Future.wait([
        for (int i = 0; i < _timesPerMinute; i++)
          Future.delayed(_updateInterval * i, () => _updateLiveStreamParticipants(i)),
      ]);
    } catch (e, stacktrace) {
      print('Error during action $functionName');
      print(e);
      print(stacktrace);
      rethrow;
    }
  }

  Future<void> _updateLiveStreamParticipants(int i) async {
    print('Starting livestream participant calculation $i: ${_updateInterval * i}');
    final stopwatch = Stopwatch()..start();

    await _updateAllLivestreamCounts();

    print('finished run $i: ${stopwatch.elapsed}');
  }

  Future<void> _updateAllLivestreamCounts() async {
    // Get all discussions that have a discussion participant that has been
    // updated in the last duration + buffer seconds (limit 1)
    final updateWindow =
        DateTime.now().subtract(_updateInterval).subtract(const Duration(seconds: 4));
    print('Checking last update time greater than: $updateWindow');
    final discussionParticipants = await firestore
        .collectionGroup('discussion-participants')
        .where(
          Participant.kFieldLastUpdatedTime,
          isGreaterThan: Timestamp.fromDateTime(updateWindow.toUtc()),
        )
        .select([]).get();

    final discussionPaths = discussionParticipants.documents
        .map((d) => _getDiscussionPathFromParticipantPath(d.reference.path))
        .toSet();

    await Future.wait(
        [for (final path in discussionPaths) _updateDiscussionParticipantCount(path)]);
  }

  Future<void> _updateDiscussionParticipantCount(String discussionPath) async {
    print('updating discussion count for $discussionPath');
    final participantDocs =
        await firestore.collection('$discussionPath/discussion-participants').get();
    final participants = participantDocs.documents
        .map((d) => Participant.fromJson(firestoreUtils.fromFirestoreJson(d.data.toMap())))
        .where((p) => p.status == ParticipantStatus.active)
        .toList();

    final participantCount = participants.length;
    final presentParticipantCount = participants.where((p) => p.isPresent).length;

    final updateMap = {
      Discussion.kFieldPresentParticipantCountEstimate: presentParticipantCount,
      Discussion.kFieldParticipantCountEstimate: participantCount,
    };
    print('updated counts for $discussionPath: $updateMap');
    await firestore.document(discussionPath).updateData(UpdateData.fromMap(firestoreUtils.toFirestoreJson(updateMap)));
  }

  String _getDiscussionPathFromParticipantPath(String participantPath) {
    print('getting discussion path from participant path: $participantPath');
    final discussionMatch =
        RegExp('junto/([^/]+)/topics/([^/]+)/discussions/([^/]+)').matchAsPrefix(participantPath);
    return discussionMatch?.group(0) ?? '';
  }

  @override
  void register(FirebaseFunctions functions) {
    functions[functionName] = functions
        .runWith(RuntimeOptions(timeoutSeconds: 60, memory: '4GB', minInstances: isDev ? 0 : 1))
        .pubsub
        .schedule('every 1 minutes')
        .onRun((_, context) => _action(context));
  }
}
