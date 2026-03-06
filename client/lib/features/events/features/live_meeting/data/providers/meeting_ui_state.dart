import 'package:data_models/events/live_meetings/live_meeting.dart';

enum MeetingUiState {
  leftMeeting,
  enterMeetingPrescreen,
  breakoutRoom,
  waitingRoom,
  liveStream,
  inMeeting,
}

/// Maps a [MeetingUiState] to the presence room ID that should be sent in
/// heartbeat updates.
///
/// Returns [breakoutsWaitingRoomId] for waiting room, the active breakout room
/// ID for breakout rooms, and null for all other states.
///
/// This is extracted as a standalone function so:
/// 1. The mapping logic can be unit-tested without instantiating
///    [LiveMeetingProvider] (which has web-only dependencies).
/// 2. The production [_presenceRoomId] getter delegates to it, keeping the
///    logic in one place.
String? presenceRoomIdForState(
  MeetingUiState state, {
  String? activeBreakoutRoomId,
}) {
  switch (state) {
    case MeetingUiState.waitingRoom:
      return breakoutsWaitingRoomId;
    case MeetingUiState.breakoutRoom:
      return activeBreakoutRoomId;
    case MeetingUiState.liveStream:
    case MeetingUiState.inMeeting:
    case MeetingUiState.leftMeeting:
    case MeetingUiState.enterMeetingPrescreen:
      return null;
  }
}
