import 'package:freezed_annotation/freezed_annotation.dart';

part 'junto_tag.freezed.dart';
part 'junto_tag.g.dart';

enum TaggedItemType {
  junto,
  topic,
  resource,
  profile,
}

@Freezed(makeCollectionsUnmodifiable: false)
class JuntoTag with _$JuntoTag {
  factory JuntoTag({
    @JsonKey(unknownEnumValue: null) required TaggedItemType? taggedItemType,
    required String definitionId,
    String? juntoId,
    required String taggedItemId,
  }) = _JuntoTag;

  factory JuntoTag.fromJson(Map<String, dynamic> json) => _$JuntoTagFromJson(json);
}
