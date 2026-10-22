import 'package:analyzer/dart/element/element.dart';
import 'package:freezed_annotation/freezed_annotation.dart' show Freezed;
import 'package:json_annotation/json_annotation.dart' show JsonSerializable;
import 'package:source_gen/source_gen.dart';

import 'ts_model_generator.dart';
import 'ts_type_mapper.dart';

/// Generates a zod schema + TS type for a plain (non-freezed) class
/// annotated with `@JsonSerializable()` - the shape used by the
/// `analytics/analytics_entities.dart` event family. Unlike the freezed
/// classes these declare their fields directly and have one ordinary
/// (non-factory) constructor whose `this.field` parameters double as the
/// field declarations.
class TsAnalyticsGenerator {
  final _mapper = TsTypeMapper();

  String? generateForClass(
    ClassElement classElement,
    ImportTracker imports,
  ) {
    if (!const TypeChecker.fromRuntime(JsonSerializable)
        .hasAnnotationOf(classElement)) {
      return null;
    }
    // Freezed classes are also technically visible to a `@JsonSerializable`
    // check via their generated mixin in some analyzer versions - guard
    // against double-processing.
    if (const TypeChecker.fromRuntime(Freezed).hasAnnotationOf(classElement)) {
      return null;
    }

    final constructor = classElement.constructors.where(
      (c) => !c.isFactory && c.name.isEmpty,
    );
    if (constructor.isEmpty) return null;

    final params = constructor.first.parameters;
    final fieldLines = <String>[];

    for (final param in params) {
      final result = _mapper.fieldFor(param, imports);
      fieldLines.add(result.tsLine);
    }

    final className = classElement.name;
    final body = fieldLines.isEmpty ? '' : '\n${fieldLines.join('\n')}\n';
    final ts = '''
export const ${className}Schema = z.object({$body});

export type $className = z.infer<typeof ${className}Schema>;
''';

    return ts;
  }
}
