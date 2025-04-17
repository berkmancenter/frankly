import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_tag.freezed.dart';
part 'community_tag.g.dart';

enum TaggedItemType {
  community,
  template,
  resource,
  profile,
}

@Freezed(makeCollectionsUnmodifiable: false)
class CommunityTag with _$CommunityTag {
  factory CommunityTag({
    @JsonKey(unknownEnumValue: null) required TaggedItemType? taggedItemType,
    required String definitionId,
    String? communityId,
    required String taggedItemId,
  }) = _CommunityTag;

  factory CommunityTag.fromJson(Map<String, dynamic> json) =>
      _$CommunityTagFromJson(json);
}
