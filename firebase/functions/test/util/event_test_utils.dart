import 'package:data_models/templates/template.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:functions/events/notifications/event_emails.dart';
import 'package:functions/utils/infra/firestore_utils.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/community/membership.dart';
import 'package:mocktail/mocktail.dart';

class EventTestUtils {
  Future<Event> createEvent({
    required Event event,
    required String userId,
    PrivateLiveStreamInfo? privateLiveStreamInfo,
    bool record = false,
  }) async {
    final eventRef = eventsCollection(
      communityId: event.communityId,
      templateId: event.templateId,
    ).document(event.id);

    final timeZone = getTimezone();

    final newEvent = event.copyWith(
      id: eventRef.documentID,
      collectionPath: eventRef.parent.path,
      status: EventStatus.active,
      creatorId: userId,
      scheduledTimeZone: timeZone,
    );

    final newParticipant = Participant(
      id: userId,
      communityId: event.communityId,
      templateId: event.templateId,
      status: ParticipantStatus.active,
    );
    final participantRef =
        eventRef.collection('event-participants').document(newParticipant.id);

    return firestore.runTransaction((transaction) async {
      transaction.set(
        eventRef,
        DocumentData.fromMap(
          firestoreUtils.toFirestoreJson(newEvent.toJson()),
        ),
      );

      final participantMap = {
        ...firestoreUtils.toFirestoreJson(newParticipant.toJson()),
        Participant.kFieldCreatedDate: Firestore.fieldValues.serverTimestamp(),
      };

      transaction.set(participantRef, DocumentData.fromMap(participantMap));

// TODO needed?
      //await userDataService.changeCommunityMembership(
      //userId: userId,
      //communityId: event.communityId,
      //newStatus: MembershipStatus.attendee,
      //allowMemberDowngrade: false,
      //);

      //if (record) {
      //  transaction.set(
      //    firestore.doc(firestoreLiveMeetingService.getLiveMeetingPath(newEvent)),
      //    jsonSubset([LiveMeeting.kFieldRecord], LiveMeeting(record: record).toJson()),
      // );
      //}

      //if (privateLiveStreamInfo != null) {
      //  transaction.set(eventRef.collection('private-live-stream-info').doc(eventRef.id),
      //      toFirestoreJson(privateLiveStreamInfo.toJson()));
      //}

      return newEvent;
    });
  }

  Future<void> joinEventMultiple({
    required String communityId,
    required String templateId,
    required String eventId,
    required List<String> participantIds,
    String? breakoutSessionId,
  }) async {
    for (String participantId in participantIds) {
      await joinEvent(
        communityId: communityId,
        templateId: templateId,
        eventId: eventId,
        uid: participantId,
        breakoutSessionId: breakoutSessionId,
      );
    }
  }

  Future<void> joinEvent({
    required String communityId,
    required String templateId,
    required String eventId,
    required String uid,
    String? breakoutSessionId,
    bool isPresent = true,
    bool setAttendeeStatus = true,
    ParticipantStatus? participantStatus = ParticipantStatus.active,
  }) async {
    final reference = eventReference(
      communityId: communityId,
      templateId: templateId,
      eventId: eventId,
    );

    final snapshot = await reference.get();
    final event = Event.fromJson(
      firestoreUtils.fromFirestoreJson(snapshot.data.toMap()),
    );

    final participant = Participant(
      id: uid,
      communityId: communityId,
      templateId: templateId,
      status: participantStatus,
      scheduledTime: event.scheduledTime,
      availableForBreakoutSessionId: breakoutSessionId,
      isPresent: isPresent,
      membershipStatus: MembershipStatus.attendee,
      /**joinParameters: queryParametersService.mostRecentQueryParameters,
      breakoutRoomSurveyQuestions: breakoutRoomSurveyResults?.questions ?? [],
      zipCode: breakoutRoomSurveyResults?.zipCode,**/
    );

    final participantRef =
        reference.collection('event-participants').document(uid);

    /*if (setAttendeeStatus) {
      await userDataService.changeCommunityMembership(
        userId: uid,
        communityId: communityId,
        newStatus: MembershipStatus.attendee,
        allowMemberDowngrade: false,
      );
    }*/

    final myMap = {
      ...firestoreUtils.toFirestoreJson(participant.toJson()),
      Participant.kFieldCreatedDate: Firestore.fieldValues.serverTimestamp(),
    };

    return firestore.runTransaction((transaction) async {
      transaction.set(
        participantRef,
        DocumentData.fromMap(myMap),
        merge: true,
      );
    });
  }

  DocumentReference eventReference({
    required String communityId,
    required String templateId,
    required String eventId,
  }) {
    return eventsCollection(communityId: communityId, templateId: templateId)
        .document(eventId);
  }

  CollectionReference eventsCollection({
    required String communityId,
    required String templateId,
  }) {
    return templateReference(communityId: communityId, templateId: templateId)
        .collection('events');
  }

  CollectionReference templatesCollection(String communityId) =>
      firestore.collection('community/$communityId/templates');

  DocumentReference templateReference({
    required String communityId,
    required String templateId,
  }) {
    return templatesCollection(communityId).document(templateId);
  }

  Future<Template> createTemplate({
    required String communityId,
    required Template template,
    required String creatorId,
  }) async {
    final docRef = templatesCollection(communityId).document(template.id);

    final newTemplate = template.copyWith(
      id: docRef.documentID,
      status: TemplateStatus.active,
      collectionPath: docRef.parent.path,
      creatorId: creatorId,
    );

    return firestore.runTransaction((transaction) async {
      transaction.set(
        docRef,
        DocumentData.fromMap(
          firestoreUtils.toFirestoreJson(newTemplate.toJson()),
        ),
      );
      return newTemplate;
    });
  }

  String getTimezone() {
    DateTime dateTime = DateTime.now();
    return dateTime.timeZoneName;
  }
}

class MockEventEmails extends Mock implements EventEmails {}
