import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:client/features/events/features/event_page/presentation/event_tabs_model.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/utils/firestore_utils.dart';
import 'package:client/services.dart';
import 'package:client/core/utils/extensions.dart';
import 'package:data_models/chat/chat.dart';

class ChatModel with ChangeNotifier {
  static const _kChatId = 'community_chat';

  final CommunityProvider communityProvider;
  final EventTabsControllerState? eventTabsControllerState;
  final String parentPath;
  final String chatId = _kChatId;

  String? _lastReadMessageId;
  BehaviorSubjectWrapper<List<ChatMessage>>? _messagesStream;
  StreamSubscription<List<ChatMessage>>? _messagesStreamSubscription;

  Stream<List<ChatMessage>>? get messagesStream => _messagesStream?.stream;

  /// A buffer to hold messages while they are in flight to firestore.
  final _sendingMessages = <String, ChatMessage>{};

  List<ChatMessage>? get messages =>
      _messagesStream?.stream.valueOrNull
          ?.where((m) => m.isFloatingEmoji == false)
          .toList() ??
      [];
  List<ChatMessage>? get sendingMessages => _sendingMessages.values.toList();

  bool _newMessagesProcessed = false;
  DateTime? _lastEmittedMessageTime;
  Stream<ChatMessage>? get newMessages => messagesStream?.expand((messages) {
        final newMessages = <ChatMessage>[];
        if (_newMessagesProcessed) {
          var potentialNewMessages = messages.where((m) {
            final createdDate = m.createdDate;
            final lastEmittedMessageTime = _lastEmittedMessageTime;
            if (createdDate == null || lastEmittedMessageTime == null) {
              return true;
            }

            return createdDate.isAfter(lastEmittedMessageTime);
          });

          if (_lastEmittedMessageTime == null) {
            potentialNewMessages = potentialNewMessages.take(1);
          }

          newMessages.addAll(potentialNewMessages);
        }

        _lastEmittedMessageTime = messages
            .firstWhereOrNull((m) => m.createdDate != null)
            ?.createdDate;

        _newMessagesProcessed = true;

        return newMessages;
      });

  List<ChatMessage> get nonSelfMessages =>
      messages
          ?.where((m) => m.creatorId != userService.currentUserId)
          .toList() ??
      [];

  int get numUnreadMessages {
    final lastReadIndex =
        nonSelfMessages.indexWhere((m) => m.id == _lastReadMessageId);
    return max(0, lastReadIndex);
  }

  ChatModel({
    required this.communityProvider,
    this.eventTabsControllerState,
    required this.parentPath,
  });

  void initialize() {
    if (_messagesStream?.stream == null ||
        _messagesStream?.stream.hasError == true) {
      _messagesStream?.dispose();
      _messagesStream = firestoreChatService.chatMessagesStream(
        parentPath: parentPath,
        chatId: _kChatId,
        limit: 200,
      );
      _messagesStreamSubscription?.cancel();
      _messagesStreamSubscription = _messagesStream!.listen(_onMessagesUpdate);
    }
    eventTabsControllerState?.selectedTabController
        .addListener(_checkClearUnread);
  }

  void _checkClearUnread() {
    if (eventTabsControllerState?.isChatTab() ?? false) {
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
        (_lastReadMessageId == null ||
            (eventTabsControllerState?.isChatTab() ?? false))) {
      _markAllMessagesRead();
    }

    final removableMessages =
        messages.where((message) => _sendingMessages.containsKey(message.id));
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
    assert(
      text != null || emotionType != null,
      'Emoji or text must be provided',
    );
    if (emotionType == null && (text == null || text.trim().isEmpty)) return;

    final messageId =
        firestoreChatService.generateNewChatMessageId(parentPath, _kChatId);

    final membership =
        userDataService.getMembership(communityProvider.communityId).status;

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
      communityId: communityProvider.communityId,
      parentPath: parentPath,
      chatId: _kChatId,
      chatMessage: newMessage,
    );
  }

  Future<void> removeChatMessage(ChatMessage message) =>
      firestoreChatService.removeChatMessage(chatMessage: message);
}
