import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
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

  setUp(() async {
    mockAgoraUtils = MockAgoraUtils();
    when(() => mockAgoraUtils.stopRoom(sessionId: any(named: 'sessionId')))
        .thenAnswer((_) => Future.value());
    onLiveMeeting = OnLiveMeeting(agoraUtils: mockAgoraUtils);

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
}
