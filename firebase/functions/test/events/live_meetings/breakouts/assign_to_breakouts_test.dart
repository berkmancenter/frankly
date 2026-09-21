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
        participantEmailLookup: {},
        participantNameLookup: {},
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

    test(
        'uses binaryGroupMatch when there is no free-text data at all but binary answers exist',
        () {
      final payload = buildFranklyMatchApiPayload(
        participantSurveyResponsesLookup: {'p1': '010'},
        participantFreeTextResponsesLookup: {},
        participantEmailLookup: {},
        participantNameLookup: {},
        targetParticipantsPerRoom: 2,
      );

      expect(payload['algorithm'], 'binaryGroupMatch');
      expect(payload['targetGroupSize'], 2);
      expect(payload['participants'], {
        'p1': {'binaryAnswerMask': '010'},
      });
    });

    test(
        'uses textGroupMatch and includes freeTextResponse if at least three participants have free-text responses',
        () {
      final payload = buildFranklyMatchApiPayload(
        participantSurveyResponsesLookup: {},
        participantFreeTextResponsesLookup: {
          'p1': 'I like hiking',
          'p2': 'I enjoy reading',
          'p3': 'I love cooking'
        },
        participantEmailLookup: {},
        participantNameLookup: {},
        targetParticipantsPerRoom: 2,
      );

      expect(payload['algorithm'], 'textGroupMatch');
      expect(
        payload['participants'],
        {
          'p1': {'freeTextResponse': 'I like hiking'},
          'p2': {'freeTextResponse': 'I enjoy reading'},
          'p3': {'freeTextResponse': 'I love cooking'},
        },
      );
    });

    test(
        'omits binaryAnswerMask and uses textGroupMatch when a participant '
        'has both a survey answer and a free-text answer, given at least '
        'three participants have free-text responses', () {
      final payload = buildFranklyMatchApiPayload(
        participantSurveyResponsesLookup: {'p1': '010'},
        participantFreeTextResponsesLookup: {
          'p1': 'I like hiking',
          'p2': 'I enjoy reading',
          'p3': 'I love cooking',
        },
        participantEmailLookup: {},
        participantNameLookup: {},
        targetParticipantsPerRoom: 2,
      );

      expect(payload['algorithm'], 'textGroupMatch');
      expect(
        payload['participants'],
        {
          'p1': {'freeTextResponse': 'I like hiking'},
          'p2': {'freeTextResponse': 'I enjoy reading'},
          'p3': {'freeTextResponse': 'I love cooking'},
        },
      );
    });

    test(
        'throws an error if there are fewer than three participants with free-text responses and no binary answers',
        () {
      expect(
        () => buildFranklyMatchApiPayload(
          participantSurveyResponsesLookup: {},
          participantFreeTextResponsesLookup: {
            'p1': 'I like hiking',
            'p2': 'I enjoy reading'
          },
          participantEmailLookup: {},
          participantNameLookup: {},
          targetParticipantsPerRoom: 2,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test(
        'throws an error when there are no survey responses and no free-text responses at all',
        () {
      expect(
        () => buildFranklyMatchApiPayload(
          participantSurveyResponsesLookup: {},
          participantFreeTextResponsesLookup: {},
          participantEmailLookup: {},
          participantNameLookup: {},
          targetParticipantsPerRoom: 2,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test(
        'falls back to binaryGroupMatch when there are fewer than three free-text responses but binary answers exist, still including the free-text-only participant without a binaryAnswerMask',
        () {
      final payload = buildFranklyMatchApiPayload(
        participantSurveyResponsesLookup: {'p1': '010', 'p2': '101'},
        participantFreeTextResponsesLookup: {'p3': 'I like hiking'},
        participantEmailLookup: {},
        participantNameLookup: {},
        targetParticipantsPerRoom: 2,
      );

      expect(payload['algorithm'], 'binaryGroupMatch');
      expect(payload['participants'], {
        'p1': {'binaryAnswerMask': '010'},
        'p2': {'binaryAnswerMask': '101'},
        'p3': {'freeTextResponse': 'I like hiking'},
      });
    });

    test(
        'falls back to binaryGroupMatch when at least three participants have free-text responses but one is empty, given binary answers exist',
        () {
      final payload = buildFranklyMatchApiPayload(
        participantSurveyResponsesLookup: {'p1': '010'},
        participantFreeTextResponsesLookup: {
          'p1': 'I like hiking',
          'p2': 'I enjoy reading',
          'p3': '',
        },
        participantEmailLookup: {},
        participantNameLookup: {},
        targetParticipantsPerRoom: 2,
      );

      expect(payload['algorithm'], 'binaryGroupMatch');
      expect(payload['participants'], {
        'p1': {'binaryAnswerMask': '010', 'freeTextResponse': 'I like hiking'},
        'p2': {'freeTextResponse': 'I enjoy reading'},
        'p3': {'freeTextResponse': ''},
      });
    });

    test(
        'throws an error when at least three free-text responses exist but one is empty and there are no binary answers',
        () {
      expect(
        () => buildFranklyMatchApiPayload(
          participantSurveyResponsesLookup: {},
          participantFreeTextResponsesLookup: {
            'p1': 'I like hiking',
            'p2': 'I enjoy reading',
            'p3': '',
          },
          participantEmailLookup: {},
          participantNameLookup: {},
          targetParticipantsPerRoom: 2,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('includes email alongside freeTextResponse when present', () {
      final payload = buildFranklyMatchApiPayload(
        participantSurveyResponsesLookup: {},
        participantFreeTextResponsesLookup: {'p1': 'I like hiking'},
        participantEmailLookup: {'p1': 'p1@example.com'},
        participantNameLookup: {},
        targetParticipantsPerRoom: 2,
      );

      expect(
        payload['participants'],
        {
          'p1': {
            'freeTextResponse': 'I like hiking',
            'email': 'p1@example.com',
          },
        },
      );
    });

    test('includes name alongside freeTextResponse when present', () {
      final payload = buildFranklyMatchApiPayload(
        participantSurveyResponsesLookup: {},
        participantFreeTextResponsesLookup: {'p1': 'I like hiking'},
        participantEmailLookup: {},
        participantNameLookup: {'p1': 'Pat Smith'},
        targetParticipantsPerRoom: 2,
      );

      expect(
        payload['participants'],
        {
          'p1': {
            'freeTextResponse': 'I like hiking',
            'name': 'Pat Smith',
          },
        },
      );
    });
  });
}
