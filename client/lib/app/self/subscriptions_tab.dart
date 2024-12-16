import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:junto/common_widgets/action_button.dart';
import 'package:junto/common_widgets/junto_list_view.dart';
import 'package:junto/routing/locations.dart';
import 'package:junto/services/services.dart';
import 'package:junto/services/user_service.dart';
import 'package:junto/styles/app_styles.dart';
import 'package:junto/utils/junto_text.dart';
import 'package:junto/utils/stream_utils.dart';
import 'package:junto_models/firestore/junto.dart';
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
    List<Junto>? communities,
  ) {
    if (communities == null) {
      return SizedBox.shrink();
    }

    if (communities.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(20),
        child: JuntoText('You are not the billing manager for any communities'),
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
          child: JuntoListView(
            shrinkWrap: true,
            children: [
              JuntoText(
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
                        child: JuntoText(
                          communities[i].name ?? 'Unnamed Community',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 20),
                      ActionButton(
                        type: ActionButtonType.outline,
                        text: 'Admin Billing',
                        onPressed: () => routerDelegate.beamTo(
                          JuntoPageRoutes(juntoDisplayId: communities[i].displayId)
                              .juntoAdmin(tab: 'billing'),
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
        child: JuntoStreamGetterBuilder<List<Junto>>(
          entryFrom: '_SubscriptionsTabState.build',
          streamGetter: () => firestoreDatabase.juntosUserIsOwnerOf(_userId),
          builder: _buildContent,
        ),
      ),
    );
  }
}
