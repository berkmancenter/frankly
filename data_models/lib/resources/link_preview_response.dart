import 'package:freezed_annotation/freezed_annotation.dart';

part 'link_preview_response.freezed.dart';
part 'link_preview_response.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class LinkPreviewResponse with _$LinkPreviewResponse {
  factory LinkPreviewResponse({
    String? title,
    String? description,
    String? image,
    String? url,
  }) = _LinkPreviewResponse;

  factory LinkPreviewResponse.fromJson(Map<String, dynamic> json) =>
      _$LinkPreviewResponseFromJson(json);
}
