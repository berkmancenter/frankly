@Timeout(Duration(seconds: 90))
import 'package:firebase_admin_interop/firebase_admin_interop.dart'
    hide EventType;
import 'package:functions/events/live_meetings/cleanup_stale_participants.dart';
import 'package:functions/utils/infra/firestore_utils.dart';
import 'package:test/test.dart';
import 'package:data_models/events/event.dart';

import '../../util/community_test_utils.dart';
import '../../util/event_test_utils.dart';
import '../../util/function_test_fixture.dart';

void main() {
  late String communityId;
  const templateId = '9654';
  final eventUtils = EventTestUtils();
  final communityUtils = CommunityTestUtils();
  late Event testEvent;
  setupTestFixture();

  setUp(() async {
    communityId = await communityUtils.createTestCommunity();

    testEvent = Event(
      id: '5678',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: adminUserId,
      nullableEventType: EventType.hostless,
      collectionPath: '',
    );
    testEvent = await eventUtils.createEvent(
      event: testEvent,
      userId: adminUserId,
    );
  });

  /// Helper: get the participant reference for a given user in the test event.
  DocumentReference _participantRef(String userId) {
    return firestore.document(
      '${testEvent.fullPath}/event-participants/$userId',
    );
  }

  /// Helper: set `mostRecentPresentTime` on a participant document.
  Future<void> _setMostRecentPresentTime(
    String userId,
    DateTime time,
  ) async {
    await _participantRef(userId).updateData(
      UpdateData.fromMap({
        Participant.kFieldMostRecentPresentTime: Timestamp.fromDateTime(time),
      }),
    );
  }

  /// Helper: read a participant document back from Firestore.
  Future<Participant> _getParticipant(String userId) async {
    final snapshot = await _participantRef(userId).get();
    return Participant.fromJson(
      firestoreUtils.fromFirestoreJson(snapshot.data.toMap()),
    );
  }

  test('Marks stale participant as offline', () async {
    const userId = 'staleUser';

    await eventUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: testEvent.id,
      uid: userId,
      isPresent: true,
    );

    // Set mostRecentPresentTime to 2 minutes ago (well past 45s threshold)
    await _setMostRecentPresentTime(
      userId,
      DateTime.now().subtract(const Duration(minutes: 2)),
    );

    await CleanupStaleParticipants().action(MockEventContext());

    final participant = await _getParticipant(userId);
    expect(participant.isPresent, isFalse);
  });

  test('Does not mark fresh participant as offline', () async {
    const userId = 'freshUser';

    await eventUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: testEvent.id,
      uid: userId,
      isPresent: true,
    );

    // Set mostRecentPresentTime to 10 seconds ago (within 45s threshold)
    await _setMostRecentPresentTime(
      userId,
      DateTime.now().subtract(const Duration(seconds: 10)),
    );

    await CleanupStaleParticipants().action(MockEventContext());

    final participant = await _getParticipant(userId);
    expect(participant.isPresent, isTrue);
  });

  test('Does not touch participant already marked offline', () async {
    const userId = 'offlineUser';

    await eventUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: testEvent.id,
      uid: userId,
      isPresent: false,
    );

    // Even with a stale timestamp, should be skipped (isPresent already false)
    await _setMostRecentPresentTime(
      userId,
      DateTime.now().subtract(const Duration(minutes: 5)),
    );

    await CleanupStaleParticipants().action(MockEventContext());

    final participant = await _getParticipant(userId);
    expect(participant.isPresent, isFalse);
  });

  test('Preserves currentBreakoutRoomId when marking offline', () async {
    const userId = 'roomUser';
    const breakoutRoomId = 'room-42';

    await eventUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: testEvent.id,
      uid: userId,
      isPresent: true,
    );

    // Set both the room ID and a stale timestamp
    await _participantRef(userId).updateData(
      UpdateData.fromMap({
        Participant.kFieldCurrentBreakoutRoomId: breakoutRoomId,
        Participant.kFieldMostRecentPresentTime: Timestamp.fromDateTime(
          DateTime.now().subtract(const Duration(minutes: 2)),
        ),
      }),
    );

    await CleanupStaleParticipants().action(MockEventContext());

    final participant = await _getParticipant(userId);
    expect(participant.isPresent, isFalse);
    expect(participant.currentBreakoutRoomId, equals(breakoutRoomId));
  });

  test('Cleans up stale participants across multiple events', () async {
    // Create a second event
    var event2 = Event(
      id: '9999',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: adminUserId,
      nullableEventType: EventType.hostless,
      collectionPath: '',
    );
    event2 = await eventUtils.createEvent(
      event: event2,
      userId: adminUserId,
    );

    const staleUser1 = 'staleInEvent1';
    const staleUser2 = 'staleInEvent2';

    // Stale participant in event 1
    await eventUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: testEvent.id,
      uid: staleUser1,
      isPresent: true,
    );
    await _setMostRecentPresentTime(
      staleUser1,
      DateTime.now().subtract(const Duration(minutes: 3)),
    );

    // Stale participant in event 2
    await eventUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: event2.id,
      uid: staleUser2,
      isPresent: true,
    );
    final event2ParticipantRef = firestore.document(
      '${event2.fullPath}/event-participants/$staleUser2',
    );
    await event2ParticipantRef.updateData(
      UpdateData.fromMap({
        Participant.kFieldMostRecentPresentTime: Timestamp.fromDateTime(
          DateTime.now().subtract(const Duration(minutes: 3)),
        ),
      }),
    );

    await CleanupStaleParticipants().action(MockEventContext());

    // Both should be marked offline
    final p1 = await _getParticipant(staleUser1);
    expect(p1.isPresent, isFalse);

    final p2Snapshot = await event2ParticipantRef.get();
    final p2 = Participant.fromJson(
      firestoreUtils.fromFirestoreJson(p2Snapshot.data.toMap()),
    );
    expect(p2.isPresent, isFalse);
  });

  test('Handles mix of stale and fresh participants', () async {
    const staleUser = 'staleUser';
    const freshUser = 'freshUser';

    await eventUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: testEvent.id,
      uid: staleUser,
      isPresent: true,
    );
    await _setMostRecentPresentTime(
      staleUser,
      DateTime.now().subtract(const Duration(minutes: 2)),
    );

    await eventUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: testEvent.id,
      uid: freshUser,
      isPresent: true,
    );
    await _setMostRecentPresentTime(
      freshUser,
      DateTime.now().subtract(const Duration(seconds: 5)),
    );

    await CleanupStaleParticipants().action(MockEventContext());

    final stale = await _getParticipant(staleUser);
    expect(stale.isPresent, isFalse);

    final fresh = await _getParticipant(freshUser);
    expect(fresh.isPresent, isTrue);
  });

  test('No-op when there are no stale participants', () async {
    const userId = 'activeUser';

    await eventUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: testEvent.id,
      uid: userId,
      isPresent: true,
    );
    await _setMostRecentPresentTime(
      userId,
      DateTime.now().subtract(const Duration(seconds: 3)),
    );

    // Should complete without error and not change anything
    await CleanupStaleParticipants().action(MockEventContext());

    final participant = await _getParticipant(userId);
    expect(participant.isPresent, isTrue);
  });

  test('Participant at 44s (just inside 45s threshold) is not cleaned up',
      () async {
    // staleThreshold = 45s; 44s ago is still within the safe window.
    const userId = 'boundaryFreshUser';

    await eventUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: testEvent.id,
      uid: userId,
      isPresent: true,
    );
    await _setMostRecentPresentTime(
      userId,
      DateTime.now().subtract(const Duration(seconds: 44)),
    );

    await CleanupStaleParticipants().action(MockEventContext());

    final participant = await _getParticipant(userId);
    expect(participant.isPresent, isTrue);
  });

  test('Participant at 46s (just past 45s threshold) is cleaned up', () async {
    // staleThreshold = 45s; 46s ago is outside the safe window.
    const userId = 'boundaryStaleUser';

    await eventUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: testEvent.id,
      uid: userId,
      isPresent: true,
    );
    await _setMostRecentPresentTime(
      userId,
      DateTime.now().subtract(const Duration(seconds: 46)),
    );

    await CleanupStaleParticipants().action(MockEventContext());

    final participant = await _getParticipant(userId);
    expect(participant.isPresent, isFalse);
  });
}
