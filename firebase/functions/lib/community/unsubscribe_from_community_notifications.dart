import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../on_call_function.dart';
import '../utils/infra/firestore_utils.dart';
import '../utils/notifications_utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/community/community_user_settings.dart';
import 'package:data_models/community/membership.dart';

class UnsubscribeFromCommunityNotifications
    extends OnCallMethod<UnsubscribeFromCommunityNotificationsRequest> {
  NotificationsUtils notificationsUtils;

  UnsubscribeFromCommunityNotifications({
    NotificationsUtils? notificationsUtils,
  })  : notificationsUtils = notificationsUtils ?? NotificationsUtils(),
        super(
          'unsubscribeFromCommunityNotifications',
          (jsonMap) =>
              UnsubscribeFromCommunityNotificationsRequest.fromJson(jsonMap),
        );

  @override
  Future<void> action(
    UnsubscribeFromCommunityNotificationsRequest request,
    CallableContext context,
  ) async {
    final decrypted = notificationsUtils.decryptUnsubscribeData(request.data);

    final membershipsData = await firestore
        .collectionGroup('community-membership')
        .where(Membership.kFieldUserId, isEqualTo: decrypted.userId)
        .whereNotEqual(Membership.kFieldStatus, notEqualTo: 'nonmember')
        .get();

    final communityIds = membershipsData.documents
        .map(
          (e) => Membership.fromJson(
            firestoreUtils.fromFirestoreJson(e.data.toMap()),
          ).communityId,
        )
        .toList();

    await Future.wait(
      communityIds.map((communityId) {
        final settings = CommunityUserSettings(
          userId: decrypted.userId,
          communityId: communityId,
          notifyAnnouncements: NotificationEmailType.none,
          notifyEvents: NotificationEmailType.none,
        );

        return firestore
            .document(
              'privateUserData/${decrypted.userId}/communityUserSettings/$communityId',
            )
            .setData(
              DocumentData.fromMap(
                firestoreUtils.toFirestoreJson(settings.toJson()),
              ),
              SetOptions(merge: true),
            );
      }),
    );
  }
}
