import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/smart_match_survey/survey_dialog.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/visible_exception.dart';
import 'package:junto/services/firestore/firestore_utils.dart';
import 'package:junto/services/services.dart';
import 'package:junto/utils/platform_utils.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/live_meeting.dart';
import 'package:junto_models/firestore/membership.dart';
import 'package:junto_models/utils.dart';
import 'package:pedantic/pedantic.dart';
import 'package:rxdart/rxdart.dart';

class FirestoreDiscussionService {
  static const discussions = 'discussions';

  // final time = await NTP.now();
  // Future to mimic NTP.now()
  Future<DateTime> get currentTimeAsync => Future(() => clockService.now());

  CollectionReference<Map<String, dynamic>> discussionsCollection({
    required String juntoId,
    required String topicId,
  }) {
    return firestoreDatabase
        .topicReference(juntoId: juntoId, topicId: topicId)
        .collection(discussions);
  }

  Query<Map<String, dynamic>> _discussionsCollectionGroup() =>
      firestoreDatabase.firestore.collectionGroup(discussions);

  Query<Map<String, dynamic>> _participantsCollectionGroup() =>
      firestoreDatabase.firestore.collectionGroup('discussion-participants');

  DocumentReference<Map<String, dynamic>> discussionReference({
    required String juntoId,
    required String topicId,
    required String discussionId,
  }) {
    return discussionsCollection(juntoId: juntoId, topicId: topicId).doc(discussionId);
  }

