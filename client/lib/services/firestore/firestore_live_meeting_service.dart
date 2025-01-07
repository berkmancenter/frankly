import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';
import 'package:client/services/firestore/firestore_event_service.dart';
import 'package:client/services/firestore/firestore_utils.dart';
import 'package:client/services/services.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/event_proposal.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:data_models/community/membership.dart';
import 'package:data_models/utils/utils.dart';

class FirestoreLiveMeetingService {
  String getLiveMeetingPath(Event event) =>
      '${event.fullPath}/live-meetings/${event.id}';

  String getBreakoutLiveMeetingPath({
    required Event event,
    required String breakoutSessionId,
    required String breakoutRoomId,
  }) {
    final path = getBreakoutRoomPath(
      event: event,
      breakoutSessionId: breakoutSessionId,
      breakoutRoomId: breakoutRoomId,
    );
    return '$path/live-meetings/$breakoutRoomId';
  }

  String getBreakoutSessionDoc({
    required Event event,
    required String breakoutSessionId,
  }) {
    final path = getLiveMeetingPath(event);
    return '$path/breakout-room-sessions/$breakoutSessionId';
  }

  String getBreakoutRoomsCollection({
    required Event event,
    required String breakoutSessionId,
  }) {
    final path = getBreakoutSessionDoc(
      event: event,
      breakoutSessionId: breakoutSessionId,
    );
    return '$path/breakout-rooms';
  }

  String getBreakoutRoomPath({
    required Event event,
    required String breakoutSessionId,
    required String breakoutRoomId,
  }) {
    final collectionPath = getBreakoutRoomsCollection(
      event: event,
      breakoutSessionId: breakoutSessionId,
    );
    return '$collectionPath/$breakoutRoomId';
  }

  BehaviorSubjectWrapper<LiveMeeting> liveMeetingStream({
    required String parentDoc,
    required String id,
  }) {
    final meetingPath = '$parentDoc/live-meetings/$id';

    return wrapInBehaviorSubject(
      firestoreDatabase.firestore
          .doc(meetingPath)
          .snapshots(includeMetadataChanges: true)
          .where(
            (snapshot) =>
                !snapshot.metadata.hasPendingWrites &&
                !snapshot.metadata.isFromCache,
          )
          .asyncMap((snapshot) => convertLiveMeetingAsync(snapshot)),
    );
  }

  static Future<LiveMeeting> convertLiveMeetingAsync(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    if (!doc.exists) return LiveMeeting();

    return compute<Map<String, dynamic>, LiveMeeting>(
      _convertLiveMeeting,
      doc.data()!,
    );
  }

  static LiveMeeting _convertLiveMeeting(Map<String, dynamic> data) {
    print('Live meeting json');
    print(data);
    return LiveMeeting.fromJson(fromFirestoreJson(data));
  }

  BehaviorSubjectWrapper<List<BreakoutRoom>> assignedBreakoutRoomsStream({
    required Event event,
    required String breakoutRoomSessionId,
    required String userId,
  }) {
    final collectionPath = getBreakoutRoomsCollection(
      event: event,
      breakoutSessionId: breakoutRoomSessionId,
    );

    loggingService.log('getting assigned breakout rooms for $userId');
    return wrapInBehaviorSubject(
      firestoreDatabase.firestore
          .collection(collectionPath)
          .where('participantIds', arrayContains: userId)
          .snapshots(includeMetadataChanges: true)
          .where(
            (snapshot) =>
                !snapshot.metadata.hasPendingWrites &&
                !snapshot.metadata.isFromCache,
          )
          .asyncMap((snapshot) {
        return convertBreakoutRoomsAsync(snapshot.docs);
      }),
    );
  }

  BehaviorSubjectWrapper<List<BreakoutRoom>> breakoutRoomsStream({
    required Event event,
    required String breakoutRoomSessionId,
    bool filterNeedsHelp = false,
    bool descending = false,
    int? limit,
  }) {
    final collectionPath = getBreakoutRoomsCollection(
      event: event,
      breakoutSessionId: breakoutRoomSessionId,
    );

    Query<Map<String, dynamic>> query =
        firestoreDatabase.firestore.collection(collectionPath);

    if (filterNeedsHelp) {
      query = query.where(
        'flagStatus',
        isEqualTo:
            EnumToString.convertToString(BreakoutRoomFlagStatus.needsHelp),
      );
    }
    if (limit != null) {
      query = query.limit(limit);
    }
    query = query.orderBy('orderingPriority', descending: descending);

    return wrapInBehaviorSubject(
      query
          .snapshots(includeMetadataChanges: true)
          .where(
            (snapshot) =>
                !snapshot.metadata.hasPendingWrites &&
                !snapshot.metadata.isFromCache,
          )
          .asyncMap((snapshot) => convertBreakoutRoomsAsync(snapshot.docs)),
    );
  }

