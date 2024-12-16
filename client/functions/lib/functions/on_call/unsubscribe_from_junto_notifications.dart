import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/on_call_function.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_functions/utils/notifications_utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/junto_user_settings.dart';
import 'package:junto_models/firestore/membership.dart';

class UnsubscribeFromJuntoNotifications
    extends OnCallMethod<UnsubscribeFromJuntoNotificationsRequest> {
  UnsubscribeFromJuntoNotifications()
      : super('unsubscribeFromJuntoNotifications',
            (jsonMap) => UnsubscribeFromJuntoNotificationsRequest.fromJson(jsonMap));

  @override
  Future<void> action(
      UnsubscribeFromJuntoNotificationsRequest request, CallableContext context) async {
    final decrypted = notificationsUtils.decryptUnsubscribeData(request.data);

    final membershipsData = await firestore
        .collectionGroup('junto-membership')
        .where(Membership.kFieldUserId, isEqualTo: decrypted.userId)
        .whereNotEqual(Membership.kFieldStatus, notEqualTo: 'nonmember')
        .get();

    final juntoIds =
        membershipsData.documents.map((e) => Membership.fromJson(firestoreUtils.fromFirestoreJson(e.data.toMap())).juntoId).toList();

    await Future.wait(juntoIds.map((juntoId) {
      final settings = JuntoUserSettings(
          userId: decrypted.userId,
          juntoId: juntoId,
          notifyAnnouncements: NotificationEmailType.none,
          notifyEvents: NotificationEmailType.none);

      return firestore
          .document('privateUserData/${decrypted.userId}/juntoUserSettings/$juntoId')
          .setData(DocumentData.fromMap(firestoreUtils.toFirestoreJson(settings.toJson())), SetOptions(merge: true));
    }));
  }
}
