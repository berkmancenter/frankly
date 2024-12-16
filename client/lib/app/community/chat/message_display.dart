import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:client/app/community/chat/chat_model.dart';
import 'package:client/app/community/community_permissions_provider.dart';
import 'package:client/app/community/events/event_page/event_permissions_provider.dart';
import 'package:client/app/community/utils.dart';
import 'package:client/common_widgets/custom_ink_well.dart';
import 'package:client/common_widgets/user_info_builder.dart';
import 'package:client/common_widgets/user_profile_chip.dart';
import 'package:client/services/services.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/utils/height_constained_text.dart';
import 'package:data_models/firestore/chat.dart';
import 'package:data_models/firestore/membership.dart';
import 'package:provider/provider.dart';

class MessageDisplay extends StatefulWidget {
  final ChatMessage message;
  final bool isSending;

  const MessageDisplay({
    Key? key,
    required this.message,
    required this.isSending,
  }) : super(key: key);

  @override
  MessageDisplayState createState() => MessageDisplayState();
}

class MessageDisplayState extends State<MessageDisplay> {
  bool _isHovered = false;

  bool get _canDelete =>
      EventPermissionsProvider.watch(context)
          ?.canDeleteEventMessage(widget.message) ??
      context
          .watch<CommunityPermissionsProvider>()
          .canDeleteChatMessage(widget.message);

  bool get _removed =>
      widget.message.messageStatus == ChatMessageStatus.removed;

  @override
  Widget build(BuildContext context) {
    final createdDate = widget.message.createdDate ?? clockService.now();
    final messageTimeZone = DateFormat('a').format(createdDate).toLowerCase();
    final messageDate = DateFormat('MMM d').format(createdDate);
    final messageTime = DateFormat('hh:mm').format(createdDate);

    final isAdmin = widget.message.membershipStatusSnapshot?.isAdmin ?? false;
    final isMod = widget.message.membershipStatusSnapshot?.isMod ?? false;

    return UserInfoBuilder(
      userId: widget.message.creatorId,
      builder: (_, isLoading, snapshot) {
        return MouseRegion(
          onEnter: (hover) => setState(() => _isHovered = true),
          onExit: (hover) => setState(() => _isHovered = false),
          child: Semantics(
            label: 'Chat Message',
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              color: _isHovered ? AppColor.black.withOpacity(0.05) : null,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserProfileChip(
                    userId: widget.message.creatorId,
                    showName: false,
                    imageHeight: 40,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            SelectableText(
                              semanticsLabel: 'Message from',
                              snapshot.data?.displayName ?? '...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).isDark
                                    ? AppColor.gray5
                                    : AppColor.darkBlue,
                              ),
                            ),
                            SelectableText(
                              semanticsLabel: 'Message time',
                              ' $messageDate, $messageTime$messageTimeZone',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).isDark
                                    ? AppColor.gray5
                                    : AppColor.darkBlue,
                              ),
                            ),
                            if (isMod)
                              Container(
                                color: Theme.of(context).primaryColor,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 3,
                                  horizontal: 4,
                                ),
                                child: HeightConstrainedText(
                                  isAdmin ? 'ADMIN' : 'MOD',
                                  style: TextStyle(
                                    color: AppColor.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            if (widget.isSending)
                              Container(
                                margin: const EdgeInsets.only(left: 4),
                                height: 14,
                                width: 14,
                                alignment: Alignment.center,
                                child: CustomLoadingIndicator(
                                  strokeWidth: 2,
                                  color: Colors.blueGrey,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 4),
                        if (_removed)
                          HeightConstrainedText(
                            'This message was removed.',
                            style: TextStyle(
                              color: Theme.of(context).isDark
                                  ? AppColor.gray5
                                  : AppColor.gray1,
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        else
                          // Note: There are highlighting issues due to the below
                          // https://github.com/Cretezy/flutter_linkify/issues/59
                          // https://github.com/Cretezy/flutter_linkify/issues/54
                          Semantics(
                            label: 'Message',
                            child: SelectableLinkify(
                              text: widget.message.message ?? '',
                              style: TextStyle(
                                fontSize: 15,
                                color: Theme.of(context).isDark
                                    ? AppColor.white
                                    : AppColor.darkBlue,
                              ),
                              options: LinkifyOptions(looseUrl: true),
                              onOpen: (link) async {
                                await launch(link.url);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!_removed && _canDelete)
                    CustomInkWell(
                      onTap: () => alertOnError(
                        context,
                        () => Provider.of<ChatModel>(context, listen: false)
                            .removeChatMessage(widget.message),
                      ),
                      borderRadius: BorderRadius.circular(15),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.close,
                          color: Theme.of(context).isDark
                              ? AppColor.gray6
                              : AppColor.darkBlue,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
