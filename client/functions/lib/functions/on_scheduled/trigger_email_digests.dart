import 'dart:async';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart' as admin;
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/junto_cloud_function.dart';
import 'package:junto_functions/utils/email_templates.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_functions/utils/notifications_utils.dart';
import 'package:junto_functions/utils/send_email_client.dart';
import 'package:junto_functions/utils/utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/email_digest_record.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:junto_models/firestore/junto_user_settings.dart';
import 'package:junto_models/firestore/membership.dart';
import 'package:junto_models/firestore/topic.dart';

import '../../utils/topic_utils.dart';

class DiscussionWithTopic {
  final Discussion discussion;
  final Topic topic;

  const DiscussionWithTopic(this.discussion, this.topic);
}

class JuntoWithDiscussions {
  final Junto junto;
  final List<DiscussionWithTopic> discussions;

  const JuntoWithDiscussions(this.junto, this.discussions);
}

class TriggerEmailDigests extends JuntoCloudFunction {
  @override
  final String functionName = 'TriggerEmailDigests';

  FutureOr<void> _action(EventContext context) async {
    // discussions are included that fall between 'now' and 'endTime'
    // digest is discarded if one was already sent after 'prevCutoffTime'
    final now = DateTime.now();
    final endTime = now.add(const Duration(days: 30));
    final prevCutoffTime = now.subtract(const Duration(days: 6, hours: 12));

    print('Getting email digests');
    final discussionsListFiltered = await _getUpcomingDiscussions(now, endTime);

    print(
        'Generating emails for juntos: ${discussionsListFiltered.map((d) => '${d.junto.id}: ${d.discussions.length} discussions').toList()}');
    final emails = await _generateAllUserEmails(
        discussionsListFiltered, now, prevCutoffTime);
    print('Sending ${emails.length} emails.');

    await sendEmailClient.sendEmails(emails);
  }

  /// Get list of upcoming discussions for juntos that have digest emails
  /// enabled.
  Future<Iterable<JuntoWithDiscussions>> _getUpcomingDiscussions(
      DateTime now, DateTime endTime) async {
    final topicLookups = <String, Future<DocumentSnapshot>>{};
    final juntoDocs = await firestore.collection('/junto').get();
    final juntos = juntoDocs.documents
        .map((e) => Junto.fromJson(firestoreUtils.fromFirestoreJson(e.data.toMap())));
    final filteredJuntos = juntos.where((junto) => !junto.settingsMigration.disableEmailDigests);
    final discussionsList = await Future.wait(filteredJuntos.map((junto) async {
      final discussionDocs = await firestore
          .collectionGroup('discussions')
          .where(Discussion.kFieldJuntoId, isEqualTo: junto.id)
          .where(Discussion.kFieldScheduledTime, isGreaterThan: now)
          .where(Discussion.kFieldScheduledTime, isLessThanOrEqualTo: endTime)
          .where(Discussion.kFieldStatus,
              isEqualTo: EnumToString.convertToString(DiscussionStatus.active))
          .where(Discussion.kFieldIsPublic, isEqualTo: true)
          .orderBy(Discussion.kFieldScheduledTime, descending: false)
          .limit(10) // keep emails of reasonable length
          .get();
      final discussions = await Future.wait(discussionDocs.documents
          .map((e) => Discussion.fromJson(firestoreUtils.fromFirestoreJson(e.data.toMap())))
          .map((e) async {
        final topicPath = 'junto/${junto.id}/topics/${e.topicId}';
        final topicDoc = await (topicLookups[topicPath] ??=
            firestore.document(topicPath).get());
        final topic = TopicUtils.topicFromSnapshot(topicDoc);
        return DiscussionWithTopic(e, topic);
      }));
      return JuntoWithDiscussions(junto, discussions);
    }));
    return discussionsList.where((e) => e.discussions.isNotEmpty);
  }

