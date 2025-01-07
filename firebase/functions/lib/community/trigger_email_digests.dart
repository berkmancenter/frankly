import 'dart:async';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart' as admin;
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart'
    hide CloudFunction;
import '../cloud_function.dart';
import '../utils/email_templates.dart';
import '../utils/infra/firestore_utils.dart';
import '../utils/notifications_utils.dart';
import '../utils/send_email_client.dart';
import '../utils/utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/community/email_digest_record.dart';
import 'package:data_models/community/community.dart';
import 'package:data_models/community/community_user_settings.dart';
import 'package:data_models/community/membership.dart';

import '../utils/template_utils.dart';

class CommunityWithEvents {
  final Community community;
  final List<EventWithTemplate> events;

  const CommunityWithEvents(this.community, this.events);
}

class TriggerEmailDigests extends CloudFunction {
  @override
  final String functionName = 'TriggerEmailDigests';
  NotificationsUtils notificationsUtils;

  TriggerEmailDigests({NotificationsUtils? notificationsUtils})
      : notificationsUtils = notificationsUtils ?? NotificationsUtils();

  FutureOr<void> _action(EventContext context) async {
    // events are included that fall between 'now' and 'endTime'
    // digest is discarded if one was already sent after 'prevCutoffTime'
    final now = DateTime.now();
    final endTime = now.add(const Duration(days: 30));
    final prevCutoffTime = now.subtract(const Duration(days: 6, hours: 12));

    print('Getting email digests');
    final eventsListFiltered = await _getUpcomingEvents(now, endTime);

    print(
      'Generating emails for communities: ${eventsListFiltered.map((d) => '${d.community.id}: ${d.events.length} events').toList()}',
    );
    final emails = await _generateAllUserEmails(
      eventsListFiltered,
      now,
      prevCutoffTime,
    );
    print('Sending ${emails.length} emails.');

    await sendEmailClient.sendEmails(emails);
  }

  /// Get list of upcoming events for communities that have digest emails
  /// enabled.
  Future<Iterable<CommunityWithEvents>> _getUpcomingEvents(
    DateTime now,
    DateTime endTime,
  ) async {
    final templateLookups = <String, Future<DocumentSnapshot>>{};
    final communityDocs = await firestore.collection('/community').get();
    final communities = communityDocs.documents.map(
      (e) =>
          Community.fromJson(firestoreUtils.fromFirestoreJson(e.data.toMap())),
    );
    final filteredCommunities = communities
        .where((community) => !community.settingsMigration.disableEmailDigests);
    final eventsList = await Future.wait(
      filteredCommunities.map((community) async {
        final eventDocs = await firestore
            .collectionGroup('events')
            .where(Event.kFieldCommunityId, isEqualTo: community.id)
            .where(Event.kFieldScheduledTime, isGreaterThan: now)
            .where(Event.kFieldScheduledTime, isLessThanOrEqualTo: endTime)
            .where(
              Event.kFieldStatus,
              isEqualTo: EnumToString.convertToString(EventStatus.active),
            )
            .where(Event.kFieldIsPublic, isEqualTo: true)
            .orderBy(Event.kFieldScheduledTime, descending: false)
            .limit(10) // keep emails of reasonable length
            .get();
        final events = await Future.wait(
          eventDocs.documents
              .map(
            (e) => Event.fromJson(
              firestoreUtils.fromFirestoreJson(e.data.toMap()),
            ),
          )
              .map((e) async {
            final templatePath =
                'community/${community.id}/templates/${e.templateId}';
            final templateDoc = await (templateLookups[templatePath] ??=
                firestore.document(templatePath).get());
            final template = TemplateUtils.templateFromSnapshot(templateDoc);
            return EventWithTemplate(e, template);
          }),
        );
        return CommunityWithEvents(community, events);
      }),
    );
    return eventsList.where((e) => e.events.isNotEmpty);
  }

