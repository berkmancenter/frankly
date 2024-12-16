import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:junto_functions/functions/firestore_event_function.dart';
import 'package:junto_functions/functions/firestore_helper.dart';
import 'package:junto_functions/functions/on_call/check_hostless_go_to_breakouts.dart';
import 'package:junto_functions/functions/on_firestore_function.dart';
import 'package:junto_functions/utils/discussion_emails.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/junto.dart';

class OnDiscussion extends OnFirestoreFunction<Discussion> {
  OnDiscussion()
      : super(
          [
            AppFirestoreFunctionData('DiscussionOnUpdate', FirestoreEventType.onUpdate),
            AppFirestoreFunctionData('DiscussionOnCreate', FirestoreEventType.onCreate),
          ],
          (snapshot) {
            return Discussion.fromJson(firestoreUtils.fromFirestoreJson(snapshot.data.toMap())).copyWith(id: snapshot.documentID);
          },
        );

  @override
  String get documentPath => 'junto/{juntoId}/topics/{topicId}/discussions/{discussionId}';

  @override
  Future<void> onUpdate(
    Change<DocumentSnapshot> changes,
    Discussion before,
    Discussion after,
    DateTime updateTime,
    EventContext context,
  ) async {
    print("Staring onupdate for ${before.fullPath}");
    if (before.status == DiscussionStatus.canceled) {
      print('Event was canceled before. Not sending any emails.');
      return;
    }

    final actions = [
      _swallowErrors(
        action: () => _checkHostlessUpdates(before, after, updateTime, context),
        description: 'check hostless update',
      ),
      _swallowErrors(
        action: () => _sendEmailUpdates(before, after, updateTime, context),
        description: 'send email updates',
      ),
    ];

    await Future.wait(actions);
  }

  Future<void> _swallowErrors({
    required Future<void> Function() action,
    required String description,
  }) async {
    try {
      await action();
    } catch (e, stacktrace) {
      print('Error during $description');
      print(e);
      print(stacktrace);
    }
  }

  Future<void> _sendEmailUpdates(
    Discussion before,
    Discussion after,
    DateTime updateTime,
    EventContext context,
  ) async {
    DiscussionEmailType? emailType;
    if (before.status != DiscussionStatus.canceled && after.status == DiscussionStatus.canceled) {
      emailType = DiscussionEmailType.canceled;
    } else if (before.scheduledTime != after.scheduledTime) {
      emailType = DiscussionEmailType.updated;
    }

    if (emailType == null) return;

    final junto = await firestoreUtils.getFirestoreObject(
      path: '/junto/${after.juntoId}',
      constructor: (map) => Junto.fromJson(map),
    );

    // Don't send create notifications if they are turned off in the discussion settings
    if (!(after.discussionSettings?.reminderEmails ??
        junto.discussionSettingsMigration.reminderEmails ??
        true)) {
      return;
    }

    // Sending update emails to users
    if (after.juntoId == 'meetingofamerica' ||
        after.juntoId == 'america-talks' ||
        after.juntoId == 'CWPWy0JEovERcH1roZ4F') {
      print('Not sending email updates on change for meeting of america. Returning');
    } else {
      await discussionEmails.sendEmailsToUsers(
        discussionPath: 'junto/${after.juntoId}/topics/${after.topicId}/discussions/${after.id}',
        emailType: emailType,
        sendId: emailType == DiscussionEmailType.updated ? context.eventId : null,
      );
    }

    if (emailType == DiscussionEmailType.updated) {
      // Note: Old reminders in the task queue will still
      // fire and should not send emails if it is not within a thirty minute
      // buffer of expected email reminder time. But they are a waste as they
      // do not do anything and are a potential cause for bugs.
      await discussionEmails.enqueueReminders(after);
    }
  }

  Future<void> _checkHostlessUpdates(
      Discussion before, Discussion after, DateTime updateTime, EventContext context) async {
    print("Checking hostless updates");
    print(before);
    print(after);
    final discussionTypeChanged = before.discussionType != after.discussionType;
    final now = DateTime.now();
    final waitingRoomFinishedTimeChanged =
        before.timeUntilWaitingRoomFinished(now) != after.timeUntilWaitingRoomFinished(now);
    print('Finished time change: $waitingRoomFinishedTimeChanged');
    if (after.discussionType == DiscussionType.hostless &&
        (discussionTypeChanged || waitingRoomFinishedTimeChanged)) {
      await CheckHostlessGoToBreakouts().enqueueScheduledCheck(after);
    }
  }

  @override
  Future<void> onCreate(
    DocumentSnapshot documentSnapshot,
    Discussion parsedData,
    DateTime updateTime,
    EventContext context,
  ) async {
    print('Discussion (${documentSnapshot.documentID}) has been created');

    final juntoId = context.params[FirestoreHelper.kJuntoId];
    if (juntoId == null) {
      throw ArgumentError.notNull('juntoId');
    }

    await onboardingStepsHelper.updateOnboardingSteps(
      juntoId,
      documentSnapshot,
      firestoreHelper,
      OnboardingStep.hostConversation,
    );
  }

  @override
  Future<void> onDelete(
    DocumentSnapshot documentSnapshot,
    Discussion parsedData,
    DateTime updateTime,
    EventContext context,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<void> onWrite(
    Change<DocumentSnapshot> changes,
    Discussion before,
    Discussion after,
    DateTime updateTime,
    EventContext context,
  ) {
    throw UnimplementedError();
  }
}
