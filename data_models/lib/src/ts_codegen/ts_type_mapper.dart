import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:freezed_annotation/freezed_annotation.dart' show Freezed;
import 'package:path/path.dart' as p;
import 'package:source_gen/source_gen.dart';

/// Tracks which other generated `.model.ts` files the file currently being
/// built needs real `import` statements for, so nested-model references
/// (e.g. `Template.eventSettings: EventSettings`) resolve at runtime
class ImportTracker {
  ImportTracker(this.currentLibPath);

  /// This file's own Dart source path relative to `lib/`, e.g.
  /// `templates/template.dart`.
  final String currentLibPath;

  final Map<String, Set<String>> _schemasByLibPath = {};

  /// Records that the generated output needs `<ClassName>Schema` from
  /// [element]'s declaring file. Returns false if the source can't be
  /// resolved to a package-relative path (caller should fall back to a
  /// TODO comment rather than emitting a reference with no import at all).
  bool record(ClassElement element) {
    final uri = element.library.source.uri;
    if (uri.scheme != 'package') return false;
    final segments = uri.pathSegments;
    if (segments.length < 2) return false;
    final targetLibPath = segments.skip(1).join('/'); // drop the package name
    if (targetLibPath != currentLibPath) {
      // Same-file self-references (common in files like event.dart with many
      // interdependent classes) don't need an import - already in scope.
      _schemasByLibPath.putIfAbsent(targetLibPath, () => {}).add(element.name);
    }
    return true;
  }

  /// Renders one `import { ... } from '...';` line per distinct source file,
  /// sorted for deterministic output.
  List<String> renderImportLines() {
    final currentDir = p.posix.dirname(currentLibPath);
    final lines = <String>[];
    final sortedPaths = _schemasByLibPath.keys.toList()..sort();
    for (final targetLibPath in sortedPaths) {
      final schemaNames = _schemasByLibPath[targetLibPath]!.toList()..sort();
      final namedImports =
          schemaNames.map((name) => '${name}Schema').join(', ');
      final targetModulePath =
          targetLibPath.replaceFirst(RegExp(r'\.dart$'), '.model');
      var relative = p.posix.relative(targetModulePath, from: currentDir);
      if (!relative.startsWith('.')) relative = './$relative';
      lines.add("import { $namedImports } from '$relative';");
    }
    return lines;
  }
}

/// Converter functions in `lib/utils/utils_web.dart` that this prototype
/// knows how to translate to a TS equivalent. Anything else referenced via
/// `@JsonKey(fromJson: ..., toJson: ...)` falls back to an `z.any()` stub
/// with a TODO comment, rather than failing the whole file.
const _knownConverters = {
  'dateTimeFromTimestamp',
  'timestampFromDateTime',
  'serverTimestamp',
  'serverTimestampOrNull',
};

class FieldResult {
  final String tsLine;

  FieldResult(
    this.tsLine,
  );
}

