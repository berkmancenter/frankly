import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/utils/firestore_utils.dart';

part 'event_message.freezed.dart';
part 'event_message.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class EventMessage with _$EventMessage implements SerializeableRequest {
  static const kFieldCreatedAt = 'createdAt';

  const EventMessage._();
  factory EventMessage({
    required String creatorId,
    @JsonKey(ignore: true) String? docId,

    //TODO(aurimas): Does not make sense to have it nullable, because it's never nullable
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
    required DateTime? createdAt,
    int? createdAtMillis,
    required String message,
  }) = _EventMessage;

  factory EventMessage.fromJson(Map<String, dynamic> json) =>
      _$EventMessageFromJson(json);

  factory EventMessage.fromFirestore(Map<String, dynamic> json, String docId) =>
      _$EventMessageFromJson(json).copyWith(docId: docId);

  static Map<String, dynamic>? toJsonForCloudFunction(
      EventMessage eventMessage) {
    final dataMap = eventMessage.toJson();

    dataMap.remove(kFieldCreatedAt);

    return dataMap;
  }
}
