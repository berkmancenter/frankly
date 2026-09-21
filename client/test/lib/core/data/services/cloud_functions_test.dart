import 'package:cloud_functions/cloud_functions.dart';
import 'package:client/core/data/services/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';

// Subclass to construct exceptions with arbitrary codes (base ctor is protected).
class _FunctionsException extends FirebaseFunctionsException {
  _FunctionsException(String code) : super(message: 'msg', code: code);
}

void main() {
  bool retryableCode(String code) =>
      CloudFunctions.isRetryableError(_FunctionsException(code));
  bool retryableError(String message) =>
      CloudFunctions.isRetryableError(Exception(message));

  group('CloudFunctions.isRetryableError', () {
    test('retries transient callable codes', () {
      expect(retryableCode('internal'), isTrue);
      expect(retryableCode('unavailable'), isTrue);
      expect(retryableCode('deadline-exceeded'), isTrue);
    });

    test('does not retry client-side error codes', () {
      expect(retryableCode('permission-denied'), isFalse);
      expect(retryableCode('invalid-argument'), isFalse);
      expect(retryableCode('failed-precondition'), isFalse);
    });

    test('retries raw network errors', () {
      const dnsError =
          'A server with the specified hostname could not be found';
      expect(retryableError('Failed to fetch'), isTrue);
      expect(retryableError(dnsError), isTrue);
    });

    test('does not retry unrelated errors', () {
      expect(retryableError('some logic bug'), isFalse);
    });
  });
}
