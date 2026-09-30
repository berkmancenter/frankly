@TestOn('vm')
library;

import 'dart:io';

import 'package:client/core/data/services/same_origin_callables.dart';
import 'package:flutter_test/flutter_test.dart';

// Guards against the case where the allowlist is ineffectual: a callable can be listed in
// sameOriginCallables (and firebase.json) yet still call the cross-origin host
// directly. Every allowlisted name must be invoked through CloudFunctions
// .callFunction, and none may bypass it via a direct httpsCallable literal.
// This catches any additional same-origin callables that were called as
// external functions without adding them to the allowlist, which would break
// the same-origin rewrite and repeat the Firefox-breaking erro.

List<String> _dartSources(Directory dir) => dir
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'))
    .where((f) => !f.path.endsWith('.freezed.dart'))
    .where((f) => !f.path.endsWith('.g.dart'))
    .map((f) => f.readAsStringSync())
    .toList();

void main() {
  // className -> functionName constant value, e.g. CreateEventRequest -> createEvent.
  final constByClass = <String, String>{};
  final classPattern = RegExp(r'^\s*(?:abstract\s+)?class\s+(\w+)');
  final constPattern =
      RegExp(r"static const (?:String )?functionName\s*=\s*'([^']+)'");
  for (final source in _dartSources(Directory('../data_models/lib'))) {
    String? currentClass;
    for (final line in source.split('\n')) {
      final classMatch = classPattern.firstMatch(line);
      if (classMatch != null) currentClass = classMatch.group(1);
      final constMatch = constPattern.firstMatch(line);
      if (constMatch != null && currentClass != null) {
        constByClass[currentClass] = constMatch.group(1)!;
      }
    }
  }

  final clientSources = _dartSources(Directory('lib'));

  final reachedViaCallFunction = <String>{};
  final callFunctionArg =
      RegExp(r"callFunction\(\s*(?:'([^']+)'|(\w+)\.functionName)");
  for (final source in clientSources) {
    for (final match in callFunctionArg.allMatches(source)) {
      final literal = match.group(1);
      final className = match.group(2);
      if (literal != null) {
        reachedViaCallFunction.add(literal);
      } else if (className != null && constByClass.containsKey(className)) {
        reachedViaCallFunction.add(constByClass[className]!);
      }
    }
  }

  final directCallableLiterals = <String>{};
  final httpsCallableArg = RegExp(r"httpsCallable\(\s*'([^']+)'");
  for (final source in clientSources) {
    for (final match in httpsCallableArg.allMatches(source)) {
      directCallableLiterals.add(match.group(1)!);
    }
  }

  group('sameOriginCallables usage', () {
    test('every allowlisted callable is invoked via callFunction', () {
      final unreached = sameOriginCallables.difference(reachedViaCallFunction);
      expect(
        unreached,
        isEmpty,
        reason: 'allowlisted but not routed through callFunction: $unreached',
      );
    });

    test('no allowlisted callable bypasses callFunction via httpsCallable', () {
      final bypassed = sameOriginCallables.intersection(directCallableLiterals);
      expect(
        bypassed,
        isEmpty,
        reason: 'allowlisted but called directly via httpsCallable: $bypassed',
      );
    });
  });
}
