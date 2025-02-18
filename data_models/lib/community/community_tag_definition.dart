import 'package:freezed_annotation/freezed_annotation.dart';

part 'community_tag_definition.freezed.dart';
part 'community_tag_definition.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class CommunityTagDefinition with _$CommunityTagDefinition {
  factory CommunityTagDefinition({
    required String id,
    required String title,
    String? searchKey,
  }) = _CommunityTagDefinition;

  factory CommunityTagDefinition.fromJson(Map<String, dynamic> json) =>
      _$CommunityTagDefinitionFromJson(json);
}
