import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart'
    as admin_interop;
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'infra/firestore_utils.dart';
import 'send_email_client.dart';
import 'utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/community/community_user_settings.dart';
import 'package:data_models/community/membership.dart';
import 'package:data_models/templates/template.dart';

final noReplyEmailAddr = functions.config.get('app.no_reply_email') as String;

class UnsubscribeData {
  String userId;
  UnsubscribeData(this.userId);
}

class NotificationsUtils {
  Future<void> sendCommunityNotifications({
    required String communityId,
    String? creatorUserId,
    required bool Function(CommunityUserSettings) filterUsersBy,
    required SendGridEmailMessage Function({
      required Community community,
      required admin_interop.UserRecord user,
      required String unsubscribeUrl,
    }) generateMessage,
  }) async {
    // first get members of this community

    final communityRef =
        await firestore.document('/community/$communityId').get();
    final communityData = Community.fromJson(
      firestoreUtils.fromFirestoreJson(communityRef.data.toMap()),
    );

    final membershipsData = await firestore
        .collectionGroup('community-membership')
        .where(Membership.kFieldCommunityId, isEqualTo: communityId)
        .whereNotEqual(Membership.kFieldStatus, notEqualTo: 'nonmember')
        .get();

    final userIds = membershipsData.documents
        .map(
          (e) => Membership.fromJson(
            firestoreUtils.fromFirestoreJson(e.data.toMap()),
          ),
        )
        .where((m) => m.isMember)
        .map((m) => m.userId)
        .where((id) => id != creatorUserId)
        .toList();

    print('Got user IDs');
    // Get the notification settings for members
    final userSettingsFutures = userIds.map((userId) async {
      final snapshot = await firestore
          .document(
            '/privateUserData/$userId/communityUserSettings/$communityId',
          )
          .get();
      final record = CommunityUserSettings.fromJson(
        firestoreUtils.fromFirestoreJson(snapshot.data.toMap()),
      );
      if (record.userId != null) {
        return record;
      }
      return CommunityUserSettings(
        userId: userId,
        communityId: communityId,
        notifyAnnouncements: null,
        notifyEvents: null,
      );
    }).toList();

    final userSettings = await Future.wait(userSettingsFutures);

    // Discard those who have opted out
    final usersIdsFiltered = userSettings
        .where(filterUsersBy)
        .map((settings) => settings.userId ?? "")
        .toList();
    // Remove all nulls making it non-nullable list
    usersIdsFiltered.removeWhere((element) => element == "");

    print('user IDs filtered');
    // Get email addresses from auth and queue emails
    final users = await firestoreUtils.getUsers(usersIdsFiltered);

    print('Got users');
    final usersWithoutEmail =
        users.where((u) => isNullOrEmpty(u.email)).toList();
    if (usersWithoutEmail.isNotEmpty) {
      print('Some users dont have email: $usersWithoutEmail');
    }

    final emails = users
        .where((u) => !isNullOrEmpty(u.email))
        .map(
          (user) => SendGridEmail(
            to: [user.email],
            from: '${communityData.name} <$noReplyEmailAddr>',
            message: generateMessage(
              community: communityData,
              user: user,
              unsubscribeUrl: getUnsubscribeUrl(userId: user.uid),
            ),
          ),
        )
        .toList();
    print('Emails generated');
    await sendEmailClient.sendEmails(emails);
  }

  Future<void> sendEmailToEventParticipants({
    required String communityId,
    required Template template,
    required Event event,
    required SendGridEmailMessage Function({
      required Community community,
      required admin_interop.UserRecord user,
      required String unsubscribeUrl,
    }) generateMessage,
  }) async {
    // Get reference to the space which is used in the email
    final communityDoc =
        await firestore.collection('community').document(communityId).get();
    final community = Community.fromJson(
      firestoreUtils.fromFirestoreJson(communityDoc.data.toMap()),
    );

    // Get participant ids which are in this event
    final eventParticipantsSnapshots = await firestore
        .collection('community')
        .document(communityId)
        .collection('templates')
        .document(template.id)
        .collection('events')
        .document(event.id)
        .collection('event-participants')
        .get();
    final eventParticipants = eventParticipantsSnapshots.documents.map(
      (e) => Participant.fromJson(
        firestoreUtils.fromFirestoreJson(e.data.toMap()),
      ),
    );

    final eventParticipantIds = eventParticipants
        // Only send messages to those that are active in the event
        .where((element) => element.status == ParticipantStatus.active)
        // Only get IDs of participants
        .map((e) => e.id)
        .toList();

    // Get email addresses from these participants. Some of them might not have an email
    // therefore ignore them.
    final users = await firestoreUtils.getUsers(eventParticipantIds);
    final usersWithoutEmail =
        users.where((u) => isNullOrEmpty(u.email)).toList();
    if (usersWithoutEmail.isNotEmpty) {
      print('Some users do not have an email: $usersWithoutEmail');
    }

    final emails = users
        .where((u) => !isNullOrEmpty(u.email))
        .map(
          (user) => SendGridEmail(
            to: [user.email],
            from: '${community.name} <$noReplyEmailAddr>',
            message: generateMessage(
              community: community,
              user: user,
              unsubscribeUrl: getUnsubscribeUrl(userId: user.uid),
            ),
          ),
        )
        .toList();

    print('Sending event message email to: ${emails.map((e) => e.to)}');

    await sendEmailClient.sendEmails(emails);
  }

