import 'package:freezed_annotation/freezed_annotation.dart';

part 'media_item.freezed.dart';
part 'media_item.g.dart';

enum MediaType { image, video }

@Freezed(makeCollectionsUnmodifiable: false)
class MediaItem with _$MediaItem {
  const MediaItem._();

  factory MediaItem({
    required String url,
    required MediaType type,
  }) = _MediaItem;

  factory MediaItem.fromJson(Map<String, dynamic> json) =>
      _$MediaItemFromJson(json);

  String? getUrlByType(MediaType mediaType) {
    if (type == mediaType) {
      return url;
    } else {
      return null;
    }
  }
}
