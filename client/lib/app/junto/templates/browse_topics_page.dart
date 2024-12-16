import 'package:flutter/material.dart';
import 'package:junto/app/junto/community_permissions_provider.dart';
import 'package:junto/app/junto/templates/create_topic/create_topic_dialog.dart';
import 'package:junto/app/junto/templates/select_topic.dart';
import 'package:junto/app/junto/templates/select_topic_provider.dart';
import 'package:junto/app/junto/junto_provider.dart';
import 'package:junto/app/junto/utils.dart';
import 'package:junto/common_widgets/junto_list_view.dart';
import 'package:provider/provider.dart';

class BrowseTopicsPage extends StatefulWidget {
  @override
  _BrowseTopicsPageState createState() => _BrowseTopicsPageState();
}

class _BrowseTopicsPageState extends State<BrowseTopicsPage> {
  @override
  Widget build(BuildContext context) {
    final juntoProvider = context.watch<JuntoProvider>();

    final canCreateTopic = Provider.of<CommunityPermissionsProvider>(context).canCreateTopic;

    return JuntoListView(
      children: [
        SizedBox(height: 30),
        ContentHorizontalPadding(
          child: ChangeNotifierProvider(
            create: (_) => SelectTopicProvider(
              juntoId: juntoProvider.juntoId,
            ),
            builder: (context, _) => SelectTopic(
              onAddNew: canCreateTopic
                  ? () => CreateTopicDialog.show(
                        juntoProvider: juntoProvider,
                        communityPermissionsProvider:
                            Provider.of<CommunityPermissionsProvider>(context, listen: false),
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
