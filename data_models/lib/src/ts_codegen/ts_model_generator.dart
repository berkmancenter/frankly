import 'package:analyzer/dart/element/element.dart';
import 'package:freezed_annotation/freezed_annotation.dart' show Freezed;
import 'package:source_gen/source_gen.dart';

import 'ts_type_mapper.dart';

/// Generates a zod schema + TS type for a single `@Freezed` class.
///
/// Scoped to this package's actual usage: every `@Freezed` class here has
/// exactly one unnamed factory constructor (no unions), so this does not
/// attempt to handle freezed's sealed-class/union codegen at all.
class TsModelGenerator {
  final _mapper = TsTypeMapper();

  String? generateForClass(
    ClassElement classElement,
    ImportTracker imports,
  ) {
    if (!const TypeChecker.fromRuntime(Freezed).hasAnnotationOf(classElement)) {
      return null;
    }

    final factory = classElement.constructors.where(
      (c) => c.isFactory && c.name.isEmpty,
    );
    if (factory.isEmpty) return null;

    final params = factory.first.parameters;
    final fieldLines = <String>[];

    for (final param in params) {
      final result = _mapper.fieldFor(param, imports);
      fieldLines.add(result.tsLine);
    }

    final className = classElement.name;
    final ts = '''
export const ${className}Schema = z.object({
${fieldLines.join('\n')}
});

export type $className = z.infer<typeof ${className}Schema>;
''';

    return ts;
  }
}
