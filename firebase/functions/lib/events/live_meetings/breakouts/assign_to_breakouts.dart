import 'dart:async';
import 'dart:math' as math;

import 'package:collection/src/iterable_extensions.dart';
import 'package:firebase_admin_interop/firebase_admin_interop.dart'
    hide EventType;
import 'package:get_it/get_it.dart';
import 'package:frankly_matching/matching.dart' as matching;
import '../../../utils/firestore_utils.dart';
import 'package:data_models/firestore/event.dart';
import 'package:data_models/firestore/live_meeting.dart';
import 'package:data_models/firestore/membership.dart';
import 'package:data_models/utils.dart';
import 'package:meta/meta.dart';
import 'package:quiver/collection.dart';
import 'package:quiver/iterables.dart';
import 'package:uuid/uuid.dart';

/// A utility class for handling assignments to breakouts.
class AssignToBreakouts {
  @visibleForTesting
  static math.Random random = math.Random();

  AssignToBreakouts();

  Stopwatch? _stopWatch;

  void profile(String log) {
    _stopWatch ??= Stopwatch()..start();

    print('${_stopWatch!.elapsed}: $log');
  }

  Future<List<BreakoutRoom>> _assignBreakoutsBasedOnTargetSize({
    required int targetParticipantsPerRoom,
    required List<Participant> presentParticipants,
    required String creatorId,
    required CollectionReference breakoutRoomsCollection,
  }) async {
    print('starting breakout assignment');
    final presentParticipantIds = presentParticipants.map((p) => p.id).toList();

    print('getting membership lookup');
    // Order by Membership Status
    // Generate a lookup of present participants memberships
    final participantMembershipLookup = <String, MembershipStatus>{
      for (Participant p in presentParticipants)
        if (p.membershipStatus != null) p.id: p.membershipStatus!,
    };

    print('bucketize members');
    // Put all members into buckets based off of membership status.
    final memberBuckets = SetMultimap<MembershipStatus, String>();
    for (final id in presentParticipantIds) {
      memberBuckets.add(
        participantMembershipLookup[id] ?? MembershipStatus.nonmember,
        id,
      );
    }

    print('Get all grouped ids in order');
    // Print out all values from the multimap in order of the MembershipStatus Enum
    final groupedIds = [
      for (final status in MembershipStatus.values) memberBuckets[status],
    ].expand((list) => list).toList();

    print('calculate num rooms');
    final int numRooms;
    if (targetParticipantsPerRoom == 0) {
      numRooms = 1;
    } else {
      numRooms = math.max(
        1,
        (presentParticipantIds.length.toDouble() / targetParticipantsPerRoom)
            .round(),
      );
    }

    print('generate list of room participants');
    final roomParticipants = List.generate(numRooms, (i) => <String>[]);
    for (int i = 0; i < groupedIds.length; i++) {
      roomParticipants[i % numRooms].add(groupedIds[i]);
    }

    print('create rooms');
    final rooms = <BreakoutRoom>[];
    for (var i = 0; i < roomParticipants.length; i++) {
      rooms.add(
        BreakoutRoom(
          roomId: breakoutRoomsCollection.document().documentID,
          creatorId: creatorId,
          roomName: (i + 1).toString(),
          orderingPriority: i,
          participantIds: roomParticipants[i],
          originalParticipantIdsAssignment: roomParticipants[i],
        ),
      );
    }

    print('return rooms');
    return rooms;
  }

  String? _getJoinParametersOrNull(
    Participant participant,
    Event event,
  ) {
    String? surveyAnswers;
    final allQuestionsAnswered = participant.breakoutRoomSurveyQuestions
        .every((q) => q.answerOptionId.isNotEmpty);
    if (allQuestionsAnswered) {
      final surveyResponses = participant.breakoutRoomSurveyQuestions.map((q) {
        final answerId = q.answerOptionId;
        final answerIndex = q.answers.indexWhere(
          (answer) => answer.options.any((option) => option.id == answerId),
        );
        return answerIndex == 0 ? 0 : 1;
      }).join();
      surveyAnswers = surveyResponses;
    }

    final joinParameters = participant.joinParameters ?? {};
    if ((surveyAnswers == null || surveyAnswers.isEmpty) &&
        joinParameters['eventId'] == event.id) {
      surveyAnswers = joinParameters['am'];
    }

    if (surveyAnswers != null &&
        surveyAnswers.isNotEmpty &&
        surveyAnswers.split('').every((c) => ['0', '1'].contains(c))) {
      return surveyAnswers;
    }
    return null;
  }

