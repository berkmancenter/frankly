import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';
import 'package:client/app/community/events/event_page/widgets/smart_match_survey/survey_dialog.dart';
import 'package:client/app/community/utils.dart';
import 'package:client/common_widgets/visible_exception.dart';
import 'package:client/services/firestore/firestore_utils.dart';
import 'package:client/services/services.dart';
import 'package:client/utils/platform_utils.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:data_models/community/membership.dart';
import 'package:data_models/utils/utils.dart';
import 'package:pedantic/pedantic.dart';
import 'package:rxdart/rxdart.dart';

class FirestoreEventService {
  static const events = 'events';

  // final time = await NTP.now();
  // Future to mimic NTP.now()
  Future<DateTime> get currentTimeAsync => Future(() => clockService.now());

  CollectionReference<Map<String, dynamic>> eventsCollection({
    required String communityId,
    required String templateId,
  }) {
    return firestoreDatabase
        .templateReference(communityId: communityId, templateId: templateId)
        .collection(events);
  }

  Query<Map<String, dynamic>> _eventsCollectionGroup() =>
      firestoreDatabase.firestore.collectionGroup(events);

  Query<Map<String, dynamic>> _participantsCollectionGroup() =>
      firestoreDatabase.firestore.collectionGroup('event-participants');

  DocumentReference<Map<String, dynamic>> eventReference({
    required String communityId,
    required String templateId,
    required String eventId,
  }) {
    return eventsCollection(communityId: communityId, templateId: templateId)
        .doc(eventId);
  }

  BehaviorSubjectWrapper<List<Event>> communityEvents({
    required String communityId,
  }) {
    return wrapInBehaviorSubject(
      _eventsCollectionGroup()
          .where('communityId', isEqualTo: communityId)
          .orderBy('scheduledTime', descending: true)
          .snapshots()
          .asyncMap((snapshot) async {
        final docs = snapshot.docs;
        final events = await _convertEventListAsync(docs);

// Not all events have a status on the server as it was added later on with a default of "active".
// This also applies to templates so we do filtering on the client side
        return events
            .where((event) => event.status == EventStatus.active)
            .toList();
      }),
    );
  }

  BehaviorSubjectWrapper<List<Event>> futurePublicEvents({
    required String communityId,
    required String templateId,
  }) {
    return wrapInBehaviorSubjectAsync(() async {
      final currentTime = await currentTimeAsync;

      final query = eventsCollection(
        communityId: communityId,
        templateId: templateId,
      )
          .where('isPublic', isEqualTo: true)
          .where(
            'scheduledTime',
            isGreaterThan:
                Timestamp.fromDate(currentTime.subtract(Duration(minutes: 15))),
          )
          .orderBy('scheduledTime');

      return query.snapshots().asyncMap((snapshot) async {
        final events = await _convertEventListAsync(snapshot.docs);
        return events
            .where((event) => event.status == EventStatus.active)
            .toList();
      });
    });
  }

  Future<List<Event>> getUpcomingPublicEventsFuture({
    required String communityId,
    required String templateId,
  }) async {
    final currentTime = await currentTimeAsync;

    final query = eventsCollection(
      communityId: communityId,
      templateId: templateId,
    )
        .where('isPublic', isEqualTo: true)
        .where(
          'scheduledTime',
          isGreaterThan:
              Timestamp.fromDate(currentTime.subtract(Duration(minutes: 15))),
        )
        .orderBy('scheduledTime');

    final eventsSnapshot = await query.get();
    final events = await _convertEventListAsync(eventsSnapshot.docs);
    final toReturn =
        events.where((event) => event.status == EventStatus.active).toList();
    return toReturn;
  }

  Future<List<Event>> allPublicEventsFuture([int limit = 100]) async {
    final eventsSnapshot = await _eventsCollectionGroup()
        .where('isPublic', isEqualTo: true)
        .where('scheduledTime', isGreaterThan: clockService.now())
        .limit(limit)
        .get();
    final events = eventsSnapshot.docs
        .map((doc) => _convertEvent(doc.data()..['id'] = doc.id))
        .toList();
    return events;
  }

  BehaviorSubjectWrapper<List<Event>> futurePublicEventsForCommunity({
    required String communityId,
  }) {
    return wrapInBehaviorSubjectAsync(() async {
      // final time = await NTP.now();
      // Future to mimic NTP.now()
      final currentTime = await Future(() => clockService.now());

      return _eventsCollectionGroup()
          .where('communityId', isEqualTo: communityId)
          .where(
            'scheduledTime',
            isGreaterThan:
                Timestamp.fromDate(currentTime.subtract(Duration(hours: 1))),
          )
          .where('isPublic', isEqualTo: true)
          .orderBy('scheduledTime')
          .snapshots()
          .asyncMap((snapshot) async {
        final events = await _convertEventListAsync(snapshot.docs);
        return events
            .where((event) => event.status == EventStatus.active)
            .toList();
      });
    });
  }

