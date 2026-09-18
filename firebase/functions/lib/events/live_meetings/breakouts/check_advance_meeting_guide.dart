import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import '../../../utils/infra/firestore_utils.dart';
import '../../../utils/utils.dart';
import 'advance_meeting_guide_after_delay_server.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:data_models/events/live_meetings/meeting_guide.dart';
import 'package:data_models/utils/utils.dart';

/// Result of checking whether enough participants are ready to advance past the current
/// agenda item. See [CheckAdvanceMeetingGuide._checkAdvanceMeetingGuide].
class AdvanceCheckResult {
  /// True if an advance is already pending (or was just scheduled) for the current agenda
  /// item, meaning any ready vote from here on can no longer change the outcome.
  final bool isPendingOrAdvancing;

  // True if this is the last agenda item that was voted to advance, in which case the scheduled countdown will be skipped
  final bool isLastAgendaItem;

  /// Non-null only when this call is the one that just crossed the ready threshold, meaning
  /// the caller is responsible for actually triggering the advance.
  final String? newlyPendingAgendaItemId;

  /// The time the advance should be triggered at. Set whenever [newlyPendingAgendaItemId] is.
  final DateTime? pendingAdvanceTime;

  AdvanceCheckResult({
    required this.isPendingOrAdvancing,
    required this.isLastAgendaItem,
    this.newlyPendingAgendaItemId,
    this.pendingAdvanceTime,
  });
}

/// Evaluates whether a breakout should advance past its current agenda item
/// once a ready vote has been recorded, and schedules or cancels the advance.
///
/// Clients write ready votes directly to their participant-details doc, and
/// [OnParticipantAgendaItemDetails] reacts by calling [evaluateAndScheduleAdvance].
class CheckAdvanceMeetingGuide {
  static const _advanceDelay = Duration(seconds: 8);

  /// Evaluates whether the current agenda item should advance now that a ready
  /// vote has been recorded, and schedules or cancels the advance accordingly.
  ///
  /// Invoked by the participant-details onWrite trigger. Assumes the vote has
  /// already been written to the details collection.
  Future<void> evaluateAndScheduleAdvance({
    required Event event,
    required String eventPath,
    required String? breakoutSessionId,
    required String? breakoutRoomId,
  }) async {
    final isBreakout = !isNullOrEmpty(breakoutRoomId);

    final liveMeetingPath = '$eventPath/live-meetings/${event.id}';
    final breakoutRoomPath =
        '$liveMeetingPath/breakout-room-sessions/$breakoutSessionId'
        '/breakout-rooms/$breakoutRoomId';
    final breakoutLiveMeetingPath =
        '$breakoutRoomPath/live-meetings/$breakoutRoomId';
    final activeLiveMeetingPath =
        isBreakout ? breakoutLiveMeetingPath : liveMeetingPath;
    final parentLiveMeetingPath = isBreakout ? liveMeetingPath : null;

    String? diffusionStatement;
    if (isBreakout) {
      final breakoutRoom = await firestoreUtils.getFirestoreObject(
        path: breakoutRoomPath,
        constructor: (map) => BreakoutRoom.fromJson(map),
      );
      diffusionStatement = breakoutRoom.diffusionStatement;
    }

    try {
      final checkResult = await _checkAdvanceMeetingGuide(
        liveMeetingPath: activeLiveMeetingPath,
        parentLiveMeetingPath: parentLiveMeetingPath,
        isBreakout: isBreakout,
        eventPath: eventPath,
        breakoutRoomId: breakoutRoomId,
        event: event,
        diffusionStatement: diffusionStatement,
      );

      // If this is the last item, we can move on immediately
      if (checkResult.isLastAgendaItem) {
        print('Last agenda item reached. Advancing immediately.');
        await advanceMeetingGuide(
          event: event,
          liveMeetingPath: activeLiveMeetingPath,
          diffusionStatement: diffusionStatement,
          currentAgendaItemId: checkResult.newlyPendingAgendaItemId!,
          parentLiveMeetingPath: parentLiveMeetingPath,
        );
        return;
      }

      final newlyPendingAgendaItemId = checkResult.newlyPendingAgendaItemId;
      if (newlyPendingAgendaItemId != null) {
        // We just crossed the ready threshold, so we're responsible for actually
        // triggering the advance once the delay elapses.
        final advanceRequest = AdvanceMeetingGuideAfterDelayRequest(
          eventPath: eventPath,
          breakoutSessionId: breakoutSessionId,
          breakoutRoomId: breakoutRoomId,
          agendaItemId: newlyPendingAgendaItemId,
        );

        await AdvanceMeetingGuideAfterDelayServer().schedule(
          advanceRequest,
          checkResult.pendingAdvanceTime!,
        );
      }

      if (checkResult.isPendingOrAdvancing) {
        // A countdown to advance is already running (or was just started) for the current agenda
        // item. Once that starts, further ready votes can no longer change the outcome.
        print('Advance is pending.');
        return;
      }
    } catch (e) {
      print('Error checking advance: $e');
      rethrow;
    }
  }

