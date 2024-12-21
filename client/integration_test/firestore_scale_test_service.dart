import 'package:client/services/services.dart';
import 'scale_test.dart';

import 'package:client/services/firestore/firestore_utils.dart';

class FirestoreScaleTestService {
  Future<ScaleTest> getScaleTestInfo() async {
    final docRef = firestoreDatabase.firestore.doc('testing/scale-test');
    return ScaleTest.fromJson(fromFirestoreJson((await docRef.get()).data()!));
  }
}
