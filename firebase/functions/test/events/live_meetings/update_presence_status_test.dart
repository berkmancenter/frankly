@Timeout(Duration(seconds: 90))
import 'package:firebase_admin_interop/firebase_admin_interop.dart'
    hide EventType;
import 'package:functions/events/live_meetings/update_presence_status.dart';
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
      id: 'EventToTestPresenceStatus',
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
  DocumentReference participantRef(String userId) {
    return firestore.document(
      '${testEvent.fullPath}/event-participants/$userId',
    );
  }

  /// Helper: read a participant document back from Firestore.
  Future<Participant> getParticipant(String userId) async {
    final snapshot = await participantRef(userId).get();
    return Participant.fromJson(
      firestoreUtils.fromFirestoreJson(snapshot.data.toMap()),
    );
  }

  test('Marks present participant as offline', () async {
    const userId = 'testUser';

    await eventUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: testEvent.id,
      uid: userId,
      isPresent: true,
    );

    final updateTime = DateTime.now();

    await UpdatePresenceStatus().updateEventStatusesToOffline(
      userId: userId,
      updateTime: updateTime,
    );

    final participant = await getParticipant(userId);
    expect(participant.isPresent, isFalse);
  });

  test('Clears currentBreakoutRoomId on disconnect', () async {
    const userId = 'roomUser';
    const roomId = 'breakout-42';

    await eventUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: testEvent.id,
      uid: userId,
      isPresent: true,
    );
    await participantRef(userId).updateData(
      UpdateData.fromMap({
        Participant.kFieldCurrentBreakoutRoomId: roomId,
      }),
    );

    final updateTime = DateTime.now();

    await UpdatePresenceStatus().updateEventStatusesToOffline(
      userId: userId,
      updateTime: updateTime,
    );

    final participant = await getParticipant(userId);
    expect(participant.isPresent, isFalse);
    // The function clears the room ID (sets to empty string on staging,
    // null on the #281 branch).
    expect(
      participant.currentBreakoutRoomId,
      anyOf(isNull, isEmpty),
    );
  });

  test('Sets lastUpdatedTime on disconnect', () async {
    const userId = 'timestampUser';

    await eventUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: testEvent.id,
      uid: userId,
      isPresent: true,
    );

    final updateTime = DateTime.now();

    await UpdatePresenceStatus().updateEventStatusesToOffline(
      userId: userId,
      updateTime: updateTime,
    );

    final participant = await getParticipant(userId);
    expect(participant.lastUpdatedTime, isNotNull);
    // lastUpdatedTime should be set to the updateTime
    expect(
      participant.lastUpdatedTime!.millisecondsSinceEpoch,
      equals(updateTime.millisecondsSinceEpoch),
    );
  });

  test('Skips participant already marked offline', () async {
    const userId = 'offlineUser';

    await eventUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: testEvent.id,
      uid: userId,
      isPresent: false,
    );

    final updateTime = DateTime.now();

    // Should complete without error (collectionGroup query returns no matches)
    await UpdatePresenceStatus().updateEventStatusesToOffline(
      userId: userId,
      updateTime: updateTime,
    );

    final participant = await getParticipant(userId);
    expect(participant.isPresent, isFalse);
  });

  test('Skips participant whose lastUpdatedTime is newer than updateTime',
      () async {
    const userId = 'racyUser';

    await eventUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: testEvent.id,
      uid: userId,
      isPresent: true,
    );

    // Set lastUpdatedTime to a time well after the trigger
    final updateTime = DateTime.now().subtract(const Duration(seconds: 30));
    final newerFirestoreTime = DateTime.now();
    await participantRef(userId).updateData(
      UpdateData.fromMap({
        Participant.kFieldLastUpdatedTime:
            Timestamp.fromDateTime(newerFirestoreTime),
      }),
    );

    await UpdatePresenceStatus().updateEventStatusesToOffline(
      userId: userId,
      updateTime: updateTime,
    );

    // Participant should remain online because Firestore data is newer
    final participant = await getParticipant(userId);
    expect(participant.isPresent, isTrue);
  });

  test('Updates same user across multiple events', () async {
    const userId = 'multiEventUser';

    // Join first event
    await eventUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: testEvent.id,
      uid: userId,
      isPresent: true,
    );

    // Create and join second event
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
    await eventUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: event2.id,
      uid: userId,
      isPresent: true,
    );

    final updateTime = DateTime.now();

    await UpdatePresenceStatus().updateEventStatusesToOffline(
      userId: userId,
      updateTime: updateTime,
    );

    // Both events should have the participant marked offline
    final p1 = await getParticipant(userId);
    expect(p1.isPresent, isFalse);

    final p2Snapshot = await firestore
        .document('${event2.fullPath}/event-participants/$userId')
        .get();
    final p2 = Participant.fromJson(
      firestoreUtils.fromFirestoreJson(p2Snapshot.data.toMap()),
    );
    expect(p2.isPresent, isFalse);
  });

  test('Only updates the specified user', () async {
    const targetUser = 'targetUser';
    const otherUser = 'otherUser';

    await eventUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: testEvent.id,
      uid: targetUser,
      isPresent: true,
    );
    await eventUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: testEvent.id,
      uid: otherUser,
      isPresent: true,
    );

    final updateTime = DateTime.now();

    await UpdatePresenceStatus().updateEventStatusesToOffline(
      userId: targetUser,
      updateTime: updateTime,
    );

    final target = await getParticipant(targetUser);
    expect(target.isPresent, isFalse);

    final other = await getParticipant(otherUser);
    expect(other.isPresent, isTrue);
  });

  test('No-op when user has no participant records', () async {
    const nonExistentUser = 'ghostUser';

    final updateTime = DateTime.now();

    // Should complete without error even when no documents match
    await UpdatePresenceStatus().updateEventStatusesToOffline(
      userId: nonExistentUser,
      updateTime: updateTime,
    );

    // No assertions needed beyond no-throw; verify existing data is untouched
    final admin = await getParticipant(adminUserId);
    expect(admin.status, equals(ParticipantStatus.active));
  });
}
