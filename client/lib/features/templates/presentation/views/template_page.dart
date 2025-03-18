import 'dart:math';

import 'package:client/core/utils/toast_utils.dart';
import 'package:client/core/widgets/constrained_body.dart';
import 'package:flutter/material.dart';
import 'package:client/features/community/data/providers/community_permissions_provider.dart';
import 'package:client/features/events/features/event_page/presentation/views/event_settings_drawer.dart';
import 'package:client/features/events/features/live_meeting/features/meeting_agenda/presentation/widgets/meeting_agenda.dart';
import 'package:client/features/events/features/event_page/presentation/widgets/add_more_button.dart';
import 'package:client/core/widgets/buttons/circle_icon_button.dart';
import 'package:client/features/events/features/event_page/presentation/widgets/event_picture.dart';
import 'package:client/features/events/features/event_page/presentation/views/pre_post_card_widget_page.dart';
import 'package:client/features/events/features/event_page/presentation/views/prerequisite_template_widget_page.dart';
import 'package:client/features/community/presentation/widgets/event_widget.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/features/templates/data/providers/attended_prerequisite_provider.dart';
import 'package:client/features/templates/features/create_template/presentation/views/create_custom_template_page.dart';
import 'package:client/features/templates/features/create_template/presentation/create_template_presenter.dart';
import 'package:client/features/templates/features/create_template/presentation/create_template_tag_presenter.dart';
import 'package:client/features/templates/features/edit_template/presentation/views/edit_template_drawer.dart';
import 'package:client/features/templates/presentation/views/new_event_card.dart';
import 'package:client/features/templates/data/providers/template_page_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/empty_page_content.dart';
import 'package:client/core/widgets/custom_ink_well.dart';
import 'package:client/core/widgets/custom_stream_builder.dart';
import 'package:client/features/community/presentation/widgets/community_tag_builder.dart';
import 'package:client/features/templates/presentation/widgets/prerequisite_template_widget.dart';
import 'package:client/core/widgets/tabs/tab_bar.dart';
import 'package:client/core/widgets/tabs/tab_bar_view.dart';
import 'package:client/core/widgets/tabs/tab_controller.dart';
import 'package:client/features/templates/presentation/widgets/template_cards.dart';
import 'package:client/features/user/data/services/user_data_service.dart';
import 'package:client/services.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/utils/dialogs.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/core/widgets/stream_utils.dart';
import 'package:data_models/events/event.dart';
import 'package:data_models/community/community_tag.dart';
import 'package:data_models/events/pre_post_card.dart';
import 'package:data_models/templates/template.dart';
import 'package:provider/provider.dart';

class TemplatePage extends StatefulWidget {
  const TemplatePage._();

  static Widget create({required String templateId}) {
    return ChangeNotifierProvider(
      create: (context) => TemplatePageProvider(
        communityId: context.read<CommunityProvider>().communityId,
        templateId: templateId,
      )..initialize(),
      child: TemplatePage._(),
    );
  }

  @override
  _TemplatePageState createState() => _TemplatePageState();
}

