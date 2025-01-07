import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:data_models/utils/firestore_utils.dart';

part 'community_resource.freezed.dart';
part 'community_resource.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class CommunityResource with _$CommunityResource {
  factory CommunityResource({
    required String id,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
    DateTime? createdDate,
    String? title,
    String? url,
    String? image,
  }) = _CommunityResource;

  factory CommunityResource.fromJson(Map<String, dynamic> json) =>
      _$CommunityResourceFromJson(json);
}
