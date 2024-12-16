import 'package:flutter_test/flutter_test.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/agenda_item_card/items/poll/agenda_item_poll_data.dart';

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