class _TemplatePageState extends State<TemplatePage>
    with SingleTickerProviderStateMixin {
  bool get isAdmin => Provider.of<UserDataService>(context)
      .getMembership(Provider.of<CommunityProvider>(context).communityId)
      .isAdmin;

  String get communityId =>
      Provider.of<CommunityProvider>(context, listen: false).communityId;

  bool get _canCreateEvent =>
      Provider.of<CommunityPermissionsProvider>(context).canCreateEvent;

  Widget _buildPrerequisiteSection(Template template) {
    final isEditPrerequisite = template.prerequisiteTemplateId != null;
    final templatePageProvider = context.read<TemplatePageProvider>();
    if (isEditPrerequisite || templatePageProvider.isNewPrerequisite) {
      return PrerequisiteTemplateWidgetPage(
        isWhiteBackground: true,
        template: template,
        templatesFuture: context.read<TemplatePageProvider>().templatesFuture,
        isEditable: isAdmin,
        onDelete: () {
          alertOnError(
            context,
            () => firestoreDatabase.updateTemplate(
              communityId: communityId,
              template: template.copyWith(prerequisiteTemplateId: null),
              keys: [Template.fieldPrerequisiteTemplate],
            ),
          );
          templatePageProvider.isNewPrerequisite = false;
        },
        onUpdate: (prerequisiteId) => alertOnError(context, () async {
          await firestoreDatabase.updateTemplate(
            communityId: communityId,
            template: template.copyWith(prerequisiteTemplateId: prerequisiteId),
            keys: [Template.fieldPrerequisiteTemplate],
          );

          showRegularToast(
            context,
            'Prerequisite saved',
            toastType: ToastType.success,
          );
        }),
      );
    } else {
      return AddMoreButton(
        label: 'Add a prerequisite template',
        onPressed: () {
          templatePageProvider.isNewPrerequisite = true;
        },
      );
    }
  }

  Widget _buildAgenda(Template template, bool hasAttendedPrerequisite) {
    final prerequisiteTemplateId = template.prerequisiteTemplateId;
    return Container(
      alignment: Alignment.centerLeft,
      child: Column(
        children: [
          if (prerequisiteTemplateId != null && !hasAttendedPrerequisite) ...[
            PrerequisiteTemplateWidget(
              prerequisiteTemplateId: prerequisiteTemplateId,
              communityId: communityId,
            ),
            SizedBox(height: 12),
          ],
          MeetingAgendaWrapper(
            communityId: Provider.of<CommunityProvider>(context).communityId,
            template: template,
            allowButtonForUserSubmittedAgenda: false,
            backgroundColor: AppColor.gray6,
            child: MeetingAgenda(
              canUserEditAgenda: context
                  .watch<CommunityPermissionsProvider>()
                  .canEditTemplate(template),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvents(Template template, bool hasAttendedPrerequisite) {
    return ConstrainedBody(
      child: CustomStreamBuilder<List<Event>?>(
        entryFrom: '_TemplatePageState._buildEvents',
        stream: Provider.of<TemplatePageProvider>(context).events,
        height: 100,
        errorMessage: 'Something went wrong loading events.',
        builder: (_, events) {
          if (events == null || events.isEmpty) {
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
              for (final event in events.take(40)) ...[
                EventWidget(
                  event,
                  key: Key('event-${event.id}'),
                ),
                SizedBox(height: 20),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildTemplateContents(Template template) {
    final prerequisiteTemplateId = template.prerequisiteTemplateId;
    return MemoizedStreamBuilder<bool?>(
      key: Key('template-page-pre-post-enabled-$isAdmin${template.id}'),
      keys: [isAdmin],
      streamGetter: () => isAdmin
          ? Provider.of<CommunityProvider>(context).prePostEnabled().asStream()
          : Stream.value(false),
      builder: (context, prePostEnabled) => CustomTabController(
        tabs: [
          CustomTabAndContent(
            tab: 'About',
            content: (context) => CustomStreamBuilder<bool>(
              entryFrom: 'TemplatePage._buildTemplateContents',
              stream: Provider.of<AttendedPrerequisiteProvider>(context)
                  .hasParticipantAttendedPrerequisiteFuture
                  .asStream(),
              builder: (context, hasAttendedPrerequisite) {
                return _buildAboutTabContent(
                  template: template,
                  context: context,
                  hasAttendedPrerequisite: hasAttendedPrerequisite ?? false,
                );
              },
            ),
          ),
          CustomTabAndContent(
            tab: 'Agenda',
            content: (context) {
              return CustomStreamBuilder<bool>(
                entryFrom: 'TemplatePage._buildTemplateContents',
                stream: Provider.of<AttendedPrerequisiteProvider>(context)
                    .hasParticipantAttendedPrerequisiteFuture
                    .asStream(),
                builder: (context, hasAttendedPrerequisite) {
                  return _buildAgenda(
                    template,
                    hasAttendedPrerequisite ?? false,
                  );
                },
              );
            },
          ),
          CustomTabAndContent(
            tab: 'Upcoming Events',
            content: (context) => CustomStreamBuilder<bool>(
              entryFrom: 'TemplatePage._buildTemplateContents',
              stream: Provider.of<AttendedPrerequisiteProvider>(context)
                  .hasParticipantAttendedPrerequisiteFuture
                  .asStream(),
              builder: (context, hasAttendedPrerequisite) {
                return _buildEvents(
                  template,
                  hasAttendedPrerequisite ?? false,
                );
              },
            ),
          ),
          if (isAdmin)
            CustomTabAndContent(
              tab: 'CTAS',
              content: (context) => CustomStreamBuilder<bool>(
                entryFrom: 'TemplatePage._buildTemplateContents',
                stream: Provider.of<AttendedPrerequisiteProvider>(context)
                    .hasParticipantAttendedPrerequisiteFuture
                    .asStream(),
                builder: (context, hasAttendedPrerequisite) {
                  return _buildPrePostTabContent(
                    template,
                    hasAttendedPrerequisite ?? false,
                  );
                },
              ),
              isGated: !(prePostEnabled ?? false),
            ),
        ],
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColor.gray5, width: 2),
                ),
                color: AppColor.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TemplateHeader(template: template),
                  ConstrainedBody(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: CustomTabBar(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ConstrainedBody(
              child: ChangeNotifierProvider<AttendedPrerequisiteProvider>(
                create: (_) => AttendedPrerequisiteProvider(
                  template: template,
                  isAdmin: isAdmin,
                )..initialize(),
                builder: (context, __) {
                  return CustomStreamBuilder<bool>(
                    entryFrom: '_TemplatePageState._buildTemplateContents',
                    stream: Provider.of<AttendedPrerequisiteProvider>(context)
                        .hasParticipantAttendedPrerequisiteFuture
                        .asStream(),
                    builder: (_, hasAttendedPrerequisite) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CustomTabBarView(),
                          ),
                          if (!responsiveLayoutService.isMobile(context) &&
                              _canCreateEvent) ...[
                            SizedBox(width: 25),
                            SizedBox(
                              width: 350,
                              child: Column(
                                children: [
                                  NewEventCard(
                                    template: template,
                                    hasAttendedPrerequisite:
                                        hasAttendedPrerequisite ?? false,
                                  ),
                                  if (prerequisiteTemplateId != null &&
                                      !(hasAttendedPrerequisite ?? false)) ...[
                                    SizedBox(height: 20),
                                    PrerequisiteTemplateWidget(
                                      communityId: communityId,
                                      prerequisiteTemplateId:
                                          prerequisiteTemplateId,
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
      ),
    );
  }

  Widget _buildTemplateDescription({required Template template}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeightConstrainedText(
          'Description',
          style: AppTextStyle.headlineSmall.copyWith(
            fontSize: 16,
          ),
        ),
        SizedBox(height: 10),
        HeightConstrainedText(
          template.description ?? 'No description for this event',
          style: AppTextStyle.body.copyWith(color: AppColor.gray2),
        ),
      ],
    );
  }

  Widget _buildMoreTemplates() {
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
    final community = CommunityProvider.watch(context).community;

    return CustomStreamBuilder<List<Template>>(
      entryFrom: '_TemplatePageState.buildMoreTemplates',
      stream:
          Provider.of<TemplatePageProvider>(context).templatesFuture.asStream(),
      builder: (context, returnedTemplates) {
        final templates = returnedTemplates ?? [];

        final showAdditionalTemplatesCard =
            templates.length > maxContainerDisplayCount;

        final templatesToShow = showAdditionalTemplatesCard
            ? templates.sublist(
                0,
                min(templates.length, maxContainerDisplayCount - 1),
              )
            : templates;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeightConstrainedText(
              'More from ${community.name}',
              style: AppTextStyle.headlineSmall.copyWith(
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
                if (templates.length > maxContainerDisplayCount) ...[
                  SizedBox(width: 16),
                  AdditionalTemplatesCard(
                    context: context,
                    templates: templates,
                    numShown: maxContainerDisplayCount,
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildUpcomingEvents(context) {
    final templatePageProvider = Provider.of<TemplatePageProvider>(context);
    final tabController = Provider.of<CustomTabControllerState>(context);
    return Column(
      children: [
        Row(
          children: [
            HeightConstrainedText(
              'Upcoming Events',
              style: AppTextStyle.headlineSmall.copyWith(
                fontSize: 16,
              ),
            ),
            Spacer(),
            if (templatePageProvider.hasUpcomingEvents)
              CustomInkWell(
                onTap: () => tabController.currentTab = 3,
                child: HeightConstrainedText(
                  'See all',
                  style: AppTextStyle.bodyMedium,
                ),
              ),
          ],
        ),
        CustomStreamBuilder<List<Event>?>(
          entryFrom: '_EventPageState._buildEvents',
          stream: templatePageProvider.events,
          height: 100,
          errorMessage: 'Something went wrong loading events.',
          builder: (_, events) {
            if (events == null || events.isEmpty) {
              return Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: HeightConstrainedText(
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
                for (final event in events.take(1)) ...[
                  EventWidget(
                    event,
                    key: Key('event-${event.id}'),
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
    required Template template,
    required BuildContext context,
    required bool hasAttendedPrerequisite,
  }) {
    return SingleChildScrollView(
      controller: ScrollController(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          _buildTemplateDescription(template: template),
          SizedBox(height: 40),
          _buildUpcomingEvents(context),
          SizedBox(height: 40),
          _buildMoreTemplates(),
        ],
      ),
    );
  }

  Widget _buildPrePostTabContent(
    Template template,
    bool hasAttendedPrerequisite,
  ) {
    final permissions = Provider.of<CommunityPermissionsProvider>(context);
    final preEventCardData = template.preEventCardData;
    final postEventCardData = template.postEventCardData;
    final isPrePostEditable = permissions.canEditTemplate(template);

    final enablePrerequisites = template.eventSettings?.enablePrerequisites ??
        CommunityProvider.watch(context).eventSettings.enablePrerequisites ??
        false;
    return SingleChildScrollView(
      controller: ScrollController(),
      child: Column(
        children: [
          SizedBox(height: 20),
          if (enablePrerequisites) ...[
            _buildPrerequisiteSection(template),
            SizedBox(height: 20),
          ],
          _buildPrePostCardSection(
            context: context,
            prePostCardType: PrePostCardType.preEvent,
            eventCardData: preEventCardData,
            template: template,
            isEditable: isPrePostEditable,
          ),
          SizedBox(height: 20),
          _buildPrePostCardSection(
            context: context,
            prePostCardType: PrePostCardType.postEvent,
            eventCardData: postEventCardData,
            template: template,
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
    required Template template,
    required bool isEditable,
  }) {
    String communityId =
        Provider.of<CommunityProvider>(context, listen: false).communityId;
    if (!isEditable && (eventCardData == null || eventCardData.isNew())) {
      return SizedBox.shrink();
    }

    final String addNewTitle;
    final String fieldName;
    switch (prePostCardType) {
      case PrePostCardType.preEvent:
        addNewTitle = 'Add Pre-event';
        fieldName = Template.kFieldPreEventCardData;
        break;
      case PrePostCardType.postEvent:
        addNewTitle = 'Add Post-event';
        fieldName = Template.kFieldPostEventCardData;
        break;
    }

    if (eventCardData != null) {
      return PrePostCardWidgetPage(
        prePostCardType: prePostCardType,
        prePostCard: eventCardData,
        isWhiteBackground: true,
        template: template,
        onUpdate: (prePostCard) {
          final Template updatedTemplate;
          switch (prePostCardType) {
            case PrePostCardType.preEvent:
              updatedTemplate =
                  template.copyWith(preEventCardData: prePostCard);
              break;
            case PrePostCardType.postEvent:
              updatedTemplate =
                  template.copyWith(postEventCardData: prePostCard);
              break;
          }

          alertOnError(context, () async {
            await firestoreDatabase.updateTemplate(
              communityId: communityId,
              template: updatedTemplate,
              keys: [fieldName],
            );
          });
        },
        onDelete: () {
          final Template updatedTemplate;
          switch (prePostCardType) {
            case PrePostCardType.preEvent:
              updatedTemplate = template.copyWith(preEventCardData: null);
              break;
            case PrePostCardType.postEvent:
              updatedTemplate = template.copyWith(postEventCardData: null);
              break;
          }

          alertOnError(context, () async {
            await firestoreDatabase.updateTemplate(
              communityId: communityId,
              template: updatedTemplate,
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
        onPressed: () {
          final prePostCard = PrePostCard.newCard(prePostCardType);
          final Template updatedTemplate;
          switch (prePostCardType) {
            case PrePostCardType.preEvent:
              updatedTemplate =
                  template.copyWith(preEventCardData: prePostCard);
              break;
            case PrePostCardType.postEvent:
              updatedTemplate =
                  template.copyWith(postEventCardData: prePostCard);
              break;
          }

          alertOnError(context, () async {
            await firestoreDatabase.updateTemplate(
              communityId: communityId,
              template: updatedTemplate,
              keys: [fieldName],
            );
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final template = context.watch<TemplatePageProvider>().template;
    if (template == null) {
      return SizedBox.shrink();
    }

    return GestureDetector(
      onTap: context.read<TemplatePageProvider>().isHelpExpanded
          ? () => context.read<TemplatePageProvider>().isHelpExpanded = false
          : null,
      child: CustomStreamBuilder<Template?>(
        entryFrom: '_TemplatePageState.build',
        stream: context.watch<TemplatePageProvider>().templateStream,
        errorMessage: 'There was an error loading templates.',
        builder: (_, template) {
          if (template == null) {
            return HeightConstrainedText(
              'There was an error loading templates.',
            );
          }
          return _buildTemplateContents(template);
        },
      ),
    );
  }
}

class _TemplateHeader extends StatefulWidget {
  final Template template;

  const _TemplateHeader({required this.template});

  @override
  _TemplateHeaderState createState() => _TemplateHeaderState();
}

class _TemplateHeaderState extends State<_TemplateHeader> {
  List<CommunityTag> get templateTags =>
      Provider.of<TemplatePageProvider>(context).tags;

  bool get _canEdit => Provider.of<CommunityPermissionsProvider>(context)
      .canEditTemplate(widget.template);

  Widget _buildSettingsButton() {
    return CircleIconButton(
      icon: Icons.settings_outlined,
      onPressed: () => Dialogs.showAppDrawer(
        context,
        AppDrawerSide.right,
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
              value: context.read<CommunityProvider>(),
            ),
            ChangeNotifierProvider.value(
              value: context.read<TemplatePageProvider>(),
            ),
          ],
          child: EventSettingsDrawer(
            eventSettingsDrawerType: EventSettingsDrawerType.template,
          ),
        ),
      ),
      toolTipText: 'Edit settings',
    );
  }

  Widget _buildEditButton() {
    final communityProvider = context.read<CommunityProvider>();

    return CircleIconButton(
      icon: Icons.edit,
      onPressed: () => Dialogs.showAppDrawer(
        context,
        AppDrawerSide.right,
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: communityProvider),
            ChangeNotifierProvider.value(
              value: context.read<TemplatePageProvider>(),
            ),
            ChangeNotifierProvider.value(
              value: context.read<CommunityPermissionsProvider>(),
            ),
            ChangeNotifierProvider(
              create: (_) => CreateTemplatePresenter(
                communityProvider: communityProvider,
                templateActionType: TemplateActionType.edit,
                template: widget.template,
                templateId: widget.template.id,
              )..initialize(),
            ),
            ChangeNotifierProvider<CreateTemplateTagPresenter>(
              create: (_) => CreateTemplateTagPresenter(
                templateId: widget.template.id,
                communityId: communityProvider.community.id,
                isNewTemplate: false,
              )..initialize(),
            ),
          ],
          child: EditTemplateDrawer(),
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
                  EventOrTemplatePicture(
                    key: ObjectKey(widget.template),
                    height: 80.0,
                    template: widget.template,
                    onEdit: _canEdit
                        ? (imageUrl) async {
                            await alertOnError(
                              context,
                              () => firestoreDatabase.updateTemplate(
                                communityId: context
                                    .read<CommunityProvider>()
                                    .communityId,
                                template:
                                    widget.template.copyWith(image: imageUrl),
                                keys: [Template.kFieldTemplateImage],
                              ),
                            );
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
                  HeightConstrainedText(
                    widget.template.title ?? '',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.headline2.copyWith(
                      decoration:
                          widget.template.status == TemplateStatus.removed
                              ? TextDecoration.lineThrough
                              : null,
                    ),
                  ),
                  if (templateTags.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Wrap(
                      children: [
                        for (var tag in templateTags)
                          CommunityTagBuilder(
                            tagDefinitionId: tag.definitionId,
                            builder: (_, __, definition) => definition == null
                                ? SizedBox.shrink()
                                : Text(
                                    '#${definition.title} ',
                                    style: AppTextStyle.bodyMedium
                                        .copyWith(color: AppColor.gray3),
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
              EventOrTemplatePicture(
                key: ObjectKey(widget.template),
                height: 120.0,
                template: widget.template,
                onEdit: _canEdit
                    ? (imageUrl) async {
                        await alertOnError(
                          context,
                          () => firestoreDatabase.updateTemplate(
                            communityId:
                                context.read<CommunityProvider>().communityId,
                            template: widget.template.copyWith(image: imageUrl),
                            keys: [Template.kFieldTemplateImage],
                          ),
                        );
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
                            child: HeightConstrainedText(
                              widget.template.title ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.headline1.copyWith(
                                fontSize: 40,
                                decoration: widget.template.status ==
                                        TemplateStatus.removed
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
                      if (templateTags.isNotEmpty) ...[
                        SizedBox(height: 8),
                        Wrap(
                          children: [
                            for (var tag in templateTags)
                              CommunityTagBuilder(
                                tagDefinitionId: tag.definitionId,
                                builder: (_, __, definition) => definition ==
                                        null
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
