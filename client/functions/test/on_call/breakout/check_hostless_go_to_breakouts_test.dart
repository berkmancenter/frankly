import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/on_call/check_hostless_go_to_breakouts.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/live_meeting.dart';
import 'package:test/test.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import '../../util/community_test_utils.dart';
import '../../util/discussion_test_utils.dart';
import '../../util/live_meeting_test_utils.dart';

void main() {
  String juntoId = '';
  const userId = 'fakeAuthId';
  const topicId = '9654';
  final communityTestUtils = CommunityTestUtils();
  final discussionTestUtils = DiscussionTestUtils();
  final liveMeetingTestUtils = LiveMeetingTestUtils();

  setUp(() async {
    setFirebaseAppFactory(() => FirebaseAdmin.instance.initializeApp()!);

    final testJunto = Junto(
      id: '1234',
      name: 'Testing Community',
      isPublic: true,
      profileImageUrl: 'http://someimage.com',
      bannerImageUrl: 'http://mybanner.com',
    );

    final juntoResult = await communityTestUtils.createJunto(junto: testJunto, userId: userId);
    juntoId = juntoResult['juntoId'];
  });

  test('Breakouts are initiated for a hostless event', () async {
    var discussion = Discussion(
      id: '1234',
      status: DiscussionStatus.active,
      juntoId: juntoId,
      topicId: topicId,
      creatorId: userId,
      nullableDiscussionType: DiscussionType.hostless,
      collectionPath: '',
      agendaItems: [
        AgendaItem(id: '555', title: "Role call", content: "Shout out if you're here"),
      ],
      scheduledTime: DateTime.now().subtract(const Duration(minutes: 5)),
      waitingRoomInfo: const WaitingRoomInfo(durationSeconds: 60),
    );
    discussion = await discussionTestUtils.createDiscussion(discussion: discussion, userId: userId);
    await liveMeetingTestUtils.addMeetingEvent(
      liveMeetingPath: liveMeetingTestUtils.getLiveMeetingPath(discussion),
      meetingEvent: LiveMeetingEvent(
        agendaItem: discussion.agendaItems.first.id,
        event: LiveMeetingEventType.agendaItemStarted,
      ),
    );

    final req = CheckHostlessGoToBreakoutsRequest(discussionPath: discussion.fullPath);
    final checker = CheckHostlessGoToBreakouts();
    // We may be able to reorganize to mock out the functions scheduler to avoid exception
    try {
      await checker.action(req, CallableContext(userId, null, 'fakeInstanceId'));
    } catch (e) {
      //Expect enqueuing to fail, can proceed with validating that the data was updated
    }

    final meetingRef =
        await firestore.document(liveMeetingTestUtils.getLiveMeetingPath(discussion)).get();
    final meeting = LiveMeeting.fromJson(firestoreUtils.fromFirestoreJson(meetingRef.data.toMap()));
    expect(meeting.currentBreakoutSession, isNotNull);

    final expectedBreakout = BreakoutRoomSession(
      breakoutRoomSessionId: discussion.id, // this is expected for hostless events
      breakoutRoomStatus: BreakoutRoomStatus.pending,
      assignmentMethod: BreakoutAssignmentMethod.targetPerRoom,
      targetParticipantsPerRoom: 8, //default
      hasWaitingRoom: true,
      statusUpdatedTime: meeting.currentBreakoutSession!.statusUpdatedTime,
      createdDate: meeting.currentBreakoutSession!.createdDate,
      scheduledTime: meeting.currentBreakoutSession!.scheduledTime,
    );

    expect(meeting.currentBreakoutSession, equals(expectedBreakout));
  });
}
