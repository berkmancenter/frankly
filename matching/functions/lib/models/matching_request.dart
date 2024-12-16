import 'package:json_annotation/json_annotation.dart';

part 'matching_request.g.dart';

@JsonSerializable()
class MatchingRequest {
  final int? targetGroupSize;
  final String googleSheetId;

  MatchingRequest({
    required this.targetGroupSize,
    required this.googleSheetId,
  });

  factory MatchingRequest.fromJson(Map<String, dynamic> json) =>
      _$MatchingRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MatchingRequestToJson(this);
}
