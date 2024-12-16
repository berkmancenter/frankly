import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:junto/services/services.dart';
import 'package:junto_models/firestore/external_partners.dart';

import 'firestore_utils.dart';

class FirestoreExternalPartnersService {
  CollectionReference<Map<String, dynamic>> get _externalPartnersCollection =>
      firestoreDatabase.firestore.collection('external-partners');

  Future<MeetingOfAmerica> getMeetingOfAmerica() async {
    final doc = await _externalPartnersCollection.doc(MeetingOfAmerica.docId).get();

    final result = MeetingOfAmerica.fromJson(fromFirestoreJson(doc.data() ?? {}));
    return result;
  }
}
