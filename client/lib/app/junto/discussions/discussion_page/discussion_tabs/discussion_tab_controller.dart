import 'dart:math';

import 'package:flutter/material.dart';
import 'package:junto/app/junto/chat/chat_model.dart';
import 'package:junto/app/junto/chat/chat_widget.dart';
import 'package:junto/app/junto/community_permissions_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/admin_panel/admin_panel.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_permissions_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_tabs/discussion_tabs.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_tabs/discussion_tabs_model.dart';
import 'package:junto/app/junto/discussions/discussion_page/live_meeting/live_meeting_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/user_submitted_agenda/user_submitted_agenda.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/user_submitted_agenda/user_submitted_agenda_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/add_more_button.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/discussion_message_widget.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/pre_post_card_widget/pre_post_card_widget_page.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/prerequisite_topic_widget/prerequisite_topic_widget_page.dart';
import 'package:junto/app/junto/home/discussion_widget.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/empty_page_content.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/common_widgets/tabs/tab_controller.dart';
import 'package:junto/common_widgets/topic_cards.dart';
import 'package:junto/services/junto_user_data_service.dart';
import 'package:junto/services/services.dart';
import 'package:junto/services/user_service.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/dialogs.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto/utils/stream_utils.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/discussion_message.dart';
import 'package:junto_models/firestore/pre_post_card.dart';
import 'package:junto_models/firestore/topic.dart';
import 'package:provider/provider.dart';

/// Class that defines our discussion tabs and their associated content.
///
/// This class does not actually render the content but passes it to JuntoTabBar and JuntoTabBarView
/// via [JuntoTabBarController]
class DiscussionTabsDefinition extends StatefulWidget {
  final void Function(DiscussionMessage)? onRemoveMessage;
  final Widget child;

