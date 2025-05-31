import 'package:flutter/material.dart';
import 'package:client/features/community/features/create_community/presentation/views/create_community_dialog.dart';
import 'package:client/features/community/data/providers/community_provider.dart';

import 'package:client/services.dart';
import 'package:client/styles/styles.dart';
import 'package:client/core/widgets/stream_utils.dart';
import 'package:data_models/cloud_functions/requests.dart';
import 'package:data_models/admin/plan_capability_list.dart';
import 'package:provider/provider.dart';

class EditCommunityButton extends StatefulWidget {
  const EditCommunityButton({Key? key}) : super(key: key);

  @override
  State<EditCommunityButton> createState() => _EditCommunityButtonState();
}

class _EditCommunityButtonState extends State<EditCommunityButton> {
  void _editTapped({bool canSetDisplayId = false}) =>
      CreateCommunityDialog.updateCommunity(
        community: context.read<CommunityProvider>().community,
        showChooseCustomDisplayId: canSetDisplayId,
      ).show();

  @override
  Widget build(BuildContext context) {
    return MemoizedStreamBuilder<PlanCapabilityList>(
      entryFrom: 'EditCommunityButton._buildEditButton',
      showLoading: false,
      streamGetter: () => cloudFunctionsCommunityService
          .getCommunityCapabilities(
            GetCommunityCapabilitiesRequest(
              communityId: Provider.of<CommunityProvider>(context).communityId,
            ),
          )
          .asStream(),
      builder: (context, caps) {
        return IconButton.filled(
          icon: Icon(
            Icons.edit,
            color: context.theme.colorScheme.onSecondary,
          ),
          visualDensity: VisualDensity.compact,
          iconSize: 24,
          color: context.theme.colorScheme.secondary,
          onPressed: () =>
              _editTapped(canSetDisplayId: caps?.hasCustomUrls ?? false),
        );
      },
    );
  }
}
