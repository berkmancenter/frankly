
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:junto_models/firestore/topic.dart';

import 'firestore_utils.dart';

class TopicUtils {
  static Topic topicFromSnapshot(DocumentSnapshot snapshot) {
    if (snapshot.documentID== "misc") {
      return Topic(id: 'misc', creatorId: '', collectionPath: snapshot.reference.path);
    }
    else {
      return Topic.fromJson(firestoreUtils.fromFirestoreJson(snapshot.data.toMap()));
    }
  }
}