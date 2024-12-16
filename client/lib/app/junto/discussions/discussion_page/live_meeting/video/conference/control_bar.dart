import 'dart:async';

import 'package:flutter/material.dart';
import 'package:junto/app/junto/chat/chat_model.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_tabs/discussion_tabs_model.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/live_meeting_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/video/conference/audio_video_error.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/video/conference/audio_video_settings.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/video/conference/conference_room.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/video/conference/talking_odometer/talking_odometer.dart';
import 'package:junto/app/junto/discussions/instant_unify/unify_america_controller.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/common_widgets/junto_text_field.dart';
import 'package:junto/common_widgets/junto_ui_migration.dart';
import 'package:junto/common_widgets/user_info_builder.dart';
import 'package:junto/services/logging_service.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/extensions.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto/utils/platform_utils.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_html/js_util.dart' as js_util;

class ControlBar extends StatefulWidget {
  @override
  _ControlBarState createState() => _ControlBarState();
}

class _ControlBarState extends State<ControlBar> {
  LiveMeetingProvider get _liveMeetingProvider =>
      Provider.of<LiveMeetingProvider>(context);

  ConferenceRoom get _conferenceRoom => _liveMeetingProvider.conferenceRoom!;

  ConferenceRoom get _conferenceRoomRead =>
      LiveMeetingProvider.read(context).conferenceRoom!;

  Widget _buildScreenShareButton() {
    if (!_conferenceRoomRead.isLocalSharingScreenActive &&
        _conferenceRoomRead.screenSharer != null) {
      return UserInfoBuilder(
        userId: _conferenceRoomRead.screenSharerUserId,
        builder: (_, isLoading, snapshot) => ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 200),
          child: JuntoText(
              '${isLoading ? 'A participant' : snapshot.data?.displayName ?? 'A participant'} is screen sharing'),
        ),
      );
    } else {
      return JuntoText(_conferenceRoomRead.isLocalSharingScreenActive
          ? 'Stop Sharing'
          : 'Share Screen');
    }
  }

  Widget _buildVideoToggle() {
    return _IconButton(
      onTap: () => AudioVideoErrorDialog.showOnError(
          context, () => _conferenceRoomRead.toggleVideoEnabled()),
      text: _conferenceRoom.videoEnabled ? 'Stop Video' : 'Start Video',
      icon: _conferenceRoom.videoEnabled
          ? Icons.videocam_outlined
          : Icons.videocam_off_outlined,
      iconColor:
          _conferenceRoom.videoEnabled ? AppColor.white : AppColor.redDarkMode,
    );
  }

  Widget _buildMoreOptionsButton() {
    final enabled = !_liveMeetingProvider.audioTemporarilyDisabled;

    // To implement screensharing, uncomment this flag and add in Agora functionality
    const enableScreenshare = false;

    final mediaDevices = html.window.navigator.mediaDevices;
    return JuntoUiMigration(
      whiteBackground: true,
      child: JuntoInkWell(
        hoverColor: AppColor.white.withOpacity(0.15),
        forceHighlightOnHover: true,
        child: PopupMenuButton<FutureOr<void> Function()>(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: () =>
                  AudioVideoSettingsDialog(conferenceRoom: _conferenceRoomRead)
                      .show(),
              child: JuntoText(
                'Audio/Video Settings',
              ),
            ),
            if (enableScreenshare &&
                !responsiveLayoutService.isMobile(context) &&
                mediaDevices != null &&
                js_util.hasProperty(mediaDevices, 'getDisplayMedia') &&
                context.read<DiscussionProvider>().enableScreenshare)
              PopupMenuItem(
                enabled: enabled,
                value: enabled
                    ? () => alertOnError(
                        context, () => _conferenceRoomRead.toggleScreenShare())
                    : null,
                child: _buildScreenShareButton(),
              ),
          ],
          onSelected: (itemAction) => itemAction(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.center,
            child: Icon(
              Icons.more_horiz,
              size: 32,
              color: AppColor.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlWidgets() {
    final enabled = !_liveMeetingProvider.audioTemporarilyDisabled;
    final isMobile = responsiveLayoutService.isMobile(context);
    final double spacerWidth = isMobile ? 6 : 12;
    bool showTalkingTimer = !isMobile &&
        UnifyAmericaController.watch(context) == null &&
        context.watch<DiscussionProvider>().enableTalkingTimer;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: spacerWidth),
        _buildVideoToggle(),
        _IconButton(
          onTap: enabled
              ? () => AudioVideoErrorDialog.showOnError(
                  context, () => _conferenceRoomRead.toggleAudioEnabled())
              : () async {
                  showRegularToast(
                    context,
                    'All participants are muted during video!',
                    toastType: ToastType.success,
                  );
                },
          text: _conferenceRoom.audioEnabled ? 'Mute' : 'Unmute',
          icon: _conferenceRoom.audioEnabled
              ? Icons.mic_outlined
              : Icons.mic_off_outlined,
          iconColor: _conferenceRoom.audioEnabled
              ? AppColor.white
              : AppColor.redDarkMode,
        ),
        _buildMoreOptionsButton(),
        SizedBox(width: spacerWidth),
        if (showTalkingTimer) ...[
          TalkingOdometer(),
          SizedBox(width: spacerWidth),
        ]
      ],
    );
  }

  Widget _buildChatSectionWidgets() {
    return Flexible(child: ChatAndEmojisInput());
  }

  Widget _buildLeaveButton() {
    EdgeInsets padding = EdgeInsets.symmetric(horizontal: 26);

    final needHelpIsLaunched =
        UnifyAmericaController.watch(context)?.isNeedsHelpLaunched ?? false;
    if (needHelpIsLaunched && !responsiveLayoutService.isMobile(context)) {
      padding += EdgeInsets.only(right: 70);
    }

    return Container(
      alignment: Alignment.center,
      padding: padding,
      child: ActionButton(
        onPressed: () => LiveMeetingProvider.read(context).leaveMeeting(),
        text: 'Leave',
        color: AppColor.redLightMode,
        textColor: AppColor.white,
        sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final discussionTabsControllerState =
        Provider.of<DiscussionTabsControllerState>(context).widget;
    final isInLiveStreamLobby =
        DiscussionProvider.watch(context).isLiveStream &&
            !LiveMeetingProvider.watch(context).isInBreakout;
    final isChatBarVisible = !isInLiveStreamLobby &&
        discussionTabsControllerState.enableChat &&
        context.watch<DiscussionProvider>().enableFloatingChat;
    return AnimatedBuilder(
      animation: _liveMeetingProvider.conferenceRoomNotifier,
      builder: (context, __) => Container(
        color: AppColor.gray1,
        height: 90,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_liveMeetingProvider.conferenceRoom?.room == null)
              SizedBox.shrink()
            else
              _buildControlWidgets(),
            if (!responsiveLayoutService.isMobile(context) && isChatBarVisible)
              _buildChatSectionWidgets(),
            _buildLeaveButton(),
          ],
        ),
      ),
    );
  }
}

