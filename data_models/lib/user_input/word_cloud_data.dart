import 'package:freezed_annotation/freezed_annotation.dart';

part 'word_cloud_data.freezed.dart';
part 'word_cloud_data.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class WordCloudData with _$WordCloudData {
  const factory WordCloudData({
    required String userId,
    required String agendaItemId,
    required String roomId,
    required String prompt,
    required String message,
    DateTime? createdDate,

    /// Word clouds currently have no voting mechanism.
    @Default(0) int upvotes,
  }) = _WordCloudData;

  factory WordCloudData.fromJson(Map<String, dynamic> json) =>
      _$WordCloudDataFromJson(json);
}
