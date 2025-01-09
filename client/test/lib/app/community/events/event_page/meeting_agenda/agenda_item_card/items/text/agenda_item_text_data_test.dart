import 'package:flutter_test/flutter_test.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_text_data.dart';

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
