import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:client/core/widgets/action_button.dart';
import 'package:client/core/widgets/custom_list_view.dart';
import 'package:client/core/routing/locations.dart';
import 'package:client/services.dart';
import 'package:client/features/user/data/services/user_service.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/core/widgets/height_constained_text.dart';
import 'package:client/core/widgets/stream_utils.dart';
import 'package:data_models/community/community.dart';
import 'package:provider/provider.dart';

class SubscriptionsTab extends StatefulHookWidget {
  const SubscriptionsTab();

  @override
  _SubscriptionsTabState createState() => _SubscriptionsTabState();
}

class _SubscriptionsTabState extends State<SubscriptionsTab> {
  String get _userId => context.read<UserService>().currentUserId!;

  Widget _buildContent(
    BuildContext context,
    List<Community>? communities,
  ) {
    if (communities == null) {
      return SizedBox.shrink();
    }

    if (communities.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(20),
        child: HeightConstrainedText(
          'You are not the billing manager for any communities',
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: AppColor.white,
          ),
          constraints: BoxConstraints(maxWidth: 600, maxHeight: 500),
          child: CustomListView(
            shrinkWrap: true,
            children: [
              HeightConstrainedText(
                'Communities',
                textAlign: TextAlign.start,
                style: AppTextStyle.headline4,
              ),
              SizedBox(height: 20),
              for (int i = 0; i < communities.length; i++)
                Container(
                  height: 60,
                  color: i.isOdd ? AppColor.gray6 : null,
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      SizedBox(width: 10),
                      Expanded(
                        child: HeightConstrainedText(
                          communities[i].name ?? 'Unnamed Community',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 20),
                      ActionButton(
                        type: ActionButtonType.outline,
                        text: 'Admin Billing',
                        onPressed: () => routerDelegate.beamTo(
                          CommunityPageRoutes(
                            communityDisplayId: communities[i].displayId,
                          ).communityAdmin(tab: 'billing'),
                        ),
                        textColor: AppColor.darkBlue,
                        borderSide: BorderSide(color: AppColor.darkBlue),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        constraints: BoxConstraints(minWidth: 280, maxWidth: 540),
        child: CustomStreamGetterBuilder<List<Community>>(
          entryFrom: '_SubscriptionsTabState.build',
          streamGetter: () =>
              firestoreDatabase.communitiesUserIsOwnerOf(_userId),
          builder: _buildContent,
        ),
      ),
    );
  }
}
