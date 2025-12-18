import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:client/core/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:client/features/events/features/event_page/data/providers/event_permissions_provider.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/event_page/presentation/widgets/event_tabs.dart';
import 'package:client/features/events/features/live_meeting/presentation/widgets/live_meeting_desktop.dart';
import 'package:client/features/events/features/live_meeting/presentation/views/live_meeting_mobile_page.dart';
import 'package:client/features/events/features/live_meeting/data/providers/live_meeting_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_guide/data/providers/meeting_guide_card_store.dart';
import 'package:client/features/events/features/live_meeting/features/video/data/providers/conference_room.dart';
import 'package:client/features/events/features/live_meeting/data/providers/use_kick_proposal_listeners.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/widgets/meeting_agenda.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/providers/meeting_agenda_provider.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/core/widgets/navbar/nav_bar_provider.dart';
import 'package:client/services.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/live_meetings/live_meeting.dart';
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
    return ChangeNotifierProvider(
      create: (context) => LiveMeetingProvider(
        communityProvider: CommunityProvider.read(context),
        eventProvider: EventProvider.read(context),
        navBarProvider: Provider.of<NavBarProvider>(context, listen: false),
        isInstant: isInstant,
        leaveLocation: leaveLocation,
        onLeave: onLeave,
        showToast: (String message, {bool? hideOnMobile}) {
          final hideToast =
              hideOnMobile == true && responsiveLayoutService.isMobile(context);
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

  @override
  MeetingDialogState createState() => MeetingDialogState();
}

class MeetingDialogState extends State<MeetingDialog> {
  LiveMeetingProvider get liveMeetingProvider =>
      Provider.of<LiveMeetingProvider>(context);

  EventProvider get eventProvider => Provider.of<EventProvider>(context);

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

  @override
  Widget build(BuildContext context) {
    final event = eventProvider.event;
    final permissions = Provider.of<EventPermissionsProvider>(context);
    final liveMeetingKey = ObjectKey(ConferenceRoom.read(context));

    return PopScope(
      // onPopInvoked: (didPop) async {
      //   await Provider.of<LiveMeetingProvider>(context, listen: false)
      //       .leaveMeeting();
      // },
      child: SizedBox.expand(
        child: _StreamLoadingWrapper(
          eventProvider: eventProvider,
          child: MeetingAgendaWrapper(
            communityId: eventProvider.communityId,
            event: event,
            labelColor: Colors.white60,
            child: Builder(
              builder: (context) {
                final liveMeetingProvider = LiveMeetingProvider.watch(context);

                final agendaProvider = Provider.of<AgendaProvider>(context);
                final communityProvider = CommunityProvider.watch(context);

                final bool enableGuide = (eventProvider.agendaPreview ||
                    context
                        .watch<EventPermissionsProvider>()
                        .isAgendaVisibleOverride ||
                    liveMeetingProvider.isInBreakout);

                return ChangeNotifierProvider(
                  key: Key(agendaProvider.liveMeetingPath),
                  create: (context) => MeetingGuideCardStore(
                    communityProvider: communityProvider,
                    liveMeetingProvider: liveMeetingProvider,
                    agendaProvider: agendaProvider,
                    showToast: (String message) => showRegularToast(
                      context,
                      message,
                      toastType: ToastType.success,
                    ),
                  )..initialize(),
                  child: EventTabsWrapper(
                    meetingAgendaBuilder: (context) => MeetingAgenda(
                      canUserEditAgenda: context
                          .watch<EventPermissionsProvider>()
                          .canEditEvent,
                      displayLocation: MeetingAgendaDisplayLocation.meetingPage,
                    ),
                    enableGuide: enableGuide,
                    enableUserSubmittedAgenda:
                        eventProvider.event.eventType == EventType.livestream &&
                            !liveMeetingProvider.isInBreakout,
                    enableChat:
                        (permissions.canChat && eventProvider.enableChat),
                    enableAdminPanel: permissions.canAccessAdminTabInEvent,
                    child: _ConferenceRoomWrapper(
                      child: responsiveLayoutService.isMobile(context)
                          ? LiveMeetingMobilePage(key: liveMeetingKey)
                          : LiveMeetingDesktopLayout(key: liveMeetingKey),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _StreamLoadingWrapper extends StatelessWidget {
  const _StreamLoadingWrapper({
    super.key,
    required this.eventProvider,
    required this.child,
  });

  final EventProvider eventProvider;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomStreamBuilder(
        entryFrom: 'MeetingDialogState._buildLoading1',
        stream: eventProvider.eventStream,
        errorMessage: 'There was an error loading event details.',
        builder: (_, __) => CustomStreamBuilder(
          entryFrom: 'MeetingDialogState._buildLoading2',
          stream: eventProvider.selfParticipantStream,
          errorMessage: 'There was an error loading event details.',
          builder: (_, __) => CustomStreamBuilder(
            entryFrom: 'MeetingDialogState._buildLoading3',
            stream: eventProvider.eventParticipantsStream,
            errorMessage: 'There was an error loading event details.',
            builder: (_, __) => CustomStreamBuilder(
              entryFrom: 'MeetingDialogState._buildLoading4',
              stream:
                  Provider.of<LiveMeetingProvider>(context).liveMeetingStream,
              errorMessage: 'There was an error loading event details.',
              builder: (context, __) => child,
            ),
          ),
        ),
      ),
    );
  }
}

class _ConferenceRoomWrapper extends StatelessWidget {
  const _ConferenceRoomWrapper({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return HookBuilder(
      builder: (context) {
        useKickProposalListeners(context);

        // Load meeting if necessary, otherwise return child
        final liveMeetingProvider = LiveMeetingProvider.watch(context);

        if (liveMeetingProvider.leftMeeting) {
          return child;
        }

        // Look up correct future
        Future<GetMeetingJoinInfoResponse>? loadingFuture =
            liveMeetingProvider.getCurrentMeetingJoinInfo();
        if (loadingFuture == null) {
          return child;
        }

        return CustomStreamBuilder<GetMeetingJoinInfoResponse>(
          entryFrom: '_buildConferenceRoomWrapper.build',
          key: ObjectKey(loadingFuture),
          stream: loadingFuture.asStream(),
          errorBuilder: (context) => Container(
            padding: const EdgeInsets.all(12),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                HeightConstrainedText(
                  'There was an error connecting to the room.',
                ),
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
            if (liveMeetingProvider.currentBreakoutRoomId ==
                breakoutsWaitingRoomId) {
              return child;
            }

            return ChangeNotifierProvider(
              create: (context) => ConferenceRoom(
                liveMeetingProvider: liveMeetingProvider,
                agendaProvider: AgendaProvider.read(context),
                communityProvider: CommunityProvider.read(context),
                meetingGuideCardModel: MeetingGuideCardStore.read(context)!,
                roomName: response.meetingId,
                token: response.meetingToken,
              )..initialize(context),
              builder: (_, __) => child,
            );
          },
        );
      },
    );
  }
}
