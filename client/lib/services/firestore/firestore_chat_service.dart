import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:client/services/firestore/firestore_utils.dart';
import 'package:client/services/services.dart';
import 'package:data_models/chat/chat.dart';
import 'package:data_models/utils/utils.dart';
import 'package:rxdart/rxdart.dart';

class FirestoreChatService {
  static const String chats = 'chats';

  CollectionReference<Map<String, dynamic>> _chatMessageCollection({
    required String parentPath,
    required String chatId,
  }) {
    return firestoreDatabase.firestore
        .collection('$parentPath/$chats/$chatId/messages');
  }

  BehaviorSubjectWrapper<List<ChatMessage>> chatMessagesStream({
    required String parentPath,
    required String chatId,
    int limit = 100,
  }) {
    return wrapInBehaviorSubject(
      _chatMessageCollection(parentPath: parentPath, chatId: chatId)
          .orderBy('createdDate', descending: true)
          .limit(limit)
          .snapshots()
          .sampleTime(Duration(milliseconds: 400))
          .asyncMap(_convertChatMessageListAsync),
    );
  }

  String generateNewChatMessageId(String parentPath, String chatId) {
    return _chatMessageCollection(parentPath: parentPath, chatId: chatId)
        .doc()
        .id;
  }

  Future<ChatMessage> createChatMessage({
    required String communityId,
    required String parentPath,
    required String chatId,
    required ChatMessage chatMessage,
  }) async {
    final messagesCollection =
        _chatMessageCollection(parentPath: parentPath, chatId: chatId);
    await messagesCollection
        .doc(chatMessage.id)
        .set(toFirestoreJson(chatMessage.toJson()));

    return chatMessage;
  }

  Future<void> removeChatMessage({required ChatMessage chatMessage}) async {
    final messageRef = firestoreDatabase.firestore
        .doc('${chatMessage.collectionPath}/${chatMessage.id}');
    await messageRef.update(
      jsonSubset(
        [ChatMessage.kFieldMessageStatus],
        chatMessage.copyWith(messageStatus: ChatMessageStatus.removed).toJson(),
      ),
    );
  }

  static Future<List<ChatMessage>> _convertChatMessageListAsync(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) async {
    // This is a lengthy operation so its important to ensure it doesnt happen
    // for each doc access
    final docs = showTime(() => snapshot.docs, 'get docs time');

    // compute does nothing on web: https://github.com/flutter/flutter/issues/33577
    final chatMessages = await compute(
      _convertChatMessageList,
      docs.map((doc) => doc.data()).toList(),
    );

    for (var i = 0; i < chatMessages.length; i++) {
      chatMessages[i] = chatMessages[i].copyWith(
        id: docs[i].id,
        collectionPath: docs[i].reference.parent.path,
      );
    }

    return chatMessages;
  }

  static List<ChatMessage> _convertChatMessageList(
    List<Map<String, dynamic>> data,
  ) {
    return data.map((d) => ChatMessage.fromJson(fromFirestoreJson(d))).toList();
  }
}

T showTime<T>(T Function() action, String description) {
  const enable = false;
  if (enable) {
    final timer = Stopwatch()..start();
    final temp = action();
    loggingService.log('$description: ${timer.elapsedMilliseconds}');
    return temp;
  } else {
    return action();
  }
}
