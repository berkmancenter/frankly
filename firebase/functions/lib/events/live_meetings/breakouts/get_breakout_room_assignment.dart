import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../../../on_call_function.dart';
import '../../../utils/infra/firestore_utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:data_models/utils/utils.dart';

class GetBreakoutRoomAssignment
    extends OnCallMethod<GetBreakoutRoomAssignmentRequest> {
  GetBreakoutRoomAssignment()
      : super(
          'GetBreakoutRoomAssignment',
          (jsonMap) => GetBreakoutRoomAssignmentRequest.fromJson(jsonMap),
        );

  @override
  Future<Map<String, dynamic>> action(
    GetBreakoutRoomAssignmentRequest request,
    CallableContext context,
  ) async {
    // Verify user is a participant
    final participant = await firestoreUtils.getFirestoreObject(
      path: '${request.eventPath}/event-participants/${context.authUid}',
      constructor: (map) => Participant.fromJson(map),
    );
    if (participant.status != ParticipantStatus.active) {
      throw HttpsError(HttpsError.failedPrecondition, 'unauthorized', null);
    }

    final liveMeetingPath =
        '${request.eventPath}/live-meetings/${request.eventId}';
    final liveMeeting = await firestoreUtils.getFirestoreObject(
      path: liveMeetingPath,
      constructor: (map) => LiveMeeting.fromJson(map),
    );

    final breakoutSession = liveMeeting.currentBreakoutSession;

    if (breakoutSession == null ||
        breakoutSession.breakoutRoomStatus != BreakoutRoomStatus.active) {
      throw Exception('Breakout rooms not active');
    }

    final breakoutRoomsCollection = firestore.collection(
      '$liveMeetingPath/breakout-room-sessions/${breakoutSession.breakoutRoomSessionId}/breakout-rooms',
    );

    final currentBreakoutRoom = await breakoutRoomsCollection
        .where(
          BreakoutRoom.kFieldParticipantIds,
          arrayContains: context.authUid,
        )
        .get();

    String? assignment;
    if (currentBreakoutRoom.documents.isNotEmpty) {
      assignment = BreakoutRoom.fromJson(
        firestoreUtils.fromFirestoreJson(
          currentBreakoutRoom.documents.first.data.toMap(),
        ),
      ).roomId;
    } else {
      final allBreakoutRoomDocs = await breakoutRoomsCollection.get();
      final allBreakoutRooms = allBreakoutRoomDocs.documents
          .map(
            (doc) => BreakoutRoom.fromJson(
              firestoreUtils.fromFirestoreJson(doc.data.toMap()),
            ),
          )
          .toList();

      assignment = await firestore.runTransaction((transaction) async {
        // Assign to waiting room if there is one.
        var assignedRoomIndex = allBreakoutRooms
            .indexWhere((br) => br.roomId == breakoutsWaitingRoomId);
        if (assignedRoomIndex < 0 && allBreakoutRooms.isNotEmpty) {
          // If no waiting room, then assign to a room with least participants
          final minBreakoutRoomCount = allBreakoutRooms
              .map((b) => b.participantIds.length)
              .reduce((a, b) => a < b ? a : b);
          assignedRoomIndex = allBreakoutRooms.indexWhere(
            (b) => b.participantIds.length == minBreakoutRoomCount,
          );
        }

        if (assignedRoomIndex < 0) {
          print('error, no breakout rooms found.');
          return null;
        } else {
          final roomDoc = breakoutRoomsCollection
              .document(allBreakoutRooms[assignedRoomIndex].roomId);
          final assignedRoomLookup = await firestoreUtils.getFirestoreObject(
            transaction: transaction,
            path: roomDoc.path,
            constructor: (map) => BreakoutRoom.fromJson(map),
          );

          transaction.update(
            roomDoc,
            UpdateData.fromMap(
              jsonSubset(
                [BreakoutRoom.kFieldParticipantIds],
                firestoreUtils.toFirestoreJson(
                  assignedRoomLookup.copyWith(
                    participantIds: [
                      ...assignedRoomLookup.participantIds,
                      context.authUid!,
                    ],
                  ).toJson(),
                ),
              ),
            ),
          );

          return assignedRoomLookup.roomId;
        }
      });
    }

    return GetBreakoutRoomAssignmentResponse(roomId: assignment).toJson();
  }
}
