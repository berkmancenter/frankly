import 'package:client/services/services.dart';
import 'package:data_models/firestore/scale_test.dart';

import 'firestore_utils.dart';

class FirestoreScaleTestService {
  Future<ScaleTest> getScaleTestInfo() async {
    final docRef = firestoreDatabase.firestore.doc('testing/scale-test');
    return ScaleTest.fromJson(fromFirestoreJson((await docRef.get()).data()!));
  }
}
