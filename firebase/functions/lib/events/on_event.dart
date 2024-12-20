import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart'
    hide EventType;
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../utils/infra/firestore_event_function.dart';
import '../utils/infra/on_firestore_helper.dart';
import 'live_meetings/breakouts/check_hostless_go_to_breakouts.dart';
import '../on_firestore_function.dart';
import 'notifications/event_emails.dart';
import '../utils/infra/firestore_utils.dart';
import 'package:data_models/firestore/event.dart';
import 'package:data_models/firestore/community.dart';

class OnEvent extends OnFirestoreFunction<Event> {
  EventEmails eventEmails;
  OnEvent({EventEmails? eventEmails})
      : eventEmails = eventEmails ?? EventEmails(),
        super(
          [
            AppFirestoreFunctionData(
              'EventOnUpdate',
              FirestoreEventType.onUpdate,
            ),
            AppFirestoreFunctionData(
              'EventOnCreate',
              FirestoreEventType.onCreate,
            ),
          ],
          (snapshot) {
            return Event.fromJson(
              firestoreUtils.fromFirestoreJson(snapshot.data.toMap()),
            ).copyWith(id: snapshot.documentID);
          },
        );

  @override
  String get documentPath =>
      'community/{communityId}/templates/{templateId}/events/{eventId}';

  @override
  Future<void> onUpdate(
    Change<DocumentSnapshot> changes,
    Event before,
    Event after,
    DateTime updateTime,
    EventContext context,
  ) async {
    print("Staring onupdate for ${before.fullPath}");
    if (before.status == EventStatus.canceled) {
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
    Event before,
    Event after,
    DateTime updateTime,
    EventContext context,
  ) async {
    EventEmailType? emailType;
    if (before.status != EventStatus.canceled &&
        after.status == EventStatus.canceled) {
      emailType = EventEmailType.canceled;
    } else if (before.scheduledTime != after.scheduledTime) {
      emailType = EventEmailType.updated;
    }

    if (emailType == null) return;

    final community = await firestoreUtils.getFirestoreObject(
      path: '/community/${after.communityId}',
      constructor: (map) => Community.fromJson(map),
    );

    // Don't send create notifications if they are turned off in the event settings
    if (!(after.eventSettings?.reminderEmails ??
        community.eventSettingsMigration.reminderEmails ??
        true)) {
      return;
    }

    if (emailType == EventEmailType.updated) {
      // Note: Old reminders in the task queue will still
      // fire and should not send emails if it is not within a thirty minute
      // buffer of expected email reminder time. But they are a waste as they
      // do not do anything and are a potential cause for bugs.
      await eventEmails.enqueueReminders(after);
    }
  }

  Future<void> _checkHostlessUpdates(
    Event before,
    Event after,
    DateTime updateTime,
    EventContext context,
  ) async {
    print("Checking hostless updates");
    print(before);
    print(after);
    final eventTypeChanged = before.eventType != after.eventType;
    final now = DateTime.now();
    final waitingRoomFinishedTimeChanged =
        before.timeUntilWaitingRoomFinished(now) !=
            after.timeUntilWaitingRoomFinished(now);
    print('Finished time change: $waitingRoomFinishedTimeChanged');
    if (after.eventType == EventType.hostless &&
        (eventTypeChanged || waitingRoomFinishedTimeChanged)) {
      await CheckHostlessGoToBreakouts().enqueueScheduledCheck(after);
    }
  }

  @override
  Future<void> onCreate(
    DocumentSnapshot documentSnapshot,
    Event parsedData,
    DateTime updateTime,
    EventContext context,
  ) async {
    print('Event (${documentSnapshot.documentID}) has been created');

    final communityId = context.params[FirestoreHelper.kCommunityId];
    if (communityId == null) {
      throw ArgumentError.notNull('communityId');
    }

    await onboardingStepsHelper.updateOnboardingSteps(
      communityId,
      documentSnapshot,
      firestoreHelper,
      OnboardingStep.hostEvent,
    );
  }

  @override
  Future<void> onDelete(
    DocumentSnapshot documentSnapshot,
    Event parsedData,
    DateTime updateTime,
    EventContext context,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<void> onWrite(
    Change<DocumentSnapshot> changes,
    Event before,
    Event after,
    DateTime updateTime,
    EventContext context,
  ) {
    throw UnimplementedError();
  }
}
