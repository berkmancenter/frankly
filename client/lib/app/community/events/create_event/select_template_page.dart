import 'package:flutter/material.dart';
import 'package:client/app/community/events/create_event/create_event_dialog_model.dart';
import 'package:client/app/community/events/create_event/select_template.dart';
import 'package:client/app/community/templates/create_template/create_template_dialog.dart';
import 'package:client/common_widgets/action_button.dart';
import 'package:client/common_widgets/custom_list_view.dart';
import 'package:client/app/community/community_permissions_provider.dart';
import 'package:client/styles/app_styles.dart';
import 'package:data_models/community/community.dart';
import 'package:provider/provider.dart';

class SelectTemplatePage extends StatefulWidget {
  @override
  _SelectTemplatePageState createState() => _SelectTemplatePageState();
}

class _SelectTemplatePageState extends State<SelectTemplatePage> {
  Community get community =>
      context.watch<CreateEventDialogModel>().communityProvider.community;

  @override
  Widget build(BuildContext context) {
    final permissions = Provider.of<CommunityPermissionsProvider>(context);
    final provider = context.watch<CreateEventDialogModel>();
    final canSkip = permissions.canSkipChooseTemplate;

    return CustomListView(
      shrinkWrap: true,
      children: [
        SizedBox(height: 30),
        SelectTemplate.create(
          communityId: provider.communityProvider.community.id,
          onSelected: (template) => provider.setTemplate(template),
          selectedTemplate: provider.selectedTemplate,
          onAddNew: permissions.canCreateTemplate
              ? () {
                  Navigator.of(context).pop();
                  CreateTemplateDialog.show(
                    communityProvider: provider.communityProvider,
                    communityPermissionsProvider:
                        Provider.of<CommunityPermissionsProvider>(
                      context,
                      listen: false,
                    ),
                  );
                }
              : null,
        ),
        SizedBox(height: 25),
        Row(
          children: [
            if (canSkip)
              ActionButton(
                onPressed: () => provider.goNext(),
                color: Theme.of(context).primaryColor,
                textColor: AppColor.white,
                text: 'Skip',
              ),
            Spacer(),
            ActionButton(
              onPressed: provider.selectedTemplate != null
                  ? () => provider.goNext()
                  : null,
              text: 'Next',
            ),
          ],
        ),
      ],
    );
  }
}
