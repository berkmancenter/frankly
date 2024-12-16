import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:junto_models/firestore/utils.dart';

part 'junto_resource.freezed.dart';
part 'junto_resource.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class JuntoResource with _$JuntoResource {
  factory JuntoResource({
    required String id,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp) DateTime? createdDate,
    String? title,
    String? url,
    String? image,
  }) = _JuntoResource;

  factory JuntoResource.fromJson(Map<String, dynamic> json) => _$JuntoResourceFromJson(json);
}