  Query<Map<String, dynamic>> getBreakoutRoomsQuery({
    required Event event,
    required String breakoutRoomSessionId,
    required bool filterNeedsHelp,
  }) {
    final collectionPath = getBreakoutRoomsCollection(
      event: event,
      breakoutSessionId: breakoutRoomSessionId,
    );

    Query<Map<String, dynamic>> query =
        firestoreDatabase.firestore.collection(collectionPath);

    if (filterNeedsHelp) {
      query = query.where(
        'flagStatus',
        isEqualTo:
            EnumToString.convertToString(BreakoutRoomFlagStatus.needsHelp),
      );
    }

    return query.orderBy('orderingPriority');
  }

  BehaviorSubjectWrapper<BreakoutRoom?> breakoutRoomStream({
    required Event event,
    required String breakoutRoomSessionId,
    required String breakoutRoomId,
  }) {
    final docPath = getBreakoutRoomPath(
      event: event,
      breakoutSessionId: breakoutRoomSessionId,
      breakoutRoomId: breakoutRoomId,
    );

    return wrapInBehaviorSubject(
      firestoreDatabase.firestore
          .doc(docPath)
          .snapshots(includeMetadataChanges: true)
          .map(
        (snapshot) {
          final snapshotData = snapshot.data();

          if (snapshotData != null) {
            return BreakoutRoom.fromJson(fromFirestoreJson(snapshotData));
          } else {
            return null;
          }
        },
      ),
    );
  }

  Future<BreakoutRoom?> getBreakoutRoomFromRoomNumber({
    required Event event,
    required String breakoutRoomSessionId,
    required String roomNumber,
  }) async {
    final collectionPath = getBreakoutRoomsCollection(
      event: event,
      breakoutSessionId: breakoutRoomSessionId,
    );

    final doc = await firestoreDatabase.firestore
        .collection(collectionPath)
        .where('roomName', isEqualTo: roomNumber)
        .get();

    if (doc.size == 0) return null;

    return BreakoutRoom.fromJson(fromFirestoreJson(doc.docs.first.data()));
  }

  Future<BreakoutRoomSession> getBreakoutRoomSession({
    required Event event,
    required String breakoutSessionId,
  }) async {
    final docPath = getBreakoutSessionDoc(
      event: event,
      breakoutSessionId: breakoutSessionId,
    );

    final doc = await firestoreDatabase.firestore.doc(docPath).get();

    return BreakoutRoomSession.fromJson(fromFirestoreJson(doc.data()!));
  }

  BehaviorSubjectWrapper<List<Participant>> breakoutRoomParticipantsStream({
    required Event event,
    required String breakoutRoomSessionId,
    required String breakoutRoomId,
  }) {
    final eventRef = firestoreEventService.eventReference(
      communityId: event.communityId,
      templateId: event.templateId,
      eventId: event.id,
    );
    return wrapInBehaviorSubject(
      eventRef
          .collection('event-participants')
          .where('currentBreakoutRoomId', isEqualTo: breakoutRoomId)
          .snapshots(includeMetadataChanges: true)
          .asyncMap(
            (snapshot) => FirestoreEventService.convertParticipantListAsync(
              snapshot,
            ),
          ),
    );
  }

  static Future<List<BreakoutRoom>> convertBreakoutRoomsAsync(
    List<DocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final breakouts = <BreakoutRoom>[
      for (final doc in docs)
        await compute<Map<String, dynamic>, BreakoutRoom>(
          _convertBreakoutRoom,
          doc.data()!,
        ),
    ];
    final waitingRoomIndex =
        breakouts.indexWhere((br) => br.roomId == breakoutsWaitingRoomId);
    if (waitingRoomIndex != -1) {
      final waitingRoom = breakouts.removeAt(waitingRoomIndex);
      breakouts.insert(0, waitingRoom);
    }

    return breakouts;
  }

  static BreakoutRoom _convertBreakoutRoom(Map<String, dynamic> data) =>
      BreakoutRoom.fromJson(fromFirestoreJson(data));

  Future<void> updateMeetingPresence({
    required Event event,
    required bool isPresent,
    String? currentBreakoutRoomId,
  }) async {
    final participantRef = firestoreEventService
        .eventReference(
          communityId: event.communityId,
          templateId: event.templateId,
          eventId: event.id,
        )
        .collection('event-participants')
        .doc(userService.currentUserId);

    final presenceUpdate = jsonSubset(
      [
        Participant.kFieldId,
        Participant.kFieldIsPresent,
        Participant.kFieldMembershipStatus,
        Participant.kFieldCurrentBreakoutRoomId,
        Participant.kFieldLastUpdatedTime,
        Participant.kFieldMostRecentPresentTime,
      ],
      toFirestoreJson(
        Participant(
          id: userService.currentUserId!,
          isPresent: isPresent,
          membershipStatus:
              userDataService.getMembership(event.communityId).status ??
                  MembershipStatus.nonmember,
          currentBreakoutRoomId: currentBreakoutRoomId,
          // Note: This doesnt actually use the clock time, it uses the server timestamp under the hood
          // It just needs to be non null in order to be set.
          mostRecentPresentTime: clockService.now(),
        ).toJson(),
      ),
    );

    await participantRef.set(
      toFirestoreJson(presenceUpdate),
      SetOptions(merge: true),
    );
  }

