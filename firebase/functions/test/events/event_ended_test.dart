import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:data_models/recording/recording_session.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart'
    hide EventType;
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:functions/utils/infra/firestore_utils.dart';
import 'package:data_models/community/community.dart';
import 'package:functions/events/event_ended.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:data_models/cloud_functions/requests.dart';
import '../util/community_test_utils.dart';
import '../util/email_test_utils.dart';
import '../util/event_test_utils.dart';
import '../util/function_test_fixture.dart';

void main() {
  late String communityId;
  const templateId = '9654988';
  final communityTestUtils = CommunityTestUtils();
  final eventTestUtils = EventTestUtils();
  setupTestFixture();

  setUp(() async {
    communityId = await communityTestUtils.createTestCommunity();
  });

  test('Email sent when event has ended', () async {
    var event = Event(
      id: '12341daaaåff2837',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: adminUserId,
      nullableEventType: EventType.hosted,
      collectionPath: '',
      agendaItems: [
        AgendaItem(
          id: '55005',
          title: "Role call",
          content: "Shout out if you're here",
        ),
      ],
    );
    event = await eventTestUtils.createEvent(
      event: event,
      userId: adminUserId,
    );

    registerFallbackValue(event);

    final req = EventEndedRequest(
      eventPath: event.fullPath,
    );

    final notificationsUtils = MockNotificationsUtils();
    when(
      () => notificationsUtils.sendEventEndedEmail(
        event: any(named: 'event'),
        communityId: communityId,
        userIds: any(named: 'userIds'),
        emailType: EventEmailType.ended,
        generateMessage: any(named: 'generateMessage'),
      ),
    ).thenAnswer((_) async {
      return;
    });

    final eventEnded = EventEnded(notificationsUtils: notificationsUtils);

    await eventEnded.action(
      req,
      CallableContext(adminUserId, null, 'fakeInstanceId'),
    );

    final capturedMessage = verify(
      () => notificationsUtils.sendEventEndedEmail(
        event: any(named: 'event'),
        communityId: communityId,
        userIds: [adminUserId],
        emailType: EventEmailType.ended,
        generateMessage: captureAny(named: 'generateMessage'),
      ),
    ).captured.first(MockCommunity(), MockUserRecord());
    expect(capturedMessage.subject, equals('Thanks for joining'));
    expect(capturedMessage.html, isNotNull);
  });

  test('Participant leaving does not stop active recordings', () async {
    var event = Event(
      id: 'recordingEvent1',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: adminUserId,
      nullableEventType: EventType.hosted,
      collectionPath: '',
    );
    event = await eventTestUtils.createEvent(event: event, userId: adminUserId);
    registerFallbackValue(event);

    final liveMeetingPath = '${event.fullPath}/live-meetings/${event.id}';
    const mainSessionId = 'mainRec1';
    const breakoutSessionId = 'breakoutRec1';

    Future<void> addSession(String id, String roomId, RecordingRoomType type) =>
        firestore.document('${RecordingSession.kCollection}/$id').setData(
              DocumentData.fromMap(
                firestoreUtils.toFirestoreJson(
                  RecordingSession(
                    sessionId: id,
                    communityId: communityId,
                    eventId: event.id,
                    roomId: roomId,
                    roomType: type,
                    status: RecordingSessionStatus.recording,
                  ).toJson(),
                ),
              ),
            );

    await addSession(mainSessionId, event.id, RecordingRoomType.main);
    await addSession(breakoutSessionId, 'room1', RecordingRoomType.breakout);
    await firestore.document(liveMeetingPath).setData(
          DocumentData.fromMap(
            firestoreUtils.toFirestoreJson(
              LiveMeeting(recordingSessionId: mainSessionId).toJson(),
            ),
          ),
        );
    await firestore
        .document(
          '$liveMeetingPath/breakout-room-sessions/b1/breakout-rooms/room1',
        )
        .setData(
          DocumentData.fromMap(
            firestoreUtils.toFirestoreJson(
              BreakoutRoom(
                roomId: 'room1',
                roomName: '1',
                orderingPriority: 0,
                creatorId: adminUserId,
                recordingSessionId: breakoutSessionId,
              ).toJson(),
            ),
          ),
        );

    final notificationsUtils = MockNotificationsUtils();
    when(
      () => notificationsUtils.sendEventEndedEmail(
        event: any(named: 'event'),
        communityId: communityId,
        userIds: any(named: 'userIds'),
        emailType: EventEmailType.ended,
        generateMessage: any(named: 'generateMessage'),
      ),
    ).thenAnswer((_) async {});

    await EventEnded(notificationsUtils: notificationsUtils).action(
      EventEndedRequest(eventPath: event.fullPath),
      CallableContext(adminUserId, null, 'fakeInstanceId'),
    );

    for (final id in [mainSessionId, breakoutSessionId]) {
      final snap =
          await firestore.document('${RecordingSession.kCollection}/$id').get();
      expect(
        snap.data.getString(RecordingSession.kFieldStatus),
        equals(RecordingSessionStatus.recording.name),
      );
    }
  });
}

class MockCommunity extends Mock implements Community {}
