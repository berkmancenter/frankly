import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:data_models/utils/firestore_utils.dart';

part 'email_digest_record.freezed.dart';
part 'email_digest_record.g.dart';

enum DigestType {
  weekly,
}

@Freezed(makeCollectionsUnmodifiable: false)
class EmailDigestRecord with _$EmailDigestRecord {
  static const String kFieldId = 'id';
  static const String kFieldUserId = 'userId';
  static const String kFieldCommunityId = 'communityId';
  static const String kFieldType = 'type';
  static const String kFieldSentAt = 'sentAt';

  factory EmailDigestRecord({
    String? id,
    String? userId,
    String? communityId,
    @Default(DigestType.weekly)
    @JsonKey(
        defaultValue: DigestType.weekly, unknownEnumValue: DigestType.weekly)
    DigestType type,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: serverTimestamp)
    DateTime? sentAt,
  }) = _EmailDigestRecord;

  factory EmailDigestRecord.fromJson(Map<String, dynamic> json) =>
      _$EmailDigestRecordFromJson(json);
}
