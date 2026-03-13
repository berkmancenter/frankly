import 'package:client/core/utils/navigation_utils.dart';
import 'package:client/core/widgets/custom_loading_indicator.dart';
import 'package:client/features/community/utils/community_theme_utils.dart';
import 'package:client/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:client/features/chat/data/providers/chat_model.dart';
import 'package:client/features/community/data/providers/community_permissions_provider.dart';
import 'package:client/features/events/features/event_page/data/providers/event_permissions_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/features/user/data/providers/user_info_builder.dart';
import 'package:client/features/user/presentation/widgets/user_profile_chip.dart';
import 'package:client/services.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/chat/chat.dart';
import 'package:data_models/community/membership.dart';
import 'package:provider/provider.dart';
import 'package:client/core/localization/localization_helper.dart';

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
  // Use ValueNotifier so hover-state changes only rebuild the Container's
  // color decoration, not the entire widget tree (which would cause
  // UserInfoBuilder to reload and briefly show '...' for the display name
  // and cause the admin badge to flicker/duplicate in the Wrap layout).
  final _isHovered = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _isHovered.dispose();
    super.dispose();
  }

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
        // Build the message content once. Passed as the static `child` of
        // ValueListenableBuilder so it is not recreated on hover changes.
        final content = Row(
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
                        semanticsLabel: context.l10n.messageFrom,
                        snapshot.data?.displayName ?? '...',
                        style: context.theme.textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).isDark
                              ? context.theme.colorScheme.onPrimaryContainer
                              : context.theme.colorScheme.primary,
                        ),
                      ),
                      SelectableText(
                        semanticsLabel: context.l10n.messageTime,
                        ' $messageDate, $messageTime$messageTimeZone',
                        style: context.theme.textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).isDark
                              ? context.theme.colorScheme.onPrimaryContainer
                              : context.theme.colorScheme.primary,
                        ),
                      ),
                      if (isMod)
                        Container(
                          color: Theme.of(context).primaryColor,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(
                            vertical: 3,
                            horizontal: 4,
                          ),
                          child: HeightConstrainedText(
                            isAdmin ? 'ADMIN' : 'MOD',
                            style: context.theme.textTheme.labelMedium!
                                .copyWith(
                              color: context.theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      if (widget.isSending)
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          height: 14,
                          width: 14,
                          alignment: Alignment.center,
                          child: CustomLoadingIndicator(),
                        ),
                    ],
                  ),
                  SizedBox(height: 4),
                  if (_removed)
                    HeightConstrainedText(
                      'This message was removed.',
                      style: context.theme.textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).isDark
                            ? context.theme.colorScheme.onPrimaryContainer
                            : context.theme.colorScheme.secondary,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    // Note: There are highlighting issues due to the below
                    // https://github.com/Cretezy/flutter_linkify/issues/59
                    // https://github.com/Cretezy/flutter_linkify/issues/54
                    Semantics(
                      label: context.l10n.chatMessage,
                      child: SelectableLinkify(
                        text: widget.message.message ?? '',
                        style: context.theme.textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).isDark
                              ? context.theme.colorScheme.onPrimary
                              : context.theme.colorScheme.primary,
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
                        ? context.theme.colorScheme.surface
                        : context.theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
              ),
          ],
        );

        return MouseRegion(
          onEnter: (_) => _isHovered.value = true,
          onExit: (_) => _isHovered.value = false,
          child: Semantics(
            label: context.l10n.chatMessage,
            child: ValueListenableBuilder<bool>(
              valueListenable: _isHovered,
              // `child` is the pre-built content Row — Flutter reuses it
              // unchanged when the ValueNotifier fires, so only the Container
              // decoration is re-evaluated on hover.
              child: content,
              builder: (context, isHovered, child) => Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                color: isHovered
                    ? context.theme.colorScheme.scrim.withScrimOpacity
                    : null,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