class ChatAndEmojisInput extends StatefulWidget {
  @override
  State<ChatAndEmojisInput> createState() => _ChatAndEmojisInputState();
}

class _ChatAndEmojisInputState extends State<ChatAndEmojisInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = responsiveLayoutService.isMobile(context);
    final spacer = SizedBox(width: isMobile ? 4 : 10);
    final isInLiveStreamLobby =
        DiscussionProvider.watch(context).isLiveStream &&
            !LiveMeetingProvider.watch(context).isInBreakout;
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          spacer,
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 500),
              child: JuntoPointerInterceptor(
                child: ChatInput(
                  controller: _controller,
                  messageInputHint: 'Say something',
                  shouldGuardJuntoMember: false,
                ),
              ),
            ),
          ),
          spacer,
          if (!isInLiveStreamLobby &&
              (!isMobile || _controller.text.isEmpty)) ...[
            EmojiButton(emoji: EmotionType.laughWithTears),
            spacer,
            EmojiButton(emoji: EmotionType.thumbsUp),
            spacer,
            EmojiButton(emoji: EmotionType.heart),
            spacer,
          ],
        ],
      ),
    );
  }
}

class EmojiButton extends StatefulWidget {
  final EmotionType emoji;

  const EmojiButton({required this.emoji});

  @override
  _EmojiButtonState createState() => _EmojiButtonState();
}

class _EmojiButtonState extends State<EmojiButton> {
  Future<void>? _currentNetworkCall;

  @override
  Widget build(BuildContext context) {
    final isMobile = responsiveLayoutService.isMobile(context);
    final borderRadius = BorderRadius.circular(isMobile ? 25 : 50);
    return JuntoInkWell(
      onTap: () async {
        if (_currentNetworkCall != null) return;

        setState(() {
          _currentNetworkCall = alertOnError(
              context,
              () => context.read<ChatModel>().createChatMessage(
                    emotionType: widget.emoji,
                  ));
        });

        await _currentNetworkCall;
        setState(() {
          _currentNetworkCall = null;
        });
      },
      borderRadius: borderRadius,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 20,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: AppColor.gray2,
          borderRadius: borderRadius,
        ),
        child: JuntoImage(
          null,
          asset: widget.emoji.imageAssetPath,
          loadingColor: Colors.transparent,
          width: 18,
          height: 18,
        ),
      ),
    );
  }
}

