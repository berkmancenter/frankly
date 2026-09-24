@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:client/core/data/services/same_origin_callables.dart';
import 'package:flutter_test/flutter_test.dart';

// Every same-origin callable must have a matching
// `/api/<name>` hosting rewrite, and every `/api/<name>` rewrite must be listed.
void main() {
  test('sameOriginCallables matches firebase.json /api rewrites', () {
    final file = File('../firebase.json');
    expect(file.existsSync(), isTrue, reason: 'run from the client/ directory');

    final config = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final rewrites =
        (config['hosting']['rewrites'] as List).cast<Map<String, dynamic>>();

    final apiRewrites = <String, String>{};
    for (final rewrite in rewrites) {
      final source = rewrite['source'] as String;
      if (source.startsWith('/api/')) {
        apiRewrites[source] = rewrite['function'] as String;
      }
    }

    // Rewrite set matches the allowlist exactly.
    expect(
      apiRewrites.values.toSet(),
      sameOriginCallables,
      reason: 'firebase.json /api rewrites and sameOriginCallables diverged',
    );

    // Each rewrite maps /api/<name> to the function named <name>.
    for (final entry in apiRewrites.entries) {
      expect(entry.key, '/api/${entry.value}');
    }
  });
}
