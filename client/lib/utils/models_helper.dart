import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_models/discussion_threads/discussion_thread_comment.dart';
import 'package:data_models/chat/emotion.dart';
import 'package:collection/collection.dart';

class EmotionHelper {
  /// Retrieves currently selected [Emotion].
  ///
  /// If user is not signed in, [null] will be retrieved.
  Emotion? getMyEmotion(
    List<Emotion> emotions,
    bool isSignedIn,
    String? userId,
  ) {
    if (!isSignedIn || userId == null) {
      return null;
    }

    return emotions.firstWhereOrNull((element) => element.creatorId == userId);
  }

  /// Reusable method which updates current [writeBatch] with emotion updates.
  void updateBatch(
    DocumentReference documentReference,
    Emotion? existingEmotion,
    Emotion emotion,
    WriteBatch writeBatch,
  ) {
    // Insert new emotion.
    writeBatch.update(documentReference, {
      DiscussionThreadComment.kFieldEmotions: FieldValue.arrayUnion(
        [emotion.toJson()],
      ),
    });

    // If it was already present - remove that emotion, because we are inserting a new one.
    if (existingEmotion != null) {
      writeBatch.update(documentReference, {
        DiscussionThreadComment.kFieldEmotions: FieldValue.arrayRemove(
          [existingEmotion.toJson()],
        ),
      });
    }
  }
}
