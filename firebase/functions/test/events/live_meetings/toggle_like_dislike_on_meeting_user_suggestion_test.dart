import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:functions/events/live_meetings/toggle_like_dislike_on_meeting_user_suggestion.dart';
import 'package:functions/utils/infra/firestore_utils.dart';

import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/meeting_guide.dart';
import 'package:data_models/discussion_threads/discussion_thread.dart';
import 'package:test/test.dart';
import '../../util/community_test_utils.dart';
import '../../util/event_test_utils.dart';
import '../../util/function_test_fixture.dart';
import '../../util/live_meeting_test_utils.dart';

void main() {
  const voterId = 'voterUser1';
  const suggestionId = 'suggestion123';
  const liveMeetingId = 'testMeeting123';
  const agendaItemId = 'agendaItem123';
  final liveMeetingTestUtils = LiveMeetingTestUtils();
  final communityUtils = CommunityTestUtils();
  final eventUtils = EventTestUtils();
  late ParticipantAgendaItemDetails testAgendaItemDetails;
  late String documentPath;
  late String userSuggestionId;
  setupTestFixture();

  setUp(() async {
    final communityId = await communityUtils.createTestCommunity();
    // Create test agenda item details with a suggestion
    testAgendaItemDetails = ParticipantAgendaItemDetails(
      userId: adminUserId,
      meetingId: liveMeetingId,
      suggestions: [
        MeetingUserSuggestion(
          id: suggestionId,
          suggestion: 'Test suggestion',
          likedByIds: [],
          dislikedByIds: [],
        ),
      ],
    );
    userSuggestionId = testAgendaItemDetails.suggestions.first.id;
    // Create test event and add participant agenda item details
    var testEvent = Event(
      id: '5678',
      status: EventStatus.active,
      communityId: communityId,
      templateId: 'template123',
      creatorId: adminUserId,
      nullableEventType: EventType.hostless,
      collectionPath: '',
      agendaItems: [
        AgendaItem(
          id: agendaItemId,
          title: "Test Agenda",
          content: "Test Content",
        ),
      ],
    );
    testEvent = await eventUtils.createEvent(
      event: testEvent,
      userId: adminUserId,
    );
    await liveMeetingTestUtils.addParticipantAgendaItemDetails(
      event: testEvent,
      participantAgendaItemDetails: testAgendaItemDetails,
      agendaItemId: agendaItemId,
    );
    documentPath =
        '${liveMeetingTestUtils.getLiveMeetingPath(testEvent)}/participant-agenda-item-details/${testEvent.agendaItems.first.id}/participant-details/$adminUserId';
  });

  test('Successfully toggle like on user suggestion', () async {
    final req = ParticipantAgendaItemDetailsMeta(
      documentPath: documentPath,
      userSuggestionId: userSuggestionId,
      voterId: voterId,
      likeType: LikeType.like,
    );

    final toggleLikeDislike = ToggleLikeDislikeOnMeetingUserSuggestion();

    await toggleLikeDislike.action(
      req,
      CallableContext(voterId, null, 'fakeInstanceId'),
    );

    // Verify that like was added
    final updatedDoc = await firestore.document(documentPath).get();
    final updatedDetails = ParticipantAgendaItemDetails.fromJson(
      firestoreUtils.fromFirestoreJson(updatedDoc.data.toMap()),
    );

    final suggestion = updatedDetails.suggestions.first;
    expect(suggestion.likedByIds, contains(voterId));
    expect(suggestion.dislikedByIds, isEmpty);
  });

  test('Successfully toggle dislike on user suggestion', () async {
    final req = ParticipantAgendaItemDetailsMeta(
      documentPath: documentPath,
      userSuggestionId: suggestionId,
      voterId: voterId,
      likeType: LikeType.dislike,
    );

    final toggleLikeDislike = ToggleLikeDislikeOnMeetingUserSuggestion();

    await toggleLikeDislike.action(
      req,
      CallableContext(voterId, null, 'fakeInstanceId'),
    );

    // Verify that dislike was added
    final updatedDoc = await firestore.document(documentPath).get();
    final updatedDetails = ParticipantAgendaItemDetails.fromJson(
      firestoreUtils.fromFirestoreJson(updatedDoc.data.toMap()),
    );

    final suggestion = updatedDetails.suggestions.first;
    expect(suggestion.dislikedByIds, contains(voterId));
    expect(suggestion.likedByIds, isEmpty);
  });

  test('Successfully remove like/dislike when toggling to neutral', () async {
    // First add a like
    final addLikeReq = ParticipantAgendaItemDetailsMeta(
      documentPath: documentPath,
      userSuggestionId: suggestionId,
      voterId: voterId,
      likeType: LikeType.like,
    );

    final toggleLikeDislike = ToggleLikeDislikeOnMeetingUserSuggestion();

    await toggleLikeDislike.action(
      addLikeReq,
      CallableContext(voterId, null, 'fakeInstanceId'),
    );

    // Then toggle to neutral
    final neutralReq = ParticipantAgendaItemDetailsMeta(
      documentPath: documentPath,
      userSuggestionId: suggestionId,
      voterId: voterId,
      likeType: LikeType.neutral,
    );

    await toggleLikeDislike.action(
      neutralReq,
      CallableContext(voterId, null, 'fakeInstanceId'),
    );

    // Verify that like was removed
    final updatedDoc = await firestore.document(documentPath).get();
    final updatedDetails = ParticipantAgendaItemDetails.fromJson(
      firestoreUtils.fromFirestoreJson(updatedDoc.data.toMap()),
    );

    final suggestion = updatedDetails.suggestions.first;
    expect(suggestion.likedByIds, isEmpty);
    expect(suggestion.dislikedByIds, isEmpty);
  });

  test('No effect when toggling like on non-existent suggestion', () async {
    final req = ParticipantAgendaItemDetailsMeta(
      documentPath: documentPath,
      userSuggestionId: 'nonexistent',
      voterId: voterId,
      likeType: LikeType.like,
    );

    final toggleLikeDislike = ToggleLikeDislikeOnMeetingUserSuggestion();

    await toggleLikeDislike.action(
      req,
      CallableContext(voterId, null, 'fakeInstanceId'),
    );

    // Verify that nothing changed
    final updatedDoc = await firestore.document(documentPath).get();
    final updatedDetails = ParticipantAgendaItemDetails.fromJson(
      firestoreUtils.fromFirestoreJson(updatedDoc.data.toMap()),
    );

    final suggestion = updatedDetails.suggestions.first;
    expect(suggestion.likedByIds, isEmpty);
    expect(suggestion.dislikedByIds, isEmpty);
  });

  test('No effect when document path does not exist', () async {
    final req = ParticipantAgendaItemDetailsMeta(
      documentPath: 'invalid/path',
      userSuggestionId: suggestionId,
      voterId: voterId,
      likeType: LikeType.like,
    );

    final toggleLikeDislike = ToggleLikeDislikeOnMeetingUserSuggestion();

    // Should complete without throwing error
    await toggleLikeDislike.action(
      req,
      CallableContext(voterId, null, 'fakeInstanceId'),
    );
  });
}
