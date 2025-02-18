import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../../on_call_function.dart';
import '../../utils/infra/firestore_utils.dart';
import 'package:data_models/discussion_threads/discussion_thread.dart';
import 'package:data_models/events/live_meetings/meeting_guide.dart';

class ToggleLikeDislikeOnMeetingUserSuggestion
    extends OnCallMethod<ParticipantAgendaItemDetailsMeta> {
  ToggleLikeDislikeOnMeetingUserSuggestion()
      : super(
          'toggleLikeDislikeOnMeetingUserSuggestion',
          (jsonMap) => ParticipantAgendaItemDetailsMeta.fromJson(jsonMap),
        );

  @override
  Future<void> action(
    ParticipantAgendaItemDetailsMeta request,
    CallableContext context,
  ) async {
    await firestore.runTransaction((transaction) async {
      final agendaItemDetailsDocRef = firestore.document(request.documentPath);
      final agendaItemDetailsSnap =
          await transaction.get(agendaItemDetailsDocRef);
      if (!agendaItemDetailsSnap.exists) {
        print(
          'agendaItemDetailsSnap from path ${request.documentPath} does not exist',
        );
        return;
      }
      final ParticipantAgendaItemDetails agendaItemDetails;
      final agendaItemDetailsDataMap = agendaItemDetailsSnap.data.toMap();

      try {
        agendaItemDetails = ParticipantAgendaItemDetails.fromJson(
          firestoreUtils.fromFirestoreJson(agendaItemDetailsDataMap),
        );
      } catch (e) {
        print(
          'Cannot parse participant agenda item details: $agendaItemDetailsDataMap',
        );
        return;
      }

      final userSuggestion = agendaItemDetails.suggestions
          .where(
            (element) => element.id == request.userSuggestionId,
          )
          .firstOrNull;
      if (userSuggestion == null) {
        print('userSuggestion is null. Request: ${request.toJson()}');
        return;
      }

      final voterId = request.voterId;
      print(
        'Toggle: ${request.likeType} for user suggestion ${userSuggestion.id}',
      );

      switch (request.likeType) {
        case LikeType.like:
          if (!userSuggestion.likedByIds.any((element) => element == voterId)) {
            userSuggestion.likedByIds.add(voterId);
          }
          userSuggestion.dislikedByIds
              .removeWhere((element) => element == voterId);
          break;
        case LikeType.neutral:
          userSuggestion.likedByIds
              .removeWhere((element) => element == voterId);
          userSuggestion.dislikedByIds
              .removeWhere((element) => element == voterId);
          break;
        case LikeType.dislike:
          userSuggestion.likedByIds
              .removeWhere((element) => element == voterId);
          if (!userSuggestion.dislikedByIds
              .any((element) => element == voterId)) {
            userSuggestion.dislikedByIds.add(voterId);
          }
          break;
      }

      final updateDataMap = agendaItemDetails.toJson();
      print('Update data: $updateDataMap');

      transaction.update(
        agendaItemDetailsDocRef,
        UpdateData.fromMap(firestoreUtils.toFirestoreJson(updateDataMap)),
      );
    });
  }
}
