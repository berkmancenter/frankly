import 'package:freezed_annotation/freezed_annotation.dart';

part 'platform_item.freezed.dart';
part 'platform_item.g.dart';

enum PlatformKey { community, googleMeet, maps, microsoftTeam, zoom }

@freezed
class PlatformItem with _$PlatformItem {
  factory PlatformItem({
    String? title,
    String? description,
    String? logoUrl,
    String? url,
    @JsonKey(unknownEnumValue: null) PlatformKey? platformKey,
  }) = _PlatformItem;

  factory PlatformItem.fromJson(Map<String, dynamic> json) =>
      _$PlatformItemFromJson(json);
}
