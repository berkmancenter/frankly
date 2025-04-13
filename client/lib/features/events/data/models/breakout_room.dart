// Placeholder for breakout_room.dart
// This file is imported by reassign_breakout_room_dialog.dart

import 'package:flutter/foundation.dart';

/// A model representing a breakout room
class BreakoutRoom {
  final String roomId;
  final String roomName;
  final int orderingPriority;
  final BreakoutRoomFlagStatus flagStatus;
  final String creatorId;

  const BreakoutRoom({
    required this.roomId,
    required this.roomName,
    required this.orderingPriority,
    required this.flagStatus,
    required this.creatorId,
  });

  factory BreakoutRoom.fromJson(Map<String, dynamic> json) {
    return BreakoutRoom(
      roomId: json['roomId'] as String,
      roomName: json['roomName'] as String,
      orderingPriority: json['orderingPriority'] as int,
      flagStatus: BreakoutRoomFlagStatus.values[json['flagStatus'] as int],
      creatorId: json['creatorId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'roomName': roomName,
      'orderingPriority': orderingPriority,
      'flagStatus': flagStatus.index,
      'creatorId': creatorId,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BreakoutRoom &&
          runtimeType == other.runtimeType &&
          roomId == other.roomId;

  @override
  int get hashCode => roomId.hashCode;
}

/// Status of a breakout room flag
enum BreakoutRoomFlagStatus {
  unflagged,
  flagged,
}

/// ID used to represent the waiting room
const String breakoutsWaitingRoomId = 'waiting-room';
