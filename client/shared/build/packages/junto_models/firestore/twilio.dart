import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/utils.dart';

part 'twilio.freezed.dart';
part 'twilio.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class TwilioParticipant with _$TwilioParticipant implements SerializeableRequest {
  static const String fieldRoomId = 'roomId';

  factory TwilioParticipant({
    String? roomId,
    String? roomName,
    String? participantSid,
    String? participantIdentity,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime) DateTime? joinTime,
    @JsonKey(fromJson: dateTimeFromTimestamp, toJson: timestampFromDateTime) DateTime? leaveTime,
    int? duration,
  }) = _TwilioParticipant;

  factory TwilioParticipant.fromJson(Map<String, dynamic> json) =>
      _$TwilioParticipantFromJson(json);
}
