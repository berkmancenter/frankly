final _regionPattern = RegExp(r'^[a-z]+-[a-z]+[0-9]+$');
final _cloudFunctionsHostPattern =
    RegExp(r'^([a-z]+-[a-z]+[0-9]+)-(.+)\.cloudfunctions\.net$');

/// Base URL for direct HTTP calls to Cloud Functions (recording and
/// transcript downloads, artifact repair, the image proxy).
///
/// [explicitPrefix] is `FUNCTIONS_URL_PREFIX`. It names a region of its own,
/// so a build that only changed `FUNCTIONS_REGION` would keep calling the old
/// region. The standard shapes are therefore moved to [region]:
///
/// * deployed: `https://<region>-<project>.cloudfunctions.net`
/// * emulator: `http://127.0.0.1:5001/<project>/<region>`
///
/// Other shapes (a custom domain or proxy) are used as given.
/// `scripts/validate-client-config.mjs` fails the build when the two values
/// disagree, so this is a safety net rather than the expected path.
///
/// With no explicit prefix, the local emulator URL for [projectId] and
/// [region] is used.
String resolveFunctionsUrlPrefix({
  required String explicitPrefix,
  required String region,
  required String projectId,
}) {
  final trimmedRegion = region.trim();
  final trimmedPrefix = explicitPrefix.trim();
  if (trimmedPrefix.isEmpty) {
    return 'http://127.0.0.1:5001/$projectId/$trimmedRegion';
  }
  if (trimmedRegion.isEmpty) return trimmedPrefix;

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
    final origin = uri.hasPort
        ? '${uri.scheme}://${uri.host}:${uri.port}'
        : '${uri.scheme}://${uri.host}';
    return '$origin/${segments[0]}/$trimmedRegion';
  }

  return trimmedPrefix;
}
