import 'package:flutter/material.dart';
import 'package:junto/app/junto/discussions/create_discussion/create_discussion_dialog_model.dart';
import 'package:junto/app/junto/discussions/create_discussion/select_topic.dart';
import 'package:junto/app/junto/templates/create_topic/create_topic_dialog.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/junto_list_view.dart';
import 'package:junto/app/junto/community_permissions_provider.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto_models/firestore/junto.dart';
import 'package:provider/provider.dart';

class SelectTopicPage extends StatefulWidget {
  @override
  _SelectTopicPageState createState() => _SelectTopicPageState();
}

class _SelectTopicPageState extends State<SelectTopicPage> {
  Junto get junto => context.watch<CreateDiscussionDialogModel>().juntoProvider.junto;

  @override
  Widget build(BuildContext context) {
    final permissions = Provider.of<CommunityPermissionsProvider>(context);
    final provider = context.watch<CreateDiscussionDialogModel>();
    final canSkip = permissions.canSkipChooseTemplate;

    return JuntoListView(
      shrinkWrap: true,
      children: [
        SizedBox(height: 30),
        SelectTopic.create(
          juntoId: provider.juntoProvider.junto.id,
          onSelected: (topic) => provider.setTopic(topic),
          selectedTopic: provider.selectedTopic,
          onAddNew: permissions.canCreateTopic
              ? () {
                  Navigator.of(context).pop();
                  CreateTopicDialog.show(
                    juntoProvider: provider.juntoProvider,
                    communityPermissionsProvider:
                        Provider.of<CommunityPermissionsProvider>(context, listen: false),
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
              onPressed: provider.selectedTopic != null ? () => provider.goNext() : null,
              text: 'Next',
            ),
          ],
        ),
      ],
    );
  }
}
