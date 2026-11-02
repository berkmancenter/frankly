import 'package:firebase_admin_interop/firebase_admin_interop.dart'
    hide EventType;
import 'package:functions/events/on_event_participant.dart';
import 'package:functions/utils/infra/firestore_utils.dart';
import 'package:test/test.dart';
import 'package:data_models/events/event.dart';

import '../util/community_test_utils.dart';
import '../util/event_test_utils.dart';
import '../util/function_test_fixture.dart';

void main() {
  late String communityId;
  const templateId = '9654';
  final eventUtils = EventTestUtils();
  final communityUtils = CommunityTestUtils();
  final onEventParticipant = OnEventParticipant();
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

  DocumentReference participantRef(String userId) {
    return firestore.document(
      '${testEvent.fullPath}/event-participants/$userId',
    );
  }

  Future<void> setMostRecentPresentTime(String userId, DateTime time) async {
    await participantRef(userId).updateData(
      UpdateData.fromMap({
        Participant.kFieldMostRecentPresentTime: Timestamp.fromDateTime(time),
      }),
    );
  }

  Future<Participant> getParticipant(String userId) async {
    final snapshot = await participantRef(userId).get();
    return Participant.fromJson(
      firestoreUtils.fromFirestoreJson(snapshot.data.toMap()),
    );
  }

  Future<void> joinEvent(String userId, {bool isPresent = true}) =>
      eventUtils.joinEvent(
        communityId: communityId,
        templateId: templateId,
        eventId: testEvent.id,
        uid: userId,
        isPresent: isPresent,
      );

  /// Runs recordFirstPresence with the participant as currently stored.
  Future<void> recordFirstPresence(String userId, DateTime updateTime) async {
    await onEventParticipant.recordFirstPresence(
      participantRef: participantRef(userId),
      participant: await getParticipant(userId),
      updateTime: updateTime,
    );
  }

  test('Records firstPresentTime from mostRecentPresentTime', () async {
    const userId = 'joinedUser';
    final presentTime = DateTime.utc(2026, 1, 1, 12);

    await joinEvent(userId);
    await setMostRecentPresentTime(userId, presentTime);
    await recordFirstPresence(userId, DateTime.utc(2026, 1, 1, 13));

    final participant = await getParticipant(userId);
    expect(participant.firstPresentTime?.toUtc(), equals(presentTime));
  });

  test('Does not overwrite an existing firstPresentTime', () async {
    const userId = 'rejoinedUser';
    final firstTime = DateTime.utc(2026, 1, 1, 12);
    final laterTime = DateTime.utc(2026, 1, 1, 12, 30);

    await joinEvent(userId);
    await setMostRecentPresentTime(userId, firstTime);
    await recordFirstPresence(userId, firstTime);

    await setMostRecentPresentTime(userId, laterTime);
    await recordFirstPresence(userId, laterTime);

    final participant = await getParticipant(userId);
    expect(participant.firstPresentTime?.toUtc(), equals(firstTime));
  });

  test('Skips participants who are not present', () async {
    const userId = 'absentUser';

    await joinEvent(userId, isPresent: false);
    await recordFirstPresence(userId, DateTime.utc(2026, 1, 1, 12));

    final participant = await getParticipant(userId);
    expect(participant.firstPresentTime, isNull);
  });

  test('Falls back to update time when mostRecentPresentTime is missing',
      () async {
    const userId = 'noHeartbeatUser';
    final updateTime = DateTime.utc(2026, 1, 1, 12);

    await joinEvent(userId);
    await recordFirstPresence(userId, updateTime);

    final participant = await getParticipant(userId);
    expect(participant.firstPresentTime?.toUtc(), equals(updateTime));
  });
}
