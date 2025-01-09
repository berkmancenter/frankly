import 'package:flutter_test/flutter_test.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_image_data.dart';

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
