import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:get_it/get_it.dart';
import 'package:functions/events/live_meetings/breakouts/get_breakout_room_join_info.dart';
import 'package:functions/events/live_meetings/live_meeting_utils.dart';

import 'package:data_models/firestore/event.dart';
import 'package:data_models/firestore/community.dart';
import 'package:data_models/firestore/live_meeting.dart';
import 'package:mocktail/mocktail.dart';

import 'package:test/test.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:functions/utils/infra/firestore_utils.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart'
    hide EventType;
import 'package:uuid/uuid.dart';

import '../../../util/community_test_utils.dart';
import '../../../util/event_test_utils.dart';
import '../../../util/live_meeting_test_utils.dart';

void main() {
  String communityId = '';
  const userId = 'fakeAuthId';
  const templateId = '9654';
  const uuid = Uuid();
  final breakoutSessionId = uuid.v1().toString();
  GetIt.instance.registerSingleton(const Uuid());
  final eventUtils = EventTestUtils();
  final communityUtils = CommunityTestUtils();
  final liveMeetingUtils = LiveMeetingTestUtils();

  setUp(() async {
    setFirebaseAppFactory(() => FirebaseAdmin.instance.initializeApp()!);

    final testCommunity = Community(
      id: '6543',
      name: 'More Testing Community',
      isPublic: true,
      profileImageUrl: 'http://someimage.com',
      bannerImageUrl: 'http://mybanner.com',
    );

    final communityResult = await communityUtils.createCommunity(
      community: testCommunity,
      userId: userId,
    );
    communityId = communityResult['communityId'];
  });

  test('Participant join info is returned', () async {
    var event = Event(
      id: '8622',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: userId,
      nullableEventType: EventType.hosted,
      collectionPath: '',
      agendaItems: [
        AgendaItem(
          id: '555',
          title: "Role call",
          content: "Shout out if you're here",
        ),
      ],
    );
    event = await eventUtils.createEvent(
      event: event,
      userId: userId,
    );

    await eventUtils.joinEventMultiple(
      communityId: communityId,
      templateId: templateId,
      eventId: event.id,
      participantIds: ['333', '444', '555', '666'],
      breakoutSessionId: breakoutSessionId,
    );

    // add Community members
    await communityUtils.addCommunityMember(
      userId: '333',
      communityId: communityId,
    );
    await communityUtils.addCommunityMember(
      userId: '444',
      communityId: communityId,
    );
    await communityUtils.addCommunityMember(
      userId: '555',
      communityId: communityId,
    );
    await communityUtils.addCommunityMember(
      userId: '666',
      communityId: communityId,
    );

    await liveMeetingUtils.addMeetingEvent(
      liveMeetingPath: liveMeetingUtils.getLiveMeetingPath(event),
      meetingEvent: LiveMeetingEvent(
        agendaItem: event.agendaItems.first.id,
        event: LiveMeetingEventType.agendaItemStarted,
      ),
    );

    await liveMeetingUtils.initiateBreakoutSession(
      event: event,
      breakoutSessionId: breakoutSessionId,
      userId: userId,
    );

    // Retrieve a created breakout room
    final breakoutRoom = await liveMeetingUtils.getBreakoutRoom(
      event: event,
      breakoutSessionId: breakoutSessionId,
      roomName: '1',
    );

    final agoraUtils = MockAgoraUtils();
    when(
      () => agoraUtils.createToken(
        uid: liveMeetingUtils.uidToInt('333'),
        roomId: breakoutRoom.roomId,
      ),
    ).thenReturn('fakeToken');

    final req = GetBreakoutRoomJoinInfoRequest(
      eventId: event.id,
      eventPath: event.fullPath,
      breakoutRoomId: breakoutRoom.roomId,
      enableAudio: false,
      enableVideo: false,
    );
    final roomInfo = GetBreakoutRoomJoinInfo(
      liveMeetingUtils: LiveMeetingUtils(agoraUtils: agoraUtils),
    );

    //First user should have been put into room 1 by bucket assignment
    final result = await roomInfo.action(
      req,
      CallableContext('333', null, 'fakeInstanceId'),
    );
    final expectedResult = {
      'identity': '333',
      'meetingToken': 'fakeToken',
      'meetingId': breakoutRoom.roomId,
    };
    expect(result, equals(expectedResult));
  });
}
