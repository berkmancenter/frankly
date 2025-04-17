import 'package:cloud_functions/cloud_functions.dart';
import 'package:client/core/utils/platform_utils.dart';

class CloudFunctions {
  static bool usingEmulator = false;

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
    if (useRedirects) {
      final callable = getHttpsCallableWeb(function)!;
      print('Callable origin: ${callable.origin}');
      print('Callable: ${callable.uri.toString()}');
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
}
