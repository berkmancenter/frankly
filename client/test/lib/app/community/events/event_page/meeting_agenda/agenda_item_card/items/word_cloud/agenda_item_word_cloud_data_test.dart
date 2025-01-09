import 'package:flutter_test/flutter_test.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_word_cloud_data.dart';

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
