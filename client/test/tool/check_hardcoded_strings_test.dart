@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory temporaryDirectory;
  late File fixture;

  setUp(() {
    temporaryDirectory = Directory.systemTemp.createTempSync('hardcoded_strings_');
    fixture = File('${temporaryDirectory.path}/fixture.dart');
  });

  tearDown(() {
    temporaryDirectory.deleteSync(recursive: true);
  });

  List<String> scan(String source, {required int expectedExitCode}) {
    fixture.writeAsStringSync(source);
    final result = Process.runSync(
      'dart',
      ['run', 'tool/check_hardcoded_strings.dart', '--all', fixture.path],
    );
    expect(
      result.exitCode,
      expectedExitCode,
      reason: '${result.stdout}\n${result.stderr}',
    );
    expect(result.stderr, isEmpty);
    const marker = 'hardcoded user-facing string: ';
    return const LineSplitter()
        .convert(result.stdout as String)
        .where((line) => line.contains(marker))
        .map((line) => jsonDecode(line.split(marker).last) as String)
        .toList();
  }

  test('reports both conditional branches inside interpolation', () {
    expect(
      scan(
        r"void build() { HeightConstrainedText('$count ${count == 1 ? 'comment' : 'comments'}'); }",
        expectedExitCode: 1,
      ),
      ['comment', 'comments'],
    );
  });

  test('walks nested, parenthesized and null-coalescing interpolation values', () {
    expect(
      scan(
        r'''void build() {
  Text('${(name ?? 'Unknown person')}');
  Text('${enabled ? '${count == 1 ? '设置' : '設定'}' : 'カタカナ'}');
}''',
        expectedExitCode: 1,
      ),
      ['Unknown person', '设置', '設定', 'カタカナ'],
    );
  });

  test('preserves adjacent-string grouping while checking interpolation values', () {
    expect(
      scan(
        r'''void build() {
  Text('Total: ' '${count == 1 ? 'one item' : 'many items'}');
}''',
        expectedExitCode: 1,
      ),
      ['Total: ', 'one item', 'many items'],
    );
  });

  test('stops at call boundaries inside interpolation', () {
    expect(
      scan(
        r'''void build() {
  Text('${context.l10n.someKey('argument')}');
  Text('${enabled ? context.l10n.someKey('enabled') : context.l10n.someKey('disabled')}');
  Text('${format('technical input')}');
}''',
        expectedExitCode: 0,
      ),
      isEmpty,
    );
  });

  test('honors ignore comments for the complete interpolated literal', () {
    expect(
      scan(
        r"""void build() {
  // ignore: hardcoded_string development-only fixture
  Text('''
${enabled ? 'Fake participant' : 'Debug user'}
''');
}""",
        expectedExitCode: 0,
      ),
      isEmpty,
    );
  });
}
