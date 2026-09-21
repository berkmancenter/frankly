import 'package:cloud_functions/cloud_functions.dart';
import 'package:client/core/utils/platform_utils.dart';

class CloudFunctions {
  static bool usingEmulator = false;

  // Retry transient/never-reached failures only; never retry client-side errors.
  static const _retryableCodes = {
    'internal',
    'unavailable',
    'deadline-exceeded',
  };
  static const _maxRetries = 2;

  Future<void> initialize() async {
    if (usingEmulator) {
      FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
    }
  }

  /// If running on web without emulators, this directs all function calls through the redirects in
  /// firebase.json to improve loading times by avoiding preflight CORS requests
  Future<Map<String, dynamic>> callFunction(
    String function,
    Map<String, dynamic> data, {
    bool isWeb = true,
  }) async {
    final isLocalhost = Uri.base.origin.contains('localhost');
    final useRedirects = !usingEmulator && isWeb && !isLocalhost;

    Future<Map<String, dynamic>> attempt() async {
      if (useRedirects) {
        final callable = getHttpsCallableWeb(function)!;
        final result = await callable.call(data);
        return result ?? {};
      } else {
        final callable = FirebaseFunctions.instance.httpsCallable(function);
        final result = await callable.call(data);
        final resultData = result.data;
        if (resultData != null &&
            resultData is String &&
            resultData.trim().isEmpty) {
          return {};
        }
        return result.data ?? {};
      }
    }

    for (var attemptNum = 0;; attemptNum++) {
      try {
        return await attempt();
      } catch (e) {
        if (attemptNum >= _maxRetries || !_isRetryable(e)) {
          rethrow;
        }
        await Future<void>.delayed(
          Duration(milliseconds: 300 * (1 << attemptNum)),
        );
      }
    }
  }

  bool _isRetryable(Object e) {
    if (e is FirebaseFunctionsException) {
      return _retryableCodes.contains(e.code);
    }
    final s = e.toString().toLowerCase();
    return s.contains('failed to fetch') ||
        s.contains('networkerror') ||
        s.contains('network error') ||
        s.contains('hostname could not be found');
  }
}
