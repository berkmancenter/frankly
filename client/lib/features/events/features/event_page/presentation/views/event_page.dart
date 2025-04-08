import 'dart:async';

import 'package:client/core/utils/toast_utils.dart';
import 'package:client/core/widgets/constrained_body.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:client/features/community/data/providers/community_permissions_provider.dart';
import 'package:client/features/events/features/event_page/presentation/views/event_page_contract.dart';
import 'package:client/features/events/features/event_page/presentation/widgets/event_page_meeting_agenda.dart';
import 'package:client/features/events/features/event_page/data/providers/event_page_provider.dart';
import 'package:client/features/events/features/event_page/data/providers/event_permissions_provider.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/event_page/presentation/widgets/event_tabs.dart';
import 'package:client/features/events/features/live_meeting/data/providers/live_meeting_provider.dart';
import 'package:client/features/events/features/live_meeting/presentation/views/meeting_dialog.dart';
import 'package:client/features/events/features/event_page/data/providers/template_provider.dart';
import 'package:client/features/events/features/event_page/presentation/widgets/event_info.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/proxied_image.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/core/widgets/navbar/nav_bar_provider.dart';
import 'package:client/features/auth/presentation/views/sign_in_dialog.dart';
import 'package:client/core/widgets/tabs/tab_bar.dart';
import 'package:client/core/widgets/tabs/tab_bar_view.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_asset.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/data/providers/dialog_provider.dart';
import 'package:client/core/utils/dialogs.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/event_message.dart';
import 'package:provider/provider.dart';

import '../event_page_presenter.dart';

class EventPage extends StatefulWidget {
  final String templateId;
  final String eventId;
  final bool cancel;
  final String? uid;

  const EventPage({
    required this.templateId,
    required this.eventId,
    required this.cancel,
    this.uid,
    Key? key,
  }) : super(key: key);

