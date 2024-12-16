import 'package:flutter_test/flutter_test.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/agenda_item_card/items/text/agenda_item_text_data.dart';

void main() {
  group('isNew', () {
    test('true', () {
      expect(AgendaItemTextData('', '').isNew(), isTrue);
    });

    test('false', () {
      expect(AgendaItemTextData('title', '').isNew(), isFalse);
      expect(AgendaItemTextData('', 'content').isNew(), isFalse);
      expect(AgendaItemTextData('title', 'content').isNew(), isFalse);
    });
  });
}