  Future<void> updateAvailableForBreakoutSessionId({
    required Event event,
    required String breakoutSessionId,
  }) async {
    final participantRef = firestoreEventService
        .eventReference(
          communityId: event.communityId,
          templateId: event.templateId,
          eventId: event.id,
        )
        .collection('event-participants')
        .doc(userService.currentUserId);

    await participantRef.set(
      jsonSubset(
        [Participant.kAvailableForBreakoutSessionId],
        toFirestoreJson(
          Participant(
            id: userService.currentUserId!,
            availableForBreakoutSessionId: breakoutSessionId,
          ).toJson(),
        ),
      ),
      SetOptions(merge: true),
    );
  }

  Future<void> update({
    required String liveMeetingPath,
    required LiveMeeting liveMeeting,
    required Iterable<String> keys,
  }) async {
    await firestoreDatabase.firestore.doc(liveMeetingPath).set(
          jsonSubset(keys, toFirestoreJson(liveMeeting.toJson())),
          SetOptions(merge: true),
        );
  }

  Future<void> addMeetingEvent({
    required String liveMeetingPath,
    String? liveMeetingId,
    required LiveMeetingEvent meetingEvent,
  }) {
    return firestoreDatabase.firestore.runTransaction((transaction) async {
      final meetingPathRef = firestoreDatabase.firestore.doc(liveMeetingPath);

      final liveMeetingDoc = await transaction.get(meetingPathRef);
      var liveMeeting = await convertLiveMeetingAsync(liveMeetingDoc);

      final existingEvents = liveMeeting.events;
      final last = existingEvents.lastOrNull;
      final alreadyExists = last?.event == meetingEvent.event &&
          last?.agendaItem == meetingEvent.agendaItem;
      if (alreadyExists) return;

      liveMeeting =
          liveMeeting.copyWith(events: [...existingEvents, meetingEvent]);

      if (!liveMeetingDoc.exists) {
        liveMeeting = liveMeeting.copyWith(meetingId: liveMeetingId);
        transaction.set(meetingPathRef, toFirestoreJson(liveMeeting.toJson()));
      } else {
        transaction.update(
          meetingPathRef,
          jsonSubset(
            [LiveMeeting.kFieldEvents],
            toFirestoreJson(liveMeeting.toJson()),
          ),
        );
      }
    });
  }

  Stream<List<EventProposal>> getProposals({
    required String liveMeetingPath,
  }) {
    return firestoreDatabase.firestore
        .collection('$liveMeetingPath/proposals')
        .where('targetUserId', isNotEqualTo: userService.currentUserId)
        .snapshots()
        .map(
          (querySnapshot) => querySnapshot.docs
              .map(
                (doc) => EventProposal.fromJson(fromFirestoreJson(doc.data())),
              )
              .toList(),
        );
  }

  Future<LiveMeetingRating?> getRating(Event event) async {
    final ratingPathRef = firestoreDatabase.firestore.doc(
      '${getLiveMeetingPath(event)}/ratings/${userService.currentUserId}',
    );

    final doc = await ratingPathRef.get();
    final docData = doc.data();

    if (docData == null) return null;

    return LiveMeetingRating.fromJson(fromFirestoreJson(docData));
  }

  Future<void> updateRating(Event event, double rating) {
    final ratingPathRef = firestoreDatabase.firestore.doc(
      '${getLiveMeetingPath(event)}/ratings/${userService.currentUserId}',
    );

    final ratingModel =
        LiveMeetingRating(ratingId: userService.currentUserId, rating: rating);

    return ratingPathRef.set(toFirestoreJson(ratingModel.toJson()));
  }

  Future<void> updateGuideCardIsMinimized({
    required Event event,
    required bool isCardMinimized,
  }) async {
    final meetingPathRef =
        firestoreDatabase.firestore.doc(getLiveMeetingPath(event));

    await meetingPathRef.set(
      jsonSubset(
        [LiveMeeting.kFieldIsMeetingCardMinimized],
        toFirestoreJson(
          LiveMeeting(isMeetingCardMinimized: isCardMinimized).toJson(),
        ),
      ),
      SetOptions(merge: true),
    );
  }

  Future<void> updateParticipantMuteOverride({
    required Event event,
    required String participantId,
    bool muteOverride = true,
  }) async {
    await firestoreEventService
        .eventReference(
          communityId: event.communityId,
          templateId: event.templateId,
          eventId: event.id,
        )
        .collection('event-participants')
        .doc(participantId)
        .set(
          jsonSubset(
            [Participant.kFieldMuteOverride],
            toFirestoreJson(
              Participant(id: participantId, muteOverride: muteOverride)
                  .toJson(),
            ),
          ),
          SetOptions(merge: true),
        );
  }
}
