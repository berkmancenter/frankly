import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart'
    as functions_interop;
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import '../../on_call_function.dart';
import '../../utils/firestore_utils.dart';
import '../../utils/utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/chat/chat.dart';
import 'package:data_models/chat/chat_suggestion_data.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/meeting_guide.dart';
import 'package:data_models/community/membership.dart';
import 'package:data_models/user/public_user_info.dart';

class GetMeetingChatSuggestionData
    extends OnCallMethod<GetMeetingChatsSuggestionsDataRequest> {
  GetMeetingChatSuggestionData()
      : super(
          'GetMeetingChatSuggestionData',
          (jsonMap) => GetMeetingChatsSuggestionsDataRequest.fromJson(jsonMap),
        );

  @override
  Future<Map<String, dynamic>> action(
    GetMeetingChatsSuggestionsDataRequest request,
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
      firestoreUtils
          .fromFirestoreJson(communityMembershipDoc.data.toMap() ?? {}),
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

    final chatDataListResults =
        await Future.wait(<Future<List<ChatSuggestionData>>>[
      for (final path in meetingPaths) _getChatsFromPath(path),
    ]);
    final suggestionDataListResults =
        await Future.wait(<Future<List<ChatSuggestionData>>>[
      for (final path in meetingPaths) _getSuggestionsFromPath(path),
    ]);

    final agendaItemSuggestions = await _getAgendaItemSuggestions(event, [
      liveMeetingPath,
      ...breakoutMeetingLinks,
    ]);

    return GetMeetingChatsSuggestionsDataResponse(
      chatsSuggestionsList: [
        ...chatDataListResults.expand((c) => c),
        ...suggestionDataListResults.expand((c) => c),
        ...agendaItemSuggestions,
      ],
    ).toJson();
  }

  Future<List<ChatSuggestionData>> _getChatsFromPath(String path) async {
    final roomId = path.split('/').last;
    final chatsData = await firestore
        .collection('$path/chats/community_chat/messages')
        .orderBy(ChatMessage.kFieldCreatedDate)
        .get();

    final chatSuggestions = <ChatSuggestionData>[];
    for (var document in chatsData.documents) {
      var doc = ChatMessage.fromJson(
        firestoreUtils.fromFirestoreJson(document.data.toMap()),
      );
      final memberInfo = await firestoreUtils.getUser(doc.creatorId!);

      String memberName;
      if (isNullOrEmpty(memberInfo.displayName)) {
        final memberDoc =
            await firestore.document('publicUser/${memberInfo.uid}').get();
        var info = PublicUserInfo.fromJson(
          firestoreUtils.fromFirestoreJson(memberDoc.data.toMap()),
        );
        memberName = info.displayName ?? '';
      } else {
        memberName = memberInfo.displayName;
      }

      chatSuggestions.add(
        ChatSuggestionData(
          id: document.documentID,
          creatorId: doc.creatorId,
          creatorEmail: memberInfo.email,
          creatorName: memberName,
          createdDate: doc.createdDate,
          message: doc.message,
          emotionType: doc.emotionType,
          type: ChatSuggestionType.chat,
          roomId: roomId,
          deleted: doc.messageStatus == ChatMessageStatus.removed,
        ),
      );
    }

    return chatSuggestions;
  }

  Future<List<ChatSuggestionData>> _getSuggestionsFromPath(String path) async {
    final roomId = path.split('/').last;
    final userSuggestionsData = await firestore
        .collection('$path/user-suggestions')
        .orderBy(SuggestedAgendaItem.kFieldCreatedDate)
        .get();

    final chatSuggestionDataList = <ChatSuggestionData>[];
    for (var document in userSuggestionsData.documents) {
      var doc = SuggestedAgendaItem.fromJson(
        firestoreUtils.fromFirestoreJson(document.data.toMap()),
      );
      final memberInfo = await firestoreUtils.getUser(doc.creatorId!);

      String memberName;
      if (isNullOrEmpty(memberInfo.displayName)) {
        final memberDoc =
            await firestore.document('publicUser/${memberInfo.uid}').get();
        final publicUserInfo = PublicUserInfo.fromJson(
          firestoreUtils.fromFirestoreJson(memberDoc.data.toMap()),
        );
        memberName = publicUserInfo.displayName ?? '';
      } else {
        memberName = memberInfo.displayName;
      }

      chatSuggestionDataList.add(
        ChatSuggestionData(
          id: document.documentID,
          creatorId: doc.creatorId,
          creatorEmail: memberInfo.email,
          creatorName: memberName,
          createdDate: doc.createdDate,
          message: doc.content,
          type: ChatSuggestionType.suggestion,
          upvotes: doc.upvotedUserIds.length,
          downvotes: doc.downvotedUserIds.length,
          roomId: roomId,
        ),
      );
    }

    return chatSuggestionDataList;
  }

  Future<List<ChatSuggestionData>> _getAgendaItemSuggestions(
    Event event,
    List<String> roomPaths,
  ) async {
    final suggestionAgendaItems = event.agendaItems
        .where((a) => a.type == AgendaItemType.userSuggestions)
        .map((a) => a.id)
        .toList();

    final participantDetailsCollections = roomPaths
        .map(
          (path) => suggestionAgendaItems.map(
            (suggestionAgendaItemId) =>
                '$path/participant-agenda-item-details/$suggestionAgendaItemId/participant-details',
          ),
        )
        .expand((element) => element);

    print(participantDetailsCollections);
    final participantAgendaItemDetails = await Future.wait(
      participantDetailsCollections
          .map((collection) => _getParticipantAgendaItemDetails(collection)),
    );

    return participantAgendaItemDetails.expand((e) => e).toList();
  }

  Future<List<ChatSuggestionData>> _getParticipantAgendaItemDetails(
    String collection,
  ) async {
    final documents = await firestore.collection(collection).get();

    final results = await Future.wait(
      documents.documents
          .map(
            (doc) => _getSuggestionsFromParticipantAgendaItem(
              doc,
              ParticipantAgendaItemDetails.fromJson(
                firestoreUtils.fromFirestoreJson(doc.data.toMap()),
              ),
            ),
          )
          .toList(),
    );

    return results.expand((element) => element).toList();
  }

  Future<List<ChatSuggestionData>> _getSuggestionsFromParticipantAgendaItem(
    DocumentSnapshot document,
    ParticipantAgendaItemDetails details,
  ) async {
    final memberInfo = await firestoreUtils.getUser(details.userId!);

    String memberName;
    if (isNullOrEmpty(memberInfo.displayName)) {
      final memberDoc =
          await firestore.document('publicUser/${memberInfo.uid}').get();
      final publicUserInfo = PublicUserInfo.fromJson(
        firestoreUtils.fromFirestoreJson(memberDoc.data.toMap()),
      );
      memberName = publicUserInfo.displayName ?? '';
    } else {
      memberName = memberInfo.displayName;
    }

    return details.suggestions
        .map(
          (suggestion) => ChatSuggestionData(
            id: document.documentID,
            creatorId: details.userId,
            creatorEmail: memberInfo.email,
            creatorName: memberName,
            createdDate:
                suggestion.createdDate ?? document.createTime?.toDateTime(),
            message: suggestion.suggestion,
            type: ChatSuggestionType.suggestion,
            upvotes: suggestion.likedByIds.length,
            downvotes: suggestion.dislikedByIds.length,
            roomId: details.meetingId,
            agendaItemId: details.agendaItemId,
          ),
        )
        .toList();
  }
}