  void _normalizeParticipantSurveyResponses(
    Map<String, String> participantSurveyResponsesLookup,
    Event event,
  ) {
    int numberOfQuestions =
        event.breakoutRoomDefinition?.breakoutQuestions.length ?? 0;

    final hasQuestions = numberOfQuestions > 0;
    if (!hasQuestions && participantSurveyResponsesLookup.values.isNotEmpty) {
      // If breakouts didnt specify a number of questions, get the max answer mask length.
      numberOfQuestions = participantSurveyResponsesLookup.values
          .map((s) => s.length)
          .reduce(math.max);
    }

    final int nonNullNumberOfQuestions = math.min(9, numberOfQuestions ?? 9);

    // Update all values to be numberOfQuestions in length.
    participantSurveyResponsesLookup.updateAll((key, value) {
      if (value.length > nonNullNumberOfQuestions) {
        return value.substring(0, nonNullNumberOfQuestions);
      } else if (value.length < nonNullNumberOfQuestions) {
        final paddingLength = nonNullNumberOfQuestions - value.length;

        final padding = [
          for (int i = 0; i < paddingLength; i++) random.nextBool() ? 0 : 1,
        ].join();

        return '$value$padding';
      }

      return value;
    });
  }

  Future<List<BreakoutRoom>> _assignBreakoutsForSmartMatch({
    required int targetParticipantsPerRoom,
    required List<Participant> presentParticipants,
    required String creatorId,
    required Event event,
    required CollectionReference breakoutRoomsCollection,
  }) async {
    profile('starting smart match with authUid: $creatorId');

    final unmatchedParticipants = presentParticipants.toList();

    // Match all participants who have an assigned match_id
    profile('prematching: ${unmatchedParticipants.length}');

    final prematches = <String, List<Participant>>{};
    for (final participant in unmatchedParticipants) {
      final joinParameters = participant.joinParameters ?? {};
      final matchId = joinParameters['match_id'];
      if (matchId != null &&
          matchId.isNotEmpty &&
          joinParameters['eventId'] == event.id) {
        print('adding match for $matchId');
        final prematchList = prematches[matchId] ?? <Participant>[];
        prematchList.add(participant);
        prematches[matchId] = prematchList;
      }
    }

    // Remove all prematches where one partner is present from the rest of matching.
    prematches.removeWhere((_, partners) => partners.length < 2);
    final prematchedIds =
        prematches.values.expand((p) => p).map((p) => p.id).toSet();
    unmatchedParticipants.removeWhere((p) => prematchedIds.contains(p.id));
    print('prematches: ${prematches.length}');
    print('unmatched: ${unmatchedParticipants.length}');

    // Build survey responses lookup for unmatched users with a valid answer mask
    print('unmatched: ${unmatchedParticipants.length}');
    final participantSurveyResponsesLookup = <String, String>{};
    for (final participant in unmatchedParticipants) {
      final joinParameters = _getJoinParametersOrNull(participant, event);
      if (joinParameters != null) {
        participantSurveyResponsesLookup[participant.id] = joinParameters;
      }
    }
    _normalizeParticipantSurveyResponses(
      participantSurveyResponsesLookup,
      event,
    );

    final nonNullSurveyResponsesLength = participantSurveyResponsesLookup
        .entries
        .where((e) => e.value.isNotEmpty)
        .length;
    print(
      'Starting smart matching with non null participant survey count: $nonNullSurveyResponsesLength',
    );

    print('target participants: $targetParticipantsPerRoom');

    // Smart match users who had valid survey responses
    profile('smart matching');
    List<List<String>> smartMatches;
    if (targetParticipantsPerRoom <= 2 ||
        participantSurveyResponsesLookup.length <= 2) {
      smartMatches =
          matching.bucketMatch(samples: participantSurveyResponsesLookup);
    } else {
      final adjustedTargetParticipants = calculateAdjustedTargetParticipants(
        participantSurveyResponsesLookup.length,
        targetParticipantsPerRoom,
      );

      smartMatches = matching.groupMatch(
        participantResponses: participantSurveyResponsesLookup,
        targetGroupSize: adjustedTargetParticipants,
      );
    }

    print('Total smart matches before filtering: ${smartMatches.length}');
    if (smartMatches.isNotEmpty &&
        smartMatches.last.length < targetParticipantsPerRoom) {
      smartMatches.removeLast();
    }
    final smartMatchedIds = smartMatches.expand((p) => p).toSet();
    unmatchedParticipants.removeWhere((p) => smartMatchedIds.contains(p.id));
    print('smartMatches: ${smartMatches.length}');

    // Match any leftover unmatched participants
    profile('leftover matching');
    print('unmatched: ${unmatchedParticipants.length}');
    final leftoverMatches = partition(
      unmatchedParticipants.map((e) => e.id),
      targetParticipantsPerRoom,
    );
    print('leftovermatches: ${leftoverMatches.length}');

    List<List<String>> matches = [
      ...smartMatches,
      ...leftoverMatches,
    ];

    if (matches.length > 1 && matches.last.length == 1) {
      final loneUser = matches.last.single;
      matches.removeLast();
      matches.last.add(loneUser);
    }
    profile('total matches: ${prematches.length + matches.length}');

    final breakoutMatchIdsToRecord = event.breakoutMatchIdsToRecord.toSet();
    final prematchEntries = prematches.entries.toList();

    int i = 0;
    return [
      for (i = 0; i < prematchEntries.length; i++)
        BreakoutRoom(
          roomId: breakoutRoomsCollection.document().documentID,
          creatorId: creatorId,
          roomName: (i + 1).toString(),
          orderingPriority: i,
          participantIds: prematchEntries[i].value.map((p) => p.id).toList(),
          originalParticipantIdsAssignment:
              prematchEntries[i].value.map((p) => p.id).toList(),
          record: breakoutMatchIdsToRecord.contains(prematchEntries[i].key),
        ),
      for (var j = 0; j < matches.length; j++)
        BreakoutRoom(
          roomId: breakoutRoomsCollection.document().documentID,
          creatorId: creatorId,
          roomName: (j + i + 1).toString(),
          orderingPriority: j + i,
          participantIds: matches[j],
          originalParticipantIdsAssignment: matches[j],
        ),
    ];
  }

