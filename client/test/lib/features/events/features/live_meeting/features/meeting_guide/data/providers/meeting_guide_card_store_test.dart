import 'package:client/features/events/features/live_meeting/features/meeting_guide/data/providers/meeting_guide_card_store.dart';
import 'package:data_models/events/live_meetings/meeting_guide.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MeetingGuideCardStore.detailsForAgendaItem', () {
    final itemA = ParticipantAgendaItemDetails(
      userId: 'u1',
      agendaItemId: 'A',
      readyToAdvance: true,
    );
    final itemB = ParticipantAgendaItemDetails(
      userId: 'u1',
      agendaItemId: 'B',
      readyToAdvance: false,
    );

    test('keeps only entries for the given agenda item', () {
      final result =
          MeetingGuideCardStore.detailsForAgendaItem([itemA, itemB], 'B');
      expect(result, [itemB]);
    });

    test('excludes a stale previous-item snapshot (anti-flash)', () {
      // Simulates the card handoff where the stream still holds the previous
      // item A snapshot (user ready) while the current item is now B.
      final result = MeetingGuideCardStore.detailsForAgendaItem([itemA], 'B');
      expect(result, isEmpty);
    });

    test('returns empty for null details or null agenda item', () {
      expect(MeetingGuideCardStore.detailsForAgendaItem(null, 'A'), isEmpty);
      expect(
          MeetingGuideCardStore.detailsForAgendaItem([itemA], null), isEmpty);
    });
  });
}
