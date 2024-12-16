import 'package:freezed_annotation/freezed_annotation.dart';

part 'junto_tag_definition.freezed.dart';
part 'junto_tag_definition.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class JuntoTagDefinition with _$JuntoTagDefinition {
  factory JuntoTagDefinition({
    required String id,
    required String title,
    String? searchKey,
  }) = _JuntoTagDefinition;

  factory JuntoTagDefinition.fromJson(Map<String, dynamic> json) =>
      _$JuntoTagDefinitionFromJson(json);
}
