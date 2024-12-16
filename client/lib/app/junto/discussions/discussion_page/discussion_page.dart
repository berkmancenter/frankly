import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:junto/app/junto/community_permissions_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_page_contract.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_page_meeting_agenda.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_page_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_permissions_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_tabs/discussion_tabs.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/live_meeting_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/meeting_dialog.dart';
import 'package:junto/app/junto/discussions/discussion_page/topic_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/discussion_info.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/common_widgets/junto_ui_migration.dart';
import 'package:junto/common_widgets/navbar/nav_bar_provider.dart';
import 'package:junto/common_widgets/sign_in_dialog.dart';
import 'package:junto/common_widgets/tabs/tab_bar.dart';
import 'package:junto/common_widgets/tabs/tab_bar_view.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_asset.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/dialog_provider.dart';
import 'package:junto/utils/dialogs.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/discussion_message.dart';
import 'package:pedantic/pedantic.dart';
import 'package:provider/provider.dart';

import 'discussion_page_presenter.dart';

class DiscussionPage extends StatefulWidget {
  final String topicId;
  final String discussionId;
  final bool cancel;
  final String? uid;

  const DiscussionPage({
    required this.topicId,
    required this.discussionId,
    required this.cancel,
    this.uid,
    Key? key,
  }) : super(key: key);

  Widget create() {
    return JuntoUiMigration(
      child: ChangeNotifierProvider(
        create: (context) => DiscussionProvider(
          juntoProvider: context.read<JuntoProvider>(),
          topicId: topicId,
          discussionId: discussionId,
        ),
        child: ChangeNotifierProvider(
          create: (context) => TopicProvider(
            juntoId: context.read<JuntoProvider>().juntoId,
            topicId: topicId,
          ),
          child: ChangeNotifierProvider(
            create: (context) => DiscussionPageProvider(
              discussionProvider: context.read<DiscussionProvider>(),
              juntoProvider: context.read<JuntoProvider>(),
              navBarProvider: context.read<NavBarProvider>(),
              cancelParam: cancel,
            ),
            child: ChangeNotifierProvider(
              create: (context) => DiscussionPermissionsProvider(
                discussionProvider: context.read<DiscussionProvider>(),
                communityPermissions: context.read<CommunityPermissionsProvider>(),
                juntoProvider: context.read<JuntoProvider>(),
              ),
              child: this,
            ),
          ),
        ),
      ),
    );
  }