  const DiscussionTabsDefinition({
    required this.onRemoveMessage,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  _DiscussionTabsDefinitionState createState() => _DiscussionTabsDefinitionState();
}

class _DiscussionTabsDefinitionState extends State<DiscussionTabsDefinition> {
  bool get hasAnnouncements =>
      context.watch<DiscussionTabsControllerState>().announcementsCount > 1;

  @override
  Widget build(BuildContext context) {
    final enablePrePostEvent =
        context.watch<DiscussionTabsControllerState>().widget.enablePrePostEvent;
    return JuntoStreamGetterBuilder<bool?>(
      streamGetter: enablePrePostEvent
          ? () => Provider.of<JuntoProvider>(context).prePostEnabled().asStream()
          : () => Stream.value(false),
      builder: (context, prePostUnlocked) => _buildController(prePostUnlocked!),
    );
  }

  JuntoTabController _buildController(bool prePostUnlocked) {
    final discussionTabsModel = context.watch<DiscussionTabsControllerState>().widget;
    return JuntoTabController(
      selectedTabController: context.watch<DiscussionTabsControllerState>().selectedTabController,
      tabs: [
        if (discussionTabsModel.enableAbout)
          JuntoTabAndContent(
            tab: 'About',
            content: (context) => _buildAboutSection(context),
          ),
        if (discussionTabsModel.enableGuide)
          JuntoTabAndContent(
            tab: 'Agenda',
            content: (context) => _buildAgendaSection(context),
          ),
        if (discussionTabsModel.enableUserSubmittedAgenda)
          JuntoTabAndContent(
            tab: 'Suggest',
            content: (_) => _buildSuggestSection(),
            unreadCount: Provider.of<UserSubmittedAgendaProvider>(context).numUnreadSuggestions,
          ),
        if (discussionTabsModel.enableChat)
          JuntoTabAndContent(
            tab: 'Chat',
            content: (context) => _buildChatSection(context),
            unreadCount: Provider.of<ChatModel>(context).numUnreadMessages,
          ),
        if (discussionTabsModel.enableMessages)
          JuntoTabAndContent(
            tab: 'Announcements',
            content: (_) => _buildAnnouncements(),
          ),
        if (discussionTabsModel.enableAdminPanel)
          JuntoTabAndContent(
            tab: 'Admin',
            content: (context) => AdminPanel(padding: EdgeInsets.zero),
          ),
        if (discussionTabsModel.enablePrePostEvent)
          JuntoTabAndContent(
            tab: 'CTAs',
            isGated: !prePostUnlocked,
            content: (context) => _buildPrePostSection(context),
          ),
      ],
      child: widget.child,
    );
  }

  Widget _buildAnnouncements({bool compact = false}) {
    return JuntoStreamBuilder<List<DiscussionMessage>>(
      entryFrom: '_DiscussionPageState._buildGuide',
      stream: context.watch<DiscussionTabsControllerState>().discussionMessagesStream,
      errorBuilder: (_) => JuntoText(
        'There was an error while loading Announcements',
        style: AppTextStyle.body.copyWith(color: AppColor.gray2),
      ),
      builder: (context, discussionMessages) {
        final localDiscussionMessages =
            discussionMessages?.take(compact ? 1 : discussionMessages.length).toList() ?? [];
        if (localDiscussionMessages.isEmpty) {
          return compact
              ? JuntoText(
                  'No Announcements sent yet',
                  style: AppTextStyle.body.copyWith(color: AppColor.gray2),
                )
              : _buildNoResource(context);
        }

        final junto = context.watch<JuntoProvider>().junto;

        final canEditDiscussion =
            Provider.of<DiscussionPermissionsProvider>(context).canEditDiscussion;
        return Column(
          children: [
            if (canEditDiscussion)
              Container(
                alignment: Alignment.centerLeft,
                child: ActionButton(
                  type: ActionButtonType.outline,
                  onPressed: _showSendMessageDialog,
                  text: '+ Add New',
                  borderSide: BorderSide(color: AppColor.darkBlue),
                  textColor: AppColor.darkBlue,
                ),
              ),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: compact ? 0 : 8),
              shrinkWrap: true,
              itemCount: localDiscussionMessages.length,
              itemBuilder: (context, index) {
                final DiscussionMessage discussionMessage = localDiscussionMessages[index];
                final localOnRemoveMessage = widget.onRemoveMessage;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: DiscussionMessageWidget(
                    discussionMessage: discussionMessage,
                    onRemoveMessage: () => localOnRemoveMessage?.call(discussionMessage),
                    isMod: Provider.of<JuntoUserDataService>(context).getMembership(junto.id).isMod,
                    isDocCreator: userService.currentUserId ==
                        Provider.of<DiscussionProvider>(context).discussion.creatorId,
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
    final tabsController = Provider.of<DiscussionTabsControllerState>(context, listen: false);

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
      await alertOnError(context, () => tabsController.sendMessage(message));
    }
  }

  Widget _buildAboutSection(context) {
    final tabsController = Provider.of<DiscussionTabsControllerState>(context);
    final hasAnnouncements = tabsController.announcementsCount > 1;
    final description = Provider.of<DiscussionProvider>(context).discussion.description;
    final hideUpcomingEvents = JuntoProvider.watch(context).isAmericaTalks ||
        JuntoProvider.watch(context).isMeetingOfAmerica;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 30),
        if (description != null && description.isNotEmpty) ...[
          JuntoText(
            'Description',
            style: AppTextStyle.headlineSmall.copyWith(color: AppColor.darkBlue, fontSize: 16),
          ),
          JuntoText(
            description,
            style: AppTextStyle.body.copyWith(color: AppColor.gray2),
          ),
          SizedBox(height: 30),
        ],
        if (tabsController.widget.enableMessages) ...[
          Row(
            children: [
              JuntoText(
                'Announcements',
                style: AppTextStyle.headlineSmall.copyWith(
                  color: AppColor.darkBlue,
                  fontSize: 16,
                ),
              ),
              Spacer(),
              if (hasAnnouncements)
                JuntoInkWell(
                  onTap: () => tabsController.openTab(TabType.messages),
                  child: JuntoText(
                    'See all',
                    style: AppTextStyle.bodyMedium.copyWith(color: AppColor.darkBlue),
                  ),
                )
            ],
          ),
          SizedBox(height: 10),
          _buildAnnouncements(compact: true),
          SizedBox(height: 40),
        ],
        if (!hideUpcomingEvents) ...[
          JuntoText(
            'More Upcoming Events',
            style: AppTextStyle.headlineSmall.copyWith(
              color: AppColor.darkBlue,
              fontSize: 16,
            ),
          ),
          _buildUpcomingDiscussions(),
          SizedBox(height: 40),
          _buildTopics(),
        ],
      ],
    );
  }

  Widget _buildTopics() {
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
    final bool _canCreateTopic = Provider.of<CommunityPermissionsProvider>(context)
        .canSeeCreateTopicButtonOnCommunityHomePage;

    final int maxTopicDisplayCount = maxContainerDisplayCount - (_canCreateTopic ? 1 : 0);
    final junto = JuntoProvider.watch(context).junto;
    final isMeetingOfAmerica = JuntoProvider.watch(context).isMeetingOfAmerica;
    return JuntoStreamBuilder<List<Topic>>(
        entryFrom: '_DiscussionPageState.buildTopics',
        stream: Provider.of<DiscussionProvider>(context).topicsStream,
        builder: (context, returnedTopics) {
          final topics = returnedTopics ?? [];

          final showAdditionalTopicsCard = topics.length > maxTopicDisplayCount;

          final topicsToShow = showAdditionalTopicsCard
              ? topics.sublist(0, min(topics.length, maxTopicDisplayCount - 1))
              : topics;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              JuntoText(
                isMeetingOfAmerica ? 'Meeting of America Experience' : 'More from ${junto.name}',
                style: AppTextStyle.headlineSmall.copyWith(
                  color: AppColor.darkBlue,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (topics.isNotEmpty)
                    for (final topic in topicsToShow) ...[
                      if (topic != topics.first) SizedBox(width: 16),
                      TopicCard(
                        context: context,
                        topic: topic,
                      ),
                    ],
                  if (topics.length > maxTopicDisplayCount) ...[
                    SizedBox(width: 16),
                    AdditionalTopicsCard(
                      context: context,
                      topics: topics,
                      numShown: maxTopicDisplayCount,
                    ),
                  ],
                ],
              ),
            ],
          );
        });
  }

  Widget _buildUpcomingDiscussions() {
    final discussionProvider = Provider.of<DiscussionProvider>(context);
    return JuntoStreamBuilder<List<Discussion>?>(
      entryFrom: '_DiscussionPageState._buildDiscussions',
      stream: discussionProvider.upcomingDiscussionsStream,
      height: 100,
      errorMessage: 'Something went wrong loading events.',
      builder: (_, __) {
        final discussions = discussionProvider.upcomingDiscussions;
        if (discussions.isEmpty) {
          return JuntoText(
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
            for (final discussion in discussions) ...[
              DiscussionWidget(
                discussion,
                key: Key('discussion-${discussion.id}'),
              ),
              SizedBox(height: 20),
            ],
          ],
        );
      },
    );
  }

  Widget _buildNoResource(BuildContext context) {
    final canEditDiscussion = Provider.of<DiscussionPermissionsProvider>(context).canEditDiscussion;

    return Center(
      child: EmptyPageContent(
        type: EmptyPageType.announcements,
        subtitleText: canEditDiscussion
            ? 'Send a message to all the participants in the group'
            : 'If the host sends a message, you\'ll see it here.',
        onButtonPress: canEditDiscussion ? _showSendMessageDialog : null,
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
                context.watch<DiscussionPermissionsProvider>().canBroadcastChat,
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
          builder: context.watch<DiscussionTabsControllerState>().widget.meetingAgendaBuilder,
        ),
      );

  Widget _buildPrePostSection(BuildContext context) {
    final discussionProvider = context.read<DiscussionProvider>();
    final discussion = discussionProvider.discussion;
    final preEventCardData = discussion.preEventCardData;
    final postEventCardData = discussion.postEventCardData;

    final enablePrerequisites = discussionProvider.enablePrerequisites;

    final bool _isAdmin = Provider.of<JuntoUserDataService>(context)
        .getMembership(Provider.of<JuntoProvider>(context).juntoId)
        .isAdmin;
    final bool _isMod = Provider.of<JuntoUserDataService>(context)
        .getMembership(Provider.of<JuntoProvider>(context).juntoId)
        .isMod;
    final bool _canEdit =
        discussion.creatorId == Provider.of<UserService>(context).currentUserId || _isMod;

    return SingleChildScrollView(
      controller: ScrollController(),
      child: Column(
        children: [
          if (enablePrerequisites) ...[
            _buildPrerequisiteTopicSection(
              context: context,
              discussion: discussion,
              isEditable: _canEdit || _isAdmin,
            ),
            SizedBox(height: 20),
          ],
          _buildPrePostCardSection(
            context: context,
            prePostCardType: PrePostCardType.preEvent,
            eventCardData: preEventCardData,
            discussion: discussion,
            isEditable: _canEdit || _isAdmin,
          ),
          SizedBox(height: 20),
          _buildPrePostCardSection(
            context: context,
            prePostCardType: PrePostCardType.postEvent,
            eventCardData: postEventCardData,
            discussion: discussion,
            isEditable: _canEdit || _isAdmin,
          ),
        ],
      ),
    );
  }

  Widget _buildPrePostCardSection({
    required BuildContext context,
    required PrePostCardType prePostCardType,
    PrePostCard? eventCardData,
    required Discussion discussion,
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
        fieldName = Discussion.kFieldPreEventCardData;
        break;
      case PrePostCardType.postEvent:
        addNewTitle = 'Add Post-event';
        fieldName = Discussion.kFieldPostEventCardData;
        break;
    }

    if (eventCardData != null) {
      return PrePostCardWidgetPage(
        prePostCardType: prePostCardType,
        prePostCard: eventCardData,
        isWhiteBackground: true,
        discussion: discussion,
        onUpdate: (prePostCard) async {
          final Discussion updatedDiscussion;
          switch (prePostCardType) {
            case PrePostCardType.preEvent:
              updatedDiscussion = discussion.copyWith(preEventCardData: prePostCard);
              break;
            case PrePostCardType.postEvent:
              updatedDiscussion = discussion.copyWith(postEventCardData: prePostCard);
              break;
          }

          await alertOnError(
              context,
              () => firestoreDiscussionService.updateDiscussion(
                    discussion: updatedDiscussion,
                    keys: [fieldName],
                  ));
        },
        onDelete: () async {
          final Discussion updatedDiscussion;
          switch (prePostCardType) {
            case PrePostCardType.preEvent:
              updatedDiscussion = discussion.copyWith(preEventCardData: null);
              break;
            case PrePostCardType.postEvent:
              updatedDiscussion = discussion.copyWith(postEventCardData: null);
              break;
          }

          await alertOnError(
              context,
              () => firestoreDiscussionService.updateDiscussion(
                    discussion: updatedDiscussion,
                    keys: [fieldName],
                  ));
        },
        prePostCardWidgetType: isEditable && eventCardData.isNew()
            ? PrePostCardWidgetType.edit
            : PrePostCardWidgetType.overview,
        isEditable: isEditable,
      );
    } else {
      return AddMoreButton(
        label: addNewTitle,
        isWhiteBackground: true,
        onPressed: () async {
          final prePostCard = PrePostCard.newCard(prePostCardType);
          final Discussion updatedDiscussion;
          switch (prePostCardType) {
            case PrePostCardType.preEvent:
              updatedDiscussion = discussion.copyWith(preEventCardData: prePostCard);
              break;
            case PrePostCardType.postEvent:
              updatedDiscussion = discussion.copyWith(postEventCardData: prePostCard);
              break;
          }

          await alertOnError(
              context,
              () => firestoreDiscussionService.updateDiscussion(
                    discussion: updatedDiscussion,
                    keys: [fieldName],
                  ));
        },
      );
    }
  }

  Widget _buildPrerequisiteTopicSection({
    required BuildContext context,
    required Discussion discussion,
    required bool isEditable,
  }) {
    final discussionTabsModelState = context.watch<DiscussionTabsControllerState>();

    final hasPrerequisite = discussion.prerequisiteTopicId != null;

    final String fieldName = Discussion.fieldPrerequisiteTopic;

    if (hasPrerequisite || discussionTabsModelState.isNewPrerequisite) {
      return PrerequisiteTopicWidgetPage(
        isWhiteBackground: true,
        topicsFuture: discussionTabsModelState.topicsFuture,
        discussion: discussion,
        onUpdate: (prerequisiteTopicId) async {
          final Discussion updatedDiscussion =
              discussion.copyWith(prerequisiteTopicId: prerequisiteTopicId);

          await alertOnError(
              context,
              () => firestoreDiscussionService.updateDiscussion(
                    discussion: updatedDiscussion,
                    keys: [fieldName],
                  ));
        },
        onDelete: () => alertOnError(context, () async {
          final Discussion updatedDiscussion = discussion.copyWith(prerequisiteTopicId: null);
          await firestoreDiscussionService.updateDiscussion(
            discussion: updatedDiscussion,
            keys: [fieldName],
          );
          discussionTabsModelState.isNewPrerequisite = false;
        }),
        prerequisiteTopicWidgetType: PrerequisiteTopicWidgetType.edit,
        isEditable: isEditable,
      );
    } else {
      return AddMoreButton(
        label: 'Add a prerequisite template',
        isWhiteBackground: true,
        onPressed: () {
          discussionTabsModelState.isNewPrerequisite = true;
        },
      );
    }
  }
}