  /// Checks whether enough participants are ready to advance past the current agenda item.
  ///
  /// [AdvanceCheckResult.isPendingOrAdvancing] is true if an advance is already pending (or was
  /// just scheduled) for the current agenda item, meaning any ready vote from here on can no
  /// longer change the outcome. [AdvanceCheckResult.newlyPendingAgendaItemId] is non-null only
  /// when this call is the one that just crossed the ready threshold, meaning the caller is
  /// responsible for actually triggering the advance. [AdvanceCheckResult.isLastAgendaItem] is true
  /// if this is the last agenda item that was voted to advance, in which case the scheduled countdown will be skipped.
  Future<AdvanceCheckResult> _checkAdvanceMeetingGuide({
    required bool isBreakout,
    required String liveMeetingPath,
    required String? parentLiveMeetingPath,
    required String eventPath,
    required String? breakoutRoomId,
    required Event event,
    required String? diffusionStatement,
  }) async {
    final liveMeeting = await firestoreUtils.getFirestoreObject(
      path: liveMeetingPath,
      constructor: (map) => LiveMeeting.fromJson(map),
    );

    if (!isBreakout) {
      print('Only breakouts are currently hostless');
      return AdvanceCheckResult(
        isPendingOrAdvancing: false,
        isLastAgendaItem: false,
      );
    }
    if (liveMeeting.events
        .any((e) => e.event == LiveMeetingEventType.finishMeeting)) {
      print('Meeting already finished. Not checking advanced');
      return AdvanceCheckResult(
        isPendingOrAdvancing: false,
        isLastAgendaItem: false,
      );
    }
    print('Checking advance for event: $eventPath, '
        'live meeting: $liveMeetingPath');

    final currentAgendaItemId = _getCurrentAgendaItemId(event, liveMeeting);
    print('current agenda item: $currentAgendaItemId');

    // Read server-side Participant.isPresent (our authoritative presence state)
    DocumentQuery participantsQuery =
        firestore.collection('$eventPath/event-participants');
    if (isBreakout) {
      participantsQuery = participantsQuery.where(
        Participant.kFieldCurrentBreakoutRoomId,
        isEqualTo: breakoutRoomId,
      );
    }
    final participantsSnapshot = await participantsQuery.get();

    final presentParticipants = participantsSnapshot.documents
        .map(
          (doc) => Participant.fromJson(
            firestoreUtils.fromFirestoreJson(doc.data.toMap()),
          ),
        )
        .where(
          (participant) =>
              participant.status == ParticipantStatus.active &&
              participant.isPresent,
        )
        .toList();
    final presentParticipantIds = presentParticipants.map((p) => p.id).toSet();

    // Determine who has said they are ready for this agenda item to be over
    final agendaItemParticipantDetailsPath =
        '$liveMeetingPath/participant-agenda-item-details/'
        '$currentAgendaItemId/participant-details';
    final agendaItemParticipantDetailsDocs =
        await firestore.collection(agendaItemParticipantDetailsPath).get();

    final readyToMoveOnIds = _readyPresentParticipantIds(
      agendaItemParticipantDetailsDocs,
      presentParticipantIds,
    );

    print('ready to move on: $readyToMoveOnIds');
    print('present: $presentParticipantIds');
    final threshold = readyToAdvanceThreshold(presentParticipantIds.length);
    final belowThreshold = readyToMoveOnIds.length < threshold;

    if (liveMeeting.pendingAdvanceAgendaItemId == currentAgendaItemId) {
      // Advance is already scheduled for this item. New ready votes don't
      // change the outcome, but an undo during the delay cancels the advance.
      if (belowThreshold) {
        print('Ready count is below threshold ($threshold). Cancelling '
            'pending advance for $currentAgendaItemId.');
        final cancelled = await _clearPendingAdvance(
          liveMeetingPath,
          currentAgendaItemId,
          presentParticipantIds: presentParticipantIds,
          threshold: threshold,
        );
        return AdvanceCheckResult(
          isPendingOrAdvancing: !cancelled,
          isLastAgendaItem: false,
        );
      }
      print('Advance is already pending for $currentAgendaItemId');
      return AdvanceCheckResult(
        isPendingOrAdvancing: true,
        isLastAgendaItem: false,
      );
    }

    if (belowThreshold) {
      print(
        'Not enough participants ready to advance. Threshold: $threshold, ready: ${readyToMoveOnIds.length}',
      );
      return AdvanceCheckResult(
        isPendingOrAdvancing: false,
        isLastAgendaItem: false,
      );
    }

    print('$threshold required to advance. Scheduling advance in '
        '${_advanceDelay.inSeconds}s.');

    final pendingAdvanceTime = DateTime.now().toUtc().add(_advanceDelay);

    // Write the pending advance in a transaction so that two participants crossing the
    // threshold at nearly the same time don't each schedule their own advance.
    final alreadyPending = await firestore.runTransaction((transaction) async {
      final latestLiveMeeting = await firestoreUtils.getFirestoreObject(
        path: liveMeetingPath,
        constructor: (map) => LiveMeeting.fromJson(map),
        transaction: transaction,
      );

      if (latestLiveMeeting.pendingAdvanceAgendaItemId == currentAgendaItemId) {
        return true;
      }

      transaction.set(
        firestore.document(liveMeetingPath),
        DocumentData.fromMap(
          jsonSubset(
            [
              LiveMeeting.kFieldPendingAdvanceAgendaItemId,
              LiveMeeting.kFieldPendingAdvanceTime,
            ],
            firestoreUtils.toFirestoreJson(
              LiveMeeting(
                pendingAdvanceAgendaItemId: currentAgendaItemId,
                pendingAdvanceTime: pendingAdvanceTime,
              ).toJson(),
            ),
          ),
        ),
        merge: true,
      );

      return false;
    });

    if (alreadyPending) {
      return AdvanceCheckResult(
        isPendingOrAdvancing: true,
        isLastAgendaItem: false,
      );
    }

    // We're the one who just wrote the pending state, so the caller is responsible for
    // actually triggering the advance after the delay.
    return AdvanceCheckResult(
      isPendingOrAdvancing: true,
      // Use the resolved agenda (same as advanceMeetingGuide's navigation) so we
      // don't use timers for last-items even when they are `{diffusionStatement}`
      // and skipped and in prod. Last resolved item should finish immediately
      // on ready.
      isLastAgendaItem: currentAgendaItemId ==
          resolveAgendaItemsForDiffusionStatement(
            event.agendaItems,
            diffusionStatement,
            showUnresolvedAsError: !isProductionEnvironment,
          ).lastOrNull?.id,
      newlyPendingAgendaItemId: currentAgendaItemId,
      pendingAdvanceTime: pendingAdvanceTime,
    );
  }

