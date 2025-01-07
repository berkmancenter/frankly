import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';

part 'pre_post_card_attribute.freezed.dart';
part 'pre_post_card_attribute.g.dart';

enum PrePostCardAttributeType {
  userId,
  eventId,
  email,
}

// TODO: test
extension PrePostCardAttributeTypeExtension on PrePostCardAttributeType {
  String get text {
    switch (this) {
      case PrePostCardAttributeType.userId:
        return 'ParticipantID';
      case PrePostCardAttributeType.eventId:
        return 'EventID';
      case PrePostCardAttributeType.email:
        return 'Email';
    }
  }

  String? getQueryValue({String? userId, Event? event, String? email}) {
    switch (this) {
      case PrePostCardAttributeType.userId:
        return userId;
      case PrePostCardAttributeType.eventId:
        return event?.id;
      case PrePostCardAttributeType.email:
        return email;
    }
  }
}

@Freezed(makeCollectionsUnmodifiable: false)
class PrePostCardAttribute
    with _$PrePostCardAttribute
    implements SerializeableRequest {
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
      case PrePostCardAttributeType.eventId:
        return 'eventId';
      case PrePostCardAttributeType.email:
        return 'email';
    }
  }
}