  Future<List<Event>> userEventsForCommunity() async {
    final participantsQuerySnapshot = await _participantsCollectionGroup()
        .where('id', isEqualTo: userService.currentUserId)
        .where(
          'status',
          isEqualTo: EnumToString.convertToString(ParticipantStatus.active),
        )
        .get();
    final eventSnapshots = participantsQuerySnapshot.docs
        .map((doc) => doc.reference.parent.parent!.get());

    final eventDocs = await Future.wait<DocumentSnapshot<Map<String, dynamic>>>(
      eventSnapshots,
    );
    return _convertEventListAsync(eventDocs);
  }

  Future<bool> userHasParticipatedInTemplate({
    required String templateId,
  }) async {
    final participantsQuerySnapshot = await _participantsCollectionGroup()
        .where('id', isEqualTo: userService.currentUserId)
        .where('templateId', isEqualTo: templateId)
        .where(
          'status',
          isEqualTo: EnumToString.convertToString(ParticipantStatus.active),
        )
        .where('scheduledTime', isLessThan: Timestamp.now())
        .get();
    return participantsQuerySnapshot.docs.isNotEmpty;
  }

  BehaviorSubjectWrapper<Event> eventStream({
    required String communityId,
    required String templateId,
    required String eventId,
  }) {
    final eventRef = eventReference(
      communityId: communityId,
      templateId: templateId,
      eventId: eventId,
    );
    return wrapInBehaviorSubject(
      eventRef.snapshots().asyncMap((snapshot) => _convertEventAsync(snapshot)),
    );
  }

  Stream<bool> communityHasEvents({required String communityId}) =>
      _eventsCollectionGroup()
          .where('communityId', isEqualTo: communityId)
          .limit(1)
          .snapshots()
          .map((event) => event.docs.isNotEmpty);

  BehaviorSubjectWrapper<List<Participant>> eventParticipantsStream({
    required String communityId,
    required String templateId,
    required String eventId,
  }) {
    final eventRef = eventReference(
      communityId: communityId,
      templateId: templateId,
      eventId: eventId,
    );
    return wrapInBehaviorSubject(
      eventRef
          .collection('event-participants')
          .snapshots(includeMetadataChanges: true)
          .where(
            (snapshot) =>
                !snapshot.metadata.hasPendingWrites &&
                !snapshot.metadata.isFromCache,
          )
          .sampleTime(Duration(milliseconds: 500))
          .asyncMap((snapshot) => convertParticipantListAsync(snapshot)),
    );
  }

  Stream<Participant> eventParticipantStream({
    required String communityId,
    required String templateId,
    required String eventId,
    required String userId,
  }) {
    final eventRef = eventReference(
      communityId: communityId,
      templateId: templateId,
      eventId: eventId,
    );
    return eventRef
        .collection('event-participants')
        .doc(userId)
        .snapshots(includeMetadataChanges: true)
        .where(
          (snapshot) =>
              !snapshot.metadata.hasPendingWrites &&
              !snapshot.metadata.isFromCache,
        )
        .map(
          (snapshot) => _convertParticipant(snapshot.data() ?? {'id': userId}),
        );
  }

  Future<List<Event>> getEventsFromPaths(
    String communityId,
    List<String> documentPaths,
  ) async {
    final eventDocs = await Future.wait(
      documentPaths.map(
        (path) {
          final eventMatch =
              RegExp('/?community/([^/]+)/templates/([^/]+)/events/([^/]+)')
                  .matchAsPrefix(path);

          final templateId = eventMatch?.group(2);
          final eventId = eventMatch?.group(3);

          if (templateId == null || eventId == null) {
            throw Exception('No template or event found.');
          }

          return eventReference(
            communityId: communityId,
            templateId: templateId,
            eventId: eventId,
          ).get();
        },
      ),
    );

    return eventDocs
        .map((e) => _convertEvent((e.data() ?? {})..['id'] = e.id))
        .toList();
  }

  Query<Map<String, dynamic>> eventParticipantsQuery({
    required Event event,
  }) {
    return eventReference(
      communityId: event.communityId,
      templateId: event.templateId,
      eventId: event.id,
    )
        .collection('event-participants')
        .where(
          'status',
          isEqualTo: EnumToString.convertToString(ParticipantStatus.active),
        )
        .orderBy('createdDate');
  }