  /// Check if we would get a better distribution of users per room by adjusting the target.
  ///
  /// This can add an extra room if that will make the average number of users per room closer to
  /// the target.
  ///
  /// An example is with 18 participants and a target of 10, the default smart matching is 1 room of
  /// 18. This will lower the target to 9 in order to make 2 rooms of 9.
  static int calculateAdjustedTargetParticipants(
    int numParticipants,
    int targetParticipantsPerRoom,
  ) {
    if (targetParticipantsPerRoom < 4) {
      return targetParticipantsPerRoom;
    }
    final numRoomsDouble =
        numParticipants / targetParticipantsPerRoom.toDouble();

    final higherTarget = numParticipants / numRoomsDouble.floor();
    final lowerTarget = numParticipants / numRoomsDouble.ceil();

    final higherTargetDiff = (higherTarget - targetParticipantsPerRoom).abs();
    final lowerTargetDiff = (lowerTarget - targetParticipantsPerRoom).abs();

    final int adjustedTargetParticipantsPerRoom;
    if (higherTargetDiff < lowerTargetDiff) {
      adjustedTargetParticipantsPerRoom = higherTarget.floor();
    } else {
      adjustedTargetParticipantsPerRoom = lowerTarget.floor();
    }

    if (adjustedTargetParticipantsPerRoom != targetParticipantsPerRoom) {
      print(
        'Adjusting target participants to $adjustedTargetParticipantsPerRoom to create better room distribution',
      );
    }

    return adjustedTargetParticipantsPerRoom;
  }

  @visibleForTesting
  Future<void> writeDocumentsToCollection({
    required CollectionReference breakoutSessionCollection,
    required List<BreakoutRoom> rooms,
    String? firstAgendaItemId,
  }) {
    return Future.wait(
      partition(rooms, 249).map((sublist) {
        final batch = firestore.batch();
        for (final room in sublist) {
          final roomDocumentRef =
              breakoutSessionCollection.document(room.roomId);
          batch.setData(
            roomDocumentRef,
            DocumentData.fromMap(
              firestoreUtils.toFirestoreJson(room.toJson()),
            ),
          );
          if (firstAgendaItemId != null) {
            final liveMeetingDoc = roomDocumentRef
                .collection('live-meetings')
                .document(room.roomId);
            batch.setData(
              liveMeetingDoc,
              DocumentData.fromMap(
                jsonSubset(
                  [LiveMeeting.kFieldEvents],
                  firestoreUtils.toFirestoreJson(
                    LiveMeeting(
                      events: [
                        LiveMeetingEvent(
                          event: LiveMeetingEventType.agendaItemStarted,
                          agendaItem: firstAgendaItemId,
                          hostless: true,
                          timestamp: DateTime.now().toUtc(),
                        ),
                      ],
                    ).toJson(),
                  ),
                ),
              ),
            );
          }
        }
        return batch.commit();
      }).toList(),
    );
  }

