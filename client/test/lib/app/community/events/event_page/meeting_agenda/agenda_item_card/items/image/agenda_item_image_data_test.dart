import 'package:flutter_test/flutter_test.dart';
import 'package:client/app/community/events/event_page/meeting_agenda/agenda_item_card/items/image/agenda_item_image_data.dart';

void main() {
  group('isNew', () {
    test('true', () {
      expect(AgendaItemImageData('', '').isNew(), isTrue);
    });

    test('false', () {
      expect(AgendaItemImageData('', 'url').isNew(), isFalse);
      expect(AgendaItemImageData('title', '').isNew(), isFalse);
      expect(AgendaItemImageData('title', 'url').isNew(), isFalse);
    });
  });
}
