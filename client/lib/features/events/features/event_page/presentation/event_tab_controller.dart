import 'dart:math';

import 'package:flutter/material.dart';
import 'package:client/features/chat/data/providers/chat_model.dart';
import 'package:client/features/chat/presentation/widgets/chat_widget.dart';
import 'package:client/features/community/data/providers/community_permissions_provider.dart';
import 'package:client/features/events/features/live_meeting/features/admin_panel/presentation/widgets/admin_panel.dart';
import 'package:client/features/events/features/event_page/data/providers/event_permissions_provider.dart';
import 'package:client/features/events/features/event_page/data/providers/event_provider.dart';
import 'package:client/features/events/features/event_page/presentation/widgets/event_tabs.dart';
import 'package:client/features/events/features/event_page/presentation/event_tabs_model.dart';
import 'package:client/features/events/features/live_meeting/data/providers/live_meeting_provider.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/widgets/user_submitted_agenda.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/data/providers/user_submitted_agenda_provider.dart';
import 'package:client/features/events/features/event_page/presentation/widgets/add_more_button.dart';
import 'package:client/features/events/features/event_page/presentation/widgets/event_message_widget.dart';
import 'package:client/features/events/features/event_page/presentation/views/pre_post_card_widget_page.dart';
import 'package:client/features/events/features/event_page/presentation/views/prerequisite_template_widget_page.dart';
import 'package:client/features/community/presentation/widgets/event_widget.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/buttons/action_button.dart';
import 'package:client/core/widgets/empty_page_content.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/core/widgets/tabs/tab_controller.dart';
import 'package:client/features/templates/presentation/widgets/template_cards.dart';
import 'package:client/features/user/data/services/user_data_service.dart';
import 'package:client/services.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/utils/dialogs.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/core/widgets/stream_utils.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/events/event_message.dart';
import 'package:data_models/events/pre_post_card.dart';
import 'package:data_models/templates/template.dart';
import 'package:provider/provider.dart';

/// Class that defines our event tabs and their associated content.
///
/// This class does not actually render the content but passes it to CustomTabBar and CustomTabBarView
/// via [CustomTabBarController]
class EventTabsDefinition extends StatefulWidget {
  final void Function(EventMessage)? onRemoveMessage;
  final Widget child;