  @visibleForTesting
  Future<Iterable<DocumentSnapshot>> getParticipantSnapshots({
    required String participantsPath,
  }) async {
    final characterFilters = '247ADHLPTXaekmptw'.split('');

    final queries = <Future<QuerySnapshot>>[];
    for (int i = 0; i <= characterFilters.length; i++) {
      final previous = i - 1 >= 0 ? characterFilters[i - 1] : null;
      final next = i < characterFilters.length ? characterFilters[i] : null;

      print('query: $previous <= search < $next');

      DocumentQuery query = firestore.collection(participantsPath);
      if (previous != null) {
        query =
            query.where(Participant.kFieldId, isGreaterThanOrEqualTo: previous);
      }
      if (next != null) {
        query = query.where(Participant.kFieldId, isLessThan: next);
      }

      Future<QuerySnapshot> executeQuery() async {
        profile('$i starting snapshots');
        final docSnapshots = await query.select([
          Participant.kFieldId,
          Participant.kFieldStatus,
          Participant.kFieldIsPresent,
          Participant.kAvailableForBreakoutSessionId,
          Participant.kFieldBreakoutRoomSurveyQuestions,
          'joinParameters.participant_id',
          'joinParameters.match_id',
          'joinParameters.eventId',
          'joinParameters.am',
        ]).get();

        profile('$i finished snapshots');
        return docSnapshots;
      }

      queries.add(executeQuery());
    }

    final allSnapshots = await Future.wait(queries);
    profile('docs per query:');
    print(
      Map.fromEntries([
        for (int i = 0; i < allSnapshots.length; i++)
          MapEntry(i, allSnapshots[i].documents.length),
      ]),
    );
    final allDocs = allSnapshots.expand((q) => q.documents).toList();

    profile('filtering down to one doc per ID');
    final allDocIds = allDocs.map((d) => d.documentID).toSet();
    profile('all doc length: ${allDocIds.length}');
    final filteredDocs = allDocs.where((d) {
      final idIsFound = allDocIds.contains(d.documentID);
      allDocIds.remove(d.documentID);
      return idIsFound;
    }).toList();
    profile('filtering down to one doc per ID Done');
    print('all doc length: ${filteredDocs.length}');

    return filteredDocs;
  }

  /// Update the live meeting to reflect that we are currently processing assignments.
  ///
  /// If assignments has already started or finished processing we do nothing. If the meeting has
  /// been in processing assignments for some timeout duration, we go ahead and start processing
  /// again. The goal of this is to prevent race conditions so that only one caller is processing
  /// assignments at once.
  Future<bool> _markProcessingAssignmentsIfAvailable({
    required String liveMeetingPath,
    required String breakoutSessionId,
    required BreakoutAssignmentMethod assignmentMethod,
    required int targetParticipantsPerRoom,
    bool includeWaitingRoom = false,
    required String processingId,
  }) async {
    const processingTimeout = Duration(seconds: 45);
    return await firestore.runTransaction((transaction) async {
      final liveMeetingDoc = firestore.document(liveMeetingPath);
      final document = await transaction.get(liveMeetingDoc);
      final liveMeeting = LiveMeeting.fromJson(
        firestoreUtils.fromFirestoreJson(document.data.toMap()),
      );
      final currentBreakoutSession = liveMeeting.currentBreakoutSession;

      final isNewSession =
          currentBreakoutSession?.breakoutRoomSessionId != breakoutSessionId;

      final isPendingOrInactive = [
        BreakoutRoomStatus.pending,
        BreakoutRoomStatus.inactive,
      ].contains(currentBreakoutSession?.breakoutRoomStatus);

      final statusUpdateTime =
          currentBreakoutSession?.statusUpdatedTime ?? DateTime.now();
      final isProcessingCanceled = currentBreakoutSession?.breakoutRoomStatus ==
              BreakoutRoomStatus.processingAssignments &&
          (currentBreakoutSession?.processingId == null ||
              statusUpdateTime.difference(DateTime.now()) > processingTimeout);

      if (isNewSession || isPendingOrInactive || isProcessingCanceled) {
        transaction.update(
          liveMeetingDoc,
          UpdateData.fromMap(
            jsonSubset(
              [LiveMeeting.kFieldCurrentBreakoutSession],
              firestoreUtils.toFirestoreJson(
                LiveMeeting(
                  currentBreakoutSession: BreakoutRoomSession(
                    processingId: processingId,
                    breakoutRoomStatus:
                        BreakoutRoomStatus.processingAssignments,
                    assignmentMethod: assignmentMethod,
                    hasWaitingRoom: includeWaitingRoom,
                    breakoutRoomSessionId: breakoutSessionId,
                    targetParticipantsPerRoom: targetParticipantsPerRoom,
                  ),
                ).toJson(),
              ),
            ),
          ),
        );
        return true;
      }

      return false;
    });
  }

