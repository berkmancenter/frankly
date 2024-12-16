import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:junto/app/junto/discussions/discussion_page/av_check/av_check.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_permissions_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_tabs/discussion_tabs.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/live_meeting_desktop.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/live_meeting_mobile/live_meeting_mobile_page.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/live_meeting_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/meeting_guide/meeting_guide_card_store.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/video/conference/conference_room.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/use_kick_proposal_listeners.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/meeting_agenda.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/meeting_agenda_provider.dart';
import 'package:junto/app/junto/discussions/instant_unify/unify_america_controller.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/common_widgets/junto_ui_migration.dart';
import 'package:junto/common_widgets/navbar/nav_bar_provider.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/cloud_functions/requests.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/live_meeting.dart';
import 'package:provider/provider.dart';

class MeetingDialog extends StatefulWidget {
  static const enterMeetingPromptButton = Key('enter-meeting-prompt');

  const MeetingDialog._();

  static Widget create({
    bool isInstant = false,
    BeamLocation? leaveLocation,
    Function()? onLeave,
    bool avCheckEnabled = false,
  }) {
    if (!sharedPreferencesService.getAvCheckComplete() && avCheckEnabled) {
      return AvCheckPage();
    } else {
      return ChangeNotifierProvider(
        create: (context) => LiveMeetingProvider(
          juntoProvider: JuntoProvider.read(context),
          discussionProvider: DiscussionProvider.read(context),
          navBarProvider: Provider.of<NavBarProvider>(context, listen: false),
          isInstant: isInstant,
          leaveLocation: leaveLocation,
          onLeave: onLeave,
          isUnifyAmerica: UnifyAmericaController.read(context) != null,
          showToast: (String message, {bool? hideOnMobile}) {
            final hideToast = hideOnMobile == true && responsiveLayoutService.isMobile(context);
            if (!hideToast) {
              return showRegularToast(
                context,
                message,
                toastType: ToastType.success,
              );
            }
          },
        ),
        child: MeetingDialog._(),
      );
    }
  }

  @override
  _MeetingDialogState createState() => _MeetingDialogState();
}

class _MeetingDialogState extends State<MeetingDialog> {
  LiveMeetingProvider get liveMeetingProvider => Provider.of<LiveMeetingProvider>(context);

  DiscussionProvider get discussionProvider => Provider.of<DiscussionProvider>(context);

  @override
  void initState() {
    context.read<LiveMeetingProvider>().initialize();
    dialogProvider.isOnIframePage = true;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    dialogProvider.isOnIframePage = false;
  }

  Widget _buildVideoLayout() {
    final liveMeetingKey = ObjectKey(ConferenceRoom.read(context));
    if (responsiveLayoutService.isMobile(context)) {
      return LiveMeetingMobilePage(key: liveMeetingKey);
    }
    return LiveMeetingDesktopLayout(key: liveMeetingKey);
  }

