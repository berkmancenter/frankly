import 'dart:async';

import 'package:flutter/material.dart';
import 'package:client/app/community/community_permissions_provider.dart';
import 'package:client/app/community/templates/create_template/create_custom_template_page.dart';
import 'package:client/app/community/community_provider.dart';
import 'package:client/common_widgets/create_dialog_ui_migration.dart';
import 'package:client/routing/locations.dart';
import 'package:data_models/firestore/template.dart';
import 'package:provider/provider.dart';

class CreateTemplateDialog extends StatelessWidget {
  final CommunityProvider communityProvider;
  final CommunityPermissionsProvider communityPermissionsProvider;
  final TemplateActionType templateActionType;
  final Template? template;
  final FutureOr<void> Function(Template template)? afterSubmit;

  const CreateTemplateDialog._({
    required this.communityProvider,
    required this.communityPermissionsProvider,
    required this.templateActionType,
    this.template,
    this.afterSubmit,
  });

  static Future<void> show({
    required CommunityProvider communityProvider,
    required CommunityPermissionsProvider communityPermissionsProvider,
    TemplateActionType templateActionType = TemplateActionType.create,
    Template? template,
    FutureOr<void> Function(Template template)? afterSubmit,
  }) async {
    final createdTemplate = await CreateDialogUiMigration<Template>(
      isFullscreenOnMobile: true,
      builder: (context) => CreateTemplateDialog._(
        communityPermissionsProvider: communityPermissionsProvider,
        communityProvider: communityProvider,
        templateActionType: templateActionType,
        template: template,
        afterSubmit: afterSubmit,
      ),
    ).show();

    if (createdTemplate != null) {
      routerDelegate.beamTo(
        CommunityPageRoutes(communityDisplayId: communityProvider.displayId)
            .templatePage(
          templateId: createdTemplate.id,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: communityPermissionsProvider,
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: CreateCustomTemplatePage(
          communityProvider: communityProvider,
          templateActionType: templateActionType,
          template: template,
          afterSubmit: afterSubmit,
        ),
      ),
    );
  }
}