  Future<void> sendEventEndedEmail({
    required String communityId,
    required Event event,
    required EventEmailType emailType,
    required List<String> userIds,
    required SendGridEmailMessage Function(
      Community community,
      admin_interop.UserRecord user,
    ) generateMessage,
  }) async {
    // Get reference to the space which is used in the email
    final communityDoc =
        await firestore.collection('community').document(communityId).get();
    final community = Community.fromJson(
      firestoreUtils.fromFirestoreJson(communityDoc.data.toMap()),
    );

    final emailLogsCollection = firestore.collection(
      'community/${event.communityId}/templates/${event.templateId}/events/${event.id}/email-logs',
    );
    final emailLogsQuery = await emailLogsCollection.get();
    final emailLogs = emailLogsQuery.documents.map(
      (d) => EventEmailLog.fromJson(
        firestoreUtils.fromFirestoreJson(d.data.toMap()),
      ),
    );

    // Making sure we don't send more than one email. If email log already exists - we remove
    // user from the list of users whom email should be sent to.
    for (final log in emailLogs.where(
      (logEntry) =>
          logEntry.eventEmailType == emailType && logEntry.sendId == event.id,
    )) {
      userIds.remove(log.userId);
    }

    if (userIds.isEmpty) return;
    final lookedUpUsers = await firestoreUtils.getUsers(userIds.toList());
    print('Looked up users: ${lookedUpUsers.map((e) => e.uid).toList()}');
    if (lookedUpUsers.isEmpty) {
      print('No looked up users found.');
      return;
    }

    // Send out emails
    for (final user in lookedUpUsers) {
      if (isNullOrEmpty(user.email)) continue;
      print('Sending $emailType email to user: ${user.uid}');
      await sendEmailClient.sendEmail(
        SendGridEmail(
          to: [user.email],
          from: '${community.name} <$noReplyEmailAddr>',
          message: generateMessage(community, user),
        ),
      );

      // log sent email to avoid resending reminders
      await emailLogsCollection.document().setData(
            DocumentData.fromMap(
              firestoreUtils.toFirestoreJson(
                EventEmailLog(
                  userId: user.uid,
                  eventEmailType: emailType,
                  createdDate: DateTime.now(),
                  sendId: event.id,
                ).toJson(),
              ),
            ),
          );
    }
  }

  String getUnsubscribeUrl({required String userId}) {
    final encrypted = encryptUnsubscribeData(userId: userId);
    final domain = functions.config.get('app.domain') as String;
    return 'https://$domain/emailunsubscribe?data=$encrypted';
  }

  Key get _encryptionKey {
    // changing this key will invalidate previously sent unsubscribe links
    final encryptionKeyInput =
        functions.config.get('app.unsubscribe_encryption_key') as String;
    return Key.fromUtf8(encryptionKeyInput);
  }

  String encryptUnsubscribeData({required String userId}) {
    return SimpleObfuscator().encode(userId);
  }

  UnsubscribeData decryptUnsubscribeData(String data) {
    return UnsubscribeData(SimpleObfuscator().decode(data));
  }
}

class SimpleObfuscator {
  final _secretKey =
      functions.config.get('app.unsubscribe_encryption_key') as String;

  String encode(String input) {
    var output = input.runes.map((int rune) {
      int keyIndex = rune % _secretKey.length;
      int shift = _secretKey.codeUnitAt(keyIndex) % 26;
      return String.fromCharCode(rune + shift);
    }).join();
    return base64Url.encode(output.codeUnits);
  }

  String decode(String encoded) {
    List<int> bytes = base64Url.decode(encoded);
    String input = String.fromCharCodes(bytes);
    var output = input.runes.map((int rune) {
      int keyIndex = rune % _secretKey.length;
      int shift = _secretKey.codeUnitAt(keyIndex) % 26;
      return String.fromCharCode(rune - shift);
    }).join();
    return output;
  }
}
