import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:junto/app/junto/community_permissions_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_settings/discussion_settings_drawer.dart';
import 'package:junto/app/junto/discussions/discussion_page/meeting_agenda/meeting_agenda.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/add_more_button.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/circle_icon_button.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/discussion_picture.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/pre_post_card_widget/pre_post_card_widget_page.dart';
import 'package:junto/app/junto/discussions/discussion_page/widgets/prerequisite_topic_widget/prerequisite_topic_widget_page.dart';
import 'package:junto/app/junto/home/discussion_widget.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/templates/attended_prerequisite_provider.dart';
import 'package:junto/app/junto/templates/create_topic/create_custom_topic_page.dart';
import 'package:junto/app/junto/templates/create_topic/create_topic_presenter.dart';
import 'package:junto/app/junto/templates/create_topic/create_topic_tag_presenter.dart';
import 'package:junto/app/junto/templates/edit_topic/edit_topic_drawer.dart';
import 'package:junto/app/junto/templates/new_conversation_card.dart';
import 'package:junto/app/junto/templates/topic_page_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/empty_page_content.dart';
import 'package:junto/common_widgets/junto_image.dart';
import 'package:junto/common_widgets/junto_ink_well.dart';
import 'package:junto/common_widgets/junto_stream_builder.dart';
import 'package:junto/common_widgets/junto_tag_builder.dart';
import 'package:junto/common_widgets/junto_ui_migration.dart';
import 'package:junto/common_widgets/prerequisite_topic_widget.dart';
import 'package:junto/common_widgets/tabs/tab_bar.dart';
import 'package:junto/common_widgets/tabs/tab_bar_view.dart';
import 'package:junto/common_widgets/tabs/tab_controller.dart';
import 'package:junto/common_widgets/topic_cards.dart';
import 'package:junto/services/junto_user_data_service.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_asset.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/dialogs.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto/utils/stream_utils.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/junto_tag.dart';
import 'package:junto_models/firestore/pre_post_card.dart';
import 'package:junto_models/firestore/topic.dart';
import 'package:provider/provider.dart';

class TopicPage extends StatefulWidget {
  const TopicPage._();

  static Widget create({required String topicId}) {
    return ChangeNotifierProvider(
      create: (context) => TopicPageProvider(
        juntoId: context.read<JuntoProvider>().juntoId,
        topicId: topicId,
      )..initialize(),
      child: TopicPage._(),
    );
  }

  @override
  _TopicPageState createState() => _TopicPageState();
}

class _TopicPageState extends State<TopicPage> with SingleTickerProviderStateMixin {
  bool get isAdmin => Provider.of<JuntoUserDataService>(context)
      .getMembership(Provider.of<JuntoProvider>(context).juntoId)
      .isAdmin;

  String get juntoId => Provider.of<JuntoProvider>(context, listen: false).juntoId;

  bool get _canCreateEvent => Provider.of<CommunityPermissionsProvider>(context).canCreateEvent;

  Widget _buildPrerequisiteSection(Topic topic) {
    final isEditPrerequisite = topic.prerequisiteTopicId != null;
    final topicPageProvider = context.read<TopicPageProvider>();
    if (isEditPrerequisite || topicPageProvider.isNewPrerequisite) {
      return PrerequisiteTopicWidgetPage(
        isWhiteBackground: true,
        topic: topic,
        topicsFuture: context.read<TopicPageProvider>().topicsFuture,
        isEditable: isAdmin,
        onDelete: () {
          alertOnError(
            context,
            () => firestoreDatabase.updateTopic(
              juntoId: juntoId,
              topic: topic.copyWith(prerequisiteTopicId: null),
              keys: [Topic.fieldPrerequisiteTopic],
            ),
          );
          topicPageProvider.isNewPrerequisite = false;
        },
        onUpdate: (prerequisiteId) => alertOnError(context, () async {
          await firestoreDatabase.updateTopic(
            juntoId: juntoId,
            topic: topic.copyWith(prerequisiteTopicId: prerequisiteId),
            keys: [Topic.fieldPrerequisiteTopic],
          );

          showRegularToast(context, 'Prerequisite saved', toastType: ToastType.success);
        }),
      );
    } else {
      return AddMoreButton(
        label: 'Add a prerequisite template',
        isWhiteBackground: true,
        onPressed: () {
          topicPageProvider.isNewPrerequisite = true;
        },
      );
    }
  }

