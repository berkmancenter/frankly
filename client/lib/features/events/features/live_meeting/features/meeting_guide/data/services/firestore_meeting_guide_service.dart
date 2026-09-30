import 'package:data_models/user_input/word_cloud_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:client/services.dart';
import 'package:data_models/discussion_threads/discussion_thread.dart';
import 'package:data_models/events/live_meetings/meeting_guide.dart';
import 'package:data_models/utils/utils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import '../../../../../../../../core/utils/firestore_utils.dart';

class FirestoreMeetingGuideService {
  String _getAgendaItemsCollectionPath({
    required String liveMeetingPath,
    required String agendaItemId,
  }) {
    return '$liveMeetingPath/participant-agenda-item-details/$agendaItemId/participant-details';
  }

  String _getAgendaItemsDocumentPath({
    required String liveMeetingPath,
    required String agendaItemId,
    required String userId,
  }) {
    final collectionPath = _getAgendaItemsCollectionPath(
      liveMeetingPath: liveMeetingPath,
      agendaItemId: agendaItemId,
    );
    return '$collectionPath/$userId';
  }

  Stream<List<ParticipantAgendaItemDetails>>
      participantAgendaItemDetailsStream({
    required String liveMeetingPath,
    required String agendaItemId,
  }) {
    final agendaItemsCollectionPath = _getAgendaItemsCollectionPath(
      liveMeetingPath: liveMeetingPath,
      agendaItemId: agendaItemId,
    );

    return firestoreDatabase.firestore
        .collection(agendaItemsCollectionPath)
        .snapshots()
        .sampleTime(Duration(milliseconds: 200))
        .map((s) => s.docs)
        .asyncMap(_convertParticipantAgendaItemDetailsListAsync);
  }

  Future<void> voteOnPoll({
    required String agendaItemId,
    required String userId,
    required String liveMeetingPath,
    String? response,
  }) async {
    final meetingId = liveMeetingPath.split('/').last;

    final documentPath = _getAgendaItemsDocumentPath(
      liveMeetingPath: liveMeetingPath,
      agendaItemId: agendaItemId,
      userId: userId,
    );

    await firestoreDatabase.firestore.doc(documentPath).set(
          jsonSubset(
            [
              ParticipantAgendaItemDetails.kFieldUserId,
              ParticipantAgendaItemDetails.kFieldAgendaItemId,
              ParticipantAgendaItemDetails.kFieldMeetingId,
              ParticipantAgendaItemDetails.kFieldPollResponse,
            ],
            ParticipantAgendaItemDetails(
              userId: userId,
              agendaItemId: agendaItemId,
              pollResponse: response,
              meetingId: meetingId,
            ).toJson(),
          ),
          SetOptions(merge: true),
        );
  }

  /// Firestore SDK gives free local-cache optimism, offline
  /// queueing, and automatic retry.
  Future<void> setReadyToAdvance({
    required String agendaItemId,
    required String userId,
    required String liveMeetingPath,
    required bool ready,
  }) async {
    final meetingId = liveMeetingPath.split('/').last;

    final documentPath = _getAgendaItemsDocumentPath(
      liveMeetingPath: liveMeetingPath,
      agendaItemId: agendaItemId,
      userId: userId,
    );

    await firestoreDatabase.firestore.doc(documentPath).set(
          jsonSubset(
            [
              ParticipantAgendaItemDetails.kFieldUserId,
              ParticipantAgendaItemDetails.kFieldAgendaItemId,
              ParticipantAgendaItemDetails.kFieldMeetingId,
              ParticipantAgendaItemDetails.kFieldReadyToAdvance,
            ],
            ParticipantAgendaItemDetails(
              userId: userId,
              agendaItemId: agendaItemId,
              readyToAdvance: ready,
              meetingId: meetingId,
            ).toJson(),
          ),
          SetOptions(merge: true),
        );
  }