  /// The present participants (by document id, i.e. the `{userId}` path segment)
  /// who marked themselves ready for this item. Counts by document id rather
  /// than the payload `userId` field so a divergent field can't cause a miscount.
  Set<String> _readyPresentParticipantIds(
    QuerySnapshot detailsDocs,
    Set<String> presentParticipantIds,
  ) {
    return detailsDocs.documents
        .where((doc) {
          final details = ParticipantAgendaItemDetails.fromJson(
            firestoreUtils.fromFirestoreJson(doc.data.toMap()),
          );
          return (details.readyToAdvance ?? false) &&
              presentParticipantIds.contains(doc.documentID);
        })
        .map((doc) => doc.documentID)
        .toSet();
  }

  /// Cancels the scheduled advance for [currentAgendaItemId], returning true if
  /// it cleared the pending state and false if it left it in place.
  ///
  /// Re-reads the votes transactionally against [presentParticipantIds] /
  /// [threshold] and only clears when still below threshold, so a re-ready that
  /// landed after the caller's non-transactional read isn't lost: we either
  /// observe it and keep the advance, or it commits after this clear and its
  /// own trigger reschedules against the cleared state.
  Future<bool> _clearPendingAdvance(
    String liveMeetingPath,
    String currentAgendaItemId, {
    required Set<String> presentParticipantIds,
    required int threshold,
  }) async {
    final agendaItemParticipantDetailsPath =
        '$liveMeetingPath/participant-agenda-item-details/'
        '$currentAgendaItemId/participant-details';
    return firestore.runTransaction((transaction) async {
      final latestLiveMeeting = await firestoreUtils.getFirestoreObject(
        path: liveMeetingPath,
        constructor: (map) => LiveMeeting.fromJson(map),
        transaction: transaction,
      );

      // If the pending advance has already changed, don't clear it.
      if (latestLiveMeeting.pendingAdvanceAgendaItemId != currentAgendaItemId) {
        return false;
      }

      // Re-check the votes transactionally so a concurrent re-ready isn't lost.
      final detailsDocs = await transaction
          .getQuery(firestore.collection(agendaItemParticipantDetailsPath));
      final readyIds =
          _readyPresentParticipantIds(detailsDocs, presentParticipantIds);
      if (readyIds.length >= threshold) {
        print('Ready count recovered to ${readyIds.length} (threshold '
            '$threshold) before the cancel committed. Keeping pending advance '
            'for $currentAgendaItemId.');
        return false;
      }

      transaction.set(
        firestore.document(liveMeetingPath),
        DocumentData.fromMap(
          jsonSubset(
            [
              LiveMeeting.kFieldPendingAdvanceAgendaItemId,
              LiveMeeting.kFieldPendingAdvanceTime,
            ],
            firestoreUtils.toFirestoreJson(
              LiveMeeting(
                pendingAdvanceAgendaItemId: null,
                pendingAdvanceTime: null,
              ).toJson(),
            ),
          ),
        ),
        merge: true,
      );

      return true;
    });
  }

