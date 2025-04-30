import 'package:client/core/utils/provider_utils.dart';
import 'package:client/features/community/utils/guard_utils.dart';
import 'package:client/features/community/utils/community_theme_utils.dart.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:client/features/chat/data/providers/chat_model.dart';
import 'package:client/features/chat/presentation/widgets/message_display.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/empty_page_content.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/core/widgets/custom_text_field.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/chat/chat.dart';
import 'package:provider/provider.dart';

class ChatWidget extends StatelessWidget {
  final String parentPath;
  final ChatModel? chatModel;
  final String messageInputHint;
  final bool shouldGuardCommunityMember;
  final bool allowBroadcast;

  const ChatWidget({
    required this.parentPath,
    this.chatModel,
    this.messageInputHint = 'Enter message',
    this.shouldGuardCommunityMember = false,
    this.allowBroadcast = false,
  });

  @override
  Widget build(BuildContext context) {
    final chatWidget = _ChatWidget(
      messageInputHint: messageInputHint,
      shouldGuardCommunityMember: shouldGuardCommunityMember,
      allowBroadcast: allowBroadcast,
    );

    if (watchProviderOrNull<ChatModel>(context) == null) {
      return ChangeNotifierProvider(
        create: (context) => ChatModel(
          communityProvider: CommunityProvider.read(context),
          parentPath: parentPath,
        )..initialize(),
        child: chatWidget,
      );
    }

    return chatWidget;
  }
}

class _ChatWidget extends StatefulWidget {
  final String messageInputHint;
  final bool shouldGuardCommunityMember;
  final bool allowBroadcast;

  const _ChatWidget({
    this.messageInputHint = 'Enter message',
    this.shouldGuardCommunityMember = false,
    this.allowBroadcast = false,
  });

  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<_ChatWidget> {
  final _message = TextEditingController();
  final _sendController = SubmitNotifier();

  bool _broadcast = false;

  Future<void> _sendMessageWithAlert() => alertOnError(context, () async {
        final text = _message.text;
        _message.clear();
        await context
            .read<ChatModel>()
            .createChatMessage(text: text, broadcast: _broadcast);
      });

  Future<void> _sendMessage() => widget.shouldGuardCommunityMember
      ? guardCommunityMember(
          context,
          Provider.of<CommunityProvider>(context, listen: false).community,
          _sendMessageWithAlert,
        )
      : _sendMessageWithAlert();

  Widget _buildChatDisplay(List<ChatMessage> messages) {
    final List<ChatMessage>? sendingMessages =
        Provider.of<ChatModel>(context).sendingMessages;
    List<ChatMessage> allMessages = [
      ...sendingMessages?.reversed ?? [],
      ...messages,
    ];

    if (allMessages.isEmpty) {
      return _buildDefaultMessage();
    }

    return ListView(
      reverse: true,
      addAutomaticKeepAlives: false,
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      children: [
        for (int i = 0; i < allMessages.length; i++)
          MessageDisplay(
            key: Key('message-id-${allMessages[i].createdDate}'),
            message: allMessages[i],
            isSending: i < (sendingMessages?.length ?? 0),
          ),
      ],
    );
  }

  Widget _buildDefaultMessage() => Center(
        child: EmptyPageContent(
          type: EmptyPageType.chats,
          titleText: 'Welcome!',
          subtitleText: 'Introduce yourself to help break the ice 😉',
          showContainer: false,
          isBackgroundDark: Theme.of(context).isDark,
        ),
      );

  Widget _buildChatInput() {
    final canSubmit = !isNullOrEmpty(_message.text.trim());
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            key: Key('input-chat'),
            padding: EdgeInsets.zero,
            contentPadding: EdgeInsets.all(20),
            onEditingComplete:
                canSubmit ? () => _sendController.submit() : null,
            onChanged: (_) => setState(() {}),
            textStyle: context.theme.textTheme.bodyMedium,
            controller: _message,
            maxLines: 1,
            borderType: BorderType.none,
            borderRadius: 30,
            hintText: widget.messageInputHint,
            maxLength: 2000,
            hideCounter: true,
          ),
        ),
        SizedBox(width: 10),
        ActionButton(
          shape: CircleBorder(),
          minWidth: 58,
          padding: EdgeInsets.symmetric(vertical: 10),
          borderRadius: BorderRadius.circular(50),
          controller: _sendController,
          onPressed: canSubmit ? _sendMessage : null,
          child: Semantics(
            label: 'Submit Message Button',
            button: true,
            child: Icon(
              CupertinoIcons.paperplane,
              size: 30,
              color: context.theme.colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBroadcastCheckbox() {
    return Row(
      children: [
        Checkbox(
          fillColor: WidgetStateProperty.all(Theme.of(context).primaryColor),
          side: BorderSide(color: context.theme.colorScheme.onPrimary),
          value: _broadcast,
          onChanged: (value) => setState(() => _broadcast = !_broadcast),
        ),
        Flexible(
          child: HeightConstrainedText('Broadcast'),
        ),
      ],
    );
  }

  Widget _buildChatLoading() {
    return CustomStreamBuilder<List<ChatMessage>>(
      stream: context.watch<ChatModel>().messagesStream,
      entryFrom: '_ChatWidgetState._buildChatLoading',
      errorMessage: 'There was an error loading chat messages.',
      builder: (_, messages) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildChatDisplay(
              messages!.where((m) => m.isFloatingEmoji == false).toList(),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: _buildChatInput(),
          ),
          if (widget.allowBroadcast) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: _buildBroadcastCheckbox(),
            ),
          ],
          SizedBox(height: 10),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: _buildChatLoading(),
    );
  }
}
