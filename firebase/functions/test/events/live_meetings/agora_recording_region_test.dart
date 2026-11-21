import 'package:functions/events/live_meetings/agora_api.dart';
import 'package:test/test.dart';

void main() {
  group('recordingAcquireClientRequest', () {
    test('stays empty when no recording region is configured', () {
      expect(recordingAcquireClientRequest(null), isEmpty);
      expect(recordingAcquireClientRequest('  '), isEmpty);
    });

    test('pins the configured region', () {
      expect(recordingAcquireClientRequest('EU'), {'region': 'EU'});
      expect(recordingAcquireClientRequest(' eu '), {'region': 'EU'});
    });

    test('accepts every supported region', () {
      for (final region in ['CN', 'AP', 'EU', 'NA']) {
        expect(recordingAcquireClientRequest(region), {'region': region});
      }
    });

    test('leaves out an unsupported region', () {
      expect(recordingAcquireClientRequest('US'), isEmpty);
      expect(recordingAcquireClientRequest('europe'), isEmpty);
    });
  });
}