  Future<void> addWordCloudResponse({
    required String agendaItemId,
    required String userId,
    required String liveMeetingPath,
    required String response,
    required String prompt,
  }) async {
    final ref = firestoreDatabase.firestore.doc(
      _getAgendaItemsDocumentPath(
        liveMeetingPath: liveMeetingPath,
        agendaItemId: agendaItemId,
        userId: userId,
      ),
    );
    final entry = WordCloudData(
      userId: userId,
      agendaItemId: agendaItemId,
      roomId: liveMeetingPath.split('/').last,
      prompt: prompt,
      message: response,
      createdDate: clockService.now(),
    );
    await firestoreDatabase.firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      final details = ParticipantAgendaItemDetails.fromJson(
        fromFirestoreJson(snapshot.data() ?? {}),
      );
      // Preserve the existing one-copy-per-word behavior and submission time.
      if (details.wordCloudResponses.contains(response)) return;
      transaction.set(
        ref,
        {
          ParticipantAgendaItemDetails.kFieldUserId: userId,
          ParticipantAgendaItemDetails.kFieldAgendaItemId: agendaItemId,
          ParticipantAgendaItemDetails.kFieldMeetingId: entry.roomId,
          ParticipantAgendaItemDetails.kFieldWordCloudResponses: [
            ...details.wordCloudResponses,
            response,
          ],
          ParticipantAgendaItemDetails.kFieldWordCloudEntries: [
            ...details.wordCloudEntries,
            entry,
          ].map((e) => e.toJson()).toList(),
        },
        SetOptions(merge: true),
      );
    });
  }

  Future<void> removeWordCloudResponse({
    required String agendaItemId,
    required String userId,
    required String liveMeetingPath,
    required String response,
  }) async {
    final ref = firestoreDatabase.firestore.doc(
      _getAgendaItemsDocumentPath(
        liveMeetingPath: liveMeetingPath,
        agendaItemId: agendaItemId,
        userId: userId,
      ),
    );
    await firestoreDatabase.firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) return;
      final details = ParticipantAgendaItemDetails.fromJson(
        fromFirestoreJson(snapshot.data()!),
      );
      transaction.update(ref, {
        ParticipantAgendaItemDetails.kFieldWordCloudResponses: details
            .wordCloudResponses
            .where((word) => word != response)
            .toList(),
        ParticipantAgendaItemDetails.kFieldWordCloudEntries: details
            .wordCloudEntries
            .where((entry) => entry.message != response)
            .map((entry) => entry.toJson())
            .toList(),
      });
    });
  }

  Future<void> addUserSuggestion({
    required String agendaItemId,
    required String userId,
    required String liveMeetingPath,
    required String suggestion,
  }) async {
    final documentPath = _getAgendaItemsDocumentPath(
      liveMeetingPath: liveMeetingPath,
      agendaItemId: agendaItemId,
      userId: userId,
    );
    final meetingId = liveMeetingPath.split('/').last;
    final meetingUserSuggestionJson = MeetingUserSuggestion(
      id: Uuid().v4(),
      suggestion: suggestion,
      // Automatically like own suggestion
      likedByIds: [userId],
      createdDate: clockService.now(),
    ).toJson();
    final dataMap = jsonSubset([
      ParticipantAgendaItemDetails.kFieldUserId,
      ParticipantAgendaItemDetails.kFieldAgendaItemId,
      ParticipantAgendaItemDetails.kFieldMeetingId,
      ParticipantAgendaItemDetails.kFieldSuggestions,
    ], <String, dynamic>{
      ParticipantAgendaItemDetails.kFieldUserId: userId,
      ParticipantAgendaItemDetails.kFieldAgendaItemId: agendaItemId,
      ParticipantAgendaItemDetails.kFieldMeetingId: meetingId,
      ParticipantAgendaItemDetails.kFieldSuggestions:
          FieldValue.arrayUnion([meetingUserSuggestionJson]),
    });

    loggingService
        .log('FirestoreMeetingGuideService.addUserSuggestion: Data: $dataMap');

    await firestoreDatabase.firestore
        .doc(documentPath)
        .set(toFirestoreJson(dataMap), SetOptions(merge: true));
  }

  Future<void> removeUserSuggestion({
    required String agendaItemId,
    required String userId,
    required String liveMeetingPath,
    required MeetingUserSuggestion meetingUserSuggestion,
  }) async {
    final documentPath = _getAgendaItemsDocumentPath(
      liveMeetingPath: liveMeetingPath,
      agendaItemId: agendaItemId,
      userId: userId,
    );
    final dataMap = jsonSubset([
      ParticipantAgendaItemDetails.kFieldUserId,
      ParticipantAgendaItemDetails.kFieldAgendaItemId,
      ParticipantAgendaItemDetails.kFieldSuggestions,
    ], <String, dynamic>{
      ParticipantAgendaItemDetails.kFieldUserId: userId,
      ParticipantAgendaItemDetails.kFieldAgendaItemId: agendaItemId,
      ParticipantAgendaItemDetails.kFieldSuggestions:
          FieldValue.arrayRemove([meetingUserSuggestion.toJson()]),
    });

    loggingService.log(
      'FirestoreMeetingGuideService.removeUserSuggestion: Data: $dataMap',
    );

    await firestoreDatabase.firestore
        .doc(documentPath)
        .set(dataMap, SetOptions(merge: true));
  }

  Future<void> toggleLikeInMeetingSuggestion(
    LikeType likeType, {
    required String agendaItemId,
    required String creatorId,
    required String voterId,
    required String liveMeetingPath,
    required String meetingUserSuggestionId,
  }) async {
    final documentPath = _getAgendaItemsDocumentPath(
      liveMeetingPath: liveMeetingPath,
      agendaItemId: agendaItemId,
      userId: creatorId,
    );
    final participantAgendaItemDetailsMeta = ParticipantAgendaItemDetailsMeta(
      documentPath: documentPath,
      voterId: voterId,
      likeType: likeType,
      userSuggestionId: meetingUserSuggestionId,
    );

    loggingService.log(
      'FirestoreMeetingGuideService.toggleLikeInMeetingSuggestion: Meta: ${participantAgendaItemDetailsMeta.toJson()}',
    );

    await cloudFunctionsLiveMeetingService
        .toggleLikeDislikeOnMeetingUserSuggestion(
      participantAgendaItemDetailsMeta,
    );
  }

  Future<void> toggleHandRaise({
    required String agendaItemId,
    required String userId,
    required String liveMeetingPath,
    required bool isHandRaised,
  }) async {
    final documentPath = _getAgendaItemsDocumentPath(
      liveMeetingPath: liveMeetingPath,
      agendaItemId: agendaItemId,
      userId: userId,
    );
    final updateMap = jsonSubset(
      [
        ParticipantAgendaItemDetails.kFieldUserId,
        ParticipantAgendaItemDetails.kFieldAgendaItemId,
        ParticipantAgendaItemDetails.kFieldMeetingId,
        ParticipantAgendaItemDetails.kFieldHandRaisedTime,
      ],
      ParticipantAgendaItemDetails(
        userId: userId,
        meetingId: liveMeetingPath.split('/').last,
        agendaItemId: agendaItemId,
      ).toJson(),
    );

    loggingService
        .log('FirestoreMeetingGuideService.toggleHandRaise: Data: $updateMap');

    // handRaisedTime is set to serverTimestamp unless we reset to null.
    if (isHandRaised) {
      updateMap[ParticipantAgendaItemDetails.kFieldHandRaisedTime] =
          FieldValue.serverTimestamp();
    } else {
      updateMap[ParticipantAgendaItemDetails.kFieldHandRaisedTime] = null;
    }

    await firestoreDatabase.firestore
        .doc(documentPath)
        .set(toFirestoreJson(updateMap), SetOptions(merge: true));
  }

  Future<void> updateVideoPosition({
    required String agendaItemId,
    required String userId,
    required String liveMeetingPath,
    required double currentTime,
    required double duration,
  }) async {
    final documentPath = _getAgendaItemsDocumentPath(
      liveMeetingPath: liveMeetingPath,
      agendaItemId: agendaItemId,
      userId: userId,
    );
    final meetingId = liveMeetingPath.split('/').last;

    await firestoreDatabase.firestore.doc(documentPath).set(
          jsonSubset(
            [
              ParticipantAgendaItemDetails.kFieldUserId,
              ParticipantAgendaItemDetails.kFieldAgendaItemId,
              ParticipantAgendaItemDetails.kFieldMeetingId,
              ParticipantAgendaItemDetails.kFieldVideoCurrentTime,
              ParticipantAgendaItemDetails.kFieldVideoDuration,
            ],
            toFirestoreJson(
              ParticipantAgendaItemDetails(
                userId: userId,
                agendaItemId: agendaItemId,
                meetingId: meetingId,
                videoCurrentTime: currentTime,
                videoDuration: duration,
              ).toJson(),
            ),
          ),
          SetOptions(merge: true),
        );
  }

  static Future<List<ParticipantAgendaItemDetails>>
      _convertParticipantAgendaItemDetailsListAsync(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    return Future.wait(
      docs.map(
        (doc) => compute(_convertSuggestedAgendaItem, doc.data()),
      ),
    );
  }

  static ParticipantAgendaItemDetails _convertSuggestedAgendaItem(
    Map<String, dynamic> data,
  ) {
    return ParticipantAgendaItemDetails.fromJson(fromFirestoreJson(data));
  }
}
