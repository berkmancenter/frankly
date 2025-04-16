import 'package:data_models/community/membership.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:functions/events/live_meetings/reset_participant_agenda_items.dart';
import 'package:functions/utils/infra/firestore_utils.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/meeting_guide.dart';
import 'package:test/test.dart';
import 'package:data_models/cloud_functions/requests.dart';
import '../../util/community_test_utils.dart';
import '../../util/event_test_utils.dart';
import '../../util/function_test_fixture.dart';
import '../../util/live_meeting_test_utils.dart';

void main() {
  late String communityId;
  const templateId = '9654';
  const liveMeetingId = 'testMeeting123';
  final eventUtils = EventTestUtils();
  final communityUtils = CommunityTestUtils();
  late Event testEvent;
  final liveMeetingTestUtils = LiveMeetingTestUtils();
  setupTestFixture();

  setUp(() async {
    communityId = await communityUtils.createTestCommunity();

    // Create test event
    testEvent = Event(
      id: '5678',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: adminUserId,
      nullableEventType: EventType.hostless,
      collectionPath: '',
      agendaItems: [
        AgendaItem(
          id: '55005',
          title: "Role call",
          content: "Shout out if you're here",
        ),
      ],
    );
    testEvent = await eventUtils.createEvent(
      event: testEvent,
      userId: adminUserId,
    );
    final liveMeetingPath = liveMeetingTestUtils.getLiveMeetingPath(testEvent);
    // Create live meeting
    await liveMeetingTestUtils.addMeetingEvent(
      liveMeetingPath: liveMeetingPath,
      liveMeetingId: liveMeetingId,
      meetingEvent: LiveMeetingEvent(
        event: LiveMeetingEventType.agendaItemStarted,
      ),
    );
    await liveMeetingTestUtils.addParticipantAgendaItemDetails(
      event: testEvent,
      participantAgendaItemDetails: ParticipantAgendaItemDetails(
        userId: 'user1',
        meetingId: liveMeetingPath.split('/').last,
      ),
      agendaItemId: testEvent.agendaItems.first.id,
    );
    await liveMeetingTestUtils.addParticipantAgendaItemDetails(
      event: testEvent,
      participantAgendaItemDetails: ParticipantAgendaItemDetails(
        userId: 'user2',
        meetingId: liveMeetingPath.split('/').last,
      ),
      agendaItemId: testEvent.agendaItems.first.id,
    );
  });

  test('Event creator can successfully reset participant agenda items',
      () async {
    final req = ResetParticipantAgendaItemsRequest(
      liveMeetingPath: liveMeetingTestUtils.getLiveMeetingPath(testEvent),
    );

    final resetAgendaItems = ResetParticipantAgendaItems();

    await resetAgendaItems.action(
      req,
      CallableContext(adminUserId, null, 'fakeInstanceId'),
    );

    // Verify that participant details were deleted
    final participantDetails = await firestore
        .collectionGroup('participant-details')
        .where(
          ParticipantAgendaItemDetails.kFieldMeetingId,
          isEqualTo: liveMeetingId,
        )
        .get();

    expect(participantDetails.documents, isEmpty);
  });

  test('Admin can successfully reset participant agenda items', () async {
    // Create admin user
    const adminUserId2 = 'adminUser';
    await communityUtils.addCommunityMember(
      communityId: communityId,
      userId: adminUserId2,
      status: MembershipStatus.admin,
    );

    final req = ResetParticipantAgendaItemsRequest(
      liveMeetingPath: liveMeetingTestUtils.getLiveMeetingPath(testEvent),
    );

    final resetAgendaItems = ResetParticipantAgendaItems();

    await resetAgendaItems.action(
      req,
      CallableContext(adminUserId2, null, 'fakeInstanceId'),
    );

    final participantDetails = await firestore
        .collectionGroup('participant-details')
        .where(
          ParticipantAgendaItemDetails.kFieldMeetingId,
          isEqualTo: liveMeetingId,
        )
        .get();

    expect(participantDetails.documents, isEmpty);
  });

  test('Regular user cannot reset participant agenda items', () async {
    // Create regular user
    const regularUserId = 'regularUser';
    await communityUtils.addCommunityMember(
      communityId: communityId,
      userId: regularUserId,
      status: MembershipStatus.member,
    );

    final req = ResetParticipantAgendaItemsRequest(
      liveMeetingPath: liveMeetingTestUtils.getLiveMeetingPath(testEvent),
    );

    final resetAgendaItems = ResetParticipantAgendaItems();

    expect(
      () => resetAgendaItems.action(
        req,
        CallableContext(regularUserId, null, 'fakeInstanceId'),
      ),
      throwsA(
        predicate(
          (e) =>
              e is HttpsError &&
              e.code == HttpsError.failedPrecondition &&
              e.message == 'Unauthorized',
        ),
      ),
    );
  });

  test('Throws error for malformed meeting path', () async {
    final req = ResetParticipantAgendaItemsRequest(
      liveMeetingPath: 'invalid/path',
    );

    final resetAgendaItems = ResetParticipantAgendaItems();

    expect(
      () => resetAgendaItems.action(
        req,
        CallableContext(adminUserId, null, 'fakeInstanceId'),
      ),
      throwsA(
        predicate(
          (e) =>
              e is HttpsError &&
              e.code == HttpsError.invalidArgument &&
              e.message == 'LiveMeetingPath malformed.',
        ),
      ),
    );
  });

  test('Throws error for non-existent meeting', () async {
    final req = ResetParticipantAgendaItemsRequest(
      liveMeetingPath:
          'community/$communityId/templates/$templateId/events/nonexistent/live-meetings/fake',
    );

    final resetAgendaItems = ResetParticipantAgendaItems();

    expect(
      () => resetAgendaItems.action(
        req,
        CallableContext(adminUserId, null, 'fakeInstanceId'),
      ),
      throwsA(
        predicate(
          (e) =>
              e is HttpsError &&
              e.code == HttpsError.failedPrecondition &&
              e.message == 'Incorrect meeting path',
        ),
      ),
    );
  });
}
