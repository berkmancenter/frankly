import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:crypto/crypto.dart';

const _generatedSuffixes = <String>{
  '.freezed.dart',
  '.g.dart',
  '.mocks.dart',
};

const _textWidgetTypes = <String>{
  'HeightConstrainedText',
  'SelectableText',
  'Text',
};

const _userFacingNamedParameters = <String>{
  'counterText',
  'errorText',
  'helperText',
  'hintText',
  'labelText',
  'message',
  'negativeButtonText',
  'positiveButtonText',
  'prefixText',
  'semanticLabel',
  'suffixText',
  'tooltip',
};

const _namedTextParametersByWidget = <String, Set<String>>{
  'ActionButton': {'text'},
  'AppBar': {'title'},
  'CommunityPageFloatingActionButton': {'text'},
  'ConfirmDialog': {
    'cancelText',
    'confirmText',
    'mainText',
    'subText',
    'title',
  },
  'ThickOutlineButton': {'text'},
};

final _ignoreCommentPattern = RegExp(
  r'//\s*ignore:\s*hardcoded_string(?:\s|$)',
);

class _Finding {
  const _Finding({
    required this.path,
    required this.line,
    required this.column,
    required this.value,
  });

  final String path;
  final int line;
  final int column;

  final String value;

  String get key => '$path\t${_findingDigest(value)}';
}

const _baselineFile = 'tool/hardcoded_strings_baseline.txt';

String _normalizeString(String value) {
  return value.replaceAll(RegExp(r'\s+'), ' ').trim();
}

String _findingDigest(String value) {
  final digest = sha256.convert(utf8.encode(_normalizeString(value)));
  return digest.toString().substring(0, 12);
}

class _StringVisitor extends RecursiveAstVisitor<void> {
  _StringVisitor({
    required this.result,
    required this.path,
  });

  final ParseStringResult result;
  final String path;
  final findings = <_Finding>[];
  final _recorded = <AstNode>{};

