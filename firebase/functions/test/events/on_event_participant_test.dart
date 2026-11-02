import 'package:functions/events/on_event_participant.dart';
import 'package:test/test.dart';
import 'package:data_models/events/event.dart';

void main() {
  final presentTime = DateTime.utc(2026, 1, 1, 12);

  DateTime? toRecord(Participant participant) =>
      OnEventParticipant.firstPresentTimeToRecord(participant);

  test('Returns mostRecentPresentTime on first presence', () {
    final participant = Participant(
      id: 'user',
      isPresent: true,
      mostRecentPresentTime: presentTime,
    );
    expect(toRecord(participant), equals(presentTime));
  });

  test('Returns null when firstPresentTime is already set', () {
    final participant = Participant(
      id: 'user',
      isPresent: true,
      mostRecentPresentTime: presentTime,
      firstPresentTime: presentTime.subtract(const Duration(minutes: 30)),
    );
    expect(toRecord(participant), isNull);
  });

  test('Returns null when not present', () {
    final participant = Participant(
      id: 'user',
      mostRecentPresentTime: presentTime,
    );
    expect(toRecord(participant), isNull);
  });
}
