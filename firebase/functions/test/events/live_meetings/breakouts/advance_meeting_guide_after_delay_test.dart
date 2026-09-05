import 'package:firebase_admin_interop/firebase_admin_interop.dart'
    hide EventType;
import 'package:get_it/get_it.dart';
import 'package:functions/events/live_meetings/breakouts/advance_meeting_guide_after_delay.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:test/test.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:functions/utils/infra/firestore_utils.dart';
import 'package:uuid/uuid.dart';

import '../../../util/community_test_utils.dart';
import '../../../util/event_test_utils.dart';
import '../../../util/function_test_fixture.dart';
import '../../../util/live_meeting_test_utils.dart';

void main() {
  late String communityId;
  const templateId = '9654';
  const uuid = Uuid();
  GetIt.instance.registerSingleton(const Uuid());
  final communityTestUtils = CommunityTestUtils();
  final eventTestUtils = EventTestUtils();
  final liveMeetingTestUtils = LiveMeetingTestUtils();
  setupTestFixture();

  setUp(() async {
    communityId = await communityTestUtils.createTestCommunity();
  });

  Future<Event> createEventWithAgendaItems() async {
    var event = Event(
      id: 'event-${uuid.v1()}',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: adminUserId,
      nullableEventType: EventType.hosted,
      collectionPath: '',
      agendaItems: [
        AgendaItem(id: 'agenda-1', title: 'First topic'),
        AgendaItem(id: 'agenda-2', title: 'Second topic'),
        AgendaItem(id: 'agenda-3', title: 'Third topic'),
      ],
    );
    return eventTestUtils.createEvent(event: event, userId: adminUserId);
  }

  /// Writes a live meeting doc with the given current agenda item and a pending advance already
  /// recorded for it, mirroring the state [CheckAdvanceMeetingGuide] leaves behind once the ready
  /// threshold is crossed.
  Future<void> seedPendingLiveMeeting({
    required String liveMeetingPath,
    required String currentAgendaItemId,
  }) async {
    await firestore.document(liveMeetingPath).setData(
          DocumentData.fromMap(
            firestoreUtils.toFirestoreJson(
              LiveMeeting(
                events: [
                  LiveMeetingEvent(
                    agendaItem: currentAgendaItemId,
                    event: LiveMeetingEventType.agendaItemStarted,
                  ),
                ],
                pendingAdvanceAgendaItemId: currentAgendaItemId,
                pendingAdvanceTime: DateTime.now().toUtc(),
              ).toJson(),
            ),
          ),
        );
  }

  Future<LiveMeeting> readLiveMeeting(String liveMeetingPath) async {
    final snapshot = await firestore.document(liveMeetingPath).get();
    return LiveMeeting.fromJson(
      firestoreUtils.fromFirestoreJson(snapshot.data.toMap()),
    );
  }

  test(
      'advances to the next agenda item and clears the pending state when the '
      'delay elapses for a still-pending agenda item', () async {
    final event = await createEventWithAgendaItems();
    final liveMeetingPath = liveMeetingTestUtils.getLiveMeetingPath(event);
    final firstAgendaItemId = event.agendaItems[0].id;
    final secondAgendaItemId = event.agendaItems[1].id;

    await seedPendingLiveMeeting(
      liveMeetingPath: liveMeetingPath,
      currentAgendaItemId: firstAgendaItemId,
    );

    await AdvanceMeetingGuideAfterDelay().advanceMeetingGuideAfterDelay(
      AdvanceMeetingGuideAfterDelayRequest(
        eventPath: event.fullPath,
        agendaItemId: firstAgendaItemId,
      ),
    );

    final liveMeeting = await readLiveMeeting(liveMeetingPath);
    expect(liveMeeting.events.length, equals(2));
    expect(
      liveMeeting.events[1].event,
      equals(LiveMeetingEventType.agendaItemStarted),
    );
    expect(liveMeeting.events[1].agendaItem, equals(secondAgendaItemId));
    expect(liveMeeting.pendingAdvanceAgendaItemId, isNull);
    expect(liveMeeting.pendingAdvanceTime, isNull);
  });

  test('advances to finishMeeting when the pending agenda item is the last one',
      () async {
    final event = await createEventWithAgendaItems();
    final liveMeetingPath = liveMeetingTestUtils.getLiveMeetingPath(event);
    final lastAgendaItemId = event.agendaItems.last.id;

    await seedPendingLiveMeeting(
      liveMeetingPath: liveMeetingPath,
      currentAgendaItemId: lastAgendaItemId,
    );

    await AdvanceMeetingGuideAfterDelay().advanceMeetingGuideAfterDelay(
      AdvanceMeetingGuideAfterDelayRequest(
        eventPath: event.fullPath,
        agendaItemId: lastAgendaItemId,
      ),
    );

    final liveMeeting = await readLiveMeeting(liveMeetingPath);
    expect(liveMeeting.events.length, equals(2));
    expect(
      liveMeeting.events[1].event,
      equals(LiveMeetingEventType.finishMeeting),
    );
    expect(liveMeeting.pendingAdvanceAgendaItemId, isNull);
  });

  test(
      'does not advance when the pending agenda item no longer matches the '
      'request (e.g. it was superseded by a newer pending advance)', () async {
    final event = await createEventWithAgendaItems();
    final liveMeetingPath = liveMeetingTestUtils.getLiveMeetingPath(event);
    final firstAgendaItemId = event.agendaItems[0].id;
    final secondAgendaItemId = event.agendaItems[1].id;

    // Pending advance is now for the second agenda item, but the delayed call is for the first.
    await seedPendingLiveMeeting(
      liveMeetingPath: liveMeetingPath,
      currentAgendaItemId: secondAgendaItemId,
    );

    await AdvanceMeetingGuideAfterDelay().advanceMeetingGuideAfterDelay(
      AdvanceMeetingGuideAfterDelayRequest(
        eventPath: event.fullPath,
        agendaItemId: firstAgendaItemId,
      ),
    );

    final liveMeeting = await readLiveMeeting(liveMeetingPath);
    // Unchanged: still just the seeded event, and the pending advance is untouched.
    expect(liveMeeting.events.length, equals(1));
    expect(liveMeeting.pendingAdvanceAgendaItemId, equals(secondAgendaItemId));
  });

  test('advances the correct breakout room live meeting', () async {
    final event = await createEventWithAgendaItems();
    final breakoutSessionId = uuid.v1().toString();
    final firstAgendaItemId = event.agendaItems[0].id;
    final secondAgendaItemId = event.agendaItems[1].id;

    await eventTestUtils.joinEventMultiple(
      communityId: communityId,
      templateId: templateId,
      eventId: event.id,
      participantIds: ['111', '222'],
    );

    // The parent live meeting doc must exist before breakout rooms can be assigned.
    await liveMeetingTestUtils.addMeetingEvent(
      liveMeetingPath: liveMeetingTestUtils.getLiveMeetingPath(event),
      meetingEvent: LiveMeetingEvent(
        agendaItem: firstAgendaItemId,
        event: LiveMeetingEventType.agendaItemStarted,
      ),
    );

    await liveMeetingTestUtils.initiateBreakoutSession(
      event: event,
      breakoutSessionId: breakoutSessionId,
      userId: adminUserId,
    );

    final breakoutRoom = await liveMeetingTestUtils.getBreakoutRoom(
      event: event,
      breakoutSessionId: breakoutSessionId,
      roomName: '1',
    );

    final breakoutLiveMeetingPath =
        liveMeetingTestUtils.getBreakoutLiveMeetingPath(
      event: event,
      breakoutSessionId: breakoutSessionId,
      breakoutRoomId: breakoutRoom.roomId,
    );

    await seedPendingLiveMeeting(
      liveMeetingPath: breakoutLiveMeetingPath,
      currentAgendaItemId: firstAgendaItemId,
    );

    await AdvanceMeetingGuideAfterDelay().advanceMeetingGuideAfterDelay(
      AdvanceMeetingGuideAfterDelayRequest(
        eventPath: event.fullPath,
        breakoutSessionId: breakoutSessionId,
        breakoutRoomId: breakoutRoom.roomId,
        agendaItemId: firstAgendaItemId,
      ),
    );

    final liveMeeting = await readLiveMeeting(breakoutLiveMeetingPath);
    expect(liveMeeting.events.length, equals(2));
    expect(liveMeeting.events[1].agendaItem, equals(secondAgendaItemId));
    expect(liveMeeting.pendingAdvanceAgendaItemId, isNull);
  });
}