/// Best-effort Dart type -> zod schema mapper for the subset of patterns
/// actually used in `data_models` (no freezed unions, no generics, a small fixed set of custom converters).
class TsTypeMapper {
  FieldResult fieldFor(ParameterElement param, ImportTracker imports) {
    try {
      final jsonKey = _jsonKeyAnnotation(param);
      final defaultAnnotation = _defaultAnnotation(param);

      final fromJsonName = jsonKey != null
          ? _staticFunctionName(jsonKey.peek('fromJson'))
          : null;
      final unknownEnumValueReader = jsonKey?.peek('unknownEnumValue');
      final unknownEnumValueIsNull = unknownEnumValueReader?.isNull == true;
      // A concrete fallback, e.g. `@JsonKey(unknownEnumValue: RecordingSessionStatus.failed)`,
      // not just the `unknownEnumValue: null` case.
      final unknownEnumValueName =
          (unknownEnumValueReader != null && !unknownEnumValueReader.isNull)
              ? _enumConstantName(unknownEnumValueReader.objectValue)
              : null;
      final jsonName = jsonKey?.peek('name')?.stringValue;

      var zodExpr = _zodExprFor(
        param.type,
        imports,
        fromJsonName: fromJsonName,
        unknownEnumValueIsNull: unknownEnumValueIsNull,
        unknownEnumValueName: unknownEnumValueName,
      );

      var expr = zodExpr.tsLine;

      // json_serializable's generated `fromJson` applies a field's default to
      // BOTH a missing key and an explicit JSON `null`
      // (`json['about'] as String? ?? ''`), not just a missing key. A
      // `@JsonKey(defaultValue:)` override takes precedence over
      // `@Default(...)` when both are present, matching json_serializable's
      // own precedence - freezed's `@Default` is really just forwarded into
      // the same `defaultValue` mechanism when no explicit override exists.
      final jsonKeyDefaultReader = jsonKey?.peek('defaultValue');
      final hasJsonKeyDefault =
          jsonKeyDefaultReader != null && !jsonKeyDefaultReader.isNull;
      // `jsonKeyDefaultReader` already wraps the *value* (JsonKey.defaultValue
      // itself), whereas `defaultAnnotation` wraps the whole `@Default(...)`
      // annotation object, whose value is one level deeper at its own
      // `defaultValue` field - resolve both to the same shape before
      // rendering.
      final effectiveDefaultValue = hasJsonKeyDefault
          ? jsonKeyDefaultReader.objectValue
          : defaultAnnotation?.read('defaultValue').objectValue;
      final hasEffectiveDefault =
          hasJsonKeyDefault || defaultAnnotation != null;
      final renderedDefault = effectiveDefaultValue != null
          ? _renderDefault(effectiveDefaultValue)
          : null;

      if (renderedDefault != null) {
        // zod's `.default()` only substitutes `undefined`, never `null` -
        // preprocessing both to the default before validation matches Dart's
        // `?? defaultValue` exactly, for nullable and non-nullable fields
        // alike (e.g. a non-nullable `List<T>` with `@Default([])` must
        // accept an explicit JSON `null`, not just a missing key).
        expr = 'z.preprocess((val) => val ?? $renderedDefault, $expr)';
      } else {
        if (param.type.nullabilitySuffix == NullabilitySuffix.question) {
          expr += '.nullable().default(null)';
        }
        if (hasEffectiveDefault) {
          // A default annotation is present but its value didn't map to a TS
          // literal - flag for manual follow-up rather than silently
          // dropping it.
          expr += " /* TODO: unmapped default value */";
        } else if (!param.isRequiredNamed &&
            param.type.nullabilitySuffix != NullabilitySuffix.question) {
          // Optional-but-non-nullable without @Default shouldn't occur given
          // freezed conventions, but guard anyway.
          expr += " /* TODO: optional non-nullable field, verify */";
        }
      }

      final fieldName = jsonName ?? param.name;
      return FieldResult(
        '  $fieldName: $expr,',
      );
    } catch (e) {
      // Fallback for fields that couldn't be codegen'd correctly
      return FieldResult(
        '  ${param.name}: z.any(), // TODO: codegen failed for this field: $e',
      );
    }
  }

