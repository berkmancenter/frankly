import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_tabs/discussion_tabs_model.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/services/firestore/firestore_utils.dart';
import 'package:junto/services/services.dart';
import 'package:junto/utils/extensions.dart';
import 'package:junto_models/firestore/chat.dart';

class ChatModel with ChangeNotifier {
  static const _kChatId = 'junto_chat';

  final JuntoProvider juntoProvider;
  final DiscussionTabsControllerState? discussionTabsControllerState;
  final String parentPath;
  final String chatId = _kChatId;

  String? _lastReadMessageId;
  BehaviorSubjectWrapper<List<ChatMessage>>? _messagesStream;
  StreamSubscription<List<ChatMessage>>? _messagesStreamSubscription;

  Stream<List<ChatMessage>>? get messagesStream => _messagesStream?.stream;

  /// A buffer to hold messages while they are in flight to firestore.
  final _sendingMessages = <String, ChatMessage>{};

  List<ChatMessage>? get messages =>
      _messagesStream?.stream.valueOrNull?.where((m) => m.isFloatingEmoji == false).toList() ?? [];
  List<ChatMessage>? get sendingMessages => _sendingMessages.values.toList();

  bool _newMessagesProcessed = false;
  DateTime? _lastEmittedMessageTime;
  Stream<ChatMessage>? get newMessages => messagesStream?.expand((messages) {
        final newMessages = <ChatMessage>[];
        if (_newMessagesProcessed) {
          var potentialNewMessages = messages.where((m) {
            final createdDate = m.createdDate;
            final lastEmittedMessageTime = _lastEmittedMessageTime;
            if (createdDate == null || lastEmittedMessageTime == null) return true;

            return createdDate.isAfter(lastEmittedMessageTime);
          });

          if (_lastEmittedMessageTime == null) {
            potentialNewMessages = potentialNewMessages.take(1);
          }

          newMessages.addAll(potentialNewMessages);
        }

        _lastEmittedMessageTime =
            messages.firstWhereOrNull((m) => m.createdDate != null)?.createdDate;

        _newMessagesProcessed = true;

        return newMessages;
      });

  List<ChatMessage> get nonSelfMessages =>
      messages?.where((m) => m.creatorId != userService.currentUserId).toList() ?? [];

  int get numUnreadMessages {
    final lastReadIndex = nonSelfMessages.indexWhere((m) => m.id == _lastReadMessageId);
    return max(0, lastReadIndex);
  }

  ChatModel({
    required this.juntoProvider,
    this.discussionTabsControllerState,
    required this.parentPath,
  });

  void initialize() {
    if (_messagesStream?.stream == null || _messagesStream?.stream.hasError == true) {
      _messagesStream?.dispose();
      _messagesStream = firestoreChatService.chatMessagesStream(
        parentPath: parentPath,
        chatId: _kChatId,
        limit: 200,
      );
      _messagesStreamSubscription?.cancel();
      _messagesStreamSubscription = _messagesStream!.listen(_onMessagesUpdate);
    }
    discussionTabsControllerState?.selectedTabController.addListener(_checkClearUnread);
  }

  void _checkClearUnread() {
    if (discussionTabsControllerState?.isChatTab() ?? false) {
      _markAllMessagesRead();
    }
  }

  @override
  void dispose() {
    _messagesStreamSubscription?.cancel();
    _messagesStream?.dispose();
    super.dispose();
  }

  void _markAllMessagesRead() {
    _lastReadMessageId = nonSelfMessages.firstOrNull?.id;
    notifyListeners();
  }

  void _onMessagesUpdate(List<ChatMessage> messages) {

    if (nonSelfMessages.isNotEmpty == true &&
        (_lastReadMessageId == null || (discussionTabsControllerState?.isChatTab() ?? false))) {
      _markAllMessagesRead();
    }

    final removableMessages = messages.where((message) => _sendingMessages.containsKey(message.id));
    for (final message in removableMessages) {
      _sendingMessages.remove(message.id);
    }

    notifyListeners();
  }

  Future<void> createChatMessage({
    String? text,
    EmotionType? emotionType,
    bool broadcast = false,
  }) async {
    assert(text != null || emotionType != null, 'Emoji or text must be provided');
    if (emotionType == null && (text == null || text.trim().isEmpty)) return;

    final messageId = firestoreChatService.generateNewChatMessageId(parentPath, _kChatId);

    final membership = juntoUserDataService.getMembership(juntoProvider.juntoId).status;

    final newMessage = ChatMessage(
      id: messageId,
      message: text,
      creatorId: userService.currentUserId,
      createdDate: clockService.now(),
      emotionType: emotionType,
      membershipStatusSnapshot: membership,
      broadcast: broadcast,
    );

    if (emotionType == null) {
      _sendingMessages[messageId] = newMessage;
      notifyListeners();
    }

    await firestoreChatService.createChatMessage(
      juntoId: juntoProvider.juntoId,
      parentPath: parentPath,
      chatId: _kChatId,
      chatMessage: newMessage,
    );
  }

  Future<void> removeChatMessage(ChatMessage message) =>
      firestoreChatService.removeChatMessage(chatMessage: message);
}
