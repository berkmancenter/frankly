import 'package:flutter_test/flutter_test.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/agenda_item_card/items/video/agenda_item_video_data.dart';
import 'package:junto/utils/extensions.dart';

void main() {
  group('isNew', () {
    test('true', () {
      expect(AgendaItemVideoData('', AgendaItemVideoType.url, '').isNew(), isTrue);
    });

    test('false', () {
      expect(AgendaItemVideoData('title', AgendaItemVideoType.url, '').isNew(), isFalse);
      expect(AgendaItemVideoData('', AgendaItemVideoType.url, 'url').isNew(), isFalse);
      expect(AgendaItemVideoData('', AgendaItemVideoType.vimeo, '').isNew(), isFalse);
      expect(AgendaItemVideoData('title', AgendaItemVideoType.url, 'url').isNew(), isFalse);
    });
  });
}
