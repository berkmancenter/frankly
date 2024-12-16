import 'package:flutter/material.dart';
import 'package:client/app/community/community_permissions_provider.dart';
import 'package:client/app/community/templates/create_template/create_template_dialog.dart';
import 'package:client/app/community/templates/select_template.dart';
import 'package:client/app/community/templates/select_template_provider.dart';
import 'package:client/app/community/community_provider.dart';
import 'package:client/app/community/utils.dart';
import 'package:client/common_widgets/custom_list_view.dart';
import 'package:provider/provider.dart';

class BrowseTemplatesPage extends StatefulWidget {
  @override
  _BrowseTemplatesPageState createState() => _BrowseTemplatesPageState();
}

class _BrowseTemplatesPageState extends State<BrowseTemplatesPage> {
  @override
  Widget build(BuildContext context) {
    final communityProvider = context.watch<CommunityProvider>();

    final canCreateTemplate =
        Provider.of<CommunityPermissionsProvider>(context).canCreateTemplate;

    return CustomListView(
      children: [
        SizedBox(height: 30),
        ContentHorizontalPadding(
          child: ChangeNotifierProvider(
            create: (_) => SelectTemplateProvider(
              communityId: communityProvider.communityId,
            ),
            builder: (context, _) => SelectTemplate(
              onAddNew: canCreateTemplate
                  ? () => CreateTemplateDialog.show(
                        communityProvider: communityProvider,
                        communityPermissionsProvider:
                            Provider.of<CommunityPermissionsProvider>(
                          context,
                          listen: false,
                        ),
                      )
                  : null,
            ),
          ),
        ),
        SizedBox(height: 80),
      ],
    );
  }
}