  BehaviorSubjectWrapper<List<Discussion>> juntoDiscussions({required String juntoId}) {
    return wrapInBehaviorSubject(_discussionsCollectionGroup()
        .where('juntoId', isEqualTo: juntoId)
        .orderBy('scheduledTime', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final docs = snapshot.docs;
      final discussions = await _convertDiscussionListAsync(docs);

// Not all discussions have a status on the server as it was added later on with a default of "active".
// This also applies to topics so we do filtering on the client side
      return discussions
          .where((discussion) => discussion.status == DiscussionStatus.active)
          .toList();
    }));
  }

  BehaviorSubjectWrapper<List<Discussion>> futurePublicDiscussions({
    required String juntoId,
    required String topicId,
  }) {
    return wrapInBehaviorSubjectAsync(() async {
      final currentTime = await currentTimeAsync;

      final query = discussionsCollection(
        juntoId: juntoId,
        topicId: topicId,
      )
          .where('isPublic', isEqualTo: true)
          .where(
            'scheduledTime',
            isGreaterThan: Timestamp.fromDate(currentTime.subtract(Duration(minutes: 15))),
          )
          .orderBy('scheduledTime');

      return query.snapshots().asyncMap((snapshot) async {
        final discussions = await _convertDiscussionListAsync(snapshot.docs);
        return discussions
            .where((discussion) => discussion.status == DiscussionStatus.active)
            .toList();
      });
    });
  }

  Future<List<Discussion>> getUpcomingPublicDiscussionsFuture({
    required String juntoId,
    required String topicId,
  }) async {
    final currentTime = await currentTimeAsync;

    final query = discussionsCollection(
      juntoId: juntoId,
      topicId: topicId,
    )
        .where('isPublic', isEqualTo: true)
        .where(
          'scheduledTime',
          isGreaterThan: Timestamp.fromDate(currentTime.subtract(Duration(minutes: 15))),
        )
        .orderBy('scheduledTime');

    final discussionsSnapshot = await query.get();
    final discussions = await _convertDiscussionListAsync(discussionsSnapshot.docs);
    final toReturn =
        discussions.where((discussion) => discussion.status == DiscussionStatus.active).toList();
    return toReturn;
  }

  Future<List<Discussion>> allPublicDiscussionsFuture([int limit = 100]) async {
    final discussionsSnapshot = await _discussionsCollectionGroup()
        .where('isPublic', isEqualTo: true)
        .where('scheduledTime', isGreaterThan: clockService.now())
        .limit(limit)
        .get();
    final discussions = discussionsSnapshot.docs
        .map((doc) => _convertDiscussion(doc.data()..['id'] = doc.id))
        .toList();
    return discussions;
  }

  BehaviorSubjectWrapper<List<Discussion>> futurePublicDiscussionsForJunto({
    required String juntoId,
  }) {
    return wrapInBehaviorSubjectAsync(() async {
      // final time = await NTP.now();
      // Future to mimic NTP.now()
      final currentTime = await Future(() => clockService.now());

      return _discussionsCollectionGroup()
          .where('juntoId', isEqualTo: juntoId)
          .where(
            'scheduledTime',
            isGreaterThan: Timestamp.fromDate(currentTime.subtract(Duration(hours: 1))),
          )
          .where('isPublic', isEqualTo: true)
          .orderBy('scheduledTime')
          .snapshots()
          .asyncMap((snapshot) async {
        final discussions = await _convertDiscussionListAsync(snapshot.docs);
        return discussions
            .where((discussion) => discussion.status == DiscussionStatus.active)
            .toList();
      });
    });
  }

  Future<List<Discussion>> userDiscussionsForJunto() async {
    final participantsQuerySnapshot = await _participantsCollectionGroup()
        .where('id', isEqualTo: userService.currentUserId)
        .where('status', isEqualTo: EnumToString.convertToString(ParticipantStatus.active))
        .get();
    final discussionSnapshots =
        participantsQuerySnapshot.docs.map((doc) => doc.reference.parent.parent!.get());

    final discussionDocs =
        await Future.wait<DocumentSnapshot<Map<String, dynamic>>>(discussionSnapshots);
    return _convertDiscussionListAsync(discussionDocs);
  }

  Future<bool> userHasParticipatedInTopic({required String topicId}) async {
    final participantsQuerySnapshot = await _participantsCollectionGroup()
        .where('id', isEqualTo: userService.currentUserId)
        .where('topicId', isEqualTo: topicId)
        .where('status', isEqualTo: EnumToString.convertToString(ParticipantStatus.active))
        .where('scheduledTime', isLessThan: Timestamp.now())
        .get();
    return participantsQuerySnapshot.docs.isNotEmpty;
  }

  BehaviorSubjectWrapper<Discussion> discussionStream({
    required String juntoId,
    required String topicId,
    required String discussionId,
  }) {
    final discussionRef = discussionReference(
      juntoId: juntoId,
      topicId: topicId,
      discussionId: discussionId,
    );
    return wrapInBehaviorSubject(
        discussionRef.snapshots().asyncMap((snapshot) => _convertDiscussionAsync(snapshot)));
  }

  Stream<bool> juntoHasDiscussions({required String juntoId}) => _discussionsCollectionGroup()
      .where('juntoId', isEqualTo: juntoId)
      .limit(1)
      .snapshots()
      .map((event) => event.docs.isNotEmpty);

  BehaviorSubjectWrapper<List<Participant>> discussionParticipantsStream({
    required String juntoId,
    required String topicId,
    required String discussionId,
  }) {
    final discussionRef = discussionReference(
      juntoId: juntoId,
      topicId: topicId,
      discussionId: discussionId,
    );
    return wrapInBehaviorSubject(discussionRef
        .collection('discussion-participants')
        .snapshots(includeMetadataChanges: true)
        .where((snapshot) => !snapshot.metadata.hasPendingWrites && !snapshot.metadata.isFromCache)
        .sampleTime(Duration(milliseconds: 500))
        .asyncMap((snapshot) => convertParticipantListAsync(snapshot)));
  }

  Stream<Participant> discussionParticipantStream({
    required String juntoId,
    required String topicId,
    required String discussionId,
    required String userId,
  }) {
    final discussionRef = discussionReference(
      juntoId: juntoId,
      topicId: topicId,
      discussionId: discussionId,
    );
    return discussionRef
        .collection('discussion-participants')
        .doc(userId)
        .snapshots(includeMetadataChanges: true)
        .where((snapshot) => !snapshot.metadata.hasPendingWrites && !snapshot.metadata.isFromCache)
        .map((snapshot) => _convertParticipant(snapshot.data() ?? {'id': userId}));
  }

  Future<List<Discussion>> getDiscussionsFromPaths(
      String juntoId, List<String> documentPaths) async {
    final discussionDocs = await Future.wait(
      documentPaths.map(
        (path) {
          final discussionMatch =
              RegExp('/?junto/([^/]+)/topics/([^/]+)/discussions/([^/]+)').matchAsPrefix(path);

          final topicId = discussionMatch?.group(2);
          final discussionId = discussionMatch?.group(3);

          if (topicId == null || discussionId == null) {
            throw Exception('No template or event found.');
          }

          return discussionReference(
            juntoId: juntoId,
            topicId: topicId,
            discussionId: discussionId,
          ).get();
        },
      ),
    );

    return discussionDocs.map((e) => _convertDiscussion((e.data() ?? {})..['id'] = e.id)).toList();
  }

  Query<Map<String, dynamic>> discussionParticipantsQuery({required Discussion discussion}) {
    return discussionReference(
      juntoId: discussion.juntoId,
      topicId: discussion.topicId,
      discussionId: discussion.id,
    )
        .collection('discussion-participants')
        .where('status', isEqualTo: EnumToString.convertToString(ParticipantStatus.active))
        .orderBy('createdDate');
  }

  Future<List<Participant>> getDiscussionParticipants({required Discussion discussion}) async {
    final discussionRef = discussionReference(
      juntoId: discussion.juntoId,
      topicId: discussion.topicId,
      discussionId: discussion.id,
    );
    final participantDocs = await discussionRef.collection('discussion-participants').get();

    return convertParticipantListAsync(participantDocs);
  }

  Future<PrivateLiveStreamInfo?> liveStreamPrivateInfo({required Discussion discussion}) async {
    final discussionRef = firestoreDatabase.firestore
        .doc('${discussion.fullPath}/private-live-stream-info/${discussion.id}');
    final doc = await discussionRef.get();
    final data = doc.data();

    if (data == null) return null;

    return PrivateLiveStreamInfo.fromJson(fromFirestoreJson(data));
  }

  Future<Discussion> createDiscussionIfNotExists({
    required Discussion discussion,
    PrivateLiveStreamInfo? privateLiveStreamInfo,
    bool record = false,
  }) async {
    final discussionRef = discussionsCollection(
      juntoId: discussion.juntoId,
      topicId: discussion.topicId,
    ).doc(discussion.id);

    final timeZone = getTimezone();

    final newDiscussion = discussion.copyWith(
      id: discussionRef.id,
      collectionPath: discussionRef.parent.path,
      status: DiscussionStatus.active,
      creatorId: userService.currentUserId!,
      scheduledTimeZone: timeZone,
    );

    final newParticipant = Participant(
      id: userService.currentUserId!,
      juntoId: discussion.juntoId,
      topicId: discussion.topicId,
      status: ParticipantStatus.active,
    );
    final participantRef =
        discussionRef.collection('discussion-participants').doc(newParticipant.id);

    return firestoreDatabase.firestore.runTransaction((transaction) async {
      if (!isNullOrEmpty(discussion.id)) {
        final snapshot = await transaction.get(discussionRef);
        final snapshotData = snapshot.data();

        if (snapshotData != null) {
          return Discussion.fromJson(fromFirestoreJson(snapshotData));
        }
      }

      transaction.set(discussionRef, toFirestoreJson(newDiscussion.toJson()));
      transaction.set(participantRef, {
        ...toFirestoreJson(newParticipant.toJson()),
        Participant.kFieldCreatedDate: FieldValue.serverTimestamp(),
      });

      await juntoUserDataService.changeJuntoMembership(
        userId: userService.currentUserId!,
        juntoId: discussion.juntoId,
        newStatus: MembershipStatus.attendee,
        allowMemberDowngrade: false,
      );

      if (record) {
        transaction.set(
          firestoreDatabase.firestore
              .doc(firestoreLiveMeetingService.getLiveMeetingPath(newDiscussion)),
          jsonSubset([LiveMeeting.kFieldRecord], LiveMeeting(record: record).toJson()),
        );
      }

      if (privateLiveStreamInfo != null) {
        transaction.set(discussionRef.collection('private-live-stream-info').doc(discussionRef.id),
            toFirestoreJson(privateLiveStreamInfo.toJson()));
      }

      return newDiscussion;
    });
  }

  Future<void> updateDiscussion({
    required Discussion discussion,
    required Iterable<String> keys,
  }) async {
    final docRef = discussionReference(
      juntoId: discussion.juntoId,
      topicId: discussion.topicId,
      discussionId: discussion.id,
    );

    final dataMap = jsonSubset(keys, toFirestoreJson(discussion.toJson()));
    loggingService.log(
      'FirestoreDiscussionService.updateDiscussion: Path: ${docRef.path}, Data: $dataMap',
    );

    await docRef.update(dataMap);
  }

  Future<void> addLiveStreamDiscussionDetails({
    required Discussion discussion,
    PrivateLiveStreamInfo? privateLiveStreamInfo,
  }) async {
    final discussionRef = discussionsCollection(
      juntoId: discussion.juntoId,
      topicId: discussion.topicId,
    ).doc(discussion.id);

    if (!isNullOrEmpty(discussion.id) && privateLiveStreamInfo != null) {
      await discussionRef
          .collection('private-live-stream-info')
          .doc(discussionRef.id)
          .set(toFirestoreJson(privateLiveStreamInfo.toJson()));
    }
  }

  Future<void> joinDiscussion({
    required String juntoId,
    required String topicId,
    required String discussionId,
    String? externalCommunityId,
    bool setAttendeeStatus = true,
    SurveyDialogResult? breakoutRoomSurveyResults,
  }) async {
    final uid = userService.currentUserId!;

    unawaited(firebaseAnalytics.logEvent(name: 'discussion_join'));

    final reference = discussionReference(
      juntoId: juntoId,
      topicId: topicId,
      discussionId: discussionId,
    );

    final snapshot = await reference.get();
    final discussion = await _convertDiscussionAsync(snapshot);

    if (discussion.status == DiscussionStatus.canceled) {
      throw VisibleException('Sorry, this event has been cancelled so you cannot '
          'join it. Consider creating a new event!');
    }

    final participant = Participant(
      id: uid,
      juntoId: juntoId,
      topicId: topicId,
      status: ParticipantStatus.active,
      scheduledTime: discussion.scheduledTime,
      externalCommunityId: externalCommunityId,
      joinParameters: queryParametersService.mostRecentQueryParameters,
      breakoutRoomSurveyQuestions: breakoutRoomSurveyResults?.questions ?? [],
      optInToAmericaTalks: breakoutRoomSurveyResults?.optInAmericaTalks,
      zipCode: breakoutRoomSurveyResults?.zipCode,
    );
    print('Participant $participant');
    final participantRef = reference.collection('discussion-participants').doc(uid);

    if (setAttendeeStatus) {
      await juntoUserDataService.changeJuntoMembership(
        userId: uid,
        juntoId: juntoId,
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
    required String juntoId,
    required String topicId,
    required String discussionId,
    required String participantId,
  }) async {
    final participantRef = discussionReference(
      juntoId: juntoId,
      topicId: topicId,
      discussionId: discussionId,
    ).collection('discussion-participants').doc(participantId);
    await participantRef.set(
        jsonSubset(
            [Participant.kFieldLastUpdatedTime, Participant.kFieldStatus],
            toFirestoreJson(Participant(
              id: participantId,
              status: ParticipantStatus.canceled,
            ).toJson())),
        SetOptions(merge: true));
  }

  Future<void> optInToAmericaTalks({
    required String juntoId,
    required String topicId,
    required String discussionId,
    required String participantId,
  }) async {
    final participantRef = discussionReference(
      juntoId: juntoId,
      topicId: topicId,
      discussionId: discussionId,
    ).collection('discussion-participants').doc(participantId);
    await participantRef.set(
        jsonSubset(
            [Participant.kFieldOptInAmericaTalks],
            toFirestoreJson(Participant(
              id: participantId,
              optInToAmericaTalks: true,
            ).toJson())),
        SetOptions(merge: true));
  }

  Future<void> upsertAgendaItem({
    required Discussion discussion,
    required AgendaItem updatedItem,
  }) {
    return firestoreDatabase.firestore.runTransaction((transaction) async {
      final ref = firestoreDatabase.firestore.doc(discussion.fullPath);
      final snapshot = await transaction.get(ref);
      var discussionSnapshot = await _convertDiscussionAsync(snapshot);

      final agendaItems = discussionSnapshot.agendaItems;
      final index = agendaItems.indexWhere((item) => item.id == updatedItem.id);
      if (index < 0) {
        agendaItems.add(updatedItem);
      } else {
        agendaItems[index] = updatedItem;
      }

      discussionSnapshot = discussionSnapshot.copyWith(agendaItems: agendaItems);
      transaction.update(snapshot.reference,
          jsonSubset([Discussion.kFieldAgendaItems], toFirestoreJson(discussionSnapshot.toJson())));
    });
  }

  Future<void> setAgendaItemsLegacy({
    required Discussion discussion,
    required List<AgendaItem> agendaItems,
  }) {
    return firestoreDatabase.firestore.runTransaction((transaction) async {
      final ref = firestoreDatabase.firestore.doc(discussion.fullPath);
      final snapshot = await transaction.get(ref);
      var discussionSnapshot = await _convertDiscussionAsync(snapshot);

      if (discussionSnapshot.agendaItems.isNotEmpty) {
        return;
      }

      discussionSnapshot = discussionSnapshot.copyWith(agendaItems: agendaItems);
      transaction.update(snapshot.reference,
          jsonSubset([Discussion.kFieldAgendaItems], toFirestoreJson(discussionSnapshot.toJson())));
    });
  }

  Future<void> deleteTopicAgendaItem({
    required Discussion discussion,
    required String itemId,
  }) {
    return firestoreDatabase.firestore.runTransaction((transaction) async {
      final ref = firestoreDatabase.firestore.doc(discussion.fullPath);
      final snapshot = await transaction.get(ref);
      var discussionSnapshot = await _convertDiscussionAsync(snapshot);

      final agendaItems = discussionSnapshot.agendaItems;
      agendaItems.removeWhere((item) => item.id == itemId);

      discussionSnapshot = discussionSnapshot.copyWith(agendaItems: agendaItems);
      transaction.update(snapshot.reference,
          jsonSubset([Discussion.kFieldAgendaItems], toFirestoreJson(discussionSnapshot.toJson())));
    });
  }

  Future<void> updateAgendaOrdering({
    required Discussion discussion,
    required List<String> ordering,
  }) {
    return firestoreDatabase.firestore.runTransaction((transaction) async {
      final ref = firestoreDatabase.firestore.doc(discussion.fullPath);
      final snapshot = await transaction.get(ref);
      var discussionSnapshot = await _convertDiscussionAsync(snapshot);

      final agendaItems = discussionSnapshot.agendaItems;
      final agendaItemMap = Map.fromIterable(
        agendaItems,
        key: (item) => (item as AgendaItem).id,
      );

      if (!setEquals(ordering.toSet(), agendaItemMap.keys.toSet())) {
        throw VisibleException('Error in updating agenda ordering. Please refresh.');
      }

      final List<AgendaItem> newAgenda =
          ordering.map((itemId) => agendaItemMap[itemId] as AgendaItem).toList();

      discussionSnapshot = discussionSnapshot.copyWith(agendaItems: newAgenda);
      transaction.update(snapshot.reference,
          jsonSubset([Discussion.kFieldAgendaItems], toFirestoreJson(discussionSnapshot.toJson())));
    });
  }

  Future<void> kickParticipant({
    required Discussion discussion,
    required String kickedUserId,
    bool lockRoom = false,
  }) async {
    final discussionPath = discussion.fullPath;
    final discussionDoc = firestoreDatabase.firestore.doc(discussionPath);
    final snapshot = await discussionDoc.get();
    final firestoreDiscussion = await _convertDiscussionAsync(snapshot);
    if (firestoreDiscussion.creatorId == kickedUserId) {
      throw VisibleException('Can\'t kick the event creator.');
    }

    final participantRef = discussionReference(
      juntoId: discussion.juntoId,
      topicId: discussion.topicId,
      discussionId: discussion.id,
    ).collection('discussion-participants').doc(kickedUserId);

    loggingService.log('setting the users status to banned: $kickedUserId');
    await participantRef.set(
        jsonSubset(
            [Participant.kFieldLastUpdatedTime, Participant.kFieldStatus],
            toFirestoreJson(Participant(
              id: kickedUserId,
              status: ParticipantStatus.banned,
            ).toJson())),
        SetOptions(merge: true));

    if (lockRoom) {
      await updateDiscussion(
        discussion: firestoreDiscussion.copyWith(isLocked: true),
        keys: [Discussion.kFieldIsLocked],
      );
    }
  }

  Future<void> updateParticipantBreakoutSurveyAnswers({
    required Discussion discussion,
    bool lockRoom = false,
    required SurveyDialogResult surveyDialogResult,
  }) async {
    final userId = userService.currentUserId!;
    final participant = Participant(
      id: userId,
      breakoutRoomSurveyQuestions: surveyDialogResult.questions,
      optInToAmericaTalks: surveyDialogResult.optInAmericaTalks,
      zipCode: surveyDialogResult.zipCode,
    );
    final participantRef = discussionReference(
      juntoId: discussion.juntoId,
      topicId: discussion.topicId,
      discussionId: discussion.id,
    ).collection('discussion-participants').doc(userId);

    loggingService.log('Updating survey answers for $userId');
    await participantRef.set(
        jsonSubset([
          Participant.kFieldBreakoutRoomSurveyQuestions,
          Participant.kFieldOptInAmericaTalks,
          Participant.kFieldZipCode,
        ], toFirestoreJson(participant.toJson())),
        SetOptions(merge: true));
  }

  static Future<List<Discussion>> _convertDiscussionListAsync(
      List<DocumentSnapshot<Map<String, dynamic>>> docs) async {
    final discussions = <Discussion?>[
      for (final doc in docs)
        await swallowErrors(
          () => compute<Map<String, dynamic>, Discussion>(
              _convertDiscussion, (doc.data() ?? {})..['id'] = doc.id),
          errorMessage: 'Error parsing discussion: ${doc.reference.path}/${doc.reference.id}',
        )
    ];

    for (var i = 0; i < discussions.length; i++) {
      discussions[i] = discussions[i]?.copyWith(id: docs[i].id);
    }

    return <Discussion>[
      for (final discussion in discussions)
        if (discussion != null) discussion
    ];
  }

  static Future<Discussion> _convertDiscussionAsync(
      DocumentSnapshot<Map<String, dynamic>> doc) async {
    final discussion = await compute<Map<String, dynamic>, Discussion>(
        _convertDiscussion, (doc.data() ?? {})..['id'] = doc.id);
    return discussion.copyWith(id: doc.id);
  }

  static Discussion _convertDiscussion(Map<String, dynamic> data) {
    return Discussion.fromJson(fromFirestoreJson(data));
  }

  static Future<List<Participant>> convertParticipantListAsync(
      QuerySnapshot<Map<String, dynamic>> snapshot) async {
    final snapshotDocs = snapshot.docs;

    final discussions =
        await Future.wait(snapshotDocs.map((doc) => compute(_convertParticipant, doc.data())));

    for (var i = 0; i < discussions.length; i++) {
      discussions[i] = discussions[i].copyWith(
        id: snapshotDocs[i].id,
      );
    }

    return discussions;
  }

  static Participant _convertParticipant(Map<String, dynamic> data) {
    try {
      return Participant.fromJson(fromFirestoreJson(data));
    } catch (exception) {
      print('Failed on ' + data.toString());
      rethrow;
    }
  }
}
