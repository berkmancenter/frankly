import 'package:flutter/material.dart';
import 'package:junto/app/junto/community_permissions_provider.dart';
import 'package:junto/app/junto/discussions/create_discussion/choose_platform_page.dart';
import 'package:junto/app/junto/discussions/create_discussion/create_discussion_dialog_model.dart';
import 'package:junto/app/junto/discussions/create_discussion/select_date_page.dart';
import 'package:junto/app/junto/discussions/create_discussion/select_hosting_option_page.dart';
import 'package:junto/app/junto/discussions/create_discussion/select_participants_number_page.dart';
import 'package:junto/app/junto/discussions/create_discussion/select_time_page.dart';
import 'package:junto/app/junto/discussions/create_discussion/select_title_page.dart';
import 'package:junto/app/junto/discussions/create_discussion/select_topic_page.dart';
import 'package:junto/app/junto/discussions/create_discussion/select_visibility_page.dart';
import 'package:junto/app/junto/discussions/discussion_page/discussion_provider.dart';
import 'package:junto/app/junto/discussions/discussion_page/topic_provider.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/create_dialog_ui_migration.dart';
import 'package:junto/common_widgets/junto_ui_migration.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/services/services.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto_models/firestore/discussion.dart';
import 'package:junto_models/firestore/topic.dart';
import 'package:provider/provider.dart';

/// Dialog Widget to create discussion
class CreateDiscussionDialog extends StatelessWidget {
  static Future<void> show(
    BuildContext context, {
    DiscussionProvider? discussionProvider,
    Topic? topic,
    Discussion? discussionTemplate,
    List<CurrentPage>? pages,
    DiscussionType discussionType = DiscussionType.hosted,
    void Function(Discussion)? onDiscussionCreated,
  }) async {
    final juntoProvider = JuntoProvider.read(context);
    final permissionsProvider = context.read<CommunityPermissionsProvider>();

    final isCreateTopicEnabled = permissionsProvider.canCreateTopic;

    bool juntoHasTopics = false;

    if (!isCreateTopicEnabled) {
      juntoHasTopics = juntoProvider.hasTopics;
    }

    final skipTopicSelection = (!isCreateTopicEnabled && !juntoHasTopics) &&
        !Provider.of<CommunityPermissionsProvider>(context, listen: false).canEditCommunity;

    Topic? topicData = topic;

    if (skipTopicSelection) {
      topicData = Topic(
        id: defaultTopicId,
        collectionPath: firestoreDatabase.topicsCollection(juntoProvider.juntoId).path,
        creatorId: userService.currentUserId!,
        title: 'My Custom Event',
        image: generateRandomImageUrl(),
        discussionSettings: juntoProvider.discussionSettings,
      );
    }
    final discussion = await CreateDialogUiMigration<Discussion>(
      isFullscreenOnMobile: true,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => CreateDiscussionDialogModel(
          juntoProvider: juntoProvider,
          discussionProvider: discussionProvider,
          initialTopic: topicData,
          discussionTemplate: discussionTemplate,
          pages: pages,
          discussionType: discussionType,
        )..initialize(),
        child: ChangeNotifierProvider.value(
          value: permissionsProvider,
          child: ChangeNotifierProvider.value(
            value: juntoProvider,
            child: CreateDiscussionDialog(),
          ),
        ),
      ),
    ).show();

    if (discussion != null) {
      if (onDiscussionCreated != null) onDiscussionCreated(discussion);

      routerDelegate.beamTo(JuntoPageRoutes(
        juntoDisplayId: juntoProvider.displayId,
      ).discussionPage(
        topicId: discussion.topicId,
        discussionId: discussion.id,
      ));
    }
  }

  Widget _buildCurrentPage(BuildContext context) {
    final currentPage = context.watch<CreateDiscussionDialogModel>().currentPageInfo;
    switch (currentPage) {
      case CurrentPage.selectTopic:
        return SelectTopicPage();
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
    final currentIndex = context.watch<CreateDiscussionDialogModel>().currentPageIndex + 1;
    final lastIndex = context.watch<CreateDiscussionDialogModel>().allPages.length;

    return JuntoUiMigration(
      whiteBackground: true,
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (currentIndex > 1 && lastIndex > 1)
              JuntoText('STEP $currentIndex OF $lastIndex', style: AppTextStyle.eyebrow),
            _buildCurrentPage(context),
          ],
        ),
      ),
    );
  }
}