  Widget _buildConferenceRoomWrapper({
    required Widget child,
  }) {
    return HookBuilder(
      builder: (context) {
        useKickProposalListeners(context);

        // Load meeting if necessary, otherwise return child
        final liveMeetingProvider = LiveMeetingProvider.watch(context);

        if (liveMeetingProvider.leftMeeting) {
          return child;
        }

        // Look up correct future
        Future<GetMeetingJoinInfoResponse>? _loadingFuture =
            liveMeetingProvider.getCurrentMeetingJoinInfo();
        if (_loadingFuture == null) {
          return child;
        }

        return JuntoStreamBuilder<GetMeetingJoinInfoResponse>(
          entryFrom: '_buildConferenceRoomWrapper.build',
          key: ObjectKey(_loadingFuture),
          stream: _loadingFuture.asStream(),
          errorBuilder: (context) => Container(
            padding: const EdgeInsets.all(12),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                JuntoText('There was an error connecting to the room.'),
                SizedBox(height: 24),
                ActionButton(
                  text: 'Reload',
                  onPressed: () => liveMeetingProvider.refreshMeeting(),
                ),
              ],
            ),
          ),
          loadingMessage: 'Loading room. Please wait...',
          buildWhileLoading: true,
          builder: (_, response) {
            if (response == null) {
              return child;
            }

            // We need to call getCurrentJoinInfo above for the waiting room so that the users
            // presence will be updated to the waiting room. Without this, the user will not show
            // up in the list of people in the waiting room. We don't want to load a conference room
            // for them however.
            if (liveMeetingProvider.currentBreakoutRoomId == breakoutsWaitingRoomId) {
              return child;
            }

            return ChangeNotifierProvider(
              create: (context) => ConferenceRoom(
                liveMeetingProvider: liveMeetingProvider,
                agendaProvider: AgendaProvider.read(context),
                juntoProvider: JuntoProvider.read(context),
                meetingGuideCardModel: MeetingGuideCardStore.read(context)!,
                roomName: response.meetingId,
                token: response.meetingToken,
                isUnifyAmerica: UnifyAmericaController.read(context) != null,
              )..initialize(context),
              builder: (_, __) => child,
            );
          },
        );
      },
    );
  }

  Widget _buildAgendaWrapper(BuildContext context) {
    final discussionProvider = Provider.of<DiscussionProvider>(context);
    final discussion = discussionProvider.discussion;
    final permissions = Provider.of<DiscussionPermissionsProvider>(context);

    return MeetingAgendaWrapper(
      juntoId: discussionProvider.juntoId,
      discussion: discussion,
      backgroundColor: AppColor.darkerBlue,
      labelColor: Colors.white60,
      child: Builder(
        builder: (context) {
          final liveMeetingProvider = LiveMeetingProvider.watch(context);

          final agendaProvider = Provider.of<AgendaProvider>(context);
          final juntoProvider = JuntoProvider.watch(context);

          final bool enableGuide = UnifyAmericaController.watch(context) == null &&
              (discussionProvider.agendaPreview ||
                  context.watch<DiscussionPermissionsProvider>().isAgendaVisibleOverride ||
                  liveMeetingProvider.isInBreakout);

          final hideChat = juntoProvider.isAmericaTalks &&
              discussionProvider.discussion.discussionType == DiscussionType.hostless &&
              !liveMeetingProvider.isInBreakout;

          return ChangeNotifierProvider(
            key: Key(agendaProvider.liveMeetingPath),
            create: (context) => MeetingGuideCardStore(
              juntoProvider: juntoProvider,
              liveMeetingProvider: liveMeetingProvider,
              agendaProvider: agendaProvider,
              showToast: (String message) => showRegularToast(
                context,
                message,
                toastType: ToastType.success,
              ),
            )..initialize(),
            child: DiscussionTabsWrapper(
              meetingAgendaBuilder: (context) => MeetingAgenda(
                canUserEditAgenda: context.watch<DiscussionPermissionsProvider>().canEditDiscussion,
              ),
              enableGuide: enableGuide,
              enableUserSubmittedAgenda:
                  discussionProvider.discussion.discussionType == DiscussionType.livestream &&
                      !liveMeetingProvider.isInBreakout,
              enableChat: !hideChat && (permissions.canChat && discussionProvider.enableChat),
              enableAdminPanel: permissions.canAccessAdminTabInDiscussion,
              child: _buildConferenceRoomWrapper(
                child: _buildVideoLayout(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: JuntoStreamBuilder(
        entryFrom: '_MeetingDialogState._buildLoading1',
        stream: discussionProvider.discussionStream,
        errorMessage: 'There was an error loading event details.',
        builder: (_, __) => JuntoStreamBuilder(
          entryFrom: '_MeetingDialogState._buildLoading2',
          stream: discussionProvider.selfParticipantStream,
          errorMessage: 'There was an error loading event details.',
          builder: (_, __) => JuntoStreamBuilder(
            entryFrom: '_MeetingDialogState._buildLoading3',
            stream: discussionProvider.discussionParticipantsStream,
            errorMessage: 'There was an error loading event details.',
            builder: (_, __) => JuntoStreamBuilder(
              entryFrom: '_MeetingDialogState._buildLoading4',
              stream: Provider.of<LiveMeetingProvider>(context).liveMeetingStream,
              errorMessage: 'There was an error loading event details.',
              builder: (context, __) => _buildAgendaWrapper(context),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Provider.of<LiveMeetingProvider>(context, listen: false).leaveMeeting();
        return Future.value(false);
      },
      child: Material(
        color: AppColor.darkBlue,
        child: SizedBox.expand(
          child: JuntoUiMigration(
            child: _buildLoading(),
          ),
        ),
      ),
    );
  }
}