  /// Returns all user email digest emails that should be sent. Stores digest
  /// records in firestore.
  Future<List<SendGridEmail>> _generateAllUserEmails(
      Iterable<JuntoWithDiscussions> discussionsListFiltered,
      DateTime now,
      DateTime prevCutoffTime) async {
    final emails = <SendGridEmail>[];
    final userLookups = <String, Future<List<admin.UserRecord>>>{};
    // loop over juntos
    await Future.wait(discussionsListFiltered.map((juntoWithDiscussions) async {
      // loop over members of this junto
      final membershipDocs = await firestore
          .collectionGroup('junto-membership')
          .where(Membership.kFieldJuntoId,
              isEqualTo: juntoWithDiscussions.junto.id)
          .whereNotEqual(
            Membership.kFieldStatus,
            notEqualTo:
                EnumToString.convertToString(MembershipStatus.nonmember),
          )
          .get();
      await Future.wait(membershipDocs.documents
          .map((d) => _parseMembership(d))
          .withoutNulls
          .where((m) => m.isMember)
          .map((membership) async {
        try {
          final List<admin.UserRecord> user =
              await (userLookups[membership.userId] ??=
                  firestoreUtils.getUsers([membership.userId]));
          if (user.isEmpty || isNullOrEmpty(user[0].email)) {
            print('Email not found for user: ${membership.userId}');
            return;
          }

          final email = await _generateEmailForMembership(
            user[0],
            membership,
            juntoWithDiscussions,
            now,
            prevCutoffTime,
          );
          if (email != null) {
            emails.add(email);
          } else {
            print('Email null for $membership.userId');
          }
        } catch (e) {
          print('Error for user ${membership.userId}: ${e.toString()}');
        }
      }));
    }));

    return emails;
  }

  Membership? _parseMembership(DocumentSnapshot document) {
    final json = document.data.toMap();
    try {
      return Membership.fromJson(firestoreUtils.fromFirestoreJson(json));
    } catch (error) {
      print(
          'Failed to parse membership: $json at doc ${document.reference.path}');
    }
  }

  /// Returns a digest email for specified user's membership, or null if they
  /// shouldn't get one. Stores digest record in firestore.
  Future<SendGridEmail?> _generateEmailForMembership(
      admin.UserRecord user,
      Membership membership,
      JuntoWithDiscussions juntoWithDiscussions,
      DateTime now,
      DateTime prevCutoffTime) async {
    final junto = juntoWithDiscussions.junto;
    final discussions = juntoWithDiscussions.discussions;

    final userId = user.uid;
    final emailAddress = user.email;

    // make sure user is subscribed to event updates
    final settingsDoc = await firestore
        .document(
            '/privateUserData/$userId/juntoUserSettings/${membership.juntoId}')
        .get();
    final settings =
        JuntoUserSettings.fromJson(firestoreUtils.fromFirestoreJson(settingsDoc.data.toMap()));
    if (settings.notifyEvents != null && settings.notifyEvents == NotificationEmailType.none) {
      return null;
    }

    // make sure we haven't already sent a digest during this time period
    final digestsCollection =
        firestore.collection('/privateUserData/$userId/emailDigests');
    final previouslySentDocs = await digestsCollection
        .where(EmailDigestRecord.kFieldJuntoId, isEqualTo: membership.juntoId)
        .where(EmailDigestRecord.kFieldSentAt,
            isGreaterThanOrEqualTo: prevCutoffTime)
        .where(
          EmailDigestRecord.kFieldType,
          isEqualTo: EnumToString.convertToString(DigestType.weekly),
        )
        .limit(1)
        .get();
    if (previouslySentDocs.documents.isNotEmpty) {
      print(
          'Not sending digest email for user that already had one recently $userId');
      return null;
    }

    // create and save a record of having produced this digest
    final digestRecord = EmailDigestRecord(
        userId: userId,
        juntoId: membership.juntoId,
        type: DigestType.weekly,
        sentAt: now);
    final digestRecordDoc = digestsCollection.document();
    final digestRecordData =
        DocumentData.fromMap(firestoreUtils.toFirestoreJson(digestRecord.toJson()));
    await digestRecordDoc.setData(digestRecordData);

    // return actual email contents
    final noReplyEmailAddr =
        functions.config.get('app.no_reply_email') as String;
    return SendGridEmail(
      to: [emailAddress],
      from: '${junto.name} <$noReplyEmailAddr>',
      message: SendGridEmailMessage(
        subject:
            'Upcoming Events for ${junto.name} (${now.month}/${now.day}/${now.year})',
        html: makeDiscussionDigestBody(
          junto: junto,
          discussions: discussions,
          unsubscribeUrl: notificationsUtils.getUnsubscribeUrl(
            userId: userId,
          ),
        ),
      ),
    );
  }

  @override
  void register(FirebaseFunctions functions) {
    functions[functionName] = functions
        .runWith(RuntimeOptions(
            timeoutSeconds: 240, memory: '4GB', minInstances: 0))
        .pubsub
        .schedule('every tuesday 17:00') // Tuesday 8pm EST, converted to PST
        .onRun((_, context) => _action(context));
  }
}
