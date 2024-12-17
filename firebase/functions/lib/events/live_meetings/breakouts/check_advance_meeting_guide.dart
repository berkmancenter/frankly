import 'dart:async';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import '../../../on_call_function.dart';
import '../../../utils/firestore_utils.dart';
import '../../../utils/utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
import 'package:data_models/events/live_meetings/meeting_guide.dart';
import 'package:data_models/utils/utils.dart';

class CheckAdvanceMeetingGuide
    extends OnCallMethod<CheckAdvanceMeetingGuideRequest> {
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
            readyToAdvance: true,
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

    await _checkAdvanceMeetingGuide(
      liveMeetingPath: activeLiveMeetingPath,
      parentLiveMeetingPath: isBreakout ? liveMeetingPath : null,
      isBreakout: isBreakout,
      request: request,
      userId: context.authUid!,
    );

    if (isNullOrEmpty(request.userReadyAgendaId)) {
      print('No agenda ID passed in so not marking user ready.');
      return;
    }

    await _markReady(
      userId: context.authUid!,
      agendaItemId: request.userReadyAgendaId,
      liveMeetingPath: activeLiveMeetingPath,
      meetingId: activeLiveMeetingPath.split('/').last,
    );
  }

  Future<void> _checkAdvanceMeetingGuide({
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
      return;
    }
    if (liveMeeting.events
        .any((e) => e.event == LiveMeetingEventType.finishMeeting)) {
      print('Meeting already finished. Not checking advanced');
      return;
    }
    // Get current agenda
    final event = await firestoreUtils.getFirestoreObject(
      path: request.eventPath,
      constructor: (map) => Event.fromJson(map),
    );

    final currentAgendaItemId = _getCurrentAgendaItemId(event, liveMeeting);
    print('current agenda item: $currentAgendaItemId');

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
            firestoreUtils.fromFirestoreJson(doc.data.toMap() ?? {}),
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

    // If it is the first one, then take the current time into account
    if (readyToMoveOnIds.length >= presentParticipantIds.length / 2) {
      await _advanceMeetingGuide(
        liveMeetingPath: liveMeetingPath,
        event: event,
        currentAgendaItemId: currentAgendaItemId,
        parentLiveMeetingPath: parentLiveMeetingPath,
      );
    }
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

  Future<void> _advanceMeetingGuide({
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
            [LiveMeeting.kFieldEvents],
            firestoreUtils.toFirestoreJson(
              LiveMeeting(
                events: [
                  ...currentLiveMeetingEvents,
                  newEvent,
                ],
              ).toJson(),
            ),
          ),
        ),
        merge: true,
      );
    });
  }
}
