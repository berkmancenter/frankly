import 'package:data_models/community/membership.dart';
import 'package:data_models/events/event_proposal.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:functions/events/live_meetings/vote_to_kick.dart';
import 'package:functions/utils/infra/firestore_utils.dart';

import 'package:data_models/events/event.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart'
    hide EventType;

import '../../util/community_test_utils.dart';
import '../../util/event_test_utils.dart';
import '../../util/function_test_fixture.dart';
import '../../util/live_meeting_test_utils.dart';

void main() {
  late String communityId;
  const targetUserId = 'testUser2';
  const templateId = '9654';
  const liveMeetingId = 'testMeeting123';
  //GetIt.instance.registerSingleton(const Uuid());
  final eventUtils = EventTestUtils();
  final communityUtils = CommunityTestUtils();
  late Event testEvent;
  late MockAgoraUtils mockAgoraUtils;
  setupTestFixture();

  setUp(() async {
    setFirebaseAppFactory(() => FirebaseAdmin.instance.initializeApp()!);

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
    );
    testEvent = await eventUtils.createEvent(
      event: testEvent,
      userId: adminUserId,
    );

    // Add participant
    await eventUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: testEvent.id,
      uid: targetUserId,
      participantStatus: ParticipantStatus.active,
    );

    mockAgoraUtils = MockAgoraUtils();
    when(
      () => mockAgoraUtils.kickParticipant(
        roomId: any(named: 'roomId'),
        userId: any(named: 'userId'),
      ),
    ).thenAnswer((_) => Future.value());
  });

  test('Successfully creates new kick proposal', () async {
    final req = VoteToKickRequest(
      eventPath: testEvent.fullPath,
      liveMeetingPath: '${testEvent.fullPath}/live-meetings/$liveMeetingId',
      targetUserId: targetUserId,
      inFavor: true,
      reason: 'Inappropriate behavior',
    );

    final voteToKick = VoteToKick(agoraUtils: mockAgoraUtils);

    await voteToKick.action(
      req,
      CallableContext(adminUserId, null, 'fakeInstanceId'),
    );

    final proposalsSnapshot = await firestore
        .collection('${req.liveMeetingPath}/proposals')
        .where('type', isEqualTo: 'kick')
        .where('targetUserId', isEqualTo: targetUserId)
        .get();

    expect(proposalsSnapshot.documents.length, equals(1));
    final proposal = EventProposal.fromJson(
      firestoreUtils.fromFirestoreJson(
        proposalsSnapshot.documents.first.data.toMap(),
      ),
    );
    expect(proposal.initiatingUserId, equals(adminUserId));
    expect(proposal.targetUserId, equals(targetUserId));
    expect(proposal.status, equals(EventProposalStatus.open));
    expect(proposal.votes?.length, equals(1));
    expect(proposal.votes?.first.inFavor, isTrue);
    expect(proposal.votes?.first.reason, equals('Inappropriate behavior'));
  });

  test('User gets kicked when receiving sufficient votes', () async {
    final req = VoteToKickRequest(
      eventPath: testEvent.fullPath,
      liveMeetingPath: '${testEvent.fullPath}/live-meetings/$liveMeetingId',
      targetUserId: targetUserId,
      inFavor: true,
      reason: 'Inappropriate behavior',
    );

    final voteToKick = VoteToKick(agoraUtils: mockAgoraUtils);

    // First vote
    await voteToKick.action(
      req,
      CallableContext(adminUserId, null, 'fakeInstanceId'),
    );

    // Second vote from different user
    await voteToKick.action(
      req,
      CallableContext('testUser3', null, 'fakeInstanceId'),
    );

    final participantSnapshot = await firestore
        .document('${testEvent.fullPath}/event-participants/$targetUserId')
        .get();
    final participant = Participant.fromJson(
      firestoreUtils.fromFirestoreJson(participantSnapshot.data.toMap()),
    );

    expect(participant.status, equals(ParticipantStatus.banned));

    verify(
      () => mockAgoraUtils.kickParticipant(
        roomId: liveMeetingId,
        userId: targetUserId,
      ),
    ).called(1);
  });

  test('Throws unauthorized error when target user is a moderator', () async {
    // Make target user a moderator

    await eventUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: testEvent.id,
      uid: targetUserId,
      participantStatus: ParticipantStatus.active,
      participantMembershipStatus: MembershipStatus.mod,
    );

    final req = VoteToKickRequest(
      eventPath: testEvent.fullPath,
      liveMeetingPath: '${testEvent.fullPath}/live-meetings/$liveMeetingId',
      targetUserId: targetUserId,
      inFavor: true,
      reason: 'Test reason',
    );

    final voteToKick = VoteToKick(agoraUtils: mockAgoraUtils);

    expect(
      () => voteToKick.action(
        req,
        CallableContext(adminUserId, null, 'fakeInstanceId'),
      ),
      throwsA(
        predicate(
          (e) =>
              e is HttpsError &&
              e.code == HttpsError.failedPrecondition &&
              e.message == 'unauthorized',
        ),
      ),
    );
  });

  test('Proposal gets rejected when receiving sufficient opposing votes',
      () async {
    final req = VoteToKickRequest(
      eventPath: testEvent.fullPath,
      liveMeetingPath: '${testEvent.fullPath}/live-meetings/$liveMeetingId',
      targetUserId: targetUserId,
      inFavor: false,
      reason: 'Not necessary',
    );

    final voteToKick = VoteToKick(agoraUtils: mockAgoraUtils);

    // First vote against
    await voteToKick.action(
      req,
      CallableContext(adminUserId, null, 'fakeInstanceId'),
    );

    // Second vote against from different user
    await voteToKick.action(
      req,
      CallableContext('testUser3', null, 'fakeInstanceId'),
    );

    final proposalsSnapshot = await firestore
        .collection('${req.liveMeetingPath}/proposals')
        .where('type', isEqualTo: 'kick')
        .where('targetUserId', isEqualTo: targetUserId)
        .get();

    final proposal = EventProposal.fromJson(
      firestoreUtils.fromFirestoreJson(
        proposalsSnapshot.documents.first.data.toMap(),
      ),
    );

    expect(proposal.status, equals(EventProposalStatus.rejected));
    expect(proposal.closedAt, isNotNull);
  });
}
