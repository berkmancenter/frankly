import 'package:flutter/material.dart';
import 'package:client/app/home/creation_dialog/create_community_dialog.dart';
import 'package:client/app/community/community_provider.dart';
import 'package:client/common_widgets/custom_ink_well.dart';
import 'package:client/services/services.dart';
import 'package:client/styles/app_styles.dart';
import 'package:client/utils/stream_utils.dart';
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
    return CustomStreamGetterBuilder<PlanCapabilityList>(
      entryFrom: 'EditCommunityButton._buildEditButton',
      showLoading: false,
      streamGetter: () => cloudFunctionsService
          .getCommunityCapabilities(
            GetCommunityCapabilitiesRequest(
              communityId: Provider.of<CommunityProvider>(context).communityId,
            ),
          )
          .asStream(),
      builder: (context, caps) {
        return CustomInkWell(
          onTap: () =>
              _editTapped(canSetDisplayId: caps?.hasCustomUrls ?? false),
          borderRadius: BorderRadius.circular(15),
          child: Container(
            alignment: Alignment.center,
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.edit,
              color: AppColor.gray1,
              size: 20,
            ),
          ),
        );
      },
    );
  }
}
