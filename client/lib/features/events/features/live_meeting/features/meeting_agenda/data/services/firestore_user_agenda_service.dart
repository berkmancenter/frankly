import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:client/core/utils/firestore_utils.dart';
import 'package:client/services.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/utils/utils.dart';

class FirestoreUserAgendaService {
  static const userSuggestions = 'user-suggestions';

  CollectionReference<Map<String, dynamic>> userSuggestionsRef({
    required String parentDoc,
  }) {
    final parentReference = firestoreDatabase.firestore.doc(parentDoc);

    return parentReference.collection(userSuggestions);
  }

  BehaviorSubjectWrapper<List<SuggestedAgendaItem>> suggestedAgendaItemsStream({
    required String parentDoc,
  }) {
    final userSuggestionsCollection = userSuggestionsRef(parentDoc: parentDoc);

    return wrapInBehaviorSubject(
      userSuggestionsCollection
          .snapshots()
          .map((s) => s.docs)
          .asyncMap(_convertSuggestedAgendaItemsListAsync),
    );
  }

  static Future<List<SuggestedAgendaItem>>
      _convertSuggestedAgendaItemsListAsync(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final suggestedAgendaItems = await Future.wait(
      docs.map((doc) => compute(_convertSuggestedAgendaItem, doc.data())),
    );

    for (var i = 0; i < suggestedAgendaItems.length; i++) {
      suggestedAgendaItems[i] = suggestedAgendaItems[i].copyWith(
        id: docs[i].id,
      );
    }

    suggestedAgendaItems.sort((a, b) {
      final bScore = b.upvotedUserIds.length - b.downvotedUserIds.length;
      final aScore = a.upvotedUserIds.length - a.downvotedUserIds.length;
      if (aScore == bScore) {
        return (a.createdDate ?? clockService.now())
            .compareTo(b.createdDate ?? clockService.now());
      }
      return bScore.compareTo(aScore);
    });

    return suggestedAgendaItems;
  }

  static SuggestedAgendaItem _convertSuggestedAgendaItem(
    Map<String, dynamic> data,
  ) =>
      SuggestedAgendaItem.fromJson(fromFirestoreJson(data));

  Future<void> addSuggestedAgendaItem({
    required String parentDoc,
    required SuggestedAgendaItem item,
  }) async {
    final docRef = userSuggestionsRef(parentDoc: parentDoc).doc(item.id);

    // This should possibly be in a transaction
    if (!(await docRef.get()).exists) {
      await docRef.set(toFirestoreJson(item.toJson()));
    }
  }

  Future<void> deleteSuggestedAgendaItem({
    required String parentDoc,
    required String id,
  }) {
    final docRef = userSuggestionsRef(parentDoc: parentDoc).doc(id);
    return docRef.delete();
  }

  Future<void> voteOnSuggestedAgendaItem({
    required String parentDoc,
    required String itemId,
    required bool upvote,
  }) {
    final userId = userService.currentUserId!;
    return firestoreDatabase.firestore.runTransaction((transaction) async {
      final agendaItemRef =
          userSuggestionsRef(parentDoc: parentDoc).doc(itemId);

      final agendaItem = SuggestedAgendaItem.fromJson(
        fromFirestoreJson((await transaction.get(agendaItemRef)).data()!),
      );

      void toggle(List<String> values, String value) {
        if (values.contains(value)) {
          values.remove(value);
        } else {
          values.add(value);
        }
      }

      if (upvote) {
        agendaItem.downvotedUserIds.remove(userId);
        toggle(agendaItem.upvotedUserIds, userId);
      } else {
        agendaItem.upvotedUserIds.remove(userId);
        toggle(agendaItem.downvotedUserIds, userId);
      }

      transaction.update(
        agendaItemRef,
        jsonSubset(
          [
            SuggestedAgendaItem.kFieldUpvotedUserIds,
            SuggestedAgendaItem.kFieldDownvotedUserIds,
          ],
          toFirestoreJson(agendaItem.toJson()),
        ),
      );
    });
  }
}
