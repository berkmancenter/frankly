import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:data_models/firestore/template.dart';

import 'firestore_utils.dart';

class TemplateUtils {
  static Template templateFromSnapshot(DocumentSnapshot snapshot) {
    if (snapshot.documentID == "misc") {
      return Template(
        id: 'misc',
        creatorId: '',
        collectionPath: snapshot.reference.path,
      );
    } else {
      return Template.fromJson(
        firestoreUtils.fromFirestoreJson(snapshot.data.toMap()),
      );
    }
  }
}
