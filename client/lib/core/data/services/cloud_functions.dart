import 'package:cloud_functions/cloud_functions.dart';
import 'package:client/core/data/services/same_origin_callables.dart';
import 'package:client/core/utils/platform_utils.dart';
import 'package:flutter/foundation.dart';

class CloudFunctions {
  static bool usingEmulator = false;

  // Retry only when responses show the call never reached the server, so a
  // retry won't duplicate an already-committed mutation.
  static const _retryableCodes = {'unavailable'};
  static const _maxRetries = 2;

  Future<void> initialize() async {
    if (usingEmulator) {
      FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
    }
  }

  /// On web (no emulator), [sameOriginCallables] are called via the app origin's
  /// `/api` rewrite to skip the cross-origin functions host and CORS preflight.
  Future<Map<String, dynamic>> callFunction(
    String function,
    Map<String, dynamic> data, {
    bool isWeb = true,
  }) async {
    final isLocalhost = Uri.base.origin.contains('localhost');
    final useRedirects = !usingEmulator && isWeb && !isLocalhost;

    Future<Map<String, dynamic>> attempt() async {
      if (useRedirects) {
        final sameOriginBase = sameOriginCallables.contains(function)
            ? '${Uri.base.origin}/api'
            : null;
        final callable = getHttpsCallableWeb(function, sameOriginBase)!;
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
        if (attemptNum >= _maxRetries || !isRetryableError(e)) {
          rethrow;
        }
        await Future<void>.delayed(
          Duration(milliseconds: 300 * (1 << attemptNum)),
        );
      }
    }
  }

  @visibleForTesting
  static bool isRetryableError(Object e) {
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
