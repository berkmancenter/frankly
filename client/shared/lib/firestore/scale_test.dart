import 'package:freezed_annotation/freezed_annotation.dart';

part 'scale_test.freezed.dart';
part 'scale_test.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class ScaleTest with _$ScaleTest {
  factory ScaleTest({
    required String juntoId,
    required String topicId,
    required String discussionId,
  }) = _ScaleTest;

  factory ScaleTest.fromJson(Map<String, dynamic> json) => _$ScaleTestFromJson(json);
}
