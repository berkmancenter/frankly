import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/utils.dart';

part 'discussion_message.freezed.dart';
part 'discussion_message.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class DiscussionMessage with _$DiscussionMessage implements SerializeableRequest {
  static const kFieldCreatedAt = 'createdAt';

  const DiscussionMessage._();
  factory DiscussionMessage({
    required String creatorId,
    @JsonKey(ignore: true) String? docId,

    //TODO(aurimas): Does not make sense to have it nullable, because it's never nullable
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime)
        required DateTime? createdAt,
    int? createdAtMillis,
    required String message,
  }) = _DiscussionMessage;

  factory DiscussionMessage.fromJson(Map<String, dynamic> json) =>
      _$DiscussionMessageFromJson(json);

  factory DiscussionMessage.fromFirestore(Map<String, dynamic> json, String docId) =>
      _$DiscussionMessageFromJson(json).copyWith(docId: docId);

  static Map<String, dynamic>? toJsonForCloudFunction(DiscussionMessage discussionMessage) {
    final dataMap = discussionMessage.toJson();

    dataMap.remove(kFieldCreatedAt);

    return dataMap;
  }
}
