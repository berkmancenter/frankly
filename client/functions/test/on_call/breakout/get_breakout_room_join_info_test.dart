import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:get_it/get_it.dart';
import 'package:junto_functions/functions/on_call/get_breakout_room_join_info.dart';
import 'package:junto_functions/functions/on_call/live_meeting_utils.dart';

import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/live_meeting.dart';
import 'package:mocktail/mocktail.dart';

import 'package:test/test.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:uuid/uuid.dart';

import '../../util/community_test_utils.dart';
import '../../util/discussion_test_utils.dart';
import '../../util/live_meeting_test_utils.dart';

void main() {
  String juntoId = '';
  const userId = 'fakeAuthId';
  const topicId = '9654';
  const uuid = Uuid();
  final breakoutSessionId = uuid.v1().toString();
  GetIt.instance.registerSingleton(const Uuid());
  final discussionUtils = DiscussionTestUtils();
  final communityUtils = CommunityTestUtils();
  final liveMeetingUtils = LiveMeetingTestUtils();

  setUp(() async {
    setFirebaseAppFactory(() => FirebaseAdmin.instance.initializeApp()!);

    final testJunto = Junto(
      id: '6543',
      name: 'More Testing Community',
      isPublic: true,
      profileImageUrl: 'http://someimage.com',
      bannerImageUrl: 'http://mybanner.com',
    );

    final juntoResult = await communityUtils.createJunto(junto: testJunto, userId: userId);
    juntoId = juntoResult['juntoId'];
  });

  test('Participant join info is returned', () async {
    var discussion = Discussion(
      id: '8622',
      status: DiscussionStatus.active,
      juntoId: juntoId,
      topicId: topicId,
      creatorId: userId,
      nullableDiscussionType: DiscussionType.hosted,
      collectionPath: '',
      agendaItems: [AgendaItem(id: '555', title: "Role call", content: "Shout out if you're here")],
    );
    discussion = await discussionUtils.createDiscussion(discussion: discussion, userId: userId);

    await discussionUtils.joinDiscussionMultiple(
      juntoId: juntoId,
      topicId: topicId,
      discussionId: discussion.id,
      participantIds: ['333', '444', '555', '666'],
      breakoutSessionId: breakoutSessionId,
    );

    // add Junto members
    await communityUtils.addJuntoMember(userId: '333', juntoId: juntoId);
    await communityUtils.addJuntoMember(userId: '444', juntoId: juntoId);
    await communityUtils.addJuntoMember(userId: '555', juntoId: juntoId);
    await communityUtils.addJuntoMember(userId: '666', juntoId: juntoId);

    await liveMeetingUtils.addMeetingEvent(
      liveMeetingPath: liveMeetingUtils.getLiveMeetingPath(discussion),
      meetingEvent: LiveMeetingEvent(
        agendaItem: discussion.agendaItems.first.id,
        event: LiveMeetingEventType.agendaItemStarted,
      ),
    );

    await liveMeetingUtils.initiateBreakoutSession(
        discussion: discussion, breakoutSessionId: breakoutSessionId, userId: userId);

    // Retrieve a created breakout room
    final breakoutRoom = await liveMeetingUtils.getBreakoutRoom(
        discussion: discussion, breakoutSessionId: breakoutSessionId, roomName: '1');

    final agoraUtils = MockAgoraUtils();
    when(() => agoraUtils.createToken(
        uid: liveMeetingUtils.uidToInt('333'),
        roomId: breakoutRoom.roomId)).thenReturn('fakeToken');

    final req = GetBreakoutRoomJoinInfoRequest(
        discussionId: discussion.id,
        discussionPath: discussion.fullPath,
        breakoutRoomId: breakoutRoom.roomId,
        enableAudio: false,
        enableVideo: false);
    final roomInfo =
        GetBreakoutRoomJoinInfo(liveMeetingUtils: LiveMeetingUtils(agoraUtils: agoraUtils));

    //First user should have been put into room 1 by bucket assignment
    final result = await roomInfo.action(req, CallableContext('333', null, 'fakeInstanceId'));
    final expectedResult = {
      'identity': '333',
      'meetingToken': 'fakeToken',
      'meetingId': breakoutRoom.roomId
    };
    expect(result, equals(expectedResult));
  });
}