class ChatInput extends StatefulWidget {
  final String messageInputHint;
  final bool shouldGuardJuntoMember;
  final TextEditingController controller;

  const ChatInput({
    required this.messageInputHint,
    required this.shouldGuardJuntoMember,
    required this.controller,
  });

  @override
  _ChatInputState createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _sendController = SubmitNotifier();

  bool get canSubmit => !isNullOrEmpty(widget.controller.text.trim());

  Future<void> _sendMessageWithAlert() => alertOnError(context, () async {
        final text = widget.controller.text;
        WidgetsBinding.instance
            ?.addPostFrameCallback((_) => widget.controller.clear());
        await context.read<ChatModel>().createChatMessage(text: text);
      });

  Future<void> _sendMessage() => widget.shouldGuardJuntoMember
      ? guardJuntoMember(
          context,
          Provider.of<JuntoProvider>(context, listen: false).junto,
          _sendMessageWithAlert)
      : _sendMessageWithAlert();

  @override
  Widget build(BuildContext context) {
    final isMobile = responsiveLayoutService.isMobile(context);

    return Container(
      padding: isMobile
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: JuntoTextField(
              cursorColor: AppColor.white,
              borderType: BorderType.none,
              textStyle: body.copyWith(color: AppColor.white),
              hintStyle: body.copyWith(color: AppColor.gray2),
              backgroundColor: AppColor.gray2,
              borderRadius: isMobile ? 25 : 10,
              padding: isMobile ? EdgeInsets.only(bottom: 6) : EdgeInsets.zero,
              contentPadding: isMobile
                  ? EdgeInsets.symmetric(horizontal: 14, vertical: 12)
                  : EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              onEditingComplete:
                  canSubmit ? _sendController.submit : widget.controller.clear,
              controller: widget.controller,
              maxLines: 2,
              minLines: 1,
              hintText: widget.messageInputHint,
              unfocusOnSubmit: false,
              maxLength: 2000,
              hideCounter: true,
            ),
          ),
          if (!isMobile || widget.controller.text.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(
                left: 10,
                bottom: isMobile ? 4 : 0,
              ),
              child: Semantics(label:'Submit Chat Button',button: true, 
              child: ActionButton(
                minWidth: 20,
                color: AppColor.darkBlue,
                controller: _sendController,
                onPressed: canSubmit ? _sendMessage : null,
                disabledColor: AppColor.white.withOpacity(0.3),
                height: isMobile ? 50 : 55,
                
                child: Icon(
                  Icons.send,
                  color: canSubmit ? AppColor.brightGreen : AppColor.gray2,
                ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _IconButton extends StatefulWidget {
  final Future<void> Function() onTap;
  final String text;
  final IconData icon;
  final Color iconColor;

  const _IconButton({
    required this.onTap,
    required this.text,
    required this.icon,
    this.iconColor = AppColor.white,
  });

  @override
  _IconButtonState createState() => _IconButtonState();
}

class _IconButtonState extends State<_IconButton> {
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    return JuntoInkWell(
      onTap: () async {
        if (_isSending) return;
        setState(() => _isSending = true);
        try {
          await widget.onTap();
          // Prevent someone from tapping it twice in quick succession
          await Future.delayed(Duration(milliseconds: 200), () {});
        } catch (e, stacktrace) {
          loggingService.log(
            'Error in icon button',
            logType: LogType.error,
            error: e,
            stackTrace: stacktrace,
          );
        }

        setState(() => _isSending = false);
      },
      hoverColor: AppColor.white.withOpacity(0.15),
      child: Container(
        padding: const EdgeInsets.all(2),
        constraints: BoxConstraints(
            minWidth: 80,
            maxWidth: responsiveLayoutService.isMobile(context)
                ? 86
                : double.infinity),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 40,
              child: Icon(widget.icon,
                  size: 34,
                  color: _isSending ? AppColor.gray3 : widget.iconColor),
            ),
            SizedBox(height: 2),
            JuntoText(
              widget.text,
              textAlign: TextAlign.center,
              style: body.copyWith(
                color: _isSending ? AppColor.gray3 : AppColor.white,
                fontWeight: FontWeight.w400,
                height: 1.05,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
