import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/membership.dart';

class DiscussionTestUtils {
  Future<Discussion> createDiscussion({
    required Discussion discussion,
    required String userId,
    PrivateLiveStreamInfo? privateLiveStreamInfo,
    bool record = false,
  }) async {
    final discussionRef = discussionsCollection(
      juntoId: discussion.juntoId,
      topicId: discussion.topicId,
    ).document(discussion.id);

    final timeZone = getTimezone();

    final newDiscussion = discussion.copyWith(
      id: discussionRef.documentID,
      collectionPath: discussionRef.parent.path,
      status: DiscussionStatus.active,
      creatorId: userId,
      scheduledTimeZone: timeZone,
    );

    final newParticipant = Participant(
      id: userId,
      juntoId: discussion.juntoId,
      topicId: discussion.topicId,
      status: ParticipantStatus.active,
    );
    final participantRef =
        discussionRef.collection('discussion-participants').document(newParticipant.id);

    return firestore.runTransaction((transaction) async {
      transaction.set(
        discussionRef,
        DocumentData.fromMap(firestoreUtils.toFirestoreJson(newDiscussion.toJson())),
      );

      final participantMap = {
        ...firestoreUtils.toFirestoreJson(newParticipant.toJson()),
        Participant.kFieldCreatedDate: Firestore.fieldValues.serverTimestamp(),
      };

      transaction.set(participantRef, DocumentData.fromMap(participantMap));

// TODO needed?
      //await juntoUserDataService.changeJuntoMembership(
      //userId: userId,
      //juntoId: discussion.juntoId,
      //newStatus: MembershipStatus.attendee,
      //allowMemberDowngrade: false,
      //);

      //if (record) {
      //  transaction.set(
      //    firestore.doc(firestoreLiveMeetingService.getLiveMeetingPath(newDiscussion)),
      //    jsonSubset([LiveMeeting.kFieldRecord], LiveMeeting(record: record).toJson()),
      // );
      //}

      //if (privateLiveStreamInfo != null) {
      //  transaction.set(discussionRef.collection('private-live-stream-info').doc(discussionRef.id),
      //      toFirestoreJson(privateLiveStreamInfo.toJson()));
      //}

      return newDiscussion;
    });
  }

  Future<void> joinDiscussionMultiple({
    required String juntoId,
    required String topicId,
    required String discussionId,
    required List<String> participantIds,
    String? breakoutSessionId,
  }) async {
    for (String participantId in participantIds) {
      await joinDiscussion(
        juntoId: juntoId,
        topicId: topicId,
        discussionId: discussionId,
        uid: participantId,
        breakoutSessionId: breakoutSessionId,
      );
    }
  }

  Future<void> joinDiscussion({
    required String juntoId,
    required String topicId,
    required String discussionId,
    required String uid,
    String? breakoutSessionId,
    bool isPresent = true,
    bool setAttendeeStatus = true,
  }) async {
    final reference = discussionReference(
      juntoId: juntoId,
      topicId: topicId,
      discussionId: discussionId,
    );

    final snapshot = await reference.get();
    final discussion = Discussion.fromJson(firestoreUtils.fromFirestoreJson(snapshot.data.toMap()));

    final participant = Participant(
      id: uid,
      juntoId: juntoId,
      topicId: topicId,
      status: ParticipantStatus.active,
      scheduledTime: discussion.scheduledTime,
      availableForBreakoutSessionId: breakoutSessionId,
      isPresent: isPresent,
      membershipStatus: MembershipStatus.attendee,
      /**joinParameters: queryParametersService.mostRecentQueryParameters,
      breakoutRoomSurveyQuestions: breakoutRoomSurveyResults?.questions ?? [],
      optInToAmericaTalks: breakoutRoomSurveyResults?.optInAmericaTalks,
      zipCode: breakoutRoomSurveyResults?.zipCode,**/
    );

    final participantRef = reference.collection('discussion-participants').document(uid);

    /*if (setAttendeeStatus) {
      await juntoUserDataService.changeJuntoMembership(
        userId: uid,
        juntoId: juntoId,
        newStatus: MembershipStatus.attendee,
        allowMemberDowngrade: false,
      );
    }*/

    final myMap = {
      ...firestoreUtils.toFirestoreJson(participant.toJson()),
      Participant.kFieldCreatedDate: Firestore.fieldValues.serverTimestamp(),
    };

    await firestore.runTransaction((transaction) async {
      transaction.set(
        participantRef,
        DocumentData.fromMap(myMap),
        merge: true,
      );
    });
  }

  DocumentReference discussionReference({
    required String juntoId,
    required String topicId,
    required String discussionId,
  }) {
    return discussionsCollection(juntoId: juntoId, topicId: topicId).document(discussionId);
  }

  CollectionReference discussionsCollection({
    required String juntoId,
    required String topicId,
  }) {
    return topicReference(juntoId: juntoId, topicId: topicId).collection('discussions');
  }

  CollectionReference topicsCollection(String juntoId) =>
      firestore.collection('junto/$juntoId/topics');

  DocumentReference topicReference({
    required String juntoId,
    required String topicId,
  }) {
    return topicsCollection(juntoId).document(topicId);
  }

  String getTimezone() {
    DateTime dateTime = DateTime.now();
    return dateTime.timeZoneName;
  }
}
