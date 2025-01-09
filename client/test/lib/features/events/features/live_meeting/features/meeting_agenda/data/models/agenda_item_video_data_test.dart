import 'package:flutter_test/flutter_test.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/models/agenda_item_video_data.dart';
import 'package:client/core/utils/extensions.dart';

void main() {
  group('isNew', () {
    test('true', () {
      expect(
        AgendaItemVideoData('', AgendaItemVideoType.url, '').isNew(),
        isTrue,
      );
    });

    test('false', () {
      expect(
        AgendaItemVideoData('title', AgendaItemVideoType.url, '').isNew(),
        isFalse,
      );
      expect(
        AgendaItemVideoData('', AgendaItemVideoType.url, 'url').isNew(),
        isFalse,
      );
      expect(
        AgendaItemVideoData('', AgendaItemVideoType.vimeo, '').isNew(),
        isFalse,
      );
      expect(
        AgendaItemVideoData('title', AgendaItemVideoType.url, 'url').isNew(),
        isFalse,
      );
    });
  });
}
