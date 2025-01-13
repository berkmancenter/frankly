import 'package:flutter_test/flutter_test.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_poll_data.dart';

void main() {
  group('isNew', () {
    test('true', () {
      expect(AgendaItemPollData('', []).isNew(), isTrue);
    });

    group('false', () {
      test('question', () {
        expect(AgendaItemPollData('question', []).isNew(), isFalse);
      });
      test('answer', () {
        expect(AgendaItemPollData('', ['answer']).isNew(), isFalse);
      });
      test('both', () {
        expect(AgendaItemPollData('question', ['answer']).isNew(), isFalse);
      });
    });
  });
}
