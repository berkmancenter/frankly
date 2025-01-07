import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:client/services/services.dart';
import 'package:data_models/discussion_threads/discussion_thread.dart';
import 'package:data_models/events/live_meetings/meeting_guide.dart';
import 'package:data_models/utils/utils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import 'firestore_utils.dart';

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

  Future<void> addWordCloudResponse({
    required String agendaItemId,
    required String userId,
    required String liveMeetingPath,
    required String response,
  }) async {
    final documentPath =
        '$liveMeetingPath/participant-agenda-item-details/$agendaItemId/participant-details/$userId';

    final meetingId = liveMeetingPath.split('/').last;

    await firestoreDatabase.firestore.doc(documentPath).set(
          jsonSubset([
            ParticipantAgendaItemDetails.kFieldUserId,
            ParticipantAgendaItemDetails.kFieldAgendaItemId,
            ParticipantAgendaItemDetails.kFieldMeetingId,
            ParticipantAgendaItemDetails.kFieldWordCloudResponses,
          ], <String, dynamic>{
            ParticipantAgendaItemDetails.kFieldUserId: userId,
            ParticipantAgendaItemDetails.kFieldAgendaItemId: agendaItemId,
            ParticipantAgendaItemDetails.kFieldMeetingId: meetingId,
            ParticipantAgendaItemDetails.kFieldWordCloudResponses:
                FieldValue.arrayUnion([response]),
          }),
          SetOptions(merge: true),
        );
  }

  Future<void> removeWordCloudResponse({
    required String agendaItemId,
    required String userId,
    required String liveMeetingPath,
    required String response,
  }) async {
    final documentPath = _getAgendaItemsDocumentPath(
      liveMeetingPath: liveMeetingPath,
      agendaItemId: agendaItemId,
      userId: userId,
    );

    await firestoreDatabase.firestore.doc(documentPath).set(
          jsonSubset([
            ParticipantAgendaItemDetails.kFieldUserId,
            ParticipantAgendaItemDetails.kFieldAgendaItemId,
            ParticipantAgendaItemDetails.kFieldWordCloudResponses,
          ], <String, dynamic>{
            ParticipantAgendaItemDetails.kFieldUserId: userId,
            ParticipantAgendaItemDetails.kFieldAgendaItemId: agendaItemId,
            ParticipantAgendaItemDetails.kFieldWordCloudResponses:
                FieldValue.arrayRemove([response]),
          }),
          SetOptions(merge: true),
        );
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

    await cloudFunctionsService.toggleLikeDislikeOnMeetingUserSuggestion(
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
    print('item details');
    print(data);
    return ParticipantAgendaItemDetails.fromJson(fromFirestoreJson(data));
  }
}
