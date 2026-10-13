const defaultFunctionsRegion = 'us-central1';

/// Location of the `scheduled-functions` Cloud Tasks queue when neither
/// `functions.cloud_tasks_region` nor `functions.region` is configured.
const defaultCloudTasksRegion = 'us-east4';

final _regionPattern = RegExp(r'^[a-z]+-[a-z]+[0-9]+$');
final _cloudFunctionsHostPattern =
    RegExp(r'^([a-z]+-[a-z]+[0-9]+)-(.+)\.cloudfunctions\.net$');

String functionRegionOrDefault(String? configuredRegion) {
  final region = configuredRegion?.trim() ?? '';
  return region.isEmpty ? defaultFunctionsRegion : region;
}

/// Picks the Cloud Tasks queue location: an explicit
/// `functions.cloud_tasks_region` wins, then `functions.region`, then the
/// historical `us-east4` default.
String cloudTasksRegionOrDefault({
  String? cloudTasksRegion,
  String? functionsRegion,
}) {
  final tasksRegion = cloudTasksRegion?.trim() ?? '';
  if (tasksRegion.isNotEmpty) return tasksRegion;
  final region = functionsRegion?.trim() ?? '';
  if (region.isNotEmpty) return region;
  return defaultCloudTasksRegion;
}

/// Returns [urlPrefix] pointed at [region].
///
/// `app.functions_url_prefix` names a region of its own. When the functions
/// move to another region, callbacks built from a stale prefix would keep
/// calling the old region. The two standard shapes are rewritten:
///
/// * deployed: `https://<region>-<project>.cloudfunctions.net`
/// * emulator: `http://127.0.0.1:5001/<project>/<region>`
///
/// Any other shape (for example a custom domain or proxy) is returned as is,
/// since its routing can't be inferred.
String functionsUrlPrefixForRegion(String urlPrefix, String region) {
  final trimmedRegion = region.trim();
  final trimmedPrefix = urlPrefix.trim();
  if (trimmedRegion.isEmpty || trimmedPrefix.isEmpty) return trimmedPrefix;

  final uri = Uri.tryParse(trimmedPrefix);
  if (uri == null || uri.scheme.isEmpty || uri.host.isEmpty) {
    return trimmedPrefix;
  }

  final hostMatch = _cloudFunctionsHostPattern.firstMatch(uri.host);
  if (hostMatch != null) {
    if (hostMatch.group(1) == trimmedRegion) return trimmedPrefix;
    final host = '$trimmedRegion-${hostMatch.group(2)}.cloudfunctions.net';
    return trimmedPrefix.replaceFirst(uri.host, host);
  }

  final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  if (segments.length == 2 && _regionPattern.hasMatch(segments[1])) {
    if (segments[1] == trimmedRegion) return trimmedPrefix;
    // Rebuild the string explicitly rather than via Uri.replace, which can
    // drop the scheme when compiled to JS.
    final origin = uri.hasPort
        ? '${uri.scheme}://${uri.host}:${uri.port}'
        : '${uri.scheme}://${uri.host}';
    return '$origin/${segments[0]}/$trimmedRegion';
  }

  return trimmedPrefix;
}
