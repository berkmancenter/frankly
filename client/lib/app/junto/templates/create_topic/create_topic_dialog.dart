import 'dart:async';

import 'package:flutter/material.dart';
import 'package:junto/app/junto/community_permissions_provider.dart';
import 'package:junto/app/junto/templates/create_topic/create_custom_topic_page.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/common_widgets/create_dialog_ui_migration.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto_models/firestore/topic.dart';
import 'package:provider/provider.dart';

class CreateTopicDialog extends StatelessWidget {
  final JuntoProvider juntoProvider;
  final CommunityPermissionsProvider communityPermissionsProvider;
  final TopicActionType topicActionType;
  final Topic? topic;
  final FutureOr<void> Function(Topic topic)? afterSubmit;

  const CreateTopicDialog._({
    required this.juntoProvider,
    required this.communityPermissionsProvider,
    required this.topicActionType,
    this.topic,
    this.afterSubmit,
  });

  static Future<void> show({
    required JuntoProvider juntoProvider,
    required CommunityPermissionsProvider communityPermissionsProvider,
    TopicActionType topicActionType = TopicActionType.create,
    Topic? topic,
    FutureOr<void> Function(Topic topic)? afterSubmit,
  }) async {
    final createdTopic = await CreateDialogUiMigration<Topic>(
      isFullscreenOnMobile: true,
      builder: (context) => CreateTopicDialog._(
        communityPermissionsProvider: communityPermissionsProvider,
        juntoProvider: juntoProvider,
        topicActionType: topicActionType,
        topic: topic,
        afterSubmit: afterSubmit,
      ),
    ).show();

    if (createdTopic != null) {
      routerDelegate.beamTo(JuntoPageRoutes(juntoDisplayId: juntoProvider.displayId).topicPage(
        topicId: createdTopic.id,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: communityPermissionsProvider,
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: CreateCustomTopicPage(
          juntoProvider: juntoProvider,
          topicActionType: topicActionType,
          topic: topic,
          afterSubmit: afterSubmit,
        ),
      ),
    );
  }
}
