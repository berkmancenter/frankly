@Timeout(Duration(seconds: 90))
import 'package:firebase_admin_interop/firebase_admin_interop.dart'
    hide EventType;
import 'package:functions/utils/infra/firestore_utils.dart';
import 'package:test/test.dart';
import 'package:data_models/events/event.dart';

import '../../util/community_test_utils.dart';
import '../../util/event_test_utils.dart';
import '../../util/function_test_fixture.dart';

/// Contract tests for the Firestore document shape written by
/// updateMeetingPresence (client-side) and read by server-side queries
/// (e.g. collectionGroup where isPresent == true).
///
/// These tests simulate the updateMeetingPresence writes from
/// LiveMeetingProvider (4 direct call sites + heartbeat timer) and
/// verify the document shape matches what server-side code expects.
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
      id: 'PresenceContractEvent',
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

  DocumentReference _participantRef(String userId) {
    return firestore.document(
      '${testEvent.fullPath}/event-participants/$userId',
    );
  }

  Future<Participant> _getParticipant(String userId) async {
    final snapshot = await _participantRef(userId).get();
    return Participant.fromJson(
      firestoreUtils.fromFirestoreJson(snapshot.data.toMap()),
    );
  }

  /// Simulates what updateMeetingPresence writes: a merge-set of presence
  /// fields on the participant document.
  Future<void> _writePresence(
    String userId, {
    required bool isPresent,
    String? currentBreakoutRoomId,
  }) async {
    final ref = _participantRef(userId);

    final data = <String, dynamic>{
      Participant.kFieldId: userId,
      Participant.kFieldIsPresent: isPresent,
      Participant.kFieldCurrentBreakoutRoomId: currentBreakoutRoomId,
      Participant.kFieldLastUpdatedTime:
          Firestore.fieldValues.serverTimestamp(),
    };

    if (isPresent) {
      data[Participant.kFieldMostRecentPresentTime] =
          Firestore.fieldValues.serverTimestamp();
    }

    await firestore.runTransaction((transaction) async {
      transaction.set(
        ref,
        DocumentData.fromMap(firestoreUtils.toFirestoreJson(data)),
        merge: true,
      );
    });
  }

  group('join (initialize) contract', () {
    test('sets isPresent true and mostRecentPresentTime on join', () async {
      const userId = 'joinUser';

      await eventUtils.joinEvent(
        communityId: communityId,
        templateId: templateId,
        eventId: testEvent.id,
        uid: userId,
        isPresent: false,
      );

      // Simulate the initialize() call: isPresent: true, no breakout room
      await _writePresence(userId, isPresent: true);

      final p = await _getParticipant(userId);
      expect(p.isPresent, isTrue);
      expect(p.mostRecentPresentTime, isNotNull);
      expect(p.currentBreakoutRoomId, isNull);
    });
  });

  group('breakout room join contract', () {
    test('sets currentBreakoutRoomId when joining breakout room', () async {
      const userId = 'breakoutJoinUser';
      const roomId = 'room-abc-123';

      await eventUtils.joinEvent(
        communityId: communityId,
        templateId: templateId,
        eventId: testEvent.id,
        uid: userId,
        isPresent: true,
      );

      // Simulate heartbeat write after getBreakoutRoomFuture() sets
      // _inTransitionToBreakoutRoomId. The heartbeat timer picks up the
      // room ID via _presenceRoomId on the next tick.
      await _writePresence(
        userId,
        isPresent: true,
        currentBreakoutRoomId: roomId,
      );

      final p = await _getParticipant(userId);
      expect(p.isPresent, isTrue);
      expect(p.currentBreakoutRoomId, equals(roomId));
    });

    test('sets waiting-room ID when in waiting room', () async {
      const userId = 'waitingRoomUser';
      const waitingRoomId = 'waiting-room';

      await eventUtils.joinEvent(
        communityId: communityId,
        templateId: templateId,
        eventId: testEvent.id,
        uid: userId,
        isPresent: true,
      );

      // Simulate heartbeat with presenceRoomIdForState(waitingRoom)
      await _writePresence(
        userId,
        isPresent: true,
        currentBreakoutRoomId: waitingRoomId,
      );

      final p = await _getParticipant(userId);
      expect(p.isPresent, isTrue);
      expect(p.currentBreakoutRoomId, equals('waiting-room'));
    });
  });

  group('leave breakout room contract', () {
    test('clears currentBreakoutRoomId when leaving breakout room', () async {
      const userId = 'breakoutLeaveUser';
      const roomId = 'room-xyz-456';

      await eventUtils.joinEvent(
        communityId: communityId,
        templateId: templateId,
        eventId: testEvent.id,
        uid: userId,
        isPresent: true,
      );

      // First set user into a breakout room
      await _writePresence(
        userId,
        isPresent: true,
        currentBreakoutRoomId: roomId,
      );

      // Simulate leaveBreakoutRoom() call: isPresent stays true, room cleared
      await _writePresence(userId, isPresent: true);

      final p = await _getParticipant(userId);
      expect(p.isPresent, isTrue);
      expect(p.currentBreakoutRoomId, isNull);
    });
  });

  group('disconnect (dispose / onBeforeUnload) contract', () {
    test('sets isPresent false on dispose', () async {
      const userId = 'disposeUser';

      await eventUtils.joinEvent(
        communityId: communityId,
        templateId: templateId,
        eventId: testEvent.id,
        uid: userId,
        isPresent: true,
      );

      // Simulate dispose() call: isPresent: false
      await _writePresence(userId, isPresent: false);

      final p = await _getParticipant(userId);
      expect(p.isPresent, isFalse);
    });

    test('sets isPresent false on tab close (onBeforeUnload)', () async {
      const userId = 'tabCloseUser';
      const roomId = 'room-in-breakout';

      await eventUtils.joinEvent(
        communityId: communityId,
        templateId: templateId,
        eventId: testEvent.id,
        uid: userId,
        isPresent: true,
      );

      // User is in a breakout room
      await _writePresence(
        userId,
        isPresent: true,
        currentBreakoutRoomId: roomId,
      );

      // Tab close sends isPresent: false (client does NOT clear room ID here)
      await _writePresence(userId, isPresent: false);

      final p = await _getParticipant(userId);
      expect(p.isPresent, isFalse);
      // lastUpdatedTime should be set (server timestamp)
      expect(p.lastUpdatedTime, isNotNull);
    });
  });

  group('collectionGroup query compatibility', () {
    test('isPresent: true participants appear in collectionGroup query',
        () async {
      const onlineUser = 'onlineQueryUser';
      const offlineUser = 'offlineQueryUser';

      await eventUtils.joinEvent(
        communityId: communityId,
        templateId: templateId,
        eventId: testEvent.id,
        uid: onlineUser,
        isPresent: true,
      );
      await eventUtils.joinEvent(
        communityId: communityId,
        templateId: templateId,
        eventId: testEvent.id,
        uid: offlineUser,
        isPresent: false,
      );

      // This is the same query shape UpdatePresenceStatus uses
      final querySnapshot = await firestore
          .collectionGroup('event-participants')
          .where(Participant.kFieldId, isEqualTo: onlineUser)
          .where(Participant.kFieldIsPresent, isEqualTo: true)
          .get();

      expect(querySnapshot.documents, hasLength(1));

      final offlineQuery = await firestore
          .collectionGroup('event-participants')
          .where(Participant.kFieldId, isEqualTo: offlineUser)
          .where(Participant.kFieldIsPresent, isEqualTo: true)
          .get();

      expect(offlineQuery.documents, isEmpty);
    });

    test('participant with breakout room ID is queryable by room', () async {
      const userId = 'roomQueryUser';
      const roomId = 'breakout-room-42';

      await eventUtils.joinEvent(
        communityId: communityId,
        templateId: templateId,
        eventId: testEvent.id,
        uid: userId,
        isPresent: true,
      );
      await _writePresence(
        userId,
        isPresent: true,
        currentBreakoutRoomId: roomId,
      );

      // Query by room + isPresent (breakoutRoomParticipantsStream shape)
      final eventRef = eventUtils.eventReference(
        communityId: communityId,
        templateId: templateId,
        eventId: testEvent.id,
      );
      final querySnapshot = await eventRef
          .collection('event-participants')
          .where(Participant.kFieldCurrentBreakoutRoomId, isEqualTo: roomId)
          .where(Participant.kFieldIsPresent, isEqualTo: true)
          .get();

      expect(querySnapshot.documents, hasLength(1));
      final doc = querySnapshot.documents.first;
      final data = firestoreUtils.fromFirestoreJson(doc.data.toMap());
      expect(data[Participant.kFieldId], equals(userId));
    });
  });
}
