import 'dart:async';

import 'package:data_models/user_input/poll_data.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart'
    as functions_interop;
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import '../../on_call_function.dart';
import '../../utils/infra/firebase_auth_utils.dart';
import '../../utils/infra/firestore_utils.dart';
import '../../utils/utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/user_input/chat.dart';
import 'package:data_models/user_input/chat_suggestion_data.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/meeting_guide.dart';
import 'package:data_models/community/membership.dart';
import 'package:data_models/user/public_user_info.dart';

class GetMeetingPollData extends OnCallMethod<GetMeetingPollDataRequest> {
  GetMeetingPollData()
      : super(
          'GetMeetingPollData',
          (jsonMap) => GetMeetingPollDataRequest.fromJson(jsonMap),
        );

  @override
  Future<Map<String, dynamic>> action(
    GetMeetingPollDataRequest request,
    functions_interop.CallableContext context,
  ) async {
    final eventPath = request.eventPath;
    final match = RegExp('/?community/([^/]+)/templates/([^/]+)/events/([^/]+)')
        .matchAsPrefix(eventPath);
    if (match == null) {
      throw functions_interop.HttpsError(
        functions_interop.HttpsError.invalidArgument,
        'Path malformed.',
        null,
      );
    }
    final communityId = match.group(1);
    final eventId = match.group(3);

    final event = await firestoreUtils.getFirestoreObject(
      path: eventPath,
      constructor: (map) => Event.fromJson(map),
    );

    final membershipDoc =
        'memberships/${context.authUid}/community-membership/$communityId';
    final communityMembershipDoc =
        await firestore.document(membershipDoc).get();
    final membership = Membership.fromJson(
      firestoreUtils.fromFirestoreJson(communityMembershipDoc.data.toMap()),
    );

    orElseUnauthorized(
      membership.isAdmin || event.creatorId == context.authUid,
    );

    final liveMeetingPath = '${request.eventPath}/live-meetings/$eventId';
    final breakoutRoomSessions = '$liveMeetingPath/breakout-room-sessions';
    print(breakoutRoomSessions);
    final sessionDocs = await firestore.collection(breakoutRoomSessions).get();
    final roomDocQueries = await Future.wait(
      sessionDocs.documents.map((session) {
        final collectionPath = '${session.reference.path}/breakout-rooms';
        print(collectionPath);
        return firestore.collection(collectionPath).get();
      }),
    );
    final roomDocs =
        roomDocQueries.map((query) => query.documents).expand((a) => a);
    final breakoutMeetingLinks = roomDocs.map(
      (roomDoc) =>
          '${roomDoc.reference.path}/live-meetings/${roomDoc.documentID}',
    );

    final meetingPaths = [
      request.eventPath,
      ...breakoutMeetingLinks,
    ];

    // final suggestionDataListResults =
    //     await Future.wait(<Future<List<ChatSuggestionData>>>[
    //   for (final path in meetingPaths) _getSuggestionsFromPath(path),
    // ]);

    // final agendaItemSuggestions = await _getAgendaItemSuggestions(event, [
    //   liveMeetingPath,
    //   ...breakoutMeetingLinks,
    // ]);

    return GetMeetingPollDataResponse(
      polls: [],
    ).toJson();
  }

  Future<List<PollData>> _getPollsFromPath(String path) async {
    final roomId = path.split('/').last;
    return [];
    // final userSuggestionsData = await firestore
    //     .collection('$path/user-suggestions')
    //     .orderBy(SuggestedAgendaItem.kFieldCreatedDate)
    //     .get();

    // final chatSuggestionDataList = <ChatSuggestionData>[];
    // for (var document in userSuggestionsData.documents) {
    //   var doc = SuggestedAgendaItem.fromJson(
    //     firestoreUtils.fromFirestoreJson(document.data.toMap()),
    //   );
    //   final memberInfo = await firebaseAuthUtils.getUser(doc.creatorId!);

    //   String memberName;
    //   if (isNullOrEmpty(memberInfo.displayName)) {
    //     final memberDoc =
    //         await firestore.document('publicUser/${memberInfo.uid}').get();
    //     final publicUserInfo = PublicUserInfo.fromJson(
    //       firestoreUtils.fromFirestoreJson(memberDoc.data.toMap()),
    //     );
    //     memberName = publicUserInfo.displayName ?? '';
    //   } else {
    //     memberName = memberInfo.displayName;
    //   }

    //   chatSuggestionDataList.add(
    //     ChatSuggestionData(
    //       id: document.documentID,
    //       creatorId: doc.creatorId,
    //       creatorEmail: memberInfo.email,
    //       creatorName: memberName,
    //       createdDate: doc.createdDate,
    //       message: doc.content,
    //       type: ChatSuggestionType.suggestion,
    //       upvotes: doc.upvotedUserIds.length,
    //       downvotes: doc.downvotedUserIds.length,
    //       roomId: roomId,
    //     ),
    //   );
    // }

    // return chatSuggestionDataList;
  }
}
