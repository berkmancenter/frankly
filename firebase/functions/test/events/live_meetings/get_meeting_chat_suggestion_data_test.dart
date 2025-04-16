import 'package:data_models/chat/emotion.dart';
import 'package:data_models/events/live_meetings/meeting_guide.dart';
import 'package:data_models/user/public_user_info.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:functions/events/live_meetings/get_meeting_chat_suggestion_data.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/chat/chat.dart';
import 'package:data_models/chat/chat_suggestion_data.dart';
import 'package:functions/utils/infra/firebase_auth_utils.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:data_models/cloud_functions/requests.dart';
import '../../util/community_test_utils.dart';
import '../../util/event_test_utils.dart';
import '../../util/function_test_fixture.dart';
import '../../util/live_meeting_test_utils.dart';

void main() {
  late String communityId;
  const templateId = '9654';
  final eventUtils = EventTestUtils();
  final communityUtils = CommunityTestUtils();
  final liveMeetingTestUtils = LiveMeetingTestUtils();
  final mockFirebaseAuthUtils = MockFirebaseAuthUtils();
  firebaseAuthUtils = mockFirebaseAuthUtils;
  setupTestFixture();

  setUp(() async {
    communityId = await communityUtils.createTestCommunity();
  });

  test('Chat suggestion data is returned correctly', () async {
    var event = Event(
      id: '5678',
      status: EventStatus.active,
      communityId: communityId,
      templateId: templateId,
      creatorId: adminUserId,
      nullableEventType: EventType.hosted,
      collectionPath: '',
      agendaItems: [
        AgendaItem(
          id: '555',
          title: "Discussion",
          content: "Group discussion topic",
          nullableType: AgendaItemType.userSuggestions,
        ),
      ],
    );

    event = await eventUtils.createEvent(
      event: event,
      userId: adminUserId,
    );

    // Add test participants
    await eventUtils.joinEventMultiple(
      communityId: communityId,
      templateId: templateId,
      eventId: event.id,
      participantIds: ['333', '444'],
      breakoutSessionId: null,
    );

    // Add Community members with public user info
    await communityUtils.addCommunityMember(
      userId: '333',
      communityId: communityId,
    );
    await communityUtils.addCommunityMember(
      userId: '444',
      communityId: communityId,
    );

    final publicUserInfo1 = PublicUserInfo(
      id: '333',
      displayName: 'Test User 1',
      agoraId: 123,
    );
    await liveMeetingTestUtils.addPublicUser(publicUser: publicUserInfo1);

    final publicUserInfo2 = PublicUserInfo(
      id: '444',
      displayName: 'Test User 2',
      agoraId: 456,
    );
    await liveMeetingTestUtils.addPublicUser(publicUser: publicUserInfo2);

    // Add some test chat messages
    await liveMeetingTestUtils.addChatMessage(
      parentPath: event.fullPath,
      message: ChatMessage(
        creatorId: '333',
        message: 'Hello everyone',
        createdDate: DateTime.now(),
        messageStatus: ChatMessageStatus.active,
        emotionType: EmotionType.exclamation,
      ),
    );

    // Add some test suggestions
    await liveMeetingTestUtils.addSuggestedAgendaItem(
      parentPath: event.fullPath,
      suggestion: SuggestedAgendaItem(
        creatorId: '444',
        content: 'Let\'s discuss this topic',
        createdDate: DateTime.now(),
        upvotedUserIds: ['333'],
        downvotedUserIds: [],
      ),
    );
    final liveMeetingPath = liveMeetingTestUtils.getLiveMeetingPath(event);
    await liveMeetingTestUtils.addParticipantAgendaItemDetails(
      event: event,
      participantAgendaItemDetails: ParticipantAgendaItemDetails(
        userId: '333',
        meetingId: liveMeetingPath.split('/').last,
        suggestions: [
          MeetingUserSuggestion(id: '6221', suggestion: 'Do something else'),
        ],
      ),
      agendaItemId: event.agendaItems.first.id,
    );
    final userRecord = MockUserRecord();
    when(() => userRecord.uid).thenReturn('333');
    when(() => userRecord.email).thenReturn('requester@example.com');
    when(() => userRecord.displayName).thenReturn('Test User 1');
    when(
      () => mockFirebaseAuthUtils.getUser('333'),
    ).thenAnswer((_) async => userRecord);

    final userRecord2 = MockUserRecord();
    when(() => userRecord2.uid).thenReturn('444');
    when(() => userRecord2.email).thenReturn('requester2@example.com');
    when(() => userRecord2.displayName).thenReturn('Test User 2');
    when(
      () => mockFirebaseAuthUtils.getUser('444'),
    ).thenAnswer((_) async => userRecord2);

    final req = GetMeetingChatsSuggestionsDataRequest(
      eventPath: event.fullPath,
    );

    final chatInfo = GetMeetingChatSuggestionData();

    final result = await chatInfo.action(
      req,
      CallableContext(adminUserId, null, 'fakeInstanceId'),
    );

    expect(result['chatsSuggestionsList'], isNotNull);
    final suggestions = (result['chatsSuggestionsList'] as List)
        .map((item) => ChatSuggestionData.fromJson(item))
        .toList();
    expect(suggestions.length, equals(3));

    // Verify chat message
    final chatMessage = suggestions.firstWhere(
      (s) => s.type == ChatSuggestionType.chat,
    );
    expect(chatMessage.creatorId, equals('333'));
    expect(chatMessage.message, equals('Hello everyone'));
    expect(chatMessage.emotionType, equals(EmotionType.exclamation));
    expect(chatMessage.creatorName, equals('Test User 1'));

    // Verify suggestion
    final suggestion = suggestions.firstWhere(
      (s) => s.type == ChatSuggestionType.suggestion && s.creatorId == '444',
    );
    expect(suggestion.message, equals('Let\'s discuss this topic'));
    expect(suggestion.upvotes, equals(1));
    expect(suggestion.downvotes, equals(0));
    expect(suggestion.creatorName, equals('Test User 2'));

    // Verify agenda item details
    final agendaItemDetails = suggestions.firstWhere(
      (s) => s.type == ChatSuggestionType.suggestion && s.creatorId == '333',
    );
    expect(agendaItemDetails.message, equals('Do something else'));
    expect(agendaItemDetails.upvotes, equals(0));
    expect(agendaItemDetails.downvotes, equals(0));
    expect(agendaItemDetails.creatorName, equals('Test User 1'));
  });
}
