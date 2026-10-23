import 'package:data_models/events/live_meetings/live_meeting.dart';
import '../../../utils/infra/firestore_utils.dart';
import '../agora_api.dart';

/// Stops the recording (and STT agent) of every room in one breakout session.
/// Idempotent; stopRoom skips sessions already stopped.
Future<void> stopBreakoutSessionRecordings({
  required String liveMeetingPath,
  required String breakoutSessionId,
  required AgoraUtils agoraUtils,
}) async {
  final breakoutRoomDocs = await firestore
      .collection(
        '$liveMeetingPath/breakout-room-sessions/$breakoutSessionId/breakout-rooms',
      )
      .get();

  await Future.wait(
    breakoutRoomDocs.documents
        .map(
          (doc) => BreakoutRoom.fromJson(
            firestoreUtils.fromFirestoreJson(doc.data.toMap()),
          ).recordingSessionId,
        )
        .whereType<String>()
        .map(
          (recordingSessionId) => agoraUtils
              .stopRoom(sessionId: recordingSessionId)
              .catchError((e) {
            print('Error stopping breakout recording $recordingSessionId: $e');
          }),
        ),
  );
}
