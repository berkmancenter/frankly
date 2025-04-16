import 'package:freezed_annotation/freezed_annotation.dart';

part 'scale_test.freezed.dart';
part 'scale_test.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class ScaleTest with _$ScaleTest {
  factory ScaleTest({
    required String communityId,
    required String templateId,
    required String eventId,
  }) = _ScaleTest;

  factory ScaleTest.fromJson(Map<String, dynamic> json) =>
      _$ScaleTestFromJson(json);
}
