import 'package:flutter/material.dart';
import 'package:client/app/community/community_permissions_provider.dart';
import 'package:client/app/community/events/create_event/choose_platform_page.dart';
import 'package:client/app/community/events/create_event/create_event_dialog_model.dart';
import 'package:client/app/community/events/create_event/select_date_page.dart';
import 'package:client/app/community/events/create_event/select_hosting_option_page.dart';
import 'package:client/app/community/events/create_event/select_participants_number_page.dart';
import 'package:client/app/community/events/create_event/select_time_page.dart';
import 'package:client/app/community/events/create_event/select_title_page.dart';
import 'package:client/app/community/events/create_event/select_template_page.dart';
import 'package:client/app/community/events/create_event/select_visibility_page.dart';
import 'package:client/app/community/events/event_page/event_provider.dart';
import 'package:client/app/community/events/event_page/template_provider.dart';
import 'package:client/app/community/community_provider.dart';
import 'package:client/app/community/utils.dart';
import 'package:client/common_widgets/create_dialog_ui_migration.dart';
import 'package:client/common_widgets/ui_migration.dart';
import 'package:client/routing/locations.dart';
import 'package:client/services/services.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/utils/height_constained_text.dart';
import 'package:data_models/firestore/event.dart';
import 'package:data_models/firestore/template.dart';
import 'package:provider/provider.dart';

/// Dialog Widget to create event
class CreateEventDialog extends StatelessWidget {
  static Future<void> show(
    BuildContext context, {
    EventProvider? eventProvider,
    Template? template,
    Event? eventTemplate,
    List<CurrentPage>? pages,
    EventType eventType = EventType.hosted,
    void Function(Event)? onEventCreated,
  }) async {
    final communityProvider = CommunityProvider.read(context);
    final permissionsProvider = context.read<CommunityPermissionsProvider>();

    final isCreateTemplateEnabled = permissionsProvider.canCreateTemplate;

    bool communityHasTemplates = false;

    if (!isCreateTemplateEnabled) {
      communityHasTemplates = communityProvider.hasTemplates;
    }

    final skipTemplateSelection =
        (!isCreateTemplateEnabled && !communityHasTemplates) &&
            !Provider.of<CommunityPermissionsProvider>(context, listen: false)
                .canEditCommunity;

    Template? templateData = template;

    if (skipTemplateSelection) {
      templateData = Template(
        id: defaultTemplateId,
        collectionPath: firestoreDatabase
            .templatesCollection(communityProvider.communityId)
            .path,
        creatorId: userService.currentUserId!,
        title: 'My Custom Event',
        image: generateRandomImageUrl(),
        eventSettings: communityProvider.eventSettings,
      );
    }
    final event = await CreateDialogUiMigration<Event>(
      isFullscreenOnMobile: true,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => CreateEventDialogModel(
          communityProvider: communityProvider,
          eventProvider: eventProvider,
          initialTemplate: templateData,
          eventTemplate: eventTemplate,
          pages: pages,
          eventType: eventType,
        )..initialize(),
        child: ChangeNotifierProvider.value(
          value: permissionsProvider,
          child: ChangeNotifierProvider.value(
            value: communityProvider,
            child: CreateEventDialog(),
          ),
        ),
      ),
    ).show();

    if (event != null) {
      if (onEventCreated != null) onEventCreated(event);

      routerDelegate.beamTo(
        CommunityPageRoutes(
          communityDisplayId: communityProvider.displayId,
        ).eventPage(
          templateId: event.templateId,
          eventId: event.id,
        ),
      );
    }
  }

  Widget _buildCurrentPage(BuildContext context) {
    final currentPage = context.watch<CreateEventDialogModel>().currentPageInfo;
    switch (currentPage) {
      case CurrentPage.selectTemplate:
        return SelectTemplatePage();
      case CurrentPage.selectTitle:
        return SelectTitlePage();
      case CurrentPage.selectVisibility:
        return SelectVisibilityPage();
      case CurrentPage.selectDate:
        return SelectDatePage();
      case CurrentPage.selectTime:
        return SelectTimePage();
      case CurrentPage.choosePlatform:
        return ChoosePlatformPage();
      case CurrentPage.selectParticipants:
        return SelectParticipantsNumber();
      case CurrentPage.selectHostingType:
        return SelectHostingOptionPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex =
        context.watch<CreateEventDialogModel>().currentPageIndex + 1;
    final lastIndex = context.watch<CreateEventDialogModel>().allPages.length;

    return UIMigration(
      whiteBackground: true,
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (currentIndex > 1 && lastIndex > 1)
              HeightConstrainedText(
                'STEP $currentIndex OF $lastIndex',
                style: AppTextStyle.eyebrow,
              ),
            _buildCurrentPage(context),
          ],
        ),
      ),
    );
  }
}
