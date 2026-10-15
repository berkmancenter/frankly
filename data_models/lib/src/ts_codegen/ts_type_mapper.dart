import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:freezed_annotation/freezed_annotation.dart' show Freezed;
import 'package:source_gen/source_gen.dart';

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
  final bool needsManualFollowUp;

  FieldResult(this.tsLine, {this.needsManualFollowUp = false});
}

/// Best-effort Dart type -> zod schema mapper for the subset of patterns
/// actually used in `data_models` (no freezed unions, no generics, a small fixed set of custom converters).
class TsTypeMapper {
  FieldResult fieldFor(ParameterElement param) {
    try {
      final jsonKey = _jsonKeyAnnotation(param);
      final defaultAnnotation = _defaultAnnotation(param);

      final fromJsonName = jsonKey != null
          ? _staticFunctionName(jsonKey.peek('fromJson'))
          : null;
      final unknownEnumValueIsNull =
          jsonKey != null && jsonKey.peek('unknownEnumValue')?.isNull == true;
      final jsonName = jsonKey?.peek('name')?.stringValue;

      var zodExpr = _zodExprFor(
        param.type,
        fromJsonName: fromJsonName,
        unknownEnumValueIsNull: unknownEnumValueIsNull,
      );

      var manualFollowUp = zodExpr.needsManualFollowUp;

      var expr = zodExpr.tsLine;

      if (param.type.nullabilitySuffix == NullabilitySuffix.question) {
        expr += '.nullable()';
      }

      if (defaultAnnotation != null) {
        final rendered = _renderDefault(defaultAnnotation);
        if (rendered != null) {
          expr += '.default($rendered)';
        } else {
          manualFollowUp = true;
          expr += " /* TODO: unmapped @Default value */";
        }
      } else if (!param.isRequiredNamed &&
          param.type.nullabilitySuffix != NullabilitySuffix.question) {
        // Optional-but-non-nullable without @Default shouldn't occur given
        // freezed conventions, but guard anyway.
        manualFollowUp = true;
        expr += " /* TODO: optional non-nullable field, verify */";
      }

      final fieldName = jsonName ?? param.name;
      return FieldResult(
        '  $fieldName: $expr,',
        needsManualFollowUp: manualFollowUp,
      );
    } catch (e) {
      return FieldResult(
        '  ${param.name}: z.any(), // TODO: codegen failed for this field: $e',
        needsManualFollowUp: true,
      );
    }
  }

  FieldResult _zodExprFor(
    DartType type, {
    String? fromJsonName,
    bool unknownEnumValueIsNull = false,
  }) {
    if (fromJsonName != null) {
      if (_knownConverters.contains(fromJsonName)) {
        // All known converters in this package are DateTime<->timestamp
        // conversions; the shared TS helper takes care of both directions.
        return FieldResult('z.coerce.date()');
      }
      return FieldResult(
        'z.any() /* TODO: unsupported converter $fromJsonName */',
        needsManualFollowUp: true,
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
        if (unknownEnumValueIsNull) {
          // Unknown values should parse to null rather than throwing.
          expr = 'z.enum([$values]).catch(undefined as any).nullable()';
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
        final inner = _zodExprFor(arg);
        return FieldResult(
          'z.array(${inner.tsLine})',
          needsManualFollowUp: inner.needsManualFollowUp,
        );
      }

      if (type.isDartCoreMap) {
        final valueArg = type.typeArguments.last;
        final inner = _zodExprFor(valueArg);
        return FieldResult(
          'z.record(z.string(), ${inner.tsLine})',
          needsManualFollowUp: inner.needsManualFollowUp,
        );
      }

      // Nested model reference - assume it will also be codegen'd and
      // exposed as `<Name>Schema`. Uses z.lazy to tolerate circular imports;
      // the actual import statement is NOT generated by this prototype.
      if (element is ClassElement &&
          const TypeChecker.fromRuntime(Freezed).hasAnnotationOf(element)) {
        return FieldResult(
          'z.lazy(() => ${element.name}Schema) /* TODO: add import for ${element.name}Schema */',
        );
      }

      return FieldResult(
        'z.any() /* TODO: unhandled type ${type.getDisplayString(withNullability: false)} */',
        needsManualFollowUp: true,
      );
    }

    return FieldResult(
      'z.any() /* TODO: unhandled type ${type.getDisplayString(withNullability: false)} */',
      needsManualFollowUp: true,
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

  String? _renderDefault(ConstantReader reader) {
    final obj = reader.read('defaultValue').objectValue;
    if (obj.isNull) return 'null';
    final boolVal = obj.toBoolValue();
    if (boolVal != null) return '$boolVal';
    final intVal = obj.toIntValue();
    if (intVal != null) return '$intVal';
    final doubleVal = obj.toDoubleValue();
    if (doubleVal != null) return '$doubleVal';
    final enumElement = obj.type?.element;
    if (enumElement is EnumElement) {
      final index = obj.getField('index')?.toIntValue();
      final constants =
          enumElement.fields.where((f) => f.isEnumConstant).toList();
      if (index != null && index < constants.length) {
        return "'${constants[index].name}'";
      }
    }
    final stringVal = obj.toStringValue();
    if (stringVal != null) return "'$stringVal'";
    final listVal = obj.toListValue();
    if (listVal != null && listVal.isEmpty) return '[]';
    final mapVal = obj.toMapValue();
    if (mapVal != null && mapVal.isEmpty) return '{}';
    return null;
  }
}
