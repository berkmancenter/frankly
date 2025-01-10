import 'dart:convert';

import 'package:client/core/utils/error_utils.dart';
import 'package:client/services.dart';

/// Service to keep track of query parameters users have accessed the page with.
///
/// This is primarily used to capture answer masks for smart matching from communities that link
/// directly to events and do the survey matching outside of our product.
class QueryParametersService {
  Map<String, String>? _queryParameters;

  Map<String, String>? get mostRecentQueryParameters {
    return _queryParameters ??= _loadParamsFromPreferences();
  }

  Map<String, String>? _loadParamsFromPreferences() {
    final queryParamsString = sharedPreferencesService.getLastQueryParams();
    if (queryParamsString != null) {
      return swallowErrorsSync<Map<String, String>?>(() {
        final queryParams = jsonDecode(queryParamsString);
        if (queryParams is Map && queryParams.isNotEmpty) {
          return queryParams
              .map((key, value) => MapEntry(key.toString(), value.toString()));
        }
        return null;
      });
    }

    return null;
  }

  void addQueryParameters(Map<String, String> parameters) {
    _queryParameters = (mostRecentQueryParameters ?? {})
      ..addEntries(parameters.entries);
    sharedPreferencesService
        .setLastQueryParameters(jsonEncode(_queryParameters));
  }
}