  @override
  _DiscussionPageState createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<DiscussionPage> implements DiscussionPageView {
  DiscussionProvider get _discussionProvider => DiscussionProvider.watch(context);

  Discussion get discussion => _discussionProvider.discussion;

  bool get userIsJoined => _discussionProvider.isParticipant;

  DiscussionSettings get discussionSettings {
    final discussionSettings = context.watch<DiscussionProvider>().discussion.discussionSettings;
    final communityDiscussionSettings = context.watch<JuntoProvider>().discussionSettings;

    return discussionSettings ?? communityDiscussionSettings;
  }

  late final DiscussionPagePresenter _presenter;

  // This is to rebuild the page when the in-meeting query parameter is applied
  void onRouterUpdate() => setState(() {});

  @override
  void initState() {
    DiscussionProvider.read(context).initialize();
    context.read<TopicProvider>().initialize();
    context.read<DiscussionPageProvider>().initialize();

    if (!isNullOrEmpty(widget.uid)) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        if (!userService.isSignedIn) {
          SignInDialog.show();
        }
      });
    }

    routerDelegate.addListener(onRouterUpdate);

    super.initState();

    _presenter = DiscussionPagePresenter(context, this);
    _presenter.init();
  }

  @override
  void dispose() {
    routerDelegate.removeListener(onRouterUpdate);
    super.dispose();
  }

  @override
  void updateView() {
    if (mounted) setState(() {});
  }

  Future<JoinDiscussionResults> _joinDiscussion({
    bool showConfirm = true,
    bool joinJunto = false,
  }) async {
    return await alertOnError<JoinDiscussionResults>(
            context,
            () => context
                .read<DiscussionPageProvider>()
                .joinDiscussion(showConfirm: showConfirm, joinJunto: joinJunto)) ??
        JoinDiscussionResults(isJoined: false);
  }

  Future<void> _startMeeting() async {
    final discussionPageProvider = context.read<DiscussionPageProvider>();
    JoinDiscussionResults? joinResults;
    if (DiscussionProvider.read(context).isParticipant) {
      joinResults = await _joinDiscussion(showConfirm: false);
      if (!joinResults.isJoined) return;
    }
    unawaited(firebaseAnalytics.logEvent(name: 'discussion_start'));
    await alertOnError(
        context,
        () => discussionPageProvider.enterMeeting(
              surveyQuestions: joinResults?.surveyQuestions,
            ));
  }

  Future<void> _showSendMessageDialog() async {
    final isMobile = responsiveLayoutService.isMobile(context);

    final message = await Dialogs.showComposeMessageDialog(
      context,
      title: 'Message Participants',
      isMobile: isMobile,
      labelText: 'Message',
      validator: (message) => message == null || message.isEmpty ? 'Message cannot be empty' : null,
      positiveButtonText: 'Send',
    );

    if (message != null) {
      await alertOnError(context, () => _presenter.sendMessage(message));
    }
  }

  Future<void> _showRemoveMessageDialog(DiscussionMessage discussionMessage) async {
    await showJuntoDialog(builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColor.white,
        title: Text(
          'Are you sure you want to remove this message?',
          style: AppTextStyle.headline3.copyWith(color: AppColor.darkBlue),
        ),
        actions: [
          ActionButton(
            text: 'No',
            color: AppColor.darkBlue,
            textColor: AppColor.brightGreen,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          ActionButton(
            text: 'Yes',
            color: AppColor.darkBlue,
            textColor: AppColor.brightGreen,
            onPressed: () => alertOnError(context, () async {
              await _presenter.removeMessage(discussionMessage);
              Navigator.pop(context);
            }),
          ),
        ],
      );
    });
  }

  bool _isEnterConversationGraphicShown(DateTime scheduled) {
    final isParticipant = DiscussionProvider.watch(context).isParticipant;
    final now = clockService.now();
    final beforeMeetingCutoff = scheduled.subtract(Duration(minutes: 10));
    final afterMeetingCutoff = scheduled.add(Duration(hours: 2));

    return isParticipant && now.isAfter(beforeMeetingCutoff) && now.isBefore(afterMeetingCutoff);
  }

  Widget _buildGuide() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isEnterConversationGraphicShown(discussion.scheduledTime!)) ...[
          JuntoInkWell(
            onTap: _startMeeting,
            child: SizedBox(
              height: 380,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: JuntoImage(
                      null,
                      asset: AppAsset('media/background.gif'),
                      fit: BoxFit.cover,
                      loadingColor: Colors.transparent,
                    ),
                  ),
                  Container(
                    color: AppColor.black.withOpacity(0.7),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        JuntoText(
                          'The event is starting',
                          style: TextStyle(
                            color: AppColor.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        ActionButton(
                          text: 'Enter Event',
                          onPressed: _startMeeting,
                          height: 65,
                          sendingIndicatorAlign: ActionButtonSendingIndicatorAlign.none,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 4),
        ],
        JuntoTabBar(
          padding: EdgeInsets.zero,
          isWhiteBackground: true,
        ),
        SizedBox(height: 16),
        JuntoTabBarView(keepAlive: !responsiveLayoutService.isMobile(context)),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDiscussionTabsWrappedGuide() {
    final discussionProvider = DiscussionProvider.watch(context);
    final juntoProvider = JuntoProvider.watch(context);
    final isInBreakouts = LiveMeetingProvider.watchOrNull(context)?.isInBreakout ?? false;
    final isParticipant = discussionProvider.isParticipant;
    final isMod = Provider.of<CommunityPermissionsProvider>(context).canModerateContent;
    final canEdit = Provider.of<CommunityPermissionsProvider>(context).canEditCommunity;

    final hasPrePostContent = (discussionProvider.discussion.preEventCardData?.hasData ?? false) ||
        (discussionProvider.discussion.postEventCardData?.hasData ?? false);

    final bool enableGuide = isInBreakouts ||
        discussionProvider.agendaPreview ||
        context.watch<DiscussionPermissionsProvider>().isAgendaVisibleOverride;

    final discussionPermissions = context.watch<DiscussionPermissionsProvider>();

    final hideChat = juntoProvider.isAmericaTalks &&
        discussionProvider.discussion.discussionType == DiscussionType.hostless;

    return DiscussionTabsWrapper(
      onRemoveMessage: (discussionMessage) => _showRemoveMessageDialog(discussionMessage),
      meetingAgendaBuilder: (context) => DiscussionPageMeetingAgenda(),
      enableChat: !hideChat && (discussionPermissions.canChat && discussionProvider.enableChat),
      enablePrePostEvent: canEdit || (isParticipant && hasPrePostContent),
      enableMessages: isParticipant || isMod,
      enableGuide: enableGuide,
      child: _buildGuide(),
    );
  }

  Widget _buildMainContent() {
    final isMobile = responsiveLayoutService.isMobile(context);
    final discussionProvider = DiscussionProvider.watch(context);
    final discussion = discussionProvider.discussion;

    return JuntoUiMigration(
      whiteBackground: true,
      child: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            if (_presenter.isEditTemplateTooltipShown) _buildEditTemplateMessage(),
            if (isMobile) ...[
              Container(
                alignment: Alignment.topCenter,
                child: DiscussionInfo(
                  discussionPagePresenter: _presenter,
                  discussion: discussion,
                  onMessagePressed: () => _showSendMessageDialog(),
                  onJoinDiscussion: _joinDiscussion,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildDiscussionTabsWrappedGuide(),
              ),
            ] else ...[
              SizedBox(height: 40),
              ConstrainedBody(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 400,
                      alignment: Alignment.topCenter,
                      child: DiscussionInfo(
                        discussionPagePresenter: _presenter,
                        discussion: discussion,
                        onMessagePressed: () => _showSendMessageDialog(),
                        onJoinDiscussion: _joinDiscussion,
                      ),
                    ),
                    SizedBox(width: 40),
                    Expanded(
                      child: _buildDiscussionTabsWrappedGuide(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEditTemplateMessage() {
    String topicId = discussion.topicId;
    return Container(
      color: AppColor.gray5,
      padding: EdgeInsets.symmetric(vertical: 20),
      child: ConstrainedBody(
        maxWidth: 1100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  text: 'You are editing an event. \n',
                  style: AppTextStyle.headlineSmall.copyWith(
                    color: AppColor.gray2,
                    fontSize: 16,
                  ),
                  children: [
                    TextSpan(
                      text: 'If you want to edit future instances, ',
                      style: AppTextStyle.body.copyWith(color: AppColor.gray2),
                    ),
                    TextSpan(
                      text: 'edit the template.',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => routerDelegate.beamTo(
                              JuntoPageRoutes(
                                juntoDisplayId:
                                    Provider.of<JuntoProvider>(context, listen: false).displayId,
                              ).topicPage(topicId: topicId),
                            ),
                      style: AppTextStyle.body.copyWith(
                        color: AppColor.accentBlue,
                        decoration: TextDecoration.underline,
                      ),
                    )
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: () => _presenter.hideEditTooltip(),
              icon: Icon(
                Icons.close,
                color: AppColor.darkBlue,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final discussionProvider = context.watch<DiscussionProvider>();
    final discussionPermissions = context.watch<DiscussionPermissionsProvider>();

    if (context.watch<DiscussionPageProvider>().isEnteredMeeting) {
      final isInstant = context.watch<DiscussionPageProvider>().isInstant;
      // Ensure discussion is loaded in discussion stream before it is accessed
      return JuntoStreamBuilder<Discussion>(
          showLoading: false,
          entryFrom: '_DiscussionPageState.buildMeetingDialog',
          stream: Provider.of<DiscussionProvider>(context).discussionStream,
          builder: (context, snapshot) {
            if (snapshot == null) return CircularProgressIndicator();
            return MeetingDialog.create(
              avCheckEnabled: false, //discussionPermissions.avCheckEnabled,
              isInstant: isInstant,
            );
          });
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 2,
            color: AppColor.gray5,
          ),
        ),
      ),
      alignment: Alignment.topCenter,
      child: JuntoStreamBuilder<Discussion>(
        entryFrom: '_DiscussionPageState.build',
        stream: discussionProvider.discussionStream,
        builder: (_, discussion) => JuntoStreamBuilder<List<Participant>>(
          entryFrom: '_DiscussionPageState.build',
          stream: discussionProvider.discussionParticipantsStream,
          builder: (_, __) {
            if (discussion == null) return CircularProgressIndicator();

            return _buildMainContent();
          },
        ),
      ),
    );
  }

  @override
  void showMessage(String message, {ToastType toastType = ToastType.neutral}) {
    showRegularToast(context, message, toastType: toastType);
  }
}

class ExpandedOnDesktop extends StatelessWidget {
  const ExpandedOnDesktop({
    Key? key,
    this.flex = 1,
    required this.child,
  }) : super(key: key);

  final Widget child;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return responsiveLayoutService.isMobile(context) ? child : Expanded(flex: flex, child: child);
  }
}
