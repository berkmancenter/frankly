import 'dart:async';

import 'package:firebase_functions_interop/firebase_functions_interop.dart' as functions_interop;
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:junto_functions/functions/on_call_function.dart';
import 'package:junto_functions/utils/firestore_utils.dart';
import 'package:junto_functions/utils/utils.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/chat.dart';
import 'package:junto_models/firestore/chat_suggestion_data.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/meeting_guide.dart';
import 'package:junto_models/firestore/membership.dart';
import 'package:junto_models/firestore/public_user_info.dart';

class GetMeetingChatSuggestionData extends OnCallMethod<GetMeetingChatsSuggestionsDataRequest> {
  GetMeetingChatSuggestionData()
      : super('GetMeetingChatSuggestionData',
            (jsonMap) => GetMeetingChatsSuggestionsDataRequest.fromJson(jsonMap));

  @override
  Future<Map<String, dynamic>> action(
      GetMeetingChatsSuggestionsDataRequest request, functions_interop.CallableContext context) async {
    final discussionPath = request.discussionPath;
    final match =
        RegExp('/?junto/([^/]+)/topics/([^/]+)/discussions/([^/]+)').matchAsPrefix(discussionPath);
    if (match == null) {
      throw functions_interop.HttpsError(functions_interop.HttpsError.invalidArgument, 'Path malformed.', null);
    }
    final juntoId = match.group(1);
    final discussionId = match.group(3);

    final discussion = await firestoreUtils.getFirestoreObject(
      path: discussionPath,
      constructor: (map) => Discussion.fromJson(map),
    );

    final membershipDoc = 'memberships/${context?.authUid}/junto-membership/$juntoId';
    final juntoMembershipDoc = await firestore.document(membershipDoc).get();
    final membership = Membership.fromJson(firestoreUtils.fromFirestoreJson(juntoMembershipDoc.data?.toMap() ?? {}));

    orElseUnauthorized(membership.isAdmin || discussion.creatorId == context?.authUid);

    final liveMeetingPath = '${request.discussionPath}/live-meetings/$discussionId';
    final breakoutRoomSessions = '$liveMeetingPath/breakout-room-sessions';
    print(breakoutRoomSessions);
    final sessionDocs = await firestore.collection(breakoutRoomSessions).get();
    final roomDocQueries = await Future.wait(sessionDocs.documents.map((session) {
      final collectionPath = '${session.reference.path}/breakout-rooms';
      print(collectionPath);
      return firestore.collection(collectionPath).get();
    }));
    final roomDocs = roomDocQueries.map((query) => query.documents).expand((a) => a);
    final breakoutMeetingLinks =
        roomDocs.map((roomDoc) => '${roomDoc.reference.path}/live-meetings/${roomDoc.documentID}');

    final meetingPaths = [
      request.discussionPath,
      ...breakoutMeetingLinks,
    ];

    final chatDataListResults = await Future.wait(<Future<List<ChatSuggestionData>>>[
      for (final path in meetingPaths) _getChatsFromPath(path),
    ]);
    final suggestionDataListResults = await Future.wait(<Future<List<ChatSuggestionData>>>[
      for (final path in meetingPaths) _getSuggestionsFromPath(path),
    ]);

    final agendaItemSuggestions = await _getAgendaItemSuggestions(discussion, [
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
        .collection('$path/chats/junto_chat/messages')
        .orderBy(ChatMessage.kFieldCreatedDate)
        .get();

    final chatSuggestions = <ChatSuggestionData>[];
    for (var document in chatsData.documents) {
      var doc = ChatMessage.fromJson(firestoreUtils.fromFirestoreJson(document.data.toMap()));
      final memberInfo = await firestoreUtils.getUser(doc.creatorId!);

      String memberName;
      if (isNullOrEmpty(memberInfo.displayName)) {
        final memberDoc = await firestore.document('publicUser/${memberInfo.uid}').get();
        var info = PublicUserInfo.fromJson(firestoreUtils.fromFirestoreJson(memberDoc.data.toMap()));
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
          createdDate: doc.createdDate!,
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
      var doc = SuggestedAgendaItem.fromJson(firestoreUtils.fromFirestoreJson(document.data.toMap()));
      final memberInfo = await firestoreUtils.getUser(doc.creatorId!);

      String memberName;
      if (isNullOrEmpty(memberInfo.displayName)) {
        final memberDoc = await firestore.document('publicUser/${memberInfo.uid}').get();
        final publicUserInfo = PublicUserInfo.fromJson(firestoreUtils.fromFirestoreJson(memberDoc.data.toMap()));
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
          createdDate: doc.createdDate!,
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
      Discussion discussion, List<String> roomPaths) async {
    final suggestionAgendaItems = discussion.agendaItems
        .where((a) => a.type == AgendaItemType.userSuggestions)
        .map((a) => a.id)
        .toList();

    final participantDetailsCollections = roomPaths
        .map((path) => suggestionAgendaItems.map((suggestionAgendaItemId) =>
            '$path/participant-agenda-item-details/$suggestionAgendaItemId/participant-details'))
        .expand((element) => element);

    print(participantDetailsCollections);
    final participantAgendaItemDetails = await Future.wait(participantDetailsCollections
        .map((collection) => _getParticipantAgendaItemDetails(collection)));

    return participantAgendaItemDetails.expand((e) => e).toList();
  }

  Future<List<ChatSuggestionData>> _getParticipantAgendaItemDetails(String collection) async {
    final documents = await firestore.collection(collection).get();

    final results = await Future.wait(documents.documents
        .map((doc) => _getSuggestionsFromParticipantAgendaItem(
            doc, ParticipantAgendaItemDetails.fromJson(firestoreUtils.fromFirestoreJson(doc.data.toMap()))))
        .toList());

    return results.expand((element) => element).toList();
  }

  Future<List<ChatSuggestionData>> _getSuggestionsFromParticipantAgendaItem(
      DocumentSnapshot document, ParticipantAgendaItemDetails details) async {
    final memberInfo = await firestoreUtils.getUser(details.userId!);

    String memberName;
    if (isNullOrEmpty(memberInfo.displayName)) {
      final memberDoc = await firestore.document('publicUser/${memberInfo.uid}').get();
      final publicUserInfo = PublicUserInfo.fromJson(firestoreUtils.fromFirestoreJson(memberDoc.data.toMap()));
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
            createdDate: suggestion.createdDate ?? document.createTime?.toDateTime(),
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
