import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:data_models/recording/recording_session.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:functions/events/live_meetings/agora_api.dart';
import 'package:functions/events/live_meetings/breakouts/on_live_meeting.dart';
import 'package:functions/utils/infra/firestore_utils.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import '../../../util/function_test_fixture.dart';
import '../../../util/live_meeting_test_utils.dart';

void main() {
  const liveMeetingPath =
      'community/c1/templates/t1/events/e1/live-meetings/e1';
  const sessionId = 'breakout-session-1';
  late MockAgoraUtils mockAgoraUtils;
  late OnLiveMeeting onLiveMeeting;
  setupTestFixture();

  Future<void> addRoom(String roomId, {String? recordingSessionId}) async {
    await firestore
        .document(
          '$liveMeetingPath/breakout-room-sessions/$sessionId/breakout-rooms/$roomId',
        )
        .setData(
          DocumentData.fromMap(
            firestoreUtils.toFirestoreJson(
              BreakoutRoom(
                roomId: roomId,
                roomName: roomId,
                orderingPriority: 0,
                creatorId: 'creator',
                recordingSessionId: recordingSessionId,
              ).toJson(),
            ),
          ),
        );
  }

  BreakoutRoomSession session(
    String id, [
    BreakoutRoomStatus status = BreakoutRoomStatus.active,
  ]) =>
      BreakoutRoomSession(
        breakoutRoomSessionId: id,
        breakoutRoomStatus: status,
        assignmentMethod: BreakoutAssignmentMethod.targetPerRoom,
        targetParticipantsPerRoom: 2,
        hasWaitingRoom: false,
      );

  Future<void> addSessionDoc(String id) =>
      firestore.document('$liveMeetingPath/breakout-room-sessions/$id').setData(
            DocumentData.fromMap(
              firestoreUtils.toFirestoreJson(session(id).toJson()),
            ),
          );

  setUp(() async {
    mockAgoraUtils = MockAgoraUtils();
    when(() => mockAgoraUtils.stopRoom(sessionId: any(named: 'sessionId')))
        .thenAnswer((_) => Future.value());
    onLiveMeeting = OnLiveMeeting(agoraUtils: mockAgoraUtils);

    await addSessionDoc(sessionId);
    await addRoom('room1', recordingSessionId: 'rec1');
    await addRoom('room2', recordingSessionId: 'rec2');
    await addRoom('room3');
  });

  test('Clearing current breakout session stops each room recording', () async {
    await onLiveMeeting.handleBreakoutSessionChange(
      liveMeetingPath: liveMeetingPath,
      before: session(sessionId),
      after: null,
    );

    verify(() => mockAgoraUtils.stopRoom(sessionId: 'rec1')).called(1);
    verify(() => mockAgoraUtils.stopRoom(sessionId: 'rec2')).called(1);
    verifyNoMoreInteractions(mockAgoraUtils);
  });

  test('Replacing breakout session stops the old session recordings', () async {
    await onLiveMeeting.handleBreakoutSessionChange(
      liveMeetingPath: liveMeetingPath,
      before: session(sessionId),
      after: session('breakout-session-2'),
    );

    verify(() => mockAgoraUtils.stopRoom(sessionId: 'rec1')).called(1);
    verify(() => mockAgoraUtils.stopRoom(sessionId: 'rec2')).called(1);
    verifyNoMoreInteractions(mockAgoraUtils);
  });

  test('Setting breakout session inactive stops recordings', () async {
    await onLiveMeeting.handleBreakoutSessionChange(
      liveMeetingPath: liveMeetingPath,
      before: session(sessionId),
      after: session(sessionId, BreakoutRoomStatus.inactive),
    );

    verify(() => mockAgoraUtils.stopRoom(sessionId: 'rec1')).called(1);
    verify(() => mockAgoraUtils.stopRoom(sessionId: 'rec2')).called(1);
    verifyNoMoreInteractions(mockAgoraUtils);
  });

  test('Unchanged breakout session does nothing', () async {
    await onLiveMeeting.handleBreakoutSessionChange(
      liveMeetingPath: liveMeetingPath,
      before: session(sessionId),
      after: session(sessionId),
    );
    await onLiveMeeting.handleBreakoutSessionChange(
      liveMeetingPath: liveMeetingPath,
      before: null,
      after: session(sessionId),
    );
    await onLiveMeeting.handleBreakoutSessionChange(
      liveMeetingPath: liveMeetingPath,
      before: session(sessionId, BreakoutRoomStatus.inactive),
      after: session(sessionId, BreakoutRoomStatus.inactive),
    );

    verifyZeroInteractions(mockAgoraUtils);
  });

  test('Ending breakout session stops only its recording sessions', () async {
    Future<void> addRecording(String id, RecordingRoomType type) =>
        firestore.document('${RecordingSession.kCollection}/$id').setData(
              DocumentData.fromMap(
                firestoreUtils.toFirestoreJson(
                  RecordingSession(
                    sessionId: id,
                    communityId: 'c1',
                    eventId: 'e1',
                    roomId: id,
                    roomType: type,
                    status: RecordingSessionStatus.recording,
                  ).toJson(),
                ),
              ),
            );

    Future<String?> statusOf(String id) async =>
        (await firestore.document('${RecordingSession.kCollection}/$id').get())
            .data
            .getString(RecordingSession.kFieldStatus);

    // Ending session rooms, main room, and a room in another session.
    await addRecording('rec1', RecordingRoomType.breakout);
    await addRecording('rec2', RecordingRoomType.breakout);
    await addRecording('mainRec', RecordingRoomType.main);
    await addRecording('otherRec', RecordingRoomType.breakout);
    await addSessionDoc('breakout-session-2');
    await firestore
        .document(
          '$liveMeetingPath/breakout-room-sessions/breakout-session-2'
          '/breakout-rooms/roomX',
        )
        .setData(
          DocumentData.fromMap(
            firestoreUtils.toFirestoreJson(
              BreakoutRoom(
                roomId: 'roomX',
                roomName: 'roomX',
                orderingPriority: 0,
                creatorId: 'creator',
                recordingSessionId: 'otherRec',
              ).toJson(),
            ),
          ),
        );

    // Real AgoraUtils; no sid/resourceId, so stopRoom only updates Firestore.
    await OnLiveMeeting(agoraUtils: AgoraUtils()).handleBreakoutSessionChange(
      liveMeetingPath: liveMeetingPath,
      before: session(sessionId),
      after: session(sessionId, BreakoutRoomStatus.inactive),
    );

    expect(await statusOf('rec1'), RecordingSessionStatus.stopped.name);
    expect(await statusOf('rec2'), RecordingSessionStatus.stopped.name);
    expect(await statusOf('mainRec'), RecordingSessionStatus.recording.name);
    expect(await statusOf('otherRec'), RecordingSessionStatus.recording.name);
  });
}