  Future<void> _processAssignments({
    required String liveMeetingPath,
    required Event event,
    required String breakoutSessionId,
    required String creatorId,
    required BreakoutAssignmentMethod assignmentMethod,
    required int targetParticipantsPerRoom,
    bool includeWaitingRoom = false,
    required String processingId,
  }) async {
    profile('getting participants');
    final participantSnapshots = (await getParticipantSnapshots(
      participantsPath: '${event.fullPath}/event-participants',
    ))
        .toList();

    profile('participants snapshot gotten');
    var presentParticipants = participantSnapshots
        .map(
          (doc) => Participant.fromJson(
            firestoreUtils.fromFirestoreJson(doc.data.toMap() ?? {}),
          ),
        )
        .toList();
    profile('constructed objects from json');
    presentParticipants = presentParticipants.where((participant) {
      final assignAllPresent = event.eventType == EventType.hosted;
      // If the breakout room already has a session ID, then make sure users
      // marked themselves ready for this session ID. Otherwise, just include
      // everyone who is present.
      final userIsAvailable = (!assignAllPresent &&
              participant.availableForBreakoutSessionId == breakoutSessionId) ||
          (assignAllPresent && participant.isPresent);
      return participant.status == ParticipantStatus.active && userIsAvailable;
    }).toList();

    profile('present available for breakouts ${presentParticipants.length}');

    final breakoutRoomsSessionDoc = firestore
        .document('$liveMeetingPath/breakout-room-sessions/$breakoutSessionId');
    final breakoutRoomsCollection =
        breakoutRoomsSessionDoc.collection('breakout-rooms');

    List<BreakoutRoom> breakoutRooms;
    if (assignmentMethod == BreakoutAssignmentMethod.targetPerRoom) {
      breakoutRooms = await _assignBreakoutsBasedOnTargetSize(
        targetParticipantsPerRoom: targetParticipantsPerRoom,
        presentParticipants: presentParticipants,
        creatorId: creatorId,
        breakoutRoomsCollection: breakoutRoomsCollection,
      );
    } else if (assignmentMethod == BreakoutAssignmentMethod.smartMatch) {
      breakoutRooms = await _assignBreakoutsForSmartMatch(
        targetParticipantsPerRoom: targetParticipantsPerRoom,
        presentParticipants: presentParticipants,
        creatorId: creatorId,
        event: event,
        breakoutRoomsCollection: breakoutRoomsCollection,
      );
    } else {
      throw Exception(
        'Unknown breakout rooms request assignment method: $assignmentMethod',
      );
    }

    breakoutRooms = breakoutRooms.map((b) => b.copyWith()).toList();

    var maxBreakoutRoomNumber = breakoutRooms.length;

    if (includeWaitingRoom) {
      breakoutRooms.insert(
        0,
        BreakoutRoom(
          roomId: breakoutsWaitingRoomId,
          roomName: 'Waiting Room',
          orderingPriority: -1,
          creatorId: creatorId,
          participantIds: [],
        ),
      );
    }

    if (breakoutRooms.isEmpty) {
      maxBreakoutRoomNumber = 1;
      breakoutRooms.add(
        BreakoutRoom(
          roomId: breakoutRoomsCollection.document().documentID,
          roomName: '1',
          orderingPriority: 0,
          creatorId: creatorId,
          participantIds: [],
        ),
      );
    }

    profile('Verifying that our processing ID still matches');
    final currentLiveMeeting = await firestoreUtils.getFirestoreObject(
      path: liveMeetingPath,
      constructor: (map) {
        print(map);
        return LiveMeeting.fromJson(map);
      },
    );
    if (currentLiveMeeting.currentBreakoutSession?.breakoutRoomStatus !=
            BreakoutRoomStatus.processingAssignments ||
        currentLiveMeeting.currentBreakoutSession?.processingId !=
            processingId) {
      profile(
        'No longer processing or processingId doesnt match. Returning without writing rooms',
      );
      profile(
        'status: ${currentLiveMeeting.currentBreakoutSession?.breakoutRoomStatus}',
      );
      profile(
        'processingId: ${currentLiveMeeting.currentBreakoutSession?.processingId}',
      );
      return;
    }

    profile('writing rooms ${breakoutRooms.length}');

    String? firstAgendaItemId;
    if (event.eventType == EventType.hosted) {
      final parentAgendaItemId = currentLiveMeeting.events
          .where((e) => LiveMeetingEventType.agendaItemStarted == e.event)
          .lastOrNull
          ?.agendaItem;

      firstAgendaItemId =
          parentAgendaItemId ?? event.agendaItems.firstOrNull?.id;
    } else {
      firstAgendaItemId = event.agendaItems.firstOrNull?.id;
    }

    await writeDocumentsToCollection(
      breakoutSessionCollection: breakoutRoomsCollection,
      rooms: breakoutRooms,
      firstAgendaItemId: firstAgendaItemId,
    );

    profile('writing session doc');

    final breakoutRoomSession = BreakoutRoomSession(
      breakoutRoomSessionId: breakoutSessionId,
      breakoutRoomStatus: BreakoutRoomStatus.active,
      hasWaitingRoom: includeWaitingRoom,
      targetParticipantsPerRoom: targetParticipantsPerRoom,
      maxRoomNumber: maxBreakoutRoomNumber,
      assignmentMethod: assignmentMethod,
    );
    await breakoutRoomsSessionDoc.setData(
      DocumentData.fromMap(
        firestoreUtils.toFirestoreJson(breakoutRoomSession.toJson()),
      ),
    );

    await firestore.document(liveMeetingPath).setData(
          DocumentData.fromMap(
            firestoreUtils.toFirestoreJson({
              LiveMeeting.kFieldCurrentBreakoutSession:
                  breakoutRoomSession.toJson(),
            }),
          ),
          SetOptions(merge: true),
        );
    profile('done writing');
  }

