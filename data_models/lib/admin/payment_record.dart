import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_record.freezed.dart';
part 'payment_record.g.dart';

enum PaymentType { oneTimeDonation }

@Freezed(makeCollectionsUnmodifiable: false)
class PaymentRecord with _$PaymentRecord {
  factory PaymentRecord({
    String? id,
    String? authUid,
    String? communityId,
    int? amountInCents,
    DateTime? createdDate,
    @JsonKey(unknownEnumValue: null) PaymentType? type,
  }) = _PaymentRecord;

  factory PaymentRecord.fromJson(Map<String, dynamic> json) =>
      _$PaymentRecordFromJson(json);
}