  @override
  void visitArgumentList(ArgumentList node) {
    for (final argument in node.arguments) {
      if (argument case NamedExpression(:final name, :final expression)) {
        if (_userFacingNamedParameters.contains(name.label.name)) {
          _record(expression);
        }
      }
    }
    super.visitArgumentList(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.name2.lexeme;
    _inspectTextCall(typeName, node.argumentList);
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    _inspectTextCall(node.methodName.name, node.argumentList);
    super.visitMethodInvocation(node);
  }

  void _inspectTextCall(String typeName, ArgumentList argumentList) {
    if (_textWidgetTypes.contains(typeName)) {
      _recordFirstPositionalArgument(argumentList);
    }

    // RichText and TextSpan expose their user-facing string as `text:` rather
    // than as the first positional argument. Keep this contextual so unrelated
    // APIs with a technical `text` parameter are not reported.
    final namedParameters = <String>{
      if (typeName == 'RichText' || typeName == 'TextSpan') 'text',
      ...?_namedTextParametersByWidget[typeName],
    };
    for (final argument in argumentList.arguments) {
      if (argument
          case NamedExpression(name: final name, expression: final expression)
          when namedParameters.contains(name.label.name)) {
        _record(expression);
      }
    }
  }

  void _recordFirstPositionalArgument(ArgumentList argumentList) {
    for (final argument in argumentList.arguments) {
      if (argument is! NamedExpression) {
        _record(argument);
        return;
      }
    }
  }

  void _record(Expression expression) {
    final literal = _unwrapLiteral(expression);
    if (literal == null || !_recorded.add(literal)) {
      return;
    }

    final value = _literalValue(literal);
    if (!_containsLetter(value) || _isIgnored(literal)) {
      return;
    }

    final location = result.lineInfo.getLocation(literal.offset);
    findings.add(
      _Finding(
        path: path,
        line: location.lineNumber,
        column: location.columnNumber,
        value: value,
      ),
    );
  }

  StringLiteral? _unwrapLiteral(Expression expression) {
    var current = expression;
    while (current is ParenthesizedExpression) {
      current = current.expression;
    }
    return current is StringLiteral ? current : null;
  }

  String _literalValue(StringLiteral literal) {
    return switch (literal) {
      SimpleStringLiteral(:final value) => value,
      AdjacentStrings(:final strings) => strings.map(_literalValue).join(),
      StringInterpolation(:final elements) => elements
          .whereType<InterpolationString>()
          .map(_interpolationStringValue)
          .join(),
    };
  }

  String _interpolationStringValue(InterpolationString element) {
    var source = element.contents.lexeme;
    for (final delimiter in <String>['"""', "'''", '"', "'"]) {
      if (source.startsWith(delimiter)) {
        source = source.substring(delimiter.length);
      }
      if (source.endsWith(delimiter)) {
        source = source.substring(0, source.length - delimiter.length);
      }
      if (source != element.contents.lexeme) {
        break;
      }
    }
    return _decodeDartEscapes(source);
  }

  bool _isIgnored(StringLiteral literal) {
    final line = result.lineInfo.getLocation(literal.offset).lineNumber;
    final lines = result.content.split('\n');
    for (final lineNumber in <int>[line, line - 1]) {
      if (lineNumber < 1 || lineNumber > lines.length) {
        continue;
      }
      final sourceLine = lines[lineNumber - 1];
      for (final match in _ignoreCommentPattern.allMatches(sourceLine)) {
        if (!_isInsideString(sourceLine, match.start)) {
          return true;
        }
      }
    }
    return false;
  }

  bool _isInsideString(String sourceLine, int offset) {
    String? quote;
    var triple = false;
    var escaped = false;
    for (var index = 0; index < offset; index++) {
      final character = sourceLine[index];
      if (quote == null) {
        if (character == '\'' || character == '"') {
          quote = character;
          triple = sourceLine.startsWith(character * 3, index);
          if (triple) {
            index += 2;
          }
        }
        continue;
      }
      if (escaped) {
        escaped = false;
      } else if (character == '\\' && !triple) {
        escaped = true;
      } else if (triple
          ? sourceLine.startsWith(quote * 3, index)
          : character == quote) {
        if (triple) {
          index += 2;
        }
        quote = null;
        triple = false;
      }
    }
    return quote != null;
  }
}

String _decodeDartEscapes(String source) {
  final buffer = StringBuffer();
  for (var index = 0; index < source.length; index++) {
    final character = source[index];
    if (character != '\\' || index + 1 >= source.length) {
      buffer.write(character);
      continue;
    }

    final escape = source[++index];
    switch (escape) {
      case 'b':
        buffer.write('\b');
      case 'f':
        buffer.write('\f');
      case 'n':
        buffer.write('\n');
      case 'r':
        buffer.write('\r');
      case 't':
        buffer.write('\t');
      case 'v':
        buffer.write('\v');
      case '\\':
        buffer.write('\\');
      case r'$':
        buffer.write(r'$');
      case '\'':
        buffer.write('\'');
      case '"':
        buffer.write('"');
      case 'x':
        final hex = _readHex(source, index + 1, 2);
        if (hex == null) {
          buffer.write(escape);
        } else {
          buffer.writeCharCode(hex.value);
          index = hex.end;
        }
      case 'u':
        var end = index + 1;
        if (end < source.length && source[end] == '{') {
          end++;
          while (end < source.length && source[end] != '}') {
            end++;
          }
          if (end < source.length) {
            final hex = int.tryParse(
              source.substring(index + 2, end),
              radix: 16,
            );
            if (hex != null) {
              buffer.writeCharCode(hex);
              index = end;
              continue;
            }
          }
        } else {
          final hex = _readHex(source, index + 1, 4);
          if (hex != null) {
            buffer.writeCharCode(hex.value);
            index = hex.end;
            continue;
          }
        }
        buffer.write(escape);
      default:
        buffer.write(escape);
    }
  }
  return buffer.toString();
}

({int value, int end})? _readHex(String source, int start, int length) {
  final end = start + length;
  if (end > source.length) {
    return null;
  }
  final value = int.tryParse(source.substring(start, end), radix: 16);
  return value == null ? null : (value: value, end: end - 1);
}

bool _containsLetter(String value) {
  for (final rune in value.runes) {
    if ((rune >= 0x41 && rune <= 0x5a) ||
        (rune >= 0x61 && rune <= 0x7a) ||
        (rune >= 0xc0 && rune <= 0x2ff) ||
        (rune >= 0x370 && rune <= 0x52f) ||
        (rune >= 0x590 && rune <= 0x8ff) ||
        (rune >= 0x900 && rune <= 0x1fff) ||
        (rune >= 0x2c00 && rune <= 0x2dff) ||
        (rune >= 0xa640 && rune <= 0xa69f) ||
        (rune >= 0xa720 && rune <= 0xa7ff) ||
        (rune >= 0xab00 && rune <= 0xabff) ||
        (rune >= 0xac00 && rune <= 0xd7af) ||
        (rune >= 0xf900 && rune <= 0xfaff) ||
        (rune >= 0x10000 && rune <= 0x1efff)) {
      return true;
    }
  }
  return false;
}

bool _isSkippable(File file) {
  final normalized = file.path.replaceAll('\\', '/');
  final segments = normalized.split('/');
  final name = segments.last;
  if (_generatedSuffixes.any(name.endsWith)) {
    return true;
  }
  if (segments.contains('l10n') || segments.contains('generated')) {
    return true;
  }
  return name == 'app_localizations.dart' ||
      name.startsWith('app_localizations_');
}

Iterable<File> _dartFiles(String root) sync* {
  final entity = FileSystemEntity.typeSync(root) == FileSystemEntityType.file
      ? File(root)
      : Directory(root);
  if (entity is File) {
    if (entity.path.endsWith('.dart') && !_isSkippable(entity)) {
      yield entity;
    }
    return;
  }
  if (entity is Directory && entity.existsSync()) {
    for (final child in entity.listSync(recursive: true, followLinks: false)) {
      if (child is File && child.path.endsWith('.dart') && !_isSkippable(child)) {
        yield child;
      }
    }
  }
}

String _relativePath(String path) {
  final current = Directory.current.absolute.path.replaceAll('\\', '/');
  final absolute = File(path).absolute.path.replaceAll('\\', '/');
  final prefix = '$current/';
  if (absolute.startsWith(prefix)) {
    return absolute.substring(prefix.length);
  }
  return path.replaceAll('\\', '/');
}

Set<String> _readBaseline() {
  final file = File(_baselineFile);
  if (!file.existsSync()) {
    throw StateError(
      'Baseline file not found at $_baselineFile. '
      'Run with --update-baseline to create it.',
    );
  }

  final entries = <String>{};
  for (final line in file.readAsLinesSync()) {
    if (line.trim().isEmpty || line.startsWith('#')) {
      continue;
    }
    final separator = line.indexOf('\t');
    if (separator <= 0 || separator == line.length - 1) {
      throw FormatException(
        'Invalid baseline entry (expected path<TAB>digest): $line',
      );
    }
    entries.add(line);
  }
  return entries;
}

void _writeBaseline(Iterable<_Finding> findings) {
  final entries = findings.map((finding) => finding.key).toSet().toList()
    ..sort();
  final file = File(_baselineFile);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync('${entries.join('\n')}\n');
  stdout.writeln('Updated $_baselineFile with ${entries.length} entries.');
}

void _printFinding(_Finding finding, {required bool newFinding}) {
  final suffix = newFinding ? ' (not in baseline)' : '';
  stdout.writeln(
    '${finding.path}:${finding.line}:${finding.column}: '
    'hardcoded user-facing string$suffix: ${jsonEncode(finding.value)}',
  );
}

void _printHelp() {
  stdout.writeln('''Usage: dart run tool/check_hardcoded_strings.dart [OPTIONS] [PATH ...]

Scan lib/ (or supplied files/directories) for hardcoded user-facing strings.
By default, only findings not present in tool/hardcoded_strings_baseline.txt fail.

Options:
  --all, --no-baseline  Print and fail on every finding (burn-down mode).
  --update-baseline    Rewrite the checked-in baseline from current findings.
  --help               Show this help text.

Add // ignore: hardcoded_string on the finding's line (or the line above) only
for a justified development-only string.''');
}

List<_Finding> _scan(Iterable<String> roots) {
  final files = <File>{};
  for (final root in roots) {
    files.addAll(_dartFiles(root));
  }

  final findings = <_Finding>[];
  for (final file in files) {
    final path = file.absolute.path;
    final result = parseFile(
      path: path,
      featureSet: FeatureSet.latestLanguageVersion(),
      throwIfDiagnostics: false,
    );
    if (result.errors.isNotEmpty) {
      stderr.writeln(
        'Warning: ${_relativePath(path)} has ${result.errors.length} '
        'parse error(s); scanning recoverable syntax.',
      );
    }
    final visitor = _StringVisitor(
      result: result,
      path: _relativePath(path),
    );
    result.unit.accept(visitor);
    findings.addAll(visitor.findings);
  }

  findings.sort((left, right) {
    final byPath = left.path.compareTo(right.path);
    if (byPath != 0) {
      return byPath;
    }
    final byLine = left.line.compareTo(right.line);
    if (byLine != 0) {
      return byLine;
    }
    return left.column.compareTo(right.column);
  });
  return findings;
}

void main(List<String> arguments) {
  var allMode = false;
  var updateBaseline = false;
  final roots = <String>[];
  for (final argument in arguments) {
    switch (argument) {
      case '--help':
      case '-h':
        _printHelp();
        return;
      case '--all':
      case '--no-baseline':
        allMode = true;
      case '--update-baseline':
        updateBaseline = true;
      default:
        if (argument.startsWith('-')) {
          stderr.writeln('Unknown option: $argument');
          _printHelp();
          exitCode = 2;
          return;
        }
        roots.add(argument);
    }
  }

  if (allMode && updateBaseline) {
    stderr.writeln('--update-baseline cannot be combined with --all.');
    exitCode = 2;
    return;
  }

  final findings = _scan(roots.isEmpty ? <String>['lib'] : roots);
  if (updateBaseline) {
    _writeBaseline(findings);
    return;
  }

  var reportFindings = findings;
  if (!allMode) {
    Set<String> baseline;
    try {
      baseline = _readBaseline();
    } on Object catch (error) {
      stderr.writeln('ERROR: $error');
      exitCode = 2;
      return;
    }

    final currentKeys = findings.map((finding) => finding.key).toSet();
    final staleCount = baseline.difference(currentKeys).length;
    if (staleCount > 0) {
      stdout.writeln(
        '$staleCount stale baseline entries; '
        'run --update-baseline to remove them.',
      );
    }
    reportFindings =
        findings.where((finding) => !baseline.contains(finding.key)).toList();
  }

  for (final finding in reportFindings) {
    _printFinding(finding, newFinding: !allMode);
  }
  if (allMode) {
    stdout.writeln('Found ${reportFindings.length} hardcoded user-facing string(s).');
  } else {
    stdout.writeln(
      'Found ${reportFindings.length} new hardcoded user-facing string(s) '
      '(${findings.length} total; baseline mode).',
    );
  }
  exitCode = reportFindings.isEmpty ? 0 : 1;
}
