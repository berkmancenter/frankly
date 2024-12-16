import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';

part 'pre_post_card_attribute.freezed.dart';
part 'pre_post_card_attribute.g.dart';

enum PrePostCardAttributeType {
  userId,
  discussionId,
  email,
}

// TODO: test
extension PrePostCardAttributeTypeExtension on PrePostCardAttributeType {
  String get text {
    switch (this) {
      case PrePostCardAttributeType.userId:
        return 'ParticipantID';
      case PrePostCardAttributeType.discussionId:
        return 'EventID';
      case PrePostCardAttributeType.email:
        return 'Email';
    }
  }

  String? getQueryValue({String? userId, Discussion? discussion, String? email}) {
    switch (this) {
      case PrePostCardAttributeType.userId:
        return userId;
      case PrePostCardAttributeType.discussionId:
        return discussion?.id;
      case PrePostCardAttributeType.email:
        return email;
    }
  }
}

@Freezed(makeCollectionsUnmodifiable: false)
class PrePostCardAttribute with _$PrePostCardAttribute implements SerializeableRequest {
  PrePostCardAttribute._();

  factory PrePostCardAttribute({
    required PrePostCardAttributeType type,
    required String queryParam,
  }) = _PrePostCardAttribute;

  factory PrePostCardAttribute.fromJson(Map<String, dynamic> json) =>
      _$PrePostCardAttributeFromJson(json);

  String get defaultQueryParam {
    switch (type) {
      case PrePostCardAttributeType.userId:
        return 'userId';
      case PrePostCardAttributeType.discussionId:
        return 'discussionId';
      case PrePostCardAttributeType.email:
        return 'email';
    }
  }
}
