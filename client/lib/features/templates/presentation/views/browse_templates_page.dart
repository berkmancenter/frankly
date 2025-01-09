import 'package:client/core/widgets/content_horizontal_padding.dart';
import 'package:flutter/material.dart';
import 'package:client/features/community/data/providers/community_permissions_provider.dart';
import 'package:client/features/templates/features/create_template/presentation/views/create_template_dialog.dart';
import 'package:client/features/templates/presentation/widgets/select_template.dart';
import 'package:client/features/templates/data/providers/select_template_provider.dart';
import 'package:client/features/community/data/providers/community_provider.dart';
import 'package:client/core/utils/error_utils.dart';
import 'package:client/core/widgets/custom_list_view.dart';
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