  Widget create() {
    return ChangeNotifierProvider(
      create: (context) => EventProvider(
        communityProvider: context.read<CommunityProvider>(),
        templateId: templateId,
        eventId: eventId,
      ),
      child: ChangeNotifierProvider(
        create: (context) => TemplateProvider(
          communityId: context.read<CommunityProvider>().communityId,
          templateId: templateId,
        ),
        child: ChangeNotifierProvider(
          create: (context) => EventPageProvider(
            eventProvider: context.read<EventProvider>(),
            communityProvider: context.read<CommunityProvider>(),
            navBarProvider: context.read<NavBarProvider>(),
            cancelParam: cancel,
          ),
          child: ChangeNotifierProvider(
            create: (context) => EventPermissionsProvider(
              eventProvider: context.read<EventProvider>(),
              communityPermissions:
                  context.read<CommunityPermissionsProvider>(),
              communityProvider: context.read<CommunityProvider>(),
            ),
            child: this,
          ),
        ),
      ),
    );
  }

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> implements EventPageView {
  EventProvider get _eventProvider => EventProvider.watch(context);

  Event get event => _eventProvider.event;

  bool get userIsJoined => _eventProvider.isParticipant;

  EventSettings get eventSettings {
    final eventSettings = context.watch<EventProvider>().event.eventSettings;
    final communityEventSettings =
        context.watch<CommunityProvider>().eventSettings;

    return eventSettings ?? communityEventSettings;
  }

  late final EventPagePresenter _presenter;

  // This is to rebuild the page when the in-meeting query parameter is applied
  void onRouterUpdate() => setState(() {});

  @override
  void initState() {
    EventProvider.read(context).initialize();
    context.read<TemplateProvider>().initialize();
    context.read<EventPageProvider>().initialize();

    if (!isNullOrEmpty(widget.uid)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!userService.isSignedIn) {
          SignInDialog.show();
        }
      });
    }

    routerDelegate.addListener(onRouterUpdate);

    super.initState();

    _presenter = EventPagePresenter(context, this);
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

  Future<JoinEventResults> _joinEvent({
    bool showConfirm = true,
    bool joinCommunity = false,
  }) async {
    return await alertOnError<JoinEventResults>(
          context,
          () => context.read<EventPageProvider>().joinEvent(
                showConfirm: showConfirm,
                joinCommunity: joinCommunity,
              ),
        ) ??
        JoinEventResults(isJoined: false);
  }

  Future<void> _startMeeting() async {
    final eventPageProvider = context.read<EventPageProvider>();
    JoinEventResults? joinResults;
    if (EventProvider.read(context).isParticipant) {
      joinResults = await _joinEvent(showConfirm: false);
      if (!joinResults.isJoined) return;
    }
    await alertOnError(
      context,
      () => eventPageProvider.enterMeeting(
        surveyQuestions: joinResults?.surveyQuestions,
      ),
    );
  }

  Future<void> _showSendMessageDialog() async {
    final isMobile = responsiveLayoutService.isMobile(context);

    final message = await Dialogs.showComposeMessageDialog(
      context,
      title: 'Message Participants',
      isMobile: isMobile,
      labelText: 'Message',
      validator: (message) =>
          message == null || message.isEmpty ? 'Message cannot be empty' : null,
      positiveButtonText: 'Send',
    );

    if (message != null) {
      await alertOnError(context, () => _presenter.sendMessage(message));
    }
  }

  Future<void> _showRemoveMessageDialog(
    EventMessage eventMessage,
  ) async {
    await showCustomDialog(
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: AppColor.white,
          title: Text(
            'Are you sure you want to remove this message?',
            style: AppTextStyle.headline3
                .copyWith(color: context.theme.colorScheme.primary),
          ),
          actions: [
            ActionButton(
              text: 'No',
              color: context.theme.colorScheme.primary,
              textColor: AppColor.brightGreen,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ActionButton(
              text: 'Yes',
              color: context.theme.colorScheme.primary,
              textColor: AppColor.brightGreen,
              onPressed: () => alertOnError(context, () async {
                await _presenter.removeMessage(eventMessage);
                Navigator.pop(context);
              }),
            ),
          ],
        );
      },
    );
  }

  bool _isEnterEventGraphicShown(DateTime scheduled) {
    final isParticipant = EventProvider.watch(context).isParticipant;
    final now = clockService.now();
    final beforeMeetingCutoff = scheduled.subtract(Duration(minutes: 10));
    final afterMeetingCutoff = scheduled.add(Duration(hours: 2));

    return isParticipant &&
        now.isAfter(beforeMeetingCutoff) &&
        now.isBefore(afterMeetingCutoff);
  }

  Widget _buildGuide() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isEnterEventGraphicShown(event.scheduledTime!)) ...[
          CustomInkWell(
            onTap: _startMeeting,
            child: SizedBox(
              height: 380,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ProxiedImage(
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
                        HeightConstrainedText(
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
                          sendingIndicatorAlign:
                              ActionButtonSendingIndicatorAlign.none,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 4),
        ],
        CustomTabBar(
          padding: EdgeInsets.zero,
        ),
        SizedBox(height: 16),
        CustomTabBarView(keepAlive: !responsiveLayoutService.isMobile(context)),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildEventTabsWrappedGuide() {
    final eventProvider = EventProvider.watch(context);
    final communityProvider = CommunityProvider.watch(context);
    final isInBreakouts =
        LiveMeetingProvider.watchOrNull(context)?.isInBreakout ?? false;
    final isParticipant = eventProvider.isParticipant;
    final isMod =
        Provider.of<CommunityPermissionsProvider>(context).canModerateContent;
    final canEdit =
        Provider.of<CommunityPermissionsProvider>(context).canEditCommunity;

    final hasPrePostContent =
        (eventProvider.event.preEventCardData?.hasData ?? false) ||
            (eventProvider.event.postEventCardData?.hasData ?? false);

    final bool enableGuide = isInBreakouts ||
        eventProvider.agendaPreview ||
        context.watch<EventPermissionsProvider>().isAgendaVisibleOverride;

    final eventPermissions = context.watch<EventPermissionsProvider>();

    return EventTabsWrapper(
      onRemoveMessage: (eventMessage) => _showRemoveMessageDialog(eventMessage),
      meetingAgendaBuilder: (context) => EventPageMeetingAgenda(),
      enableChat: (eventPermissions.canChat && eventProvider.enableChat),
      enablePrePostEvent: canEdit || (isParticipant && hasPrePostContent),
      enableMessages: isParticipant || isMod,
      enableGuide: enableGuide,
      child: _buildGuide(),
    );
  }

  Widget _buildMainContent() {
    final isMobile = responsiveLayoutService.isMobile(context);
    final eventProvider = EventProvider.watch(context);
    final event = eventProvider.event;

    return Align(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          if (_presenter.isEditTemplateTooltipShown)
            _buildEditTemplateMessage(),
          if (isMobile) ...[
            Container(
              alignment: Alignment.topCenter,
              child: EventInfo(
                eventPagePresenter: _presenter,
                event: event,
                onMessagePressed: () => _showSendMessageDialog(),
                onJoinEvent: _joinEvent,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildEventTabsWrappedGuide(),
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
                    child: EventInfo(
                      eventPagePresenter: _presenter,
                      event: event,
                      onMessagePressed: () => _showSendMessageDialog(),
                      onJoinEvent: _joinEvent,
                    ),
                  ),
                  SizedBox(width: 40),
                  Expanded(
                    child: _buildEventTabsWrappedGuide(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEditTemplateMessage() {
    String templateId = event.templateId;
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
                              CommunityPageRoutes(
                                communityDisplayId:
                                    Provider.of<CommunityProvider>(
                                  context,
                                  listen: false,
                                ).displayId,
                              ).templatePage(templateId: templateId),
                            ),
                      style: AppTextStyle.body.copyWith(
                        color: AppColor.accentBlue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: () => _presenter.hideEditTooltip(),
              icon: Icon(
                Icons.close,
                color: context.theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final eventPermissions = context.watch<EventPermissionsProvider>();

    if (context.watch<EventPageProvider>().isEnteredMeeting) {
      final isInstant = context.watch<EventPageProvider>().isInstant;
      // Ensure event is loaded in event stream before it is accessed
      return CustomStreamBuilder<Event>(
        showLoading: false,
        entryFrom: '_EventPageState.buildMeetingDialog',
        stream: Provider.of<EventProvider>(context).eventStream,
        builder: (context, snapshot) {
          if (snapshot == null) return CircularProgressIndicator();
          return MeetingDialog.create(
            avCheckEnabled: false, //eventPermissions.avCheckEnabled,
            isInstant: isInstant,
          );
        },
      );
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
      child: CustomStreamBuilder<Event>(
        entryFrom: '_EventPageState.build',
        stream: eventProvider.eventStream,
        builder: (_, event) => CustomStreamBuilder<List<Participant>>(
          entryFrom: '_EventPageState.build',
          stream: eventProvider.eventParticipantsStream,
          builder: (_, __) {
            if (event == null) return CircularProgressIndicator();

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
    return responsiveLayoutService.isMobile(context)
        ? child
        : Expanded(flex: flex, child: child);
  }
}
