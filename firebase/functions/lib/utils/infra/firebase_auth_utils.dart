import './firestore_utils.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart';

/// Use a global singleton to allow mocking in tests
FirebaseAuthUtils firebaseAuthUtils = FirebaseAuthUtils();

class FirebaseAuthUtils {
  Future<UserRecord> getUser(String uid) async {
    // Get user record
    var user = await firebaseApp.auth().getUser(uid);

    return user;
  }

  Future<List<UserRecord>> getUsers(List<String> uids) async {
    // Get emails of every user we want to email
    final getUserFutures = uids.map((id) => firebaseApp.auth().getUser(id));

    return Future.wait(getUserFutures);
  }

  Future<UserRecord?> getUserByEmailIfExists(String email) async {
    try {
      return await firebaseApp.auth().getUserByEmail(email);
    } catch (e) {
      if (e.toString().contains('user-not-found')) {
        return null;
      }
      rethrow;
    }
  }

  Future<bool> isEmailAvailableForUser(String email, String uid) async {
    final existingUser = await getUserByEmailIfExists(email);
    if (existingUser == null) {
      return true;
    }
    return existingUser.uid == uid;
  }
}
