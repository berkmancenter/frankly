@Timeout(Duration(seconds: 90))
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:functions/events/live_meetings/update_live_stream_participant_count.dart';
import 'package:functions/utils/infra/firestore_utils.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:data_models/events/event.dart';
import 'package:uuid/uuid.dart';
import 'package:get_it/get_it.dart';
import '../../util/community_test_utils.dart';
import '../../util/event_test_utils.dart';
import '../../util/function_test_fixture.dart';

void main() {
  late String communityId;
  const templateId = '9654';
  GetIt.instance.registerSingleton(const Uuid());
  final eventUtils = EventTestUtils();
  final communityUtils = CommunityTestUtils();
  setupTestFixture();

  setUp(() async {
    communityId = await communityUtils.createTestCommunity();
  });

  test('Updates participant counts for multiple active livestream events',
      () async {
    // Create first test event
    var event1 = Event(
      id: '5678',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: adminUserId,
      nullableEventType: EventType.livestream,
      collectionPath: '',
      scheduledTime: DateTime.now().add(const Duration(hours: 1)),
      participantCountEstimate: 0,
      presentParticipantCountEstimate: 0,
    );

    event1 = await eventUtils.createEvent(
      event: event1,
      userId: adminUserId,
    );

    // Create second test event
    var event2 = Event(
      id: '9012',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: adminUserId,
      nullableEventType: EventType.livestream,
      collectionPath: '',
      scheduledTime: DateTime.now().add(const Duration(minutes: 30)),
      participantCountEstimate: 0,
      presentParticipantCountEstimate: 0,
    );

    event2 = await eventUtils.createEvent(
      event: event2,
      userId: adminUserId,
    );

    // Add participants to first event
    final participants1 = [
      {'userId': 'user1', 'isPresent': true},
      {'userId': 'user2', 'isPresent': true},
      {'userId': 'user3', 'isPresent': false},
    ];

    for (final participant in participants1) {
      await eventUtils.joinEvent(
        communityId: communityId,
        templateId: templateId,
        eventId: event1.id,
        uid: participant['userId']! as String,
        participantStatus: ParticipantStatus.active,
        isPresent: participant['isPresent']! as bool,
      );
    }

    // Add participants to second event
    final participants2 = [
      {'userId': 'user4', 'isPresent': true},
      {'userId': 'user5', 'isPresent': false},
    ];

    for (final participant in participants2) {
      await eventUtils.joinEvent(
        communityId: communityId,
        templateId: templateId,
        eventId: event2.id,
        uid: participant['userId']! as String,
        participantStatus: ParticipantStatus.active,
        isPresent: participant['isPresent']! as bool,
      );
    }

    // Add banned participants to both events that shouldn't be counted
    await eventUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: event1.id,
      uid: 'bannedUser1',
      participantStatus: ParticipantStatus.banned,
      isPresent: true,
    );

    await eventUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: event2.id,
      uid: 'bannedUser2',
      participantStatus: ParticipantStatus.banned,
      isPresent: true,
    );

    // Simulate scheduled function execution
    final updateFunction = UpdateLiveStreamParticipantCount();
    await updateFunction.action(MockEventContext());

    // Verify updated counts for first event
    final updatedEventDoc1 = await firestore.document(event1.fullPath).get();
    final updatedEvent1 = Event.fromJson(
      firestoreUtils.fromFirestoreJson(updatedEventDoc1.data.toMap()),
    );

    expect(updatedEvent1.participantCountEstimate, equals(4));
    // event creator not present
    expect(updatedEvent1.presentParticipantCountEstimate, equals(2));

    // Verify updated counts for second event
    final updatedEventDoc2 = await firestore.document(event2.fullPath).get();
    final updatedEvent2 = Event.fromJson(
      firestoreUtils.fromFirestoreJson(updatedEventDoc2.data.toMap()),
    );

    expect(updatedEvent2.participantCountEstimate, equals(3));
    expect(updatedEvent2.presentParticipantCountEstimate, equals(1));
  });

  test('Skips hosted events and events outside time window', () async {
    // Create hosted event (should be skipped)
    var hostedEvent = Event(
      id: '5678',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: adminUserId,
      nullableEventType: EventType.hosted,
      collectionPath: '',
      scheduledTime: DateTime.now().add(const Duration(hours: 1)),
      participantCountEstimate: 0,
      presentParticipantCountEstimate: 0,
    );

    hostedEvent = await eventUtils.createEvent(
      event: hostedEvent,
      userId: adminUserId,
    );

    // Create future event (should be skipped)
    var futureEvent = Event(
      id: '9012',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: adminUserId,
      nullableEventType: EventType.livestream,
      collectionPath: '',
      scheduledTime: DateTime.now().add(const Duration(days: 2)),
      participantCountEstimate: 0,
      presentParticipantCountEstimate: 0,
    );

    futureEvent = await eventUtils.createEvent(
      event: futureEvent,
      userId: adminUserId,
    );

    // Add participants to both events
    await eventUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: hostedEvent.id,
      uid: 'user1',
      participantStatus: ParticipantStatus.active,
      isPresent: true,
    );

    await eventUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: futureEvent.id,
      uid: 'user2',
      participantStatus: ParticipantStatus.active,
      isPresent: true,
    );

    // Simulate scheduled function execution
    final updateFunction = UpdateLiveStreamParticipantCount();
    await updateFunction.action(MockEventContext());
    // Verify hosted event counts weren't updated
    final updatedHostedDoc =
        await firestore.document(hostedEvent.fullPath).get();
    final updatedHostedEvent = Event.fromJson(
      firestoreUtils.fromFirestoreJson(updatedHostedDoc.data.toMap()),
    );

    expect(updatedHostedEvent.participantCountEstimate, equals(0));
    expect(updatedHostedEvent.presentParticipantCountEstimate, equals(0));

    // Verify future event counts weren't updated
    final updatedFutureDoc =
        await firestore.document(futureEvent.fullPath).get();
    final updatedFutureEvent = Event.fromJson(
      firestoreUtils.fromFirestoreJson(updatedFutureDoc.data.toMap()),
    );

    expect(updatedFutureEvent.participantCountEstimate, equals(0));
    expect(updatedFutureEvent.presentParticipantCountEstimate, equals(0));
  });
}

class MockEventContext extends Mock implements EventContext {}
