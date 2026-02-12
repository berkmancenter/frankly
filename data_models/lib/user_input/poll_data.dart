import 'package:freezed_annotation/freezed_annotation.dart';

part 'poll_data.freezed.dart';
part 'poll_data.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class PollData with _$PollData {
  factory PollData({
    String? id,
    String? userId,
    String? userEmail,
    String? userName,
    DateTime? answeredDate,
    String? pollResponse,
    String? roomId,
    String? agendaItemId,
    String? pollQuestion,
  }) = _PollData;

  factory PollData.fromJson(Map<String, dynamic> json) =>
      _$PollDataFromJson(json);
}