  FieldResult _zodExprFor(
    DartType type,
    ImportTracker imports, {
    String? fromJsonName,
    bool unknownEnumValueIsNull = false,
    String? unknownEnumValueName,
  }) {
    if (fromJsonName != null) {
      if (_knownConverters.contains(fromJsonName)) {
        // All known converters in this package are DateTime<->timestamp
        // conversions; the shared TS helper takes care of both directions.
        return FieldResult('z.coerce.date()');
      }
      return FieldResult(
        'z.any() /* TODO: unsupported converter $fromJsonName */',
      );
    }

    if (type is InterfaceType) {
      final element = type.element;

      if (element is EnumElement) {
        final values = element.fields
            .where((f) => f.isEnumConstant)
            .map((f) => "'${f.name}'")
            .join(', ');
        var expr = 'z.enum([$values])';
        if (unknownEnumValueName != null) {
          // Unknown values should fall back to a concrete member, e.g.
          // `@JsonKey(unknownEnumValue: RecordingSessionStatus.failed)`,
          // matching json_serializable's generated fromJson behavior.
          expr = "z.enum([$values]).catch('$unknownEnumValueName')";
        }
        return FieldResult(expr);
      }

      if (type.isDartCoreString) return FieldResult('z.string()');
      if (type.isDartCoreBool) return FieldResult('z.boolean()');
      if (type.isDartCoreInt) return FieldResult('z.number().int()');
      if (type.isDartCoreDouble) return FieldResult('z.number()');
      if (type.isDartCoreNum) return FieldResult('z.number()');
      if (element.name == 'DateTime') {
        // No @JsonKey converter on this field, so treat the same as the known-converter case.
        return FieldResult('z.coerce.date()');
      }

      if (type.isDartCoreList) {
        final arg = type.typeArguments.first;
        final inner = _zodExprFor(arg, imports);
        return FieldResult(
          'z.array(${inner.tsLine})',
        );
      }

      if (type.isDartCoreMap) {
        final valueArg = type.typeArguments.last;
        final inner = _zodExprFor(valueArg, imports);
        return FieldResult(
          'z.record(z.string(), ${inner.tsLine})',
        );
      }

      // Nested model reference - assume it will also be codegen'd and
      // exposed as `<Name>Schema`. Uses z.lazy to tolerate circular imports
      // at the zod-schema-evaluation level even once real imports exist.
      if (element is ClassElement &&
          const TypeChecker.fromRuntime(Freezed).hasAnnotationOf(element)) {
        if (!imports.record(element)) {
          return FieldResult(
            'z.lazy(() => ${element.name}Schema) /* TODO: could not resolve import for ${element.name}Schema */',
          );
        }
        return FieldResult('z.lazy(() => ${element.name}Schema)');
      }

      return FieldResult(
        'z.any() /* TODO: unhandled type ${type.getDisplayString(withNullability: false)} */',
      );
    }

    return FieldResult(
      'z.any() /* TODO: unhandled type ${type.getDisplayString(withNullability: false)} */',
    );
  }

  ConstantReader? _jsonKeyAnnotation(ParameterElement param) {
    const checker = TypeChecker.fromUrl(
        'package:json_annotation/src/json_key.dart#JsonKey');
    final annotation = checker.firstAnnotationOf(param);
    return annotation == null ? null : ConstantReader(annotation);
  }

  ConstantReader? _defaultAnnotation(ParameterElement param) {
    const checker = TypeChecker.fromUrl(
        'package:freezed_annotation/freezed_annotation.dart#Default');
    final annotation = checker.firstAnnotationOf(param);
    return annotation == null ? null : ConstantReader(annotation);
  }

  String? _staticFunctionName(ConstantReader? reader) {
    if (reader == null || reader.isNull) return null;
    final obj = reader.objectValue;
    final fn = obj.toFunctionValue();
    return fn?.name;
  }

  /// The member name of an enum constant `DartObject` (e.g. `'failed'` for
  /// `RecordingSessionStatus.failed`), or null if `obj` isn't an enum value.
  String? _enumConstantName(DartObject obj) {
    final enumElement = obj.type?.element;
    if (enumElement is! EnumElement) return null;
    final index = obj.getField('index')?.toIntValue();
    final constants =
        enumElement.fields.where((f) => f.isEnumConstant).toList();
    if (index == null || index >= constants.length) return null;
    return constants[index].name;
  }

  String? _renderDefault(DartObject obj) {
    if (obj.isNull) return 'null';
    final boolVal = obj.toBoolValue();
    if (boolVal != null) return '$boolVal';
    final intVal = obj.toIntValue();
    if (intVal != null) return '$intVal';
    final doubleVal = obj.toDoubleValue();
    if (doubleVal != null) return '$doubleVal';
    final enumName = _enumConstantName(obj);
    if (enumName != null) return "'$enumName'";
    final stringVal = obj.toStringValue();
    if (stringVal != null) return "'$stringVal'";
    final listVal = obj.toListValue();
    if (listVal != null && listVal.isEmpty) return '[]';
    final mapVal = obj.toMapValue();
    if (mapVal != null && mapVal.isEmpty) return '{}';
    return null;
  }
}
