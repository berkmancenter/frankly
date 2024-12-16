import 'dart:async';

import 'package:collection/src/iterable_extensions.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/on_call_function.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/live_meeting.dart';
import 'package:junto_models/firestore/membership.dart';
import 'package:junto_models/utils.dart';

class ReassignBreakoutRoom extends OnCallMethod<ReassignBreakoutRoomRequest> {
  ReassignBreakoutRoom()
      : super(
          'ReassignBreakoutRoom',
          (json) => ReassignBreakoutRoomRequest.fromJson(json),
        );

  Future<void> _verifyCallerIsAuthorized(Discussion discussion, CallableContext context) async {
    final juntoMembershipDoc = await firestore
        .document('memberships/${context?.authUid}/junto-membership/${discussion.juntoId}')
        .get();

    final membership = Membership.fromJson(
        firestoreUtils.fromFirestoreJson(juntoMembershipDoc.data?.toMap() ?? {}));

    final isAuthorized = discussion.creatorId == context?.authUid || membership.isMod;
    if (!isAuthorized) {
      throw HttpsError(HttpsError.failedPrecondition, 'unauthorized', null);
    }
  }

  @override
  Future<Map<String, dynamic>?> action(
      ReassignBreakoutRoomRequest request, CallableContext context) async {
    final discussion = await firestoreUtils.getFirestoreObject(
      path: request.discussionPath,
      constructor: (map) => Discussion.fromJson(map),
    );

    await _verifyCallerIsAuthorized(discussion, context);

    final liveMeetingPath = '${request.discussionPath}/live-meetings/${discussion.id}';
    final collectionPath =
        '$liveMeetingPath/breakout-room-sessions/${request.breakoutRoomSessionId}/breakout-rooms';

    final breakoutSessionDoc = firestore
        .document('$liveMeetingPath/breakout-room-sessions/${request.breakoutRoomSessionId}');
    final breakoutsCollection = breakoutSessionDoc.collection('breakout-rooms');
    final assignedBreakoutRoomQuery = await breakoutsCollection
        .where(
          BreakoutRoom.kFieldParticipantIds,
          arrayContains: request.userId,
        )
        // There should only be one room they are in, but limit how many return
        // in the event something went wrong.
        .limit(5)
        .get();

    final assignedBreakoutRoomRefs = assignedBreakoutRoomQuery.documents.map((d) => d.reference);

    final newRoomNumber = request.newRoomNumber;
    String? newRoomId;
    if ([breakoutsWaitingRoomId, reassignNewRoomId].contains(newRoomNumber)) {
      newRoomId = newRoomNumber;
    } else {
      final newRoom = await breakoutsCollection
          .where(
            BreakoutRoom.kFieldRoomName,
            isEqualTo: newRoomNumber,
          )
          .limit(1)
          .get();
      if (newRoom.documents.isEmpty) {
        throw HttpsError(HttpsError.notFound, 'Breakout Room $newRoomNumber not found.', null);
      }
      newRoomId = newRoom.documents.first.reference.documentID;
    }

    return firestore.runTransaction((transaction) async {
      // If something goes wrong where this user is in multiple rooms, this will
      // reassign them to just one. In practice this should always only have one
      // result but its the same code to just do it for all rooms the user is a
      // part of.
      final assignedBreakoutRoomDocs =
          (await Future.wait(assignedBreakoutRoomRefs.map((ref) => transaction.get(ref))))
              .where((d) => d.exists);

      final breakoutSessionDetailsDoc = await transaction.get(breakoutSessionDoc);
      final breakoutSessionDetails =
          BreakoutRoomSession.fromJson(firestoreUtils.fromFirestoreJson(breakoutSessionDetailsDoc.data.toMap()));

      BreakoutRoom? reassignedBreakoutRoom;

      if (newRoomId != null && newRoomId != reassignNewRoomId) {
        final newRoomDoc = await transaction.get(firestore.document('$collectionPath/$newRoomId'));

        final breakoutRoom = BreakoutRoom.fromJson(firestoreUtils.fromFirestoreJson(newRoomDoc.data.toMap()));
        reassignedBreakoutRoom =
            breakoutRoom.copyWith(participantIds: breakoutRoom.participantIds..add(request.userId));

        print(
            'adding participantId: ${newRoomDoc.reference.path}/${newRoomDoc.reference.documentID}');
        transaction.update(
            newRoomDoc.reference,
            UpdateData.fromMap(jsonSubset([BreakoutRoom.kFieldParticipantIds],
                firestoreUtils.toFirestoreJson(reassignedBreakoutRoom.toJson()))));
      }

      // Don't remove if the user is already in this room.
      final filteredAssignedBreakoutRoomDocs =
          assignedBreakoutRoomDocs.where((doc) => doc.documentID != newRoomId);
      for (final breakoutRoomDoc in filteredAssignedBreakoutRoomDocs) {
        final breakoutRoom = BreakoutRoom.fromJson(firestoreUtils.fromFirestoreJson(breakoutRoomDoc.data.toMap()));
        final updatedBreakoutRoom = breakoutRoom.copyWith(
            participantIds: breakoutRoom.participantIds..remove(request.userId));
        print(
            'removing participantId: ${breakoutRoomDoc.reference.path}/${breakoutRoomDoc.reference.documentID}');
        transaction.update(
            breakoutRoomDoc.reference,
            UpdateData.fromMap(jsonSubset([BreakoutRoom.kFieldParticipantIds],
                firestoreUtils.toFirestoreJson(updatedBreakoutRoom.toJson()))));
      }

      final maxRoomNumber = breakoutSessionDetails.maxRoomNumber ?? 0;
      if (newRoomNumber == reassignNewRoomId) {
        final newDoc = breakoutsCollection.document();
        print('create new room: $newDoc');
        final roomId = newDoc.documentID;
        reassignedBreakoutRoom = BreakoutRoom(
          creatorId: context!.authUid!,
          roomId: roomId,
          roomName: (maxRoomNumber + 1).toString(),
          orderingPriority: maxRoomNumber,
          participantIds: [request.userId],
        );
        transaction.set(newDoc,
            DocumentData.fromMap(firestoreUtils.toFirestoreJson(reassignedBreakoutRoom.toJson())));
        String? firstAgendaItemId;
        if (discussion.discussionType == DiscussionType.hosted) {
          final liveMeeting = await firestoreUtils.getFirestoreObject(
            path: liveMeetingPath,
            constructor: (map) => LiveMeeting.fromJson(map),
          );
          final parentAgendaItemId = liveMeeting.events
              .where((e) => LiveMeetingEventType.agendaItemStarted == e.event)
              .lastOrNull
              ?.agendaItem;

          firstAgendaItemId = parentAgendaItemId ?? discussion.agendaItems.firstOrNull?.id;
        } else {
          firstAgendaItemId = discussion.agendaItems.firstOrNull?.id;
        }
        if (firstAgendaItemId != null) {
          final liveMeetingDoc = newDoc.collection('live-meetings').document(roomId);
          transaction.set(
            liveMeetingDoc,
            DocumentData.fromMap(jsonSubset(
                [LiveMeeting.kFieldEvents],
                firestoreUtils.toFirestoreJson(LiveMeeting(
                  events: [
                    LiveMeetingEvent(
                      event: LiveMeetingEventType.agendaItemStarted,
                      agendaItem: firstAgendaItemId,
                      hostless: true,
                      timestamp: DateTime.now().toUtc(),
                    )
                  ],
                ).toJson()))),
            merge: true,
          );
        }

        transaction.update(
            breakoutSessionDoc, UpdateData.fromMap({'maxRoomNumber': maxRoomNumber + 1}));
      }

      return reassignedBreakoutRoom?.toJson()?..['createdDate'] = DateTime.now().toIso8601String();
    });
  }
}
