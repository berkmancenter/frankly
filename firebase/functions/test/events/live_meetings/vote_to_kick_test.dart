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

  test(
      'Ghost participants (isPresent: false) are excluded from voting denominator',
      () async {
    // Set up a room with 2 present voters and 5 ghost participants.
    // Before the isPresent filter was added to VoteToKick, ghost participants
    // inflated the denominator, requiring 7+ votes to kick instead of 2.
    // With the fix, only isPresent == true participants count, so 2 votes kick.
    const voter1 = 'voter1Ghost';
    const voter2 = 'voter2Ghost';

    // Two present participants in the room (eligible voters).
    await eventUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: testEvent.id,
      uid: voter1,
      participantStatus: ParticipantStatus.active,
      currentBreakoutRoomId: liveMeetingId,
      isPresent: true,
    );
    await eventUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: testEvent.id,
      uid: voter2,
      participantStatus: ParticipantStatus.active,
      currentBreakoutRoomId: liveMeetingId,
      isPresent: true,
    );

    // Five ghost participants in the same room — should be invisible to the
    // kick denominator because isPresent == false.
    for (int i = 1; i <= 5; i++) {
      await eventUtils.joinEvent(
        communityId: communityId,
        templateId: templateId,
        eventId: testEvent.id,
        uid: 'ghostUser$i',
        participantStatus: ParticipantStatus.active,
        currentBreakoutRoomId: liveMeetingId,
        isPresent: false,
      );
    }

    final voteToKick = VoteToKick(agoraUtils: mockAgoraUtils);
    final req = VoteToKickRequest(
      eventPath: testEvent.fullPath,
      liveMeetingPath: '${testEvent.fullPath}/live-meetings/$liveMeetingId',
      targetUserId: targetUserId,
      inFavor: true,
      reason: 'Test ghost exclusion',
    );

    // First in-favor vote from voter1.
    await voteToKick.action(
      req,
      CallableContext(voter1, null, 'fakeInstanceId'),
    );

    // Second in-favor vote from voter2 — with ghosts excluded, denominator is
    // 2 (voter1 + voter2), so 2 votes satisfies inFavorCount > 1 && >= 2.
    await voteToKick.action(
      req,
      CallableContext(voter2, null, 'fakeInstanceId'),
    );

    final participantSnapshot = await firestore
        .document('${testEvent.fullPath}/event-participants/$targetUserId')
        .get();
    final participant = Participant.fromJson(
      firestoreUtils.fromFirestoreJson(participantSnapshot.data.toMap()),
    );

    // User should be kicked — ghost participants did not inflate the threshold.
    expect(participant.status, equals(ParticipantStatus.banned));

    verify(
      () => mockAgoraUtils.kickParticipant(
        roomId: any(named: 'roomId'),
        userId: targetUserId,
      ),
    ).called(1);
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

  test('Kick threshold scales with number of participants in the room',
      () async {
    const voter1 = 'voter1';
    const voter2 = 'voter2';
    const voter3 = 'voter3';

    // Add three voters to the same room as the target
    for (final uid in [voter1, voter2, voter3]) {
      await eventUtils.joinEvent(
        communityId: communityId,
        templateId: templateId,
        eventId: testEvent.id,
        uid: uid,
        isPresent: true,
      );
      await firestore
          .document('${testEvent.fullPath}/event-participants/$uid')
          .updateData(UpdateData.fromMap({
            Participant.kFieldCurrentBreakoutRoomId: liveMeetingId,
          }),);
    }
    // Place target in the same room
    await firestore
        .document('${testEvent.fullPath}/event-participants/$targetUserId')
        .updateData(UpdateData.fromMap({
          Participant.kFieldCurrentBreakoutRoomId: liveMeetingId,
        }),);

    final req = VoteToKickRequest(
      eventPath: testEvent.fullPath,
      liveMeetingPath: '${testEvent.fullPath}/live-meetings/$liveMeetingId',
      targetUserId: targetUserId,
      inFavor: true,
      reason: 'Test',
    );

    final voteToKick = VoteToKick(agoraUtils: mockAgoraUtils);

    // Two in-favor votes (need all 3 voting participants to reach threshold)
    await voteToKick.action(
      req,
      CallableContext(voter1, null, 'fakeInstanceId'),
    );
    await voteToKick.action(
      req,
      CallableContext(voter2, null, 'fakeInstanceId'),
    );

    // Should NOT be kicked yet (2 votes, 3 voting participants in room)
    var participantSnapshot = await firestore
        .document('${testEvent.fullPath}/event-participants/$targetUserId')
        .get();
    var participant = Participant.fromJson(
      firestoreUtils.fromFirestoreJson(participantSnapshot.data.toMap()),
    );
    expect(participant.status, equals(ParticipantStatus.active));

    // Third vote reaches the threshold
    await voteToKick.action(
      req,
      CallableContext(voter3, null, 'fakeInstanceId'),
    );

    participantSnapshot = await firestore
        .document('${testEvent.fullPath}/event-participants/$targetUserId')
        .get();
    participant = Participant.fromJson(
      firestoreUtils.fromFirestoreJson(participantSnapshot.data.toMap()),
    );
    expect(participant.status, equals(ParticipantStatus.banned));
  });

  test('Participants in other rooms do not affect kick threshold', () async {
    const inRoomVoter = 'inRoomVoter';
    const otherRoomUser = 'otherRoomUser';

    // One voter in the target room
    await eventUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: testEvent.id,
      uid: inRoomVoter,
      isPresent: true,
    );
    await firestore
        .document('${testEvent.fullPath}/event-participants/$inRoomVoter')
        .updateData(UpdateData.fromMap({
          Participant.kFieldCurrentBreakoutRoomId: liveMeetingId,
        }),);

    // One participant in a different room (should not count)
    await eventUtils.joinEvent(
      communityId: communityId,
      templateId: templateId,
      eventId: testEvent.id,
      uid: otherRoomUser,
      isPresent: true,
    );
    await firestore
        .document('${testEvent.fullPath}/event-participants/$otherRoomUser')
        .updateData(UpdateData.fromMap({
          Participant.kFieldCurrentBreakoutRoomId: 'some-other-room',
        }),);

    // Place target in the room
    await firestore
        .document('${testEvent.fullPath}/event-participants/$targetUserId')
        .updateData(UpdateData.fromMap({
          Participant.kFieldCurrentBreakoutRoomId: liveMeetingId,
        }),);

    final req = VoteToKickRequest(
      eventPath: testEvent.fullPath,
      liveMeetingPath: '${testEvent.fullPath}/live-meetings/$liveMeetingId',
      targetUserId: targetUserId,
      inFavor: true,
      reason: 'Test',
    );

    final voteToKick = VoteToKick(agoraUtils: mockAgoraUtils);

    // First vote
    await voteToKick.action(
      req,
      CallableContext(adminUserId, null, 'fakeInstanceId'),
    );

    // Second vote from the in-room participant (only 1 voting participant
    // in the room, so 2 votes should meet the threshold)
    await voteToKick.action(
      req,
      CallableContext(inRoomVoter, null, 'fakeInstanceId'),
    );

    final participantSnapshot = await firestore
        .document('${testEvent.fullPath}/event-participants/$targetUserId')
        .get();
    final participant = Participant.fromJson(
      firestoreUtils.fromFirestoreJson(participantSnapshot.data.toMap()),
    );

    // Kick succeeds because otherRoomUser doesn't count toward the threshold
    expect(participant.status, equals(ParticipantStatus.banned));
  });
}