  String _getCurrentAgendaItemId(
    Event event,
    LiveMeeting liveMeeting,
  ) {
    final events = liveMeeting.events
        .where((e) => LiveMeetingEventType.agendaItemStarted == e.event)
        .toList();

    return events.lastOrNull?.agendaItem ?? startMeetingAgendaItemId;
  }

  /// Advances the meeting guide to the next agenda item, clearing any pending advance in the
  /// same write. Called directly for host-controlled advances, and by
  /// [AdvanceMeetingGuideAfterDelay] once a majority-vote countdown finishes.
  Future<void> advanceMeetingGuide({
    required Event event,
    required String liveMeetingPath,
    required String currentAgendaItemId,
    required String? parentLiveMeetingPath,
    required String? diffusionStatement,
  }) async {
    await firestore.runTransaction((transaction) async {
      // Get current live meeting
      final liveMeeting = await firestoreUtils.getFirestoreObject(
        path: liveMeetingPath,
        constructor: (map) => LiveMeeting.fromJson(map),
        transaction: transaction,
      );

      // Ensure the advance is still pending for this item. A cancel due to a
      // decrement clears pendingAdvanceAgendaItemId atomically.
      if (liveMeeting.pendingAdvanceAgendaItemId != currentAgendaItemId) {
        print('Advance for $currentAgendaItemId is no longer pending '
            '(cancelled). Not advancing.');
        return;
      }

      // Ensure current agenda item is still current
      final newCurrentAgendaItemId =
          _getCurrentAgendaItemId(event, liveMeeting);
      if (newCurrentAgendaItemId != currentAgendaItemId) {
        print('$currentAgendaItemId is no longer the current '
            'agenda Item: $newCurrentAgendaItemId');
        return;
      }
      // Determine next agenda item or final
      final agendaItems = resolveAgendaItemsForDiffusionStatement(
        event.agendaItems,
        diffusionStatement,
        showUnresolvedAsError: !isProductionEnvironment,
      );
      final agendaItemIndex =
          agendaItems.indexWhere((a) => a.id == currentAgendaItemId);

      var nextAgendaItem = agendaItemIndex + 1 < agendaItems.length
          ? agendaItems[agendaItemIndex + 1]
          : null;

      // If we are at the start of a breakout room set the next agenda item to
      // match the parent meeting's current agenda item.
      if (currentAgendaItemId == startMeetingAgendaItemId &&
          parentLiveMeetingPath != null) {
        final parentLiveMeeting = await firestoreUtils.getFirestoreObject(
          path: parentLiveMeetingPath,
          constructor: (map) => LiveMeeting.fromJson(map),
        );

        final parentAgendaItemId =
            _getCurrentAgendaItemId(event, parentLiveMeeting);
        final AgendaItem? parentAgendaItem = agendaItems
            .where((item) => item.id == parentAgendaItemId)
            .firstOrNull;
        if (parentAgendaItemId != startMeetingAgendaItemId &&
            parentAgendaItem != null) {
          nextAgendaItem = parentAgendaItem;
        }
      }

      // Add the next event
      final newEvent = LiveMeetingEvent(
        agendaItem: nextAgendaItem?.id,
        event: nextAgendaItem == null
            ? LiveMeetingEventType.finishMeeting
            : LiveMeetingEventType.agendaItemStarted,
        timestamp: DateTime.now().toUtc(),
        hostless: true,
      );
      print('adding new event: $newEvent');

      final allTimingEvents = liveMeeting.events.where(
        (e) => [
          LiveMeetingEventType.agendaItemStarted,
          LiveMeetingEventType.finishMeeting,
        ].contains(e.event),
      );
      final lastEvent = allTimingEvents.isEmpty ? null : allTimingEvents.last;
      if (lastEvent?.agendaItem == newEvent.agendaItem &&
          lastEvent?.event == newEvent.event) {
        print('New live event has already been added. Returning.');
        return;
      }

      final currentLiveMeetingEvents = liveMeeting.events;
      transaction.set(
        firestore.document(liveMeetingPath),
        DocumentData.fromMap(
          jsonSubset(
            [
              LiveMeeting.kFieldEvents,
              LiveMeeting.kFieldPendingAdvanceAgendaItemId,
              LiveMeeting.kFieldPendingAdvanceTime,
            ],
            firestoreUtils.toFirestoreJson(
              LiveMeeting(
                events: [
                  ...currentLiveMeetingEvents,
                  newEvent,
                ],
                // Clear any pending advance now that we're actually advancing.
                pendingAdvanceAgendaItemId: null,
                pendingAdvanceTime: null,
              ).toJson(),
            ),
          ),
        ),
        merge: true,
      );
    });
  }
}
