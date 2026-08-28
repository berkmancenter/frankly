import 'package:functions/events/live_meetings/breakouts/assign_to_breakouts.dart';
import 'package:test/test.dart';

void main() {
  group('buildFranklyMatchApiPayload', () {
    test('includes binaryAnswerMask for participants with survey answers',
        () {
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
          'p1': {'binaryAnswerMask': '010', 'freeTextResponse': 'I like hiking'},
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