  Widget _buildAgenda(Topic topic, bool hasAttendedPrerequisite) {
    final prerequisiteTopicId = topic.prerequisiteTopicId;
    return Container(
      alignment: Alignment.centerLeft,
      child: Column(
        children: [
          if (prerequisiteTopicId != null && !hasAttendedPrerequisite) ...[
            PrerequisiteTopicWidget(
              prerequisiteTopicId: prerequisiteTopicId,
              juntoId: juntoId,
            ),
            SizedBox(height: 12),
          ],
          MeetingAgendaWrapper(
            juntoId: Provider.of<JuntoProvider>(context).juntoId,
            topic: topic,
            allowButtonForUserSubmittedAgenda: false,
            backgroundColor: AppColor.gray6,
            child: MeetingAgenda(
              canUserEditAgenda: context.watch<CommunityPermissionsProvider>().canEditTopic(topic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscussions(Topic topic, bool hasAttendedPrerequisite) {
    return ConstrainedBody(
      child: JuntoUiMigration(
        whiteBackground: true,
        child: JuntoStreamBuilder<List<Discussion>?>(
          entryFrom: '_TopicPageState._buildDiscussions',
          stream: Provider.of<TopicPageProvider>(context).discussions,
          height: 100,
          errorMessage: 'Something went wrong loading events.',
          builder: (_, discussions) {
            if (discussions == null || discussions.isEmpty) {
              return EmptyPageContent(
                type: EmptyPageType.events,
                titleText: 'No events',
                subtitleText: 'When new events are added, you’ll see them here.',
                showContainer: false,
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 30),
                for (final discussion in discussions.take(40)) ...[
                  DiscussionWidget(
                    discussion,
                    key: Key('discussion-${discussion.id}'),
                  ),
                  SizedBox(height: 20),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopicContents(Topic topic) {
    final prerequisiteTopicId = topic.prerequisiteTopicId;
    return JuntoStreamGetterBuilder<bool?>(
        key: Key('topic-page-pre-post-enabled-$isAdmin${topic.id}'),
        keys: [isAdmin],
        streamGetter: () => isAdmin
            ? Provider.of<JuntoProvider>(context).prePostEnabled().asStream()
            : Stream.value(false),
        builder: (context, prePostEnabled) => JuntoTabController(
              tabs: [
                JuntoTabAndContent(
                  tab: 'About',
                  content: (context) => JuntoStreamBuilder<bool>(
                    entryFrom: 'TopicPage._buildTopicContents',
                    stream: Provider.of<AttendedPrerequisiteProvider>(context)
                        .hasParticipantAttendedPrerequisiteFuture
                        .asStream(),
                    builder: (context, hasAttendedPrerequisite) {
                      return _buildAboutTabContent(
                        topic: topic,
                        context: context,
                        hasAttendedPrerequisite: hasAttendedPrerequisite ?? false,
                      );
                    },
                  ),
                ),
                JuntoTabAndContent(
                    tab: 'Agenda',
                    content: (context) {
                      return JuntoStreamBuilder<bool>(
                          entryFrom: 'TopicPage._buildTopicContents',
                          stream: Provider.of<AttendedPrerequisiteProvider>(context)
                              .hasParticipantAttendedPrerequisiteFuture
                              .asStream(),
                          builder: (context, hasAttendedPrerequisite) {
                            return _buildAgenda(topic, hasAttendedPrerequisite ?? false);
                          });
                    }),
                JuntoTabAndContent(
                  tab: 'Upcoming Events',
                  content: (context) => JuntoStreamBuilder<bool>(
                    entryFrom: 'TopicPage._buildTopicContents',
                    stream: Provider.of<AttendedPrerequisiteProvider>(context)
                        .hasParticipantAttendedPrerequisiteFuture
                        .asStream(),
                    builder: (context, hasAttendedPrerequisite) {
                      return _buildDiscussions(topic, hasAttendedPrerequisite ?? false);
                    },
                  ),
                ),
                if (isAdmin)
                  JuntoTabAndContent(
                    tab: 'CTAS',
                    content: (context) => JuntoStreamBuilder<bool>(
                      entryFrom: 'TopicPage._buildTopicContents',
                      stream: Provider.of<AttendedPrerequisiteProvider>(context)
                          .hasParticipantAttendedPrerequisiteFuture
                          .asStream(),
                      builder: (context, hasAttendedPrerequisite) {
                        return _buildPrePostTabContent(
                          topic,
                          hasAttendedPrerequisite ?? false,
                        );
                      },
                    ),
                    isGated: !(prePostEnabled ?? false),
                  ),
              ],
              child: Column(
                children: [
                  JuntoUiMigration(
                    whiteBackground: true,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColor.gray5, width: 2),
                        ),
                        color: AppColor.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _TopicHeader(topic: topic),
                          ConstrainedBody(
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: JuntoTabBar(isWhiteBackground: true),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ConstrainedBody(
                    child: ChangeNotifierProvider<AttendedPrerequisiteProvider>(
                      create: (_) => AttendedPrerequisiteProvider(
                        topic: topic,
                        isAdmin: isAdmin,
                      )..initialize(),
                      builder: (context, __) {
                        return JuntoStreamBuilder<bool>(
                          entryFrom: '_TopicPageState._buildTopicContents',
                          stream: Provider.of<AttendedPrerequisiteProvider>(context)
                              .hasParticipantAttendedPrerequisiteFuture
                              .asStream(),
                          builder: (_, hasAttendedPrerequisite) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: JuntoTabBarView(),
                                ),
                                if (!responsiveLayoutService.isMobile(context) &&
                                    _canCreateEvent) ...[
                                  SizedBox(width: 25),
                                  SizedBox(
                                    width: 350,
                                    child: Column(
                                      children: [
                                        NewConversationCard(
                                          topic: topic,
                                          hasAttendedPrerequisite: hasAttendedPrerequisite ?? false,
                                        ),
                                        if (prerequisiteTopicId != null &&
                                            !(hasAttendedPrerequisite ?? false)) ...[
                                          SizedBox(height: 20),
                                          PrerequisiteTopicWidget(
                                            juntoId: juntoId,
                                            prerequisiteTopicId: prerequisiteTopicId,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 100),
                ],
              ),
            ));
  }

  Widget _buildTopicDescription({required Topic topic}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JuntoText(
          'Description',
          style: AppTextStyle.headlineSmall.copyWith(
            color: AppColor.darkBlue,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 10),
        JuntoText(
          topic.description ?? 'No description for this event',
          style: AppTextStyle.body.copyWith(color: AppColor.gray2),
        ),
      ],
    );
  }

  Widget _buildMoreTopics() {
    final width = MediaQuery.of(context).size.width;
    final int maxContainerDisplayCount;
    if (width < 450) {
      maxContainerDisplayCount = 3;
    } else if (width < 550
        // Condition to handle the case when in low desktop resolutions and there is not enough space to show all cards
        ||
        (width > 1000 && width < 1120)) {
      maxContainerDisplayCount = 4;
    } else {
      maxContainerDisplayCount = 5;
    }
    final junto = JuntoProvider.watch(context).junto;

    final isMeetingOfAmerica = JuntoProvider.watch(context).isMeetingOfAmerica;
    return JuntoStreamBuilder<List<Topic>>(
        entryFrom: '_TopicPageState.buildMoreTopics',
        stream: Provider.of<TopicPageProvider>(context).topicsFuture.asStream(),
        builder: (context, returnedTopics) {
          final topics = returnedTopics ?? [];

          final showAdditionalTopicsCard = topics.length > maxContainerDisplayCount;

          final topicsToShow = showAdditionalTopicsCard
              ? topics.sublist(0, min(topics.length, maxContainerDisplayCount - 1))
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
                  if (topics.length > maxContainerDisplayCount) ...[
                    SizedBox(width: 16),
                    AdditionalTopicsCard(
                      context: context,
                      topics: topics,
                      numShown: maxContainerDisplayCount,
                    ),
                  ],
                ],
              ),
            ],
          );
        });
  }

  Widget _buildUpcomingDiscussions(context) {
    final topicPageProvider = Provider.of<TopicPageProvider>(context);
    final tabController = Provider.of<JuntoTabControllerState>(context);
    return Column(
      children: [
        Row(
          children: [
            JuntoText(
              'Upcoming Events',
              style: AppTextStyle.headlineSmall.copyWith(
                color: AppColor.darkBlue,
                fontSize: 16,
              ),
            ),
            Spacer(),
            if (topicPageProvider.hasUpcomingEvents)
              JuntoInkWell(
                onTap: () => tabController.currentTab = 3,
                child: JuntoText(
                  'See all',
                  style: AppTextStyle.bodyMedium.copyWith(color: AppColor.darkBlue),
                ),
              )
          ],
        ),
        JuntoStreamBuilder<List<Discussion>?>(
          entryFrom: '_DiscussionPageState._buildDiscussions',
          stream: topicPageProvider.discussions,
          height: 100,
          errorMessage: 'Something went wrong loading events.',
          builder: (_, discussions) {
            if (discussions == null || discussions.isEmpty) {
              return Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: JuntoText(
                    'No upcoming events.',
                    style: AppTextStyle.body.copyWith(
                      color: AppColor.gray2,
                    ),
                  ),
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 30),
                for (final discussion in discussions.take(1)) ...[
                  DiscussionWidget(
                    discussion,
                    key: Key('discussion-${discussion.id}'),
                  ),
                  SizedBox(height: 20),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildAboutTabContent({
    required Topic topic,
    required BuildContext context,
    required bool hasAttendedPrerequisite,
  }) {
    return SingleChildScrollView(
      controller: ScrollController(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          _buildTopicDescription(topic: topic),
          SizedBox(height: 40),
          _buildUpcomingDiscussions(context),
          SizedBox(height: 40),
          _buildMoreTopics(),
        ],
      ),
    );
  }

  Widget _buildPrePostTabContent(Topic topic, bool hasAttendedPrerequisite) {
    final permissions = Provider.of<CommunityPermissionsProvider>(context);
    final preEventCardData = topic.preEventCardData;
    final postEventCardData = topic.postEventCardData;
    final isPrePostEditable = permissions.canEditTopic(topic);

    final enablePrerequisites = topic.discussionSettings?.enablePrerequisites ??
        JuntoProvider.watch(context).discussionSettings.enablePrerequisites ??
        false;
    return SingleChildScrollView(
      controller: ScrollController(),
      child: Column(
        children: [
          SizedBox(height: 20),
          if (enablePrerequisites) ...[
            _buildPrerequisiteSection(topic),
            SizedBox(height: 20),
          ],
          _buildPrePostCardSection(
            context: context,
            prePostCardType: PrePostCardType.preEvent,
            eventCardData: preEventCardData,
            topic: topic,
            isEditable: isPrePostEditable,
          ),
          SizedBox(height: 20),
          _buildPrePostCardSection(
            context: context,
            prePostCardType: PrePostCardType.postEvent,
            eventCardData: postEventCardData,
            topic: topic,
            isEditable: isPrePostEditable,
          ),
        ],
      ),
    );
  }

  Widget _buildPrePostCardSection({
    required BuildContext context,
    required PrePostCardType prePostCardType,
    PrePostCard? eventCardData,
    required Topic topic,
    required bool isEditable,
  }) {
    String juntoId = Provider.of<JuntoProvider>(context, listen: false).juntoId;
    if (!isEditable && (eventCardData == null || eventCardData.isNew())) {
      return SizedBox.shrink();
    }

    final String addNewTitle;
    final String fieldName;
    switch (prePostCardType) {
      case PrePostCardType.preEvent:
        addNewTitle = 'Add Pre-event';
        fieldName = Topic.kFieldPreEventCardData;
        break;
      case PrePostCardType.postEvent:
        addNewTitle = 'Add Post-event';
        fieldName = Topic.kFieldPostEventCardData;
        break;
    }

    if (eventCardData != null) {
      return PrePostCardWidgetPage(
        prePostCardType: prePostCardType,
        prePostCard: eventCardData,
        isWhiteBackground: true,
        topic: topic,
        onUpdate: (prePostCard) {
          final Topic updatedTopic;
          switch (prePostCardType) {
            case PrePostCardType.preEvent:
              updatedTopic = topic.copyWith(preEventCardData: prePostCard);
              break;
            case PrePostCardType.postEvent:
              updatedTopic = topic.copyWith(postEventCardData: prePostCard);
              break;
          }

          alertOnError(context, () async {
            await firestoreDatabase.updateTopic(
              juntoId: juntoId,
              topic: updatedTopic,
              keys: [fieldName],
            );
          });
        },
        onDelete: () {
          final Topic updatedTopic;
          switch (prePostCardType) {
            case PrePostCardType.preEvent:
              updatedTopic = topic.copyWith(preEventCardData: null);
              break;
            case PrePostCardType.postEvent:
              updatedTopic = topic.copyWith(postEventCardData: null);
              break;
          }

          alertOnError(context, () async {
            await firestoreDatabase.updateTopic(
              juntoId: juntoId,
              topic: updatedTopic,
              keys: [fieldName],
            );
          });
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
          onPressed: () {
            final prePostCard = PrePostCard.newCard(prePostCardType);
            final Topic updatedTopic;
            switch (prePostCardType) {
              case PrePostCardType.preEvent:
                updatedTopic = topic.copyWith(preEventCardData: prePostCard);
                break;
              case PrePostCardType.postEvent:
                updatedTopic = topic.copyWith(postEventCardData: prePostCard);
                break;
            }

            alertOnError(context, () async {
              await firestoreDatabase.updateTopic(
                juntoId: juntoId,
                topic: updatedTopic,
                keys: [fieldName],
              );
            });
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final topic = context.watch<TopicPageProvider>().topic;
    if (topic == null) {
      return SizedBox.shrink();
    }

    return GestureDetector(
      onTap: context.read<TopicPageProvider>().isHelpExpanded
          ? () => context.read<TopicPageProvider>().isHelpExpanded = false
          : null,
      child: JuntoStreamBuilder<Topic?>(
        entryFrom: '_TopicPageState.build',
        stream: context.watch<TopicPageProvider>().topicStream,
        errorMessage: 'There was an error loading templates.',
        builder: (_, topic) {
          if (topic == null) return JuntoText('There was an error loading templates.');
          return _buildTopicContents(topic);
        },
      ),
    );
  }
}

class _TopicHeader extends StatefulWidget {
  final Topic topic;

  const _TopicHeader({required this.topic});

  @override
  _TopicHeaderState createState() => _TopicHeaderState();
}

class _TopicHeaderState extends State<_TopicHeader> {
  List<JuntoTag> get topicTags => Provider.of<TopicPageProvider>(context).tags;

  bool get _canEdit =>
      Provider.of<CommunityPermissionsProvider>(context).canEditTopic(widget.topic);

  Widget _buildSettingsButton() {
    return CircleIconButton(
      icon: JuntoImage(
        null,
        asset: AppAsset.kGearPng,
        width: 20,
        height: 20,
      ),
      onPressed: () => Dialogs.showAppDrawer(
        context,
        AppDrawerSide.right,
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: context.read<JuntoProvider>()),
            ChangeNotifierProvider.value(value: context.read<TopicPageProvider>()),
          ],
          child: DiscussionSettingsDrawer(
            discussionSettingsDrawerType: DiscussionSettingsDrawerType.topic,
          ),
        ),
      ),
      toolTipText: 'Edit settings',
    );
  }

  Widget _buildEditButton() {
    final juntoProvider = context.read<JuntoProvider>();

    return CircleIconButton(
      icon: JuntoImage(
        null,
        asset: AppAsset.kEditPng,
        width: 20,
        height: 20,
      ),
      onPressed: () => Dialogs.showAppDrawer(
        context,
        AppDrawerSide.right,
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: juntoProvider),
            ChangeNotifierProvider.value(
              value: context.read<TopicPageProvider>(),
            ),
            ChangeNotifierProvider.value(
              value: context.read<CommunityPermissionsProvider>(),
            ),
            ChangeNotifierProvider(
              create: (_) => CreateTopicPresenter(
                juntoProvider: juntoProvider,
                topicActionType: TopicActionType.edit,
                topic: widget.topic,
                topicId: widget.topic.id,
              )..initialize(),
            ),
            ChangeNotifierProvider<CreateTopicTagPresenter>(
              create: (_) => CreateTopicTagPresenter(
                topicId: widget.topic.id,
                juntoId: juntoProvider.junto.id,
                isNewTopic: false,
              )..initialize(),
            ),
          ],
          child: EditTopicDrawer(),
        ),
      ),
      toolTipText: 'Edit template',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = responsiveLayoutService.isMobile(context);

    if (isMobile) {
      return ConstrainedBody(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DiscussionOrTopicPicture(
                    key: ObjectKey(widget.topic),
                    height: 80.0,
                    topic: widget.topic,
                    onEdit: _canEdit
                        ? (imageUrl) async {
                            await alertOnError(
                                context,
                                () => firestoreDatabase.updateTopic(
                                      juntoId: context.read<JuntoProvider>().juntoId,
                                      topic: widget.topic.copyWith(image: imageUrl),
                                      keys: [Topic.kFieldTopicImage],
                                    ));
                          }
                        : null,
                  ),
                  if (_canEdit)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSettingsButton(),
                        SizedBox(width: 10),
                        _buildEditButton(),
                      ],
                    ),
                ],
              ),
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  JuntoText(
                    widget.topic.title ?? '',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.headline2.copyWith(
                      color: AppColor.darkBlue,
                      decoration: widget.topic.status == TopicStatus.removed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (topicTags.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Wrap(
                      children: [
                        for (var tag in topicTags)
                          JuntoTagBuilder(
                            tagDefinitionId: tag.definitionId,
                            builder: (_, __, definition) => definition == null
                                ? SizedBox.shrink()
                                : Text(
                                    '#${definition.title} ',
                                    style: AppTextStyle.bodyMedium.copyWith(color: AppColor.gray3),
                                  ),
                          ),
                      ],
                    ),
                    SizedBox(height: 8),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return ConstrainedBody(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DiscussionOrTopicPicture(
                key: ObjectKey(widget.topic),
                height: 120.0,
                topic: widget.topic,
                onEdit: _canEdit
                    ? (imageUrl) async {
                        await alertOnError(
                            context,
                            () => firestoreDatabase.updateTopic(
                                  juntoId: context.read<JuntoProvider>().juntoId,
                                  topic: widget.topic.copyWith(image: imageUrl),
                                  keys: [Topic.kFieldTopicImage],
                                ));
                      }
                    : null,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: JuntoText(
                              widget.topic.title ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.headline1.copyWith(
                                color: AppColor.darkBlue,
                                fontSize: 40,
                                decoration: widget.topic.status == TopicStatus.removed
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                          if (_canEdit)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildSettingsButton(),
                                SizedBox(width: 10),
                                _buildEditButton(),
                              ],
                            ),
                        ],
                      ),
                      if (topicTags.isNotEmpty) ...[
                        SizedBox(height: 8),
                        Wrap(
                          children: [
                            for (var tag in topicTags)
                              JuntoTagBuilder(
                                tagDefinitionId: tag.definitionId,
                                builder: (_, __, definition) => definition == null
                                    ? SizedBox.shrink()
                                    : Text(
                                        '#${definition.title} ',
                                        style: AppTextStyle.bodyMedium.copyWith(
                                          color: AppColor.gray3,
                                        ),
                                      ),
                              ),
                          ],
                        ),
                        SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