  Future<List<Participant>> getEventParticipants({
    required Event event,
  }) async {
    final eventRef = eventReference(
      communityId: event.communityId,
      templateId: event.templateId,
      eventId: event.id,
    );
    final participantDocs =
        await eventRef.collection('event-participants').get();

    return convertParticipantListAsync(participantDocs);
  }

  Future<PrivateLiveStreamInfo?> liveStreamPrivateInfo({
    required Event event,
  }) async {
    final eventRef = firestoreDatabase.firestore.doc(
      '${event.fullPath}/private-live-stream-info/${event.id}',
    );
    final doc = await eventRef.get();
    final data = doc.data();

    if (data == null) return null;

    return PrivateLiveStreamInfo.fromJson(fromFirestoreJson(data));
  }

  Future<Event> createEventIfNotExists({
    required Event event,
    PrivateLiveStreamInfo? privateLiveStreamInfo,
    bool record = false,
  }) async {
    final eventRef = eventsCollection(
      communityId: event.communityId,
      templateId: event.templateId,
    ).doc(event.id);

    final timeZone = getTimezone();

    final newEvent = event.copyWith(
      id: eventRef.id,
      collectionPath: eventRef.parent.path,
      status: EventStatus.active,
      creatorId: userService.currentUserId!,
      scheduledTimeZone: timeZone,
    );

    final newParticipant = Participant(
      id: userService.currentUserId!,
      communityId: event.communityId,
      templateId: event.templateId,
      status: ParticipantStatus.active,
    );
    final participantRef =
        eventRef.collection('event-participants').doc(newParticipant.id);

    return firestoreDatabase.firestore.runTransaction((transaction) async {
      if (!isNullOrEmpty(event.id)) {
        final snapshot = await transaction.get(eventRef);
        final snapshotData = snapshot.data();

        if (snapshotData != null) {
          return Event.fromJson(fromFirestoreJson(snapshotData));
        }
      }

      transaction.set(eventRef, toFirestoreJson(newEvent.toJson()));
      transaction.set(participantRef, {
        ...toFirestoreJson(newParticipant.toJson()),
        Participant.kFieldCreatedDate: FieldValue.serverTimestamp(),
      });

      await userDataService.changeCommunityMembership(
        userId: userService.currentUserId!,
        communityId: event.communityId,
        newStatus: MembershipStatus.attendee,
        allowMemberDowngrade: false,
      );

      if (record) {
        transaction.set(
          firestoreDatabase.firestore.doc(
            firestoreLiveMeetingService.getLiveMeetingPath(newEvent),
          ),
          jsonSubset(
            [LiveMeeting.kFieldRecord],
            LiveMeeting(record: record).toJson(),
          ),
        );
      }

      if (privateLiveStreamInfo != null) {
        transaction.set(
          eventRef.collection('private-live-stream-info').doc(eventRef.id),
          toFirestoreJson(privateLiveStreamInfo.toJson()),
        );
      }

      return newEvent;
    });
  }

  Future<void> updateEvent({
    required Event event,
    required Iterable<String> keys,
  }) async {
    final docRef = eventReference(
      communityId: event.communityId,
      templateId: event.templateId,
      eventId: event.id,
    );

    final dataMap = jsonSubset(keys, toFirestoreJson(event.toJson()));
    loggingService.log(
      'FirestoreEventService.updateEvent: Path: ${docRef.path}, Data: $dataMap',
    );

    await docRef.update(dataMap);
  }

  Future<void> addLiveStreamEventDetails({
    required Event event,
    PrivateLiveStreamInfo? privateLiveStreamInfo,
  }) async {
    final eventRef = eventsCollection(
      communityId: event.communityId,
      templateId: event.templateId,
    ).doc(event.id);

    if (!isNullOrEmpty(event.id) && privateLiveStreamInfo != null) {
      await eventRef
          .collection('private-live-stream-info')
          .doc(eventRef.id)
          .set(toFirestoreJson(privateLiveStreamInfo.toJson()));
    }
  }

