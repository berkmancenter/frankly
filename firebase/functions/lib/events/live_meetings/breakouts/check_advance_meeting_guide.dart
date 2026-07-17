import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../../../on_call_function.dart';
import '../../../utils/infra/firestore_utils.dart';
import '../../../utils/utils.dart';
import 'advance_meeting_guide_after_delay.dart';
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

class CheckAdvanceMeetingGuide
    extends OnCallMethod<CheckAdvanceMeetingGuideRequest> {
  static const _advanceDelay = Duration(seconds: 10);

  CheckAdvanceMeetingGuide()
      : super(
          'CheckAdvanceMeetingGuide',
          (jsonMap) => CheckAdvanceMeetingGuideRequest.fromJson(jsonMap),
        );

  Future<void> _markReady({
    required String userId,
    required String liveMeetingPath,
    required String? agendaItemId,
    required String meetingId,
    required bool ready,
  }) async {
    final documentId =
        '$liveMeetingPath/participant-agenda-item-details/$agendaItemId/participant-details/$userId';
    final document = firestore.document(documentId);
    final docData = DocumentData.fromMap(
      jsonSubset(
        [
          ParticipantAgendaItemDetails.kFieldUserId,
          ParticipantAgendaItemDetails.kFieldAgendaItemId,
          ParticipantAgendaItemDetails.kFieldMeetingId,
          ParticipantAgendaItemDetails.kFieldReadyToAdvance,
        ],
        firestoreUtils.toFirestoreJson(
          ParticipantAgendaItemDetails(
            agendaItemId: agendaItemId,
            meetingId: meetingId,
            readyToAdvance: ready,
            userId: userId,
          ).toJson(),
        ),
      ),
    );
    await document.setData(docData, SetOptions(merge: true));
  }

  @override
  Future<void> action(
    CheckAdvanceMeetingGuideRequest request,
    CallableContext context,
  ) async {
    // Look up event
    final event = await firestoreUtils.getFirestoreObject(
      path: request.eventPath,
      constructor: (map) => Event.fromJson(map),
    );

    final isBreakout = !isNullOrEmpty(request.breakoutRoomId);

    // Determine the current agenda item
    final liveMeetingPath = '${request.eventPath}/live-meetings/${event.id}';
    final breakoutLiveMeetingPath =
        '$liveMeetingPath/breakout-room-sessions/${request.breakoutSessionId}'
        '/breakout-rooms/${request.breakoutRoomId}/live-meetings/${request.breakoutRoomId}';

    final activeLiveMeetingPath =
        isBreakout ? breakoutLiveMeetingPath : liveMeetingPath;

    if (!isNullOrEmpty(request.userReadyAgendaId) && !request.ready) {
      // User is undoing their ready vote for this agenda item. Undoing a
      // vote can never trigger an advance, so there's nothing to check.
      await _markReady(
        userId: context.authUid!,
        agendaItemId: request.userReadyAgendaId,
        liveMeetingPath: activeLiveMeetingPath,
        meetingId: activeLiveMeetingPath.split('/').last,
        ready: false,
      );
      return;
    }

    final checkResult = await _checkAdvanceMeetingGuide(
      liveMeetingPath: activeLiveMeetingPath,
      parentLiveMeetingPath: isBreakout ? liveMeetingPath : null,
      isBreakout: isBreakout,
      request: request,
      userId: context.authUid!,
    );

    // If this is the last item, we can move on immediately
    if (checkResult.isLastAgendaItem) {
      print('Last agenda item reached. Advancing immediately.');
      await advanceMeetingGuide(
        event: event,
        liveMeetingPath: activeLiveMeetingPath,
        currentAgendaItemId: checkResult.newlyPendingAgendaItemId!,
        parentLiveMeetingPath: isBreakout ? liveMeetingPath : null,
      );
      return;
    }

    final newlyPendingAgendaItemId = checkResult.newlyPendingAgendaItemId;
    if (newlyPendingAgendaItemId != null) {
      // We're the caller that just crossed the ready threshold, so we're responsible for
      // actually triggering the advance once the delay elapses.
      final advanceRequest = AdvanceMeetingGuideAfterDelayRequest(
        eventPath: request.eventPath,
        breakoutSessionId: request.breakoutSessionId,
        breakoutRoomId: request.breakoutRoomId,
        agendaItemId: newlyPendingAgendaItemId,
      );

      final functionsUrlPrefix =
          functions.config.get('app.functions_url_prefix').toString();
      if (functionsUrlPrefix.startsWith('http://localhost') ||
          functionsUrlPrefix.startsWith('http://127.0.0.1')) {
        print('Running on localhost, skipping scheduling and running after '
            '${_advanceDelay.inSeconds} seconds');
        await Future.delayed(_advanceDelay, () async {
          await AdvanceMeetingGuideAfterDelay()
              .advanceMeetingGuideAfterDelay(advanceRequest);
        });
      } else {
        await AdvanceMeetingGuideAfterDelayServer().schedule(
          advanceRequest,
          checkResult.pendingAdvanceTime!,
        );
      }
    }

    if (checkResult.isPendingOrAdvancing) {
      // A countdown to advance is already running (or was just started) for the current agenda
      // item. Once that starts, further ready votes can no longer change the outcome.
      print('Advance is pending. Not marking user ready.');
      return;
    }

    if (isNullOrEmpty(request.userReadyAgendaId)) {
      print('No agenda ID passed in so not marking user ready.');
      return;
    }

    await _markReady(
      userId: context.authUid!,
      agendaItemId: request.userReadyAgendaId,
      liveMeetingPath: activeLiveMeetingPath,
      meetingId: activeLiveMeetingPath.split('/').last,
      ready: true,
    );
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
    required String userId,
    required String liveMeetingPath,
    required String? parentLiveMeetingPath,
    required CheckAdvanceMeetingGuideRequest request,
  }) async {
    final liveMeeting = await firestoreUtils.getFirestoreObject(
      path: liveMeetingPath,
      constructor: (map) => LiveMeeting.fromJson(map),
    );

    if (!isBreakout) {
      print('Only breakouts are currently hostless');
      return AdvanceCheckResult(
          isPendingOrAdvancing: false, isLastAgendaItem: false);
    }
    if (liveMeeting.events
        .any((e) => e.event == LiveMeetingEventType.finishMeeting)) {
      print('Meeting already finished. Not checking advanced');
      return AdvanceCheckResult(
          isPendingOrAdvancing: false, isLastAgendaItem: false);
    }
    print('Checking advance for event: ${request.eventPath}, '
        'live meeting: $liveMeetingPath');

    // Get current agenda
    final Event event;
    try {
      event = await firestoreUtils.getFirestoreObject(
        path: request.eventPath,
        constructor: (map) => Event.fromJson(map),
      );
    } catch (e) {
      throw StateError('Failed to load event at ${request.eventPath}: $e');
    }

    final currentAgendaItemId = _getCurrentAgendaItemId(event, liveMeeting);
    print('current agenda item: $currentAgendaItemId');

    if (liveMeeting.pendingAdvanceAgendaItemId == currentAgendaItemId) {
      print('Advance is already pending for $currentAgendaItemId');
      return AdvanceCheckResult(
          isPendingOrAdvancing: true, isLastAgendaItem: false);
    }

    // Determine who is present
    DocumentQuery participantsQuery =
        firestore.collection('${request.eventPath}/event-participants');
    if (isBreakout) {
      participantsQuery = participantsQuery.where(
        Participant.kFieldCurrentBreakoutRoomId,
        isEqualTo: request.breakoutRoomId,
      );
    }
    final participantsSnapshot = await participantsQuery.get();

    final registeredParticipants = participantsSnapshot.documents
        .map(
          (doc) => Participant.fromJson(
            firestoreUtils.fromFirestoreJson(doc.data.toMap()),
          ),
        )
        .where((participant) => participant.status == ParticipantStatus.active)
        .toList();
    final registeredParticipantIds =
        registeredParticipants.map((p) => p.id).toSet();
    final presentParticipantIds = request.presentIds.toSet();

    // Determine who has said they are ready for this agenda item to be over
    final agendaItemParticipantDetailsPath =
        '$liveMeetingPath/participant-agenda-item-details/'
        '$currentAgendaItemId/participant-details';
    final agendaItemParticipantDetailsDocs =
        await firestore.collection(agendaItemParticipantDetailsPath).get();

    final agendaItemParticipantDetails =
        agendaItemParticipantDetailsDocs.documents
            .map(
              (doc) => ParticipantAgendaItemDetails.fromJson(
                firestoreUtils.fromFirestoreJson(doc.data.toMap()),
              ),
            )
            .toList();

    final readyToMoveOnIds = <String>{
      ...agendaItemParticipantDetails
          .where(
            (a) =>
                (a.readyToAdvance ?? false) &&
                presentParticipantIds.contains(a.userId),
          )
          .map((p) => p.userId ?? ''),
      if (request.userReadyAgendaId == currentAgendaItemId &&
          !isNullOrEmpty(userId))
        userId,
    };

    print('ready to move on: $readyToMoveOnIds');
    print('present: $presentParticipantIds');
    print('registered: $registeredParticipantIds');

    final threshold = readyToAdvanceThreshold(presentParticipantIds.length);
    if (readyToMoveOnIds.length < threshold) {
      print(
          'Not enough participants ready to advance. Threshold: $threshold, ready: ${readyToMoveOnIds.length}');
      return AdvanceCheckResult(
          isPendingOrAdvancing: false, isLastAgendaItem: false);
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
          isPendingOrAdvancing: true, isLastAgendaItem: false);
    }

    // We're the one who just wrote the pending state, so the caller is responsible for
    // actually triggering the advance after the delay.
    return AdvanceCheckResult(
      isPendingOrAdvancing: true,
      isLastAgendaItem: currentAgendaItemId == event.agendaItems.lastOrNull?.id,
      newlyPendingAgendaItemId: currentAgendaItemId,
      pendingAdvanceTime: pendingAdvanceTime,
    );
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
  }) async {
    await firestore.runTransaction((transaction) async {
      // Get current live meeting
      final liveMeeting = await firestoreUtils.getFirestoreObject(
        path: liveMeetingPath,
        constructor: (map) => LiveMeeting.fromJson(map),
        transaction: transaction,
      );

      // Ensure current agenda item is still current
      final newCurrentAgendaItemId =
          _getCurrentAgendaItemId(event, liveMeeting);
      if (newCurrentAgendaItemId != currentAgendaItemId) {
        print('$currentAgendaItemId is no longer the current '
            'agenda Item: $newCurrentAgendaItemId');
        return;
      }
      // Determine next agenda item or final
      final agendaItems = event.agendaItems;
      final agendaItemIndex =
          agendaItems.indexWhere((a) => a.id == currentAgendaItemId);

      var nextAgendaItem = agendaItemIndex + 1 < agendaItems.length
          ? agendaItems[agendaItemIndex + 1]
          : null;

      // If we are at the start of a breakout room set the next agenda item to match the parent
      // meeting's current agenda item.
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
