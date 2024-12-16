import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/on_call/create_junto.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/membership.dart';
import 'package:junto_functions/utils/firestore_utils.dart';

class CommunityTestUtils {
  Future<Map<String, dynamic>> createJunto({
    required Junto junto,
    required String userId,
  }) async {
    final juntoCreator = CreateJunto();
    final req = CreateJuntoRequest(junto: junto);
    final result = await juntoCreator.action(req, CallableContext(userId, null, 'fakeInstanceId'));
    return result;
  }

  Future<void> addJuntoMember({
    required String userId,
    required String juntoId,
    MembershipStatus status = MembershipStatus.attendee,
  }) async {
    await firestore.runTransaction((transaction) async {
      transaction.set(
        firestore.document('memberships/$userId/junto-membership/$juntoId'),
        DocumentData.fromMap(
          firestoreUtils.toFirestoreJson(
            Membership(
              juntoId: juntoId,
              userId: userId,
              status: status,
            ).toJson(),
          ),
        ),
      );
    });
  }
}
