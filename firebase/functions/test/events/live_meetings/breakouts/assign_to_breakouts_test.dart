import 'package:functions/events/live_meetings/breakouts/assign_to_breakouts.dart';
import 'package:functions/utils/infra/firestore_utils.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:data_models/events/live_meetings/meeting_guide.dart';
import 'package:test/test.dart';

import '../../../util/function_test_fixture.dart';

void main() {
  final assigner = AssignToBreakouts();
  setupTestFixture();

  BreakoutRoom buildRoom(String roomId, {String? diffusionStatement}) {
    return BreakoutRoom(
      roomId: roomId,
      roomName: roomId,
      orderingPriority: 0,
      creatorId: 'creator',
      diffusionStatement: diffusionStatement,
    );
  }

  Future<String?> startedAgendaItemFor(
    String roomId, {
    required List<AgendaItem> agendaItems,
    String? diffusionStatement,
    String? parentMirroredAgendaItemId,
  }) async {
    final breakoutSessionCollection =
        firestore.collection('test-breakout-rooms-$roomId');

    await assigner.writeDocumentsToCollection(
      breakoutSessionCollection: breakoutSessionCollection,
      rooms: [buildRoom(roomId, diffusionStatement: diffusionStatement)],
      agendaItems: agendaItems,
      parentMirroredAgendaItemId: parentMirroredAgendaItemId,
    );

    final liveMeetingDoc = await breakoutSessionCollection
        .document(roomId)
        .collection('live-meetings')
        .document(roomId)
        .get();

    if (!liveMeetingDoc.exists) {
      return null;
    }

    final liveMeeting = LiveMeeting.fromJson(
      firestoreUtils.fromFirestoreJson(liveMeetingDoc.data.toMap()),
    );
    return liveMeeting.events.single.agendaItem;
  }

  test(
      'uses parentMirroredAgendaItemId when set, ignoring the resolved agenda items',
      () async {
    final agendaItemId = await startedAgendaItemFor(
      'hosted-room',
      agendaItems: [AgendaItem(id: 'first', content: 'Welcome')],
      parentMirroredAgendaItemId: 'parent-current-item',
    );

    expect(agendaItemId, 'parent-current-item');
  });

  test(
      'falls back to the room\'s first resolved agenda item when there is no parentMirroredAgendaItemId',
      () async {
    final agendaItemId = await startedAgendaItemFor(
      'room-1',
      agendaItems: [AgendaItem(id: 'first', content: 'Welcome')],
    );

    expect(agendaItemId, 'first');
  });

  test(
      'resolves the {diffusionStatement} token using the room\'s diffusionStatement',
      () async {
    final agendaItemId = await startedAgendaItemFor(
      'room-2',
      agendaItems: [
        AgendaItem(id: 'first', content: 'Discuss: $diffusionStatementToken'),
      ],
      diffusionStatement: 'Should we ban plastic bags?',
    );

    expect(agendaItemId, 'first');
  });

  test(
      'still resolves to the item needing a diffusionStatement when the room has none (shown as an error placeholder outside production)',
      () async {
    final agendaItemId = await startedAgendaItemFor(
      'room-3',
      agendaItems: [
        AgendaItem(id: 'first', content: 'Discuss: $diffusionStatementToken'),
      ],
    );

    expect(agendaItemId, 'first');
  });
  group('buildFranklyMatchApiPayload', () {
    test('includes binaryAnswerMask for participants with survey answers', () {
      final payload = buildFranklyMatchApiPayload(
        participantSurveyResponsesLookup: {'p1': '010', 'p2': '101'},
        participantFreeTextResponsesLookup: {},
        targetParticipantsPerRoom: 2,
      );

      expect(payload['algorithm'], 'binaryGroupMatch');
      expect(payload['targetGroupSize'], 2);
      expect(
        payload['participants'],
        {
          'p1': {'binaryAnswerMask': '010'},
          'p2': {'binaryAnswerMask': '101'},
        },
      );
    });

    test('includes freeTextResponse for participants with a free-text answer',
        () {
      final payload = buildFranklyMatchApiPayload(
        participantSurveyResponsesLookup: {},
        participantFreeTextResponsesLookup: {'p1': 'I like hiking'},
        targetParticipantsPerRoom: 2,
      );

      expect(
        payload['participants'],
        {
          'p1': {'freeTextResponse': 'I like hiking'},
        },
      );
    });

    test('merges both keys for a participant who answered both', () {
      final payload = buildFranklyMatchApiPayload(
        participantSurveyResponsesLookup: {'p1': '010'},
        participantFreeTextResponsesLookup: {'p1': 'I like hiking'},
        targetParticipantsPerRoom: 2,
      );

      expect(
        payload['participants'],
        {
          'p1': {
            'binaryAnswerMask': '010',
            'freeTextResponse': 'I like hiking'
          },
        },
      );
    });

    test(
        'includes a participant present only in the free-text lookup with no '
        'survey answer', () {
      final payload = buildFranklyMatchApiPayload(
        participantSurveyResponsesLookup: {'p1': '010'},
        participantFreeTextResponsesLookup: {'p2': 'I like hiking'},
        targetParticipantsPerRoom: 2,
      );

      expect(
        payload['participants'],
        {
          'p1': {'binaryAnswerMask': '010'},
          'p2': {'freeTextResponse': 'I like hiking'},
        },
      );
    });
  });
}