  /// Returns all user email digest emails that should be sent. Stores digest
  /// records in firestore.
  Future<List<SendGridEmail>> _generateAllUserEmails(
    Iterable<CommunityWithEvents> eventsListFiltered,
    DateTime now,
    DateTime prevCutoffTime,
  ) async {
    final emails = <SendGridEmail>[];
    final userLookups = <String, Future<List<admin.UserRecord>>>{};
    // loop over communities
    await Future.wait(
      eventsListFiltered.map((communityWithEvents) async {
        // loop over members of this community
        final membershipDocs = await firestore
            .collectionGroup('community-membership')
            .where(
              Membership.kFieldCommunityId,
              isEqualTo: communityWithEvents.community.id,
            )
            .whereNotEqual(
              Membership.kFieldStatus,
              notEqualTo:
                  EnumToString.convertToString(MembershipStatus.nonmember),
            )
            .get();
        await Future.wait(
          membershipDocs.documents
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
                communityWithEvents,
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
          }),
        );
      }),
    );

    return emails;
  }

  Membership? _parseMembership(DocumentSnapshot document) {
    final json = document.data.toMap();
    try {
      return Membership.fromJson(firestoreUtils.fromFirestoreJson(json));
    } catch (error) {
      print(
        'Failed to parse membership: $json at doc ${document.reference.path}',
      );
    }
    return null;
  }

  /// Returns a digest email for specified user's membership, or null if they
  /// shouldn't get one. Stores digest record in firestore.
  Future<SendGridEmail?> _generateEmailForMembership(
    admin.UserRecord user,
    Membership membership,
    CommunityWithEvents communityWithEvents,
    DateTime now,
    DateTime prevCutoffTime,
  ) async {
    final community = communityWithEvents.community;
    final events = communityWithEvents.events;

    final userId = user.uid;
    final emailAddress = user.email;

    // make sure user is subscribed to event updates
    final settingsDoc = await firestore
        .document(
          '/privateUserData/$userId/communityUserSettings/${membership.communityId}',
        )
        .get();
    final settings = CommunityUserSettings.fromJson(
      firestoreUtils.fromFirestoreJson(settingsDoc.data.toMap()),
    );
    if (settings.notifyEvents != null &&
        settings.notifyEvents == NotificationEmailType.none) {
      return null;
    }

    // make sure we haven't already sent a digest during this time period
    final digestsCollection =
        firestore.collection('/privateUserData/$userId/emailDigests');
    final previouslySentDocs = await digestsCollection
        .where(
          EmailDigestRecord.kFieldCommunityId,
          isEqualTo: membership.communityId,
        )
        .where(
          EmailDigestRecord.kFieldSentAt,
          isGreaterThanOrEqualTo: prevCutoffTime,
        )
        .where(
          EmailDigestRecord.kFieldType,
          isEqualTo: EnumToString.convertToString(DigestType.weekly),
        )
        .limit(1)
        .get();
    if (previouslySentDocs.documents.isNotEmpty) {
      print(
        'Not sending digest email for user that already had one recently $userId',
      );
      return null;
    }

    // create and save a record of having produced this digest
    final digestRecord = EmailDigestRecord(
      userId: userId,
      communityId: membership.communityId,
      type: DigestType.weekly,
      sentAt: now,
    );
    final digestRecordDoc = digestsCollection.document();
    final digestRecordData = DocumentData.fromMap(
      firestoreUtils.toFirestoreJson(digestRecord.toJson()),
    );
    await digestRecordDoc.setData(digestRecordData);

    // return actual email contents
    final noReplyEmailAddr =
        functions.config.get('app.no_reply_email') as String;
    return SendGridEmail(
      to: [emailAddress],
      from: '${community.name} <$noReplyEmailAddr>',
      message: SendGridEmailMessage(
        subject:
            'Upcoming Events for ${community.name} (${now.month}/${now.day}/${now.year})',
        html: makeEventDigestBody(
          community: community,
          events: events,
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
        .runWith(
          RuntimeOptions(timeoutSeconds: 240, memory: '4GB', minInstances: 0),
        )
        .pubsub
        .schedule('every tuesday 17:00') // Tuesday 8pm EST, converted to PST
        .onRun((_, context) => _action(context));
  }
}
