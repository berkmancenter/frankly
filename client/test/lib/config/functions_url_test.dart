import 'package:client/config/functions_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveFunctionsUrlPrefix', () {
    test('defaults to the emulator URL for the configured region', () {
      expect(
        resolveFunctionsUrlPrefix(
          explicitPrefix: '',
          region: 'europe-west1',
          projectId: 'dev',
        ),
        'http://127.0.0.1:5001/dev/europe-west1',
      );
    });

    test('keeps the upstream default when nothing is configured', () {
      expect(
        resolveFunctionsUrlPrefix(
          explicitPrefix: '',
          region: 'us-central1',
          projectId: 'dev',
        ),
        'http://127.0.0.1:5001/dev/us-central1',
      );
    });

    test('uses an explicit prefix that matches the region as given', () {
      const prefix = 'https://us-central1-frankly.cloudfunctions.net';
      expect(
        resolveFunctionsUrlPrefix(
          explicitPrefix: prefix,
          region: 'us-central1',
          projectId: 'frankly',
        ),
        prefix,
      );
    });

    test('moves a deployed prefix that names another region', () {
      expect(
        resolveFunctionsUrlPrefix(
          explicitPrefix: 'https://us-central1-my-project-1.cloudfunctions.net',
          region: 'europe-west1',
          projectId: 'my-project-1',
        ),
        'https://europe-west1-my-project-1.cloudfunctions.net',
      );
    });

    test('moves an emulator prefix that names another region', () {
      expect(
        resolveFunctionsUrlPrefix(
          explicitPrefix: 'http://localhost:5001/dev/us-central1',
          region: 'europe-west1',
          projectId: 'dev',
        ),
        'http://localhost:5001/dev/europe-west1',
      );
    });

    test('uses a custom-domain prefix as given', () {
      const prefix = 'https://functions.example.org';
      expect(
        resolveFunctionsUrlPrefix(
          explicitPrefix: prefix,
          region: 'europe-west1',
          projectId: 'dev',
        ),
        prefix,
      );
    });
  });
}
