import 'package:functions/utils/infra/function_region.dart';
import 'package:test/test.dart';

void main() {
  test('uses the configured Functions region after trimming whitespace', () {
    expect(functionRegionOrDefault(' europe-west1 '), equals('europe-west1'));
  });

  test('falls back to the upstream default for missing or blank values', () {
    expect(functionRegionOrDefault(null), equals(defaultFunctionsRegion));
    expect(functionRegionOrDefault('  '), equals(defaultFunctionsRegion));
  });

  group('cloudTasksRegionOrDefault', () {
    test('keeps us-east4 when nothing is configured', () {
      expect(cloudTasksRegionOrDefault(), equals('us-east4'));
      expect(
        cloudTasksRegionOrDefault(cloudTasksRegion: ' ', functionsRegion: ''),
        equals('us-east4'),
      );
    });

    test('follows the Functions region when no queue region is set', () {
      expect(
        cloudTasksRegionOrDefault(functionsRegion: 'europe-west1'),
        equals('europe-west1'),
      );
    });

    test('prefers an explicit queue region', () {
      expect(
        cloudTasksRegionOrDefault(
          cloudTasksRegion: 'europe-west3',
          functionsRegion: 'europe-west1',
        ),
        equals('europe-west3'),
      );
    });
  });

  group('functionsUrlPrefixForRegion', () {
    test('moves a deployed prefix to the configured region', () {
      expect(
        functionsUrlPrefixForRegion(
          'https://us-central1-my-project-123.cloudfunctions.net',
          'europe-west1',
        ),
        equals('https://europe-west1-my-project-123.cloudfunctions.net'),
      );
    });

    test('leaves a deployed prefix that already matches unchanged', () {
      const prefix = 'https://us-central1-frankly.cloudfunctions.net';
      expect(functionsUrlPrefixForRegion(prefix, 'us-central1'), prefix);
    });

    test('moves an emulator prefix to the configured region', () {
      expect(
        functionsUrlPrefixForRegion(
          'http://127.0.0.1:5001/dev/us-central1',
          'europe-west1',
        ),
        equals('http://127.0.0.1:5001/dev/europe-west1'),
      );
    });

    test('keeps prefixes it cannot interpret', () {
      const prefix = 'https://functions.example.org';
      expect(functionsUrlPrefixForRegion(prefix, 'europe-west1'), prefix);
      expect(functionsUrlPrefixForRegion('', 'europe-west1'), '');
    });
  });
}