  Future<void> assignToBreakouts({
    required Event event,
    required String breakoutSessionId,
    required String creatorId,
    required BreakoutAssignmentMethod assignmentMethod,
    required int targetParticipantsPerRoom,
    bool includeWaitingRoom = false,
  }) async {
    final liveMeetingPath = '${event.fullPath}/live-meetings/${event.id}';

    final processingId = GetIt.instance.get<Uuid>().v4();
    profile(
      'updating breakout room to assigning with processingID: $processingId',
    );
    final markedProcessing = await _markProcessingAssignmentsIfAvailable(
      liveMeetingPath: liveMeetingPath,
      targetParticipantsPerRoom: targetParticipantsPerRoom,
      breakoutSessionId: breakoutSessionId,
      assignmentMethod: assignmentMethod,
      includeWaitingRoom: includeWaitingRoom,
      processingId: processingId,
    );

    if (!markedProcessing) {
      profile('Breakout session already processing. Returning.');
      return;
    }

    try {
      await _processAssignments(
        liveMeetingPath: liveMeetingPath,
        event: event,
        targetParticipantsPerRoom: targetParticipantsPerRoom,
        breakoutSessionId: breakoutSessionId,
        assignmentMethod: assignmentMethod,
        includeWaitingRoom: includeWaitingRoom,
        creatorId: creatorId,
        processingId: processingId,
      );
    } catch (e) {
      /// If there was a failure, update the processingID to null so that future callers know
      /// processing is not happening.
      await firestore.runTransaction((transaction) async {
        final liveMeetingDoc = firestore.document(liveMeetingPath);
        final document = await transaction.get(liveMeetingDoc);
        final liveMeeting = LiveMeeting.fromJson(
          firestoreUtils.fromFirestoreJson(document.data.toMap()),
        );
        final currentBreakoutSession = liveMeeting.currentBreakoutSession;

        if (currentBreakoutSession?.breakoutRoomStatus ==
                BreakoutRoomStatus.processingAssignments &&
            currentBreakoutSession?.processingId == processingId) {
          print('Updating live meeting doc processingID to null');
          transaction.update(
            liveMeetingDoc,
            UpdateData.fromMap({
              '${LiveMeeting.kFieldCurrentBreakoutSession}.${BreakoutRoomSession.kFieldProcessingId}':
                  null,
            }),
          );
        }
      });

      rethrow;
    }
  }
}