  Future<void> joinEvent({
    required String communityId,
    required String templateId,
    required String eventId,
    String? externalCommunityId,
    bool setAttendeeStatus = true,
    SurveyDialogResult? breakoutRoomSurveyResults,
  }) async {
    final uid = userService.currentUserId!;

    unawaited(firebaseAnalytics.logEvent(name: 'event_join'));

    final reference = eventReference(
      communityId: communityId,
      templateId: templateId,
      eventId: eventId,
    );

    final snapshot = await reference.get();
    final event = await _convertEventAsync(snapshot);

    if (event.status == EventStatus.canceled) {
      throw VisibleException(
          'Sorry, this event has been cancelled so you cannot '
          'join it. Consider creating a new event!');
    }

    final participant = Participant(
      id: uid,
      communityId: communityId,
      templateId: templateId,
      status: ParticipantStatus.active,
      scheduledTime: event.scheduledTime,
      externalCommunityId: externalCommunityId,
      joinParameters: queryParametersService.mostRecentQueryParameters,
      breakoutRoomSurveyQuestions: breakoutRoomSurveyResults?.questions ?? [],
      zipCode: breakoutRoomSurveyResults?.zipCode,
    );
    print('Participant $participant');
    final participantRef = reference.collection('event-participants').doc(uid);

    if (setAttendeeStatus) {
      await userDataService.changeCommunityMembership(
        userId: uid,
        communityId: communityId,
        newStatus: MembershipStatus.attendee,
        allowMemberDowngrade: false,
      );
    }

    print('Setting participant');
    await participantRef.set(
      {
        ...toFirestoreJson(participant.toJson()),
        Participant.kFieldCreatedDate: FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    print('Finished setting participant');
  }

  Future<void> removeParticipant({
    required String communityId,
    required String templateId,
    required String eventId,
    required String participantId,
  }) async {
    final participantRef = eventReference(
      communityId: communityId,
      templateId: templateId,
      eventId: eventId,
    ).collection('event-participants').doc(participantId);
    await participantRef.set(
      jsonSubset(
        [Participant.kFieldLastUpdatedTime, Participant.kFieldStatus],
        toFirestoreJson(
          Participant(
            id: participantId,
            status: ParticipantStatus.canceled,
          ).toJson(),
        ),
      ),
      SetOptions(merge: true),
    );
  }

  Future<void> upsertAgendaItem({
    required Event event,
    required AgendaItem updatedItem,
  }) {
    return firestoreDatabase.firestore.runTransaction((transaction) async {
      final ref = firestoreDatabase.firestore.doc(event.fullPath);
      final snapshot = await transaction.get(ref);
      var eventSnapshot = await _convertEventAsync(snapshot);

      final agendaItems = eventSnapshot.agendaItems;
      final index = agendaItems.indexWhere((item) => item.id == updatedItem.id);
      if (index < 0) {
        agendaItems.add(updatedItem);
      } else {
        agendaItems[index] = updatedItem;
      }

      eventSnapshot = eventSnapshot.copyWith(agendaItems: agendaItems);
      transaction.update(
        snapshot.reference,
        jsonSubset(
          [Event.kFieldAgendaItems],
          toFirestoreJson(eventSnapshot.toJson()),
        ),
      );
    });
  }

  Future<void> setAgendaItemsLegacy({
    required Event event,
    required List<AgendaItem> agendaItems,
  }) {
    return firestoreDatabase.firestore.runTransaction((transaction) async {
      final ref = firestoreDatabase.firestore.doc(event.fullPath);
      final snapshot = await transaction.get(ref);
      var eventSnapshot = await _convertEventAsync(snapshot);

      if (eventSnapshot.agendaItems.isNotEmpty) {
        return;
      }

      eventSnapshot = eventSnapshot.copyWith(agendaItems: agendaItems);
      transaction.update(
        snapshot.reference,
        jsonSubset(
          [Event.kFieldAgendaItems],
          toFirestoreJson(eventSnapshot.toJson()),
        ),
      );
    });
  }

  Future<void> deleteTemplateAgendaItem({
    required Event event,
    required String itemId,
  }) {
    return firestoreDatabase.firestore.runTransaction((transaction) async {
      final ref = firestoreDatabase.firestore.doc(event.fullPath);
      final snapshot = await transaction.get(ref);
      var eventSnapshot = await _convertEventAsync(snapshot);

      final agendaItems = eventSnapshot.agendaItems;
      agendaItems.removeWhere((item) => item.id == itemId);

      eventSnapshot = eventSnapshot.copyWith(agendaItems: agendaItems);
      transaction.update(
        snapshot.reference,
        jsonSubset(
          [Event.kFieldAgendaItems],
          toFirestoreJson(eventSnapshot.toJson()),
        ),
      );
    });
  }

  Future<void> updateAgendaOrdering({
    required Event event,
    required List<String> ordering,
  }) {
    return firestoreDatabase.firestore.runTransaction((transaction) async {
      final ref = firestoreDatabase.firestore.doc(event.fullPath);
      final snapshot = await transaction.get(ref);
      var eventSnapshot = await _convertEventAsync(snapshot);

      final agendaItems = eventSnapshot.agendaItems;
      final agendaItemMap = Map.fromIterable(
        agendaItems,
        key: (item) => (item as AgendaItem).id,
      );

      if (!setEquals(ordering.toSet(), agendaItemMap.keys.toSet())) {
        throw VisibleException(
          'Error in updating agenda ordering. Please refresh.',
        );
      }

      final List<AgendaItem> newAgenda = ordering
          .map((itemId) => agendaItemMap[itemId] as AgendaItem)
          .toList();

      eventSnapshot = eventSnapshot.copyWith(agendaItems: newAgenda);
      transaction.update(
        snapshot.reference,
        jsonSubset(
          [Event.kFieldAgendaItems],
          toFirestoreJson(eventSnapshot.toJson()),
        ),
      );
    });
  }

  Future<void> kickParticipant({
    required Event event,
    required String kickedUserId,
    bool lockRoom = false,
  }) async {
    final eventPath = event.fullPath;
    final eventDoc = firestoreDatabase.firestore.doc(eventPath);
    final snapshot = await eventDoc.get();
    final firestoreEvent = await _convertEventAsync(snapshot);
    if (firestoreEvent.creatorId == kickedUserId) {
      throw VisibleException('Can\'t kick the event creator.');
    }

    final participantRef = eventReference(
      communityId: event.communityId,
      templateId: event.templateId,
      eventId: event.id,
    ).collection('event-participants').doc(kickedUserId);

    loggingService.log('setting the users status to banned: $kickedUserId');
    await participantRef.set(
      jsonSubset(
        [Participant.kFieldLastUpdatedTime, Participant.kFieldStatus],
        toFirestoreJson(
          Participant(
            id: kickedUserId,
            status: ParticipantStatus.banned,
          ).toJson(),
        ),
      ),
      SetOptions(merge: true),
    );

    if (lockRoom) {
      await updateEvent(
        event: firestoreEvent.copyWith(isLocked: true),
        keys: [Event.kFieldIsLocked],
      );
    }
  }

  Future<void> updateParticipantBreakoutSurveyAnswers({
    required Event event,
    bool lockRoom = false,
    required SurveyDialogResult surveyDialogResult,
  }) async {
    final userId = userService.currentUserId!;
    final participant = Participant(
      id: userId,
      breakoutRoomSurveyQuestions: surveyDialogResult.questions,
      zipCode: surveyDialogResult.zipCode,
    );
    final participantRef = eventReference(
      communityId: event.communityId,
      templateId: event.templateId,
      eventId: event.id,
    ).collection('event-participants').doc(userId);

    loggingService.log('Updating survey answers for $userId');
    await participantRef.set(
      jsonSubset(
        [
          Participant.kFieldBreakoutRoomSurveyQuestions,
          Participant.kFieldZipCode,
        ],
        toFirestoreJson(participant.toJson()),
      ),
      SetOptions(merge: true),
    );
  }

  static Future<List<Event>> _convertEventListAsync(
    List<DocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final events = <Event?>[
      for (final doc in docs)
        await swallowErrors(
          () => compute<Map<String, dynamic>, Event>(
            _convertEvent,
            (doc.data() ?? {})..['id'] = doc.id,
          ),
          errorMessage:
              'Error parsing event: ${doc.reference.path}/${doc.reference.id}',
        ),
    ];

    for (var i = 0; i < events.length; i++) {
      events[i] = events[i]?.copyWith(id: docs[i].id);
    }

    return <Event>[
      for (final event in events)
        if (event != null) event,
    ];
  }

  static Future<Event> _convertEventAsync(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final event = await compute<Map<String, dynamic>, Event>(
      _convertEvent,
      (doc.data() ?? {})..['id'] = doc.id,
    );
    return event.copyWith(id: doc.id);
  }

  static Event _convertEvent(Map<String, dynamic> data) {
    return Event.fromJson(fromFirestoreJson(data));
  }

  static Future<List<Participant>> convertParticipantListAsync(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) async {
    final snapshotDocs = snapshot.docs;

    final events = await Future.wait(
      snapshotDocs.map((doc) => compute(_convertParticipant, doc.data())),
    );

    for (var i = 0; i < events.length; i++) {
      events[i] = events[i].copyWith(
        id: snapshotDocs[i].id,
      );
    }

    return events;
  }

  static Participant _convertParticipant(Map<String, dynamic> data) {
    try {
      return Participant.fromJson(fromFirestoreJson(data));
    } catch (exception) {
      print('Failed on $data');
      rethrow;
    }
  }
}