  const EventTabsDefinition({
    required this.onRemoveMessage,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  _EventTabsDefinitionState createState() => _EventTabsDefinitionState();
}

class _EventTabsDefinitionState extends State<EventTabsDefinition> {
  bool get hasAnnouncements =>
      context.watch<EventTabsControllerState>().announcementsCount > 1;

  @override
  Widget build(BuildContext context) {
    final enablePrePostEvent =
        context.watch<EventTabsControllerState>().widget.enablePrePostEvent;
    return MemoizedStreamBuilder<bool?>(
      streamGetter: enablePrePostEvent
          ? () => Provider.of<CommunityProvider>(context)
              .prePostEnabled()
              .asStream()
          : () => Stream.value(false),
      builder: (context, prePostUnlocked) => _buildController(prePostUnlocked!),
    );
  }

  CustomTabController _buildController(bool prePostUnlocked) {
    final eventTabsModel = context.watch<EventTabsControllerState>().widget;
    return CustomTabController(
      selectedTabController:
          context.watch<EventTabsControllerState>().selectedTabController,
      tabs: [
        if (eventTabsModel.enableAbout)
          CustomTabAndContent(
            tab: 'About',
            content: (context) => _buildAboutSection(context),
          ),
        if (eventTabsModel.enableGuide)
          CustomTabAndContent(
            tab: 'Agenda',
            content: (context) => _buildAgendaSection(context),
          ),
        if (eventTabsModel.enableUserSubmittedAgenda)
          CustomTabAndContent(
            tab: 'Suggest',
            content: (_) => _buildSuggestSection(),
            unreadCount: Provider.of<UserSubmittedAgendaProvider>(context)
                .numUnreadSuggestions,
          ),
        if (eventTabsModel.enableChat)
          CustomTabAndContent(
            tab: 'Chat',
            content: (context) => _buildChatSection(context),
            unreadCount: Provider.of<ChatModel>(context).numUnreadMessages,
          ),
        if (eventTabsModel.enableMessages)
          CustomTabAndContent(
            tab: 'Announcements',
            content: (_) => _buildAnnouncements(),
          ),
        if (eventTabsModel.enableAdminPanel)
          CustomTabAndContent(
            tab: 'Admin',
            content: (context) => AdminPanel(padding: EdgeInsets.zero),
          ),
        if (eventTabsModel.enablePrePostEvent)
          CustomTabAndContent(
            tab: 'CTAs',
            isGated: !prePostUnlocked,
            content: (context) => _buildPrePostSection(context),
          ),
      ],
      child: widget.child,
    );
  }

  Widget _buildAnnouncements({bool compact = false}) {
    return CustomStreamBuilder<List<EventMessage>>(
      entryFrom: '_EventPageState._buildGuide',
      stream: context.watch<EventTabsControllerState>().eventMessagesStream,
      errorBuilder: (_) => HeightConstrainedText(
        'There was an error while loading Announcements',
        style: AppTextStyle.body.copyWith(color: AppColor.gray2),
      ),
      builder: (context, eventMessages) {
        final localEventMessages =
            eventMessages?.take(compact ? 1 : eventMessages.length).toList() ??
                [];
        if (localEventMessages.isEmpty) {
          return compact
              ? HeightConstrainedText(
                  'No Announcements sent yet',
                  style: AppTextStyle.body.copyWith(color: AppColor.gray2),
                )
              : _buildNoResource(context);
        }

        final community = context.watch<CommunityProvider>().community;

        final canEditEvent =
            Provider.of<EventPermissionsProvider>(context).canEditEvent;
        return Column(
          children: [
            if (canEditEvent)
              Container(
                alignment: Alignment.centerLeft,
                child: ActionButton(
                  type: ActionButtonType.outline,
                  onPressed: _showSendMessageDialog,
                  text: '+ Add New',
                  borderSide:
                      BorderSide(color: context.theme.colorScheme.primary),
                  textColor: context.theme.colorScheme.primary,
                ),
              ),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: compact ? 0 : 8),
              shrinkWrap: true,
              itemCount: localEventMessages.length,
              itemBuilder: (context, index) {
                final EventMessage eventMessage = localEventMessages[index];
                final localOnRemoveMessage = widget.onRemoveMessage;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: EventMessageWidget(
                    eventMessage: eventMessage,
                    onRemoveMessage: () =>
                        localOnRemoveMessage?.call(eventMessage),
                    isMod: Provider.of<UserDataService>(context)
                        .getMembership(community.id)
                        .isMod,
                    isDocCreator: userService.currentUserId ==
                        Provider.of<EventProvider>(context).event.creatorId,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSendMessageDialog() async {
    final tabsController =
        Provider.of<EventTabsControllerState>(context, listen: false);

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
      await alertOnError(context, () => tabsController.sendMessage(message));
    }
  }

  Widget _buildAboutSection(context) {
    final tabsController = Provider.of<EventTabsControllerState>(context);
    final hasAnnouncements = tabsController.announcementsCount > 1;
    final description = Provider.of<EventProvider>(context).event.description;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 30),
        if (description != null && description.isNotEmpty) ...[
          HeightConstrainedText(
            'Description',
            style: AppTextStyle.headlineSmall.copyWith(
                color: context.theme.colorScheme.primary, fontSize: 16),
          ),
          HeightConstrainedText(
            description,
            style: AppTextStyle.body.copyWith(color: AppColor.gray2),
          ),
          SizedBox(height: 30),
        ],
        if (tabsController.widget.enableMessages) ...[
          Row(
            children: [
              HeightConstrainedText(
                'Announcements',
                style: AppTextStyle.headlineSmall.copyWith(
                  color: context.theme.colorScheme.primary,
                  fontSize: 16,
                ),
              ),
              Spacer(),
              if (hasAnnouncements)
                CustomInkWell(
                  onTap: () => tabsController.openTab(TabType.messages),
                  child: HeightConstrainedText(
                    'See all',
                    style: AppTextStyle.bodyMedium
                        .copyWith(color: context.theme.colorScheme.primary),
                  ),
                ),
            ],
          ),
          SizedBox(height: 10),
          _buildAnnouncements(compact: true),
          SizedBox(height: 40),
        ],
        ...[
          HeightConstrainedText(
            'More Upcoming Events',
            style: AppTextStyle.headlineSmall.copyWith(
              color: context.theme.colorScheme.primary,
              fontSize: 16,
            ),
          ),
          _buildUpcomingEvents(),
          SizedBox(height: 40),
          _buildTemplates(),
        ],
      ],
    );
  }

  Widget _buildTemplates() {
    final width = MediaQuery.of(context).size.width;
    final int maxContainerDisplayCount;
    if (width < 450) {
      maxContainerDisplayCount = 4;
    } else if (width < 550
        // Condition to handle the case when in low desktop resolutions and there is not enough space to show all cards
        ||
        (width > 1000 && width < 1120)) {
      maxContainerDisplayCount = 5;
    } else {
      maxContainerDisplayCount = 6;
    }
    final bool canCreateTemplate =
        Provider.of<CommunityPermissionsProvider>(context)
            .canSeeCreateTemplateButtonOnCommunityHomePage;

    final int maxTemplateDisplayCount =
        maxContainerDisplayCount - (canCreateTemplate ? 1 : 0);
    final community = CommunityProvider.watch(context).community;
    return CustomStreamBuilder<List<Template>>(
      entryFrom: '_EventPageState.buildTemplates',
      stream: Provider.of<EventProvider>(context).templatesStream,
      builder: (context, returnedTemplates) {
        final templates = returnedTemplates ?? [];

        final showAdditionalTemplatesCard =
            templates.length > maxTemplateDisplayCount;

        final templatesToShow = showAdditionalTemplatesCard
            ? templates.sublist(
                0,
                min(templates.length, maxTemplateDisplayCount - 1),
              )
            : templates;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeightConstrainedText(
              'More from ${community.name}',
              style: AppTextStyle.headlineSmall.copyWith(
                color: context.theme.colorScheme.primary,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (templates.isNotEmpty)
                  for (final template in templatesToShow) ...[
                    if (template != templates.first) SizedBox(width: 16),
                    TemplateCard(
                      context: context,
                      template: template,
                    ),
                  ],
                if (templates.length > maxTemplateDisplayCount) ...[
                  SizedBox(width: 16),
                  AdditionalTemplatesCard(
                    context: context,
                    templates: templates,
                    numShown: maxTemplateDisplayCount,
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildUpcomingEvents() {
    final eventProvider = Provider.of<EventProvider>(context);
    return CustomStreamBuilder<List<Event>?>(
      entryFrom: '_EventPageState._buildEvents',
      stream: eventProvider.upcomingEventsStream,
      height: 100,
      errorMessage: 'Something went wrong loading events.',
      builder: (_, __) {
        final events = eventProvider.upcomingEvents;
        if (events.isEmpty) {
          return HeightConstrainedText(
            'No upcoming events.',
            style: AppTextStyle.body.copyWith(
              color: AppColor.gray2,
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 30),
            for (final event in events) ...[
              EventWidget(
                event,
                key: Key('event-${event.id}'),
              ),
              SizedBox(height: 20),
            ],
          ],
        );
      },
    );
  }

  Widget _buildNoResource(BuildContext context) {
    final canEditEvent =
        Provider.of<EventPermissionsProvider>(context).canEditEvent;

    return Center(
      child: EmptyPageContent(
        type: EmptyPageType.announcements,
        subtitleText: canEditEvent
            ? 'Send a message to all the participants in the group'
            : 'If the host sends a message, you\'ll see it here.',
        onButtonPress: canEditEvent ? _showSendMessageDialog : null,
        showContainer: false,
        buttonType: ActionButtonType.outline,
        buttonText: 'Message participants',
      ),
    );
  }

  Widget _buildChatSection(BuildContext context) {
    final liveMeetingProvider = LiveMeetingProvider.watchOrNull(context);

    return Container(
      alignment: Alignment.center,
      child: LayoutBuilder(
        builder: (context, constraints) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          margin: const EdgeInsets.only(bottom: 10),
          constraints: BoxConstraints(
            maxHeight: constraints.hasBoundedHeight
                ? constraints.maxHeight
                : responsiveLayoutService.isMobile(context)
                    ? 400
                    : MediaQuery.of(context).size.height - 300,
          ),
          child: ChatWidget(
            parentPath: context.watch<ChatModel>().parentPath,
            messageInputHint: 'Say something',
            allowBroadcast: liveMeetingProvider != null &&
                !liveMeetingProvider.isInBreakout &&
                context.watch<EventPermissionsProvider>().canBroadcastChat,
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestSection() => LayoutBuilder(
        builder: (context, constraints) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          margin: const EdgeInsets.only(bottom: 10),
          constraints: BoxConstraints(
            maxHeight: constraints.hasBoundedHeight
                ? constraints.maxHeight
                : responsiveLayoutService.isMobile(context)
                    ? 400
                    : MediaQuery.of(context).size.height - 300,
          ),
          child: UserSubmittedAgenda(),
        ),
      );

  Widget _buildAgendaSection(BuildContext context) => SingleChildScrollView(
        controller: ScrollController(),
        child: Builder(
          builder: context
              .watch<EventTabsControllerState>()
              .widget
              .meetingAgendaBuilder,
        ),
      );

  Widget _buildPrePostSection(BuildContext context) {
    final eventProvider = context.read<EventProvider>();
    final event = eventProvider.event;
    final preEventCardData = event.preEventCardData;
    final postEventCardData = event.postEventCardData;

    final enablePrerequisites = eventProvider.enablePrerequisites;

    final bool isAdmin = Provider.of<UserDataService>(context)
        .getMembership(Provider.of<CommunityProvider>(context).communityId)
        .isAdmin;
    final bool isMod = Provider.of<UserDataService>(context)
        .getMembership(Provider.of<CommunityProvider>(context).communityId)
        .isMod;
    final bool canEdit =
        event.creatorId == Provider.of<UserService>(context).currentUserId ||
            isMod;

    return SingleChildScrollView(
      controller: ScrollController(),
      child: Column(
        children: [
          if (enablePrerequisites) ...[
            _buildPrerequisiteTemplateSection(
              context: context,
              event: event,
              isEditable: canEdit || isAdmin,
            ),
            SizedBox(height: 20),
          ],
          _buildPrePostCardSection(
            context: context,
            prePostCardType: PrePostCardType.preEvent,
            eventCardData: preEventCardData,
            event: event,
            isEditable: canEdit || isAdmin,
          ),
          SizedBox(height: 20),
          _buildPrePostCardSection(
            context: context,
            prePostCardType: PrePostCardType.postEvent,
            eventCardData: postEventCardData,
            event: event,
            isEditable: canEdit || isAdmin,
          ),
        ],
      ),
    );
  }

  Widget _buildPrePostCardSection({
    required BuildContext context,
    required PrePostCardType prePostCardType,
    PrePostCard? eventCardData,
    required Event event,
    required bool isEditable,
  }) {
    if (!isEditable && (eventCardData == null || eventCardData.isNew())) {
      return SizedBox.shrink();
    }

    final String addNewTitle;
    final String fieldName;
    switch (prePostCardType) {
      case PrePostCardType.preEvent:
        addNewTitle = 'Add Pre-event';
        fieldName = Event.kFieldPreEventCardData;
        break;
      case PrePostCardType.postEvent:
        addNewTitle = 'Add Post-event';
        fieldName = Event.kFieldPostEventCardData;
        break;
    }

    if (eventCardData != null) {
      return PrePostCardWidgetPage(
        prePostCardType: prePostCardType,
        prePostCard: eventCardData,
        event: event,
        onUpdate: (prePostCard) async {
          final Event updatedEvent;
          switch (prePostCardType) {
            case PrePostCardType.preEvent:
              updatedEvent = event.copyWith(preEventCardData: prePostCard);
              break;
            case PrePostCardType.postEvent:
              updatedEvent = event.copyWith(postEventCardData: prePostCard);
              break;
          }

          await alertOnError(
            context,
            () => firestoreEventService.updateEvent(
              event: updatedEvent,
              keys: [fieldName],
            ),
          );
        },
        onDelete: () async {
          final Event updatedEvent;
          switch (prePostCardType) {
            case PrePostCardType.preEvent:
              updatedEvent = event.copyWith(preEventCardData: null);
              break;
            case PrePostCardType.postEvent:
              updatedEvent = event.copyWith(postEventCardData: null);
              break;
          }

          await alertOnError(
            context,
            () => firestoreEventService.updateEvent(
              event: updatedEvent,
              keys: [fieldName],
            ),
          );
        },
        prePostCardWidgetType: isEditable && eventCardData.isNew()
            ? PrePostCardWidgetType.edit
            : PrePostCardWidgetType.overview,
        isEditable: isEditable,
      );
    } else {
      return AddMoreButton(
        label: addNewTitle,
        onPressed: () async {
          final prePostCard = PrePostCard.newCard(prePostCardType);
          final Event updatedEvent;
          switch (prePostCardType) {
            case PrePostCardType.preEvent:
              updatedEvent = event.copyWith(preEventCardData: prePostCard);
              break;
            case PrePostCardType.postEvent:
              updatedEvent = event.copyWith(postEventCardData: prePostCard);
              break;
          }

          await alertOnError(
            context,
            () => firestoreEventService.updateEvent(
              event: updatedEvent,
              keys: [fieldName],
            ),
          );
        },
      );
    }
  }

  Widget _buildPrerequisiteTemplateSection({
    required BuildContext context,
    required Event event,
    required bool isEditable,
  }) {
    final eventTabsModelState = context.watch<EventTabsControllerState>();

    final hasPrerequisite = event.prerequisiteTemplateId != null;

    const String fieldName = Event.fieldPrerequisiteTemplate;

    if (hasPrerequisite || eventTabsModelState.isNewPrerequisite) {
      return PrerequisiteTemplateWidgetPage(
        isWhiteBackground: true,
        templatesFuture: eventTabsModelState.templatesFuture,
        event: event,
        onUpdate: (prerequisiteTemplateId) async {
          final Event updatedEvent =
              event.copyWith(prerequisiteTemplateId: prerequisiteTemplateId);

          await alertOnError(
            context,
            () => firestoreEventService.updateEvent(
              event: updatedEvent,
              keys: [fieldName],
            ),
          );
        },
        onDelete: () => alertOnError(context, () async {
          final Event updatedEvent =
              event.copyWith(prerequisiteTemplateId: null);
          await firestoreEventService.updateEvent(
            event: updatedEvent,
            keys: [fieldName],
          );
          eventTabsModelState.isNewPrerequisite = false;
        }),
        prerequisiteTemplateWidgetType: PrerequisiteTemplateWidgetType.edit,
        isEditable: isEditable,
      );
    } else {
      return AddMoreButton(
        label: 'Add a prerequisite template',
        onPressed: () {
          eventTabsModelState.isNewPrerequisite = true;
        },
      );
    }
  }
}
