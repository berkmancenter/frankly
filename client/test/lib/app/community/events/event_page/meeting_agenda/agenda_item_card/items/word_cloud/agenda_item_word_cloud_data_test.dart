import 'package:flutter_test/flutter_test.dart';
import 'package:client/app/community/events/event_page/meeting_agenda/agenda_item_card/items/word_cloud/agenda_item_word_cloud_data.dart';

void main() {
  group('isNew', () {
    test('true', () {
      expect(AgendaItemWordCloudData('').isNew(), isTrue);
    });

    test('false', () {
      expect(AgendaItemWordCloudData('prompt').isNew(), isFalse);
    });
  });
}
